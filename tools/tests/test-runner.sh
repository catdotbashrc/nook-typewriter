#!/bin/bash
# JesterOS Consolidated Test Runner
# Works with new docker structure after consolidation
# Usage: ./test-runner.sh [image-name] [test-script]
#
# Arguments:
#   image-name: Docker image to test (default: jesteros-test)
#   test-script: Test script to run (default: validate-jesteros.sh)
#
# Commands:
#   build - Build test images via Makefile
#   list  - List available images and tests
#   help  - Show usage information
#
# Returns: 0 if tests pass, 1 if tests fail

set -euo pipefail

# Default values
DEFAULT_IMAGE="jesteros-test"
DEFAULT_TEST="validate-jesteros.sh"

# Parse arguments
IMAGE_NAME="${1:-$DEFAULT_IMAGE}"
TEST_SCRIPT="${2:-$DEFAULT_TEST}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging functions with color coding
log() {
    echo -e "${GREEN}[RUNNER]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[RUNNER]${NC} $1"
}

error() {
    echo -e "${RED}[RUNNER]${NC} $1"
}

show_banner() {
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                    JESTEROS TEST RUNNER                       ║"
    echo "║                                                                ║"
    echo "║           \"By quill and candlelight, we test!\"                ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
}

# Verify Docker is available and running
check_docker() {
    if ! command -v docker >/dev/null 2>&1; then
        error "Docker is not installed or not in PATH"
        exit 1
    fi
    
    if ! docker info >/dev/null 2>&1; then
        error "Docker daemon is not running"
        exit 1
    fi
    
    log "Docker environment validated"
}

# Check if requested Docker image exists locally
check_image() {
    if ! docker images --format "{{.Repository}}" | grep -q "^$IMAGE_NAME$"; then
        warn "Image '$IMAGE_NAME' not found locally"
        echo "Available images:"
        docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | grep -E "(jesteros|nook)" || echo "No JesterOS images found"
        echo ""
        read -p "Do you want to build the image? [y/N]: " -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            build_base_image
        else
            error "Cannot proceed without image"
            exit 1
        fi
    else
        log "Using image: $IMAGE_NAME"
    fi
}

# Build Docker images using Makefile targets
build_base_image() {
    log "Building JesterOS test images..."
    
    # Use Makefile targets for consistent builds
    if [ "$IMAGE_NAME" = "jesteros-test" ]; then
        make docker-test
    elif [ "$IMAGE_NAME" = "jesteros-bullseye-test" ]; then
        make docker-test-bullseye
    elif [ "$IMAGE_NAME" = "gk61-test" ]; then
        make docker-test-gk61
    else
        warn "Unknown image type, trying default test build"
        make docker-test
    fi
    
    if [ $? -eq 0 ]; then
        log "Successfully built test images"
    else
        error "Failed to build images"
        exit 1
    fi
}

check_test_script() {
    local test_path="tests/$TEST_SCRIPT"
    if [ ! -f "$test_path" ]; then
        error "Test script not found: $test_path"
        echo "Available test scripts:"
        ls -1 tests/*.sh 2>/dev/null || echo "No test scripts found"
        exit 1
    fi
    
    if [ ! -x "$test_path" ]; then
        warn "Test script not executable, fixing..."
        chmod +x "$test_path"
    fi
    
    log "Using test script: $test_path"
}

# Execute tests in Docker container
run_tests() {
    log "Starting test execution..."
    echo ""
    
    # For jesteros-test image, use built-in validation
    if [ "$IMAGE_NAME" = "jesteros-test" ] && [ "$TEST_SCRIPT" = "validate-jesteros.sh" ]; then
        if docker run --rm "$IMAGE_NAME" /validate-jesteros.sh; then
            echo ""
            log "Test execution completed successfully"
            return 0
        else
            echo ""
            error "Test execution failed"
            return 1
        fi
    else
        # For other scripts, mount and run
        if docker run --rm \
            -v "$(pwd)/$TEST_SCRIPT:/test-script.sh:ro" \
            "$IMAGE_NAME" \
            /test-script.sh; then
            echo ""
            log "Test execution completed successfully"
            return 0
        else
            echo ""
            error "Test execution failed"
            return 1
        fi
    fi
}

show_usage() {
    cat << EOF
JesterOS Test Runner

Usage: $0 [image-name] [test-script]

Arguments:
    image-name    Docker image to test against (default: $DEFAULT_IMAGE)
    test-script   Test script to run (default: $DEFAULT_TEST)

Examples:
    $0                                    # Use defaults (jesteros-test)
    $0 jesteros-bullseye-test            # Test Bullseye image
    $0 gk61-test                         # Test GK61 keyboard support
    $0 jesteros-test 02-boot-test.sh     # Run specific test
    
Available Commands:
    $0 build                             # Build base image only
    $0 list                              # List available images and tests
    $0 help                              # Show this help

Test Scripts:
$(ls -1 tests/*.sh 2>/dev/null | sed 's/^/    /' || echo "    No test scripts found")

Notes:
- Test scripts must be executable
- Images must have JesterOS runtime structure
- Docker must be running and accessible

EOF
}

# Handle special commands
case "${1:-}" in
    build)
        show_banner
        check_docker
        build_base_image
        exit 0
        ;;
    list)
        echo "Available Docker Images:"
        docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | grep -E "(jesteros|nook)" || echo "No JesterOS images found"
        echo ""
        echo "Available Test Scripts:"
        ls -1 tests/*.sh 2>/dev/null || echo "No test scripts found"
        exit 0
        ;;
    help|-h|--help)
        show_usage
        exit 0
        ;;
esac

# Main execution
main() {
    show_banner
    
    log "Configuration:"
    log "  Image: $IMAGE_NAME"
    log "  Test Script: $TEST_SCRIPT"
    echo ""
    
    check_docker
    check_image
    check_test_script
    
    if run_tests; then
        echo ""
        log "🎭 All validations completed successfully!"
        exit 0
    else
        echo ""
        error "❌ Some validations failed"
        exit 1
    fi
}

main "$@"
# Run unit tests
if [[ -d "tests/unit" ]]; then
    echo "Running unit tests..."
    for test in tests/unit/test_*.sh; do
        [[ -f "$test" ]] && bash "$test"
    done
fi
