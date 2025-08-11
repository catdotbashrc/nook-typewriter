#!/bin/bash
# QuillKernel Docker Testing Script
# Builds and tests the kernel in a controlled environment

set -e

echo "═══════════════════════════════════════════════════════════════"
echo "         QuillKernel Docker Testing"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "     .~\"~.~\"~."
echo "    /  o   o  \\    Building thy kernel"
echo "   |  >  ◡  <  |   in a Docker container..."
echo "    \\  ___  /      "
echo "     |~|♦|~|       "
echo ""

# Function to show usage
usage() {
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  build     - Build the kernel in Docker"
    echo "  test      - Run test suite only"
    echo "  verify    - Quick build verification"
    echo "  shell     - Interactive shell"
    echo "  clean     - Remove Docker images"
    echo ""
    echo "If no command specified, runs verification by default"
}

# Function to build Docker image
build_image() {
    echo "Building Docker image..."
    docker-compose -f docker-compose.test.yml build build-test
}

# Function to ensure test-results directory exists
ensure_dirs() {
    mkdir -p test-results
    chmod 777 test-results  # Allow Docker to write
}

# Main command handling
COMMAND=${1:-verify}

case "$COMMAND" in
    build)
        echo "Starting full kernel build in Docker..."
        echo "This will:"
        echo "  1. Apply QuillKernel patches"
        echo "  2. Configure kernel"
        echo "  3. Build uImage"
        echo ""
        read -p "Continue? (y/N) " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            ensure_dirs
            build_image
            docker-compose -f docker-compose.test.yml run --rm build-test
        else
            echo "Build cancelled"
        fi
        ;;
        
    test)
        echo "Running test suite in Docker..."
        ensure_dirs
        build_image
        docker-compose -f docker-compose.test.yml run --rm test-suite
        ;;
        
    verify)
        echo "Running quick verification..."
        ensure_dirs
        build_image
        docker-compose -f docker-compose.test.yml run --rm verify-only
        ;;
        
    shell)
        echo "Starting interactive shell..."
        ensure_dirs
        build_image
        docker-compose -f docker-compose.test.yml run --rm shell
        ;;
        
    clean)
        echo "Cleaning up Docker images..."
        docker-compose -f docker-compose.test.yml down --rmi all
        echo "Cleanup complete"
        ;;
        
    help|--help|-h)
        usage
        ;;
        
    *)
        echo "Unknown command: $COMMAND"
        usage
        exit 1
        ;;
esac

echo ""
echo "═══════════════════════════════════════════════════════════════"

# Show results based on exit code
if [ $? -eq 0 ]; then
    echo "     .~\"~.~\"~."
    echo "    /  ^   ^  \\    Docker test completed!"
    echo "   |  >  ◡  <  |   Check test-results/"
    echo "    \\  ___  /      for detailed logs."
    echo "     |~|♦|~|       "
else
    echo "     .~!!!~."
    echo "    / O   O \\    Docker test failed!"
    echo "   |  >   <  |   Check the logs above."
    echo "    \\  ~~~  /    "
    echo "     |~|♦|~|     "
fi