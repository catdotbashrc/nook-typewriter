#!/bin/bash
# Docker testing - safe environment that can't break hardware

set -euo pipefail

echo "*** Docker Safety Testing ***"
echo "============================="
echo ""

# Build the Docker image if it doesn't exist
if ! docker images | grep -q "nook-writer"; then
    echo "-> Building nook-writer Docker image..."
    if docker build -t nook-writer --build-arg BUILD_MODE=writer -f build/docker/nookwriter-optimized.dockerfile .; then
        echo "[PASS] Docker image built successfully"
    else
        echo "[FAIL] Docker build failed!"
        exit 1
    fi
else
    echo "[PASS] Docker image already exists"
fi
echo ""

# Test basic functionality
echo "-> Testing basic container startup..."
if docker run --rm nook-writer echo "Container starts successfully"; then
    echo "[PASS] Container starts and runs"
else
    echo "[FAIL] Container startup failed!"
    exit 1
fi
echo ""

# Test vim availability
echo "-> Testing vim availability..."
if docker run --rm nook-writer vim --version | head -1; then
    echo "[PASS] Vim is available and working"
else
    echo "[FAIL] Vim test failed!"
    exit 1
fi
echo ""

# Test memory usage in container
echo "-> Checking memory usage in container..."
MEMORY_USAGE=$(docker run --rm nook-writer sh -c 'free -m | grep "^Mem:" | awk "{print \$3}"' 2>/dev/null || echo "unknown")
if [ "$MEMORY_USAGE" != "unknown" ]; then
    echo "[INFO] Container memory usage: ${MEMORY_USAGE}MB"
    if [ "$MEMORY_USAGE" -lt "64" ]; then
        echo "[PASS] Memory usage looks reasonable for testing"
    else
        echo "[WARN] Memory usage higher than expected"
    fi
else
    echo "[WARN] Could not measure memory usage"
fi
echo ""

# Test file operations
echo "-> Testing file operations..."
if docker run --rm nook-writer sh -c 'echo "Test content" > /tmp/test.txt && cat /tmp/test.txt'; then
    echo "[PASS] File operations work"
else
    echo "[FAIL] File operations failed!"
    exit 1
fi
echo ""

echo "*** Docker Test Summary ***"
echo "============================"
echo "[PASS] Container builds and starts"
echo "[PASS] Vim is available"
echo "[PASS] File operations work"
echo "[INFO] Memory usage: ${MEMORY_USAGE}MB (in container)"
echo ""
echo "The Docker Jester says: 'All seems well in the virtual realm!'"
echo "Ready for real hardware testing."