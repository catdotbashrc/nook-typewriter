#!/bin/bash
# Docker smoke test - Test actual runtime behavior in safe container
# This validates that core functionality works without hardware risk
#
# Usage: ./04-docker-smoke.sh
# Returns: 0 if runtime tests pass, 1 if issues detected
# Requires: Docker daemon running

set -euo pipefail

echo "🐳 DOCKER SMOKE TEST - Does it actually run?"
echo "============================================"
echo ""

DOCKER_OK=true
RUNTIME_OK=true

# Check if Docker is available
echo -n "✓ Docker available... "
if command -v docker >/dev/null 2>&1; then
    echo "YES"
else
    echo "SKIPPED (Docker not installed)"
    echo ""
    echo "⚠️  DOCKER TEST SKIPPED"
    echo "Install Docker to test runtime behavior"
    exit 0
fi

# Check if Docker image exists
echo -n "✓ Docker image built... "
if docker images 2>/dev/null | grep -qE "nook-writer|jesteros|jokernel|quillkernel"; then
    echo "YES"
    IMAGE_NAME=$(docker images --format "{{.Repository}}" | grep -E "nook-writer|jesteros|jokernel|quillkernel" | head -1)
else
    echo "NO"
    echo "  Build with: docker build -t nook-writer ."
    DOCKER_OK=false
    RUNTIME_OK=false
fi

if [ "$DOCKER_OK" = true ]; then
    # Test 1: Can the container start?
    echo -n "✓ Container starts... "
    if docker run --rm "$IMAGE_NAME" echo "Boot successful" 2>/dev/null; then
        echo "YES"
    else
        echo "NO - Container fails to start"
        RUNTIME_OK=false
    fi

    # Test 2: Menu system syntax check
    echo -n "✓ Menu system valid... "
    if docker run --rm "$IMAGE_NAME" bash -n /usr/local/bin/nook-menu.sh 2>/dev/null || \
       docker run --rm "$IMAGE_NAME" bash -n /source/scripts/menu/nook-menu.sh 2>/dev/null; then
        echo "YES"
    else
        echo "WARNING - Menu has syntax errors"
    fi

    # Test 3: Vim available and configured
    echo -n "✓ Vim installed... "
    if docker run --rm "$IMAGE_NAME" which vim >/dev/null 2>&1; then
        echo "YES"
    else
        echo "NO - Vim not found!"
        RUNTIME_OK=false
    fi

    # Test 4: JesterOS service structure
    echo -n "✓ JesterOS services... "
    if docker run --rm "$IMAGE_NAME" ls /usr/local/bin/jesteros-userspace.sh 2>/dev/null || \
       docker run --rm "$IMAGE_NAME" ls /source/scripts/services/jester-daemon.sh 2>/dev/null; then
        echo "YES"
    else
        echo "WARNING - JesterOS services missing"
    fi

    # Test 5: Common library functions
    echo -n "✓ Common functions... "
    if docker run --rm "$IMAGE_NAME" bash -c "source /source/scripts/lib/common.sh 2>/dev/null && type validate_menu_choice" >/dev/null 2>&1 || \
       docker run --rm "$IMAGE_NAME" bash -c "source /usr/local/lib/common.sh 2>/dev/null && type validate_menu_choice" >/dev/null 2>&1; then
        echo "YES"
    else
        echo "WARNING - Common functions not loading"
    fi

    # Test 6: Writing directories
    echo -n "✓ Writing directories... "
    if docker run --rm "$IMAGE_NAME" bash -c "ls -d /root/notes /root/drafts /root/scrolls 2>/dev/null | wc -l" | grep -q "3"; then
        echo "YES"
    else
        echo "MISSING - Will be created on first use"
    fi

    # Test 7: Basic write test (simulate writer workflow)
    echo -n "✓ Write workflow... "
    if docker run --rm "$IMAGE_NAME" bash -c "echo 'Test writing' > /tmp/test.txt && cat /tmp/test.txt" 2>/dev/null | grep -q "Test writing"; then
        echo "YES"
    else
        echo "NO - Can't write files!"
        RUNTIME_OK=false
    fi
fi

echo ""
if [ "$RUNTIME_OK" = true ]; then
    echo "✅ RUNTIME TESTS PASSED"
    echo "Core functionality works in Docker"
    echo "Should work on hardware too!"
    exit 0
else
    echo "⚠️  RUNTIME ISSUES DETECTED"
    echo "Fix issues before hardware deployment"
    echo "Run individual Docker commands to debug"
    exit 1
fi