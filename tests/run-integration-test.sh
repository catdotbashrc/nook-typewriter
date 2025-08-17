#!/bin/bash
# JesterOS Integration Test Runner
# Builds and runs comprehensive tests in a realistic Nook-like environment
# "By quill and candlelight, we validate the realm!"

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Project root
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEST_IMAGE="jesteros-integration-test"

log() {
    echo -e "${GREEN}[RUNNER]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[RUNNER]${NC} $1"
}

error() {
    echo -e "${RED}[RUNNER]${NC} $1" >&2
}

info() {
    echo -e "${BLUE}[RUNNER]${NC} $1"
}

# Show banner
show_banner() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════════════╗"
    echo "║                    JESTEROS INTEGRATION TEST RUNNER                 ║"
    echo "║                                                                      ║"
    echo "║    Testing userspace services under realistic deployment conditions ║"
    echo "║                \"By quill and candlelight, we test!\"                  ║"
    echo "╚══════════════════════════════════════════════════════════════════════╝"
    echo ""
}

# Build the test image
build_test_image() {
    log "Building JesterOS integration test environment..."
    
    cd "$PROJECT_ROOT"
    
    # Build the test image
    docker build \
        -f tests/jesteros-integration-test.dockerfile \
        -t "$TEST_IMAGE" \
        . || {
        error "Failed to build test image"
        exit 1
    }
    
    log "✓ Test image built successfully"
}

# Run the integration tests
run_tests() {
    log "Running JesterOS integration tests..."
    
    # Remove any existing container
    docker rm -f jesteros-test 2>/dev/null || true
    
    # Run the test container
    if docker run \
        --name jesteros-test \
        --rm \
        -e "TERM=xterm" \
        "$TEST_IMAGE"; then
        log "✓ Integration tests completed successfully!"
        return 0
    else
        error "✗ Integration tests failed!"
        return 1
    fi
}

# Show test results summary
show_summary() {
    local exit_code=$1
    
    echo ""
    echo "╔══════════════════════════════════════════════════════════════════════╗"
    echo "║                           TEST SUMMARY                              ║"
    echo "╚══════════════════════════════════════════════════════════════════════╝"
    echo ""
    
    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}🎭 INTEGRATION TESTS PASSED!${NC}"
        echo ""
        echo "✅ JesterOS userspace services are production-ready"
        echo "✅ All interface files created correctly"
        echo "✅ Service management system functional"
        echo "✅ Health monitoring operational"
        echo "✅ Memory usage within acceptable limits"
        echo "✅ Medieval theming preserved"
        echo ""
        echo -e "${GREEN}The digital court is ready to serve writers!${NC}"
    else
        echo -e "${RED}⚠️  INTEGRATION TESTS FAILED!${NC}"
        echo ""
        echo "❌ Some components need attention before deployment"
        echo "❌ Check the test output above for specific failures"
        echo ""
        echo -e "${RED}The court requires further preparation!${NC}"
    fi
    echo ""
}

# Clean up test resources
cleanup() {
    log "Cleaning up test resources..."
    docker rm -f jesteros-test 2>/dev/null || true
    # Optionally remove the test image
    # docker rmi -f "$TEST_IMAGE" 2>/dev/null || true
}

# Show help
show_help() {
    cat << EOF
JesterOS Integration Test Runner

Usage: $0 [OPTIONS]

Options:
  --build-only    Build test image only, don't run tests
  --run-only      Run tests only (assumes image already built)
  --clean         Clean up test resources and exit
  --help          Show this help message

Examples:
  $0              # Build and run complete integration tests
  $0 --build-only # Just build the test environment
  $0 --run-only   # Run tests with existing image
  $0 --clean      # Clean up test resources

This script creates a realistic Nook deployment environment in Docker
and validates that all JesterOS userspace services work correctly.
EOF
}

# Main function
main() {
    local build_only=false
    local run_only=false
    local clean_only=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --build-only)
                build_only=true
                shift
                ;;
            --run-only)
                run_only=true
                shift
                ;;
            --clean)
                clean_only=true
                shift
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Handle clean option
    if [ "$clean_only" = true ]; then
        cleanup
        log "Test resources cleaned up"
        exit 0
    fi
    
    show_banner
    
    # Set up error handling
    trap cleanup EXIT
    
    # Build phase
    if [ "$run_only" != true ]; then
        build_test_image
        
        if [ "$build_only" = true ]; then
            log "Build completed. Use --run-only to run tests."
            exit 0
        fi
    fi
    
    # Test phase
    if [ "$build_only" != true ]; then
        if run_tests; then
            show_summary 0
            exit 0
        else
            show_summary 1
            exit 1
        fi
    fi
}

# Run main function
main "$@"