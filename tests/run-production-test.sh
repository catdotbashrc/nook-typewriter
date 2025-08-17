#!/bin/bash
# JesterOS Production Environment Test Runner
# Tests services in IDENTICAL production environment
# "By quill and candlelight, we test as we deploy!"

set -euo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEST_IMAGE="jesteros-production-test"

log() {
    echo -e "${GREEN}[PROD-TEST]${NC} $1"
}

error() {
    echo -e "${RED}[PROD-TEST]${NC} $1" >&2
}

info() {
    echo -e "${BLUE}[PROD-TEST]${NC} $1"
}

show_banner() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════════════╗"
    echo "║                 JESTEROS PRODUCTION TEST RUNNER                     ║"
    echo "║                                                                      ║"
    echo "║        Testing in IDENTICAL production deployment environment       ║"
    echo "║              \"By quill and candlelight, we test true!\"               ║"
    echo "╚══════════════════════════════════════════════════════════════════════╝"
    echo ""
}

build_production_test() {
    log "Building production-identical test environment..."
    
    cd "$PROJECT_ROOT"
    
    # Build using the production test Dockerfile
    docker build \
        -f tests/jesteros-production-test.dockerfile \
        -t "$TEST_IMAGE" \
        . || {
        error "Failed to build production test image"
        exit 1
    }
    
    log "✓ Production test environment built successfully"
}

run_production_tests() {
    log "Running JesterOS production environment tests..."
    
    # Remove any existing container
    docker rm -f jesteros-prod-test 2>/dev/null || true
    
    # Run the production test
    if docker run \
        --name jesteros-prod-test \
        --rm \
        -e "TERM=linux" \
        "$TEST_IMAGE"; then
        log "✓ Production environment tests PASSED!"
        return 0
    else
        error "✗ Production environment tests FAILED!"
        return 1
    fi
}

show_environment_comparison() {
    log "Comparing test environment to production specification..."
    
    echo ""
    echo -e "${BLUE}Production Environment Specification:${NC}"
    echo "  Base OS: debian:bullseye-slim"
    echo "  Packages: vim, busybox, perl, grep, gawk, rsync, libfreetype6"
    echo "  Environment: TERM=linux, EDITOR=vim, SHELL=/bin/sh"
    echo "  Runtime: /runtime/ with 4-layer architecture"
    echo "  Services: JesterOS userspace daemons"
    echo "  Memory: Optimized for 256MB total system RAM"
    echo ""
    
    echo -e "${BLUE}Test Environment Verification:${NC}"
    docker run --rm "$TEST_IMAGE" bash -c "
        echo '  Base OS:' \$(cat /etc/os-release | grep PRETTY_NAME | cut -d'\"' -f2)
        echo '  Shell:' \$SHELL
        echo '  Editor:' \$EDITOR
        echo '  Runtime Base:' \$RUNTIME_BASE
        echo '  JesterOS Base:' \$JESTEROS_BASE
        echo '  SquireOS Version:' \$SQUIRE_OS_VERSION
        echo '  Available RAM:' \$(grep MemTotal /proc/meminfo | awk '{print \$2/1024 \"MB\"}')
        echo '  JesterOS Services:' \$(ls /usr/local/bin/jester* | wc -l) 'installed'
    "
    echo ""
}

run_interactive_test() {
    log "Starting interactive production environment session..."
    
    echo ""
    echo -e "${YELLOW}Interactive commands you can try:${NC}"
    echo "  /validate-production.sh          # Run full validation"
    echo "  cat /var/jesteros/jester         # View jester interface"
    echo "  cat /var/jesteros/typewriter/stats  # View writing stats"
    echo "  /runtime/2-application/jesteros/manager.sh status all  # Service status"
    echo "  ls -la /runtime/                 # Explore runtime structure"
    echo "  env | grep SQUIRE                # Environment variables"
    echo ""
    
    docker run --rm -it "$TEST_IMAGE" /bin/bash || {
        error "Interactive session failed - ensure Docker supports TTY"
        return 1
    }
}

cleanup() {
    log "Cleaning up production test resources..."
    docker rm -f jesteros-prod-test 2>/dev/null || true
}

show_help() {
    cat << EOF
JesterOS Production Environment Test Runner

Usage: $0 [OPTIONS]

Options:
  --build-only     Build production test environment only
  --run-only       Run tests only (assumes image exists)
  --compare        Show environment comparison
  --interactive    Start interactive session in production environment
  --clean          Clean up test resources
  --help           Show this help

This script creates a Docker environment that is IDENTICAL to the actual
JesterOS production deployment, ensuring our userspace services work
exactly as they will on the Nook hardware.

Examples:
  $0                    # Build and run complete production tests
  $0 --compare          # Compare test vs production environment
  $0 --interactive      # Explore the production environment interactively
  $0 --clean            # Clean up test resources
EOF
}

main() {
    local build_only=false
    local run_only=false
    local compare_only=false
    local interactive=false
    local clean_only=false
    
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
            --compare)
                compare_only=true
                shift
                ;;
            --interactive)
                interactive=true
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
    
    if [ "$clean_only" = true ]; then
        cleanup
        log "Production test resources cleaned up"
        exit 0
    fi
    
    show_banner
    
    trap cleanup EXIT
    
    # Build phase
    if [ "$run_only" != true ] && [ "$compare_only" != true ] && [ "$interactive" != true ]; then
        build_production_test
        
        if [ "$build_only" = true ]; then
            log "Production environment built. Use --run-only to test."
            exit 0
        fi
    fi
    
    # Environment comparison
    if [ "$compare_only" = true ]; then
        show_environment_comparison
        exit 0
    fi
    
    # Interactive session
    if [ "$interactive" = true ]; then
        run_interactive_test
        exit 0
    fi
    
    # Test phase
    if [ "$build_only" != true ]; then
        if run_production_tests; then
            show_environment_comparison
            echo ""
            echo -e "${GREEN}🎭 PRODUCTION VALIDATION COMPLETE!${NC}"
            echo -e "${GREEN}JesterOS is ready for deployment to Nook hardware!${NC}"
            exit 0
        else
            echo ""
            echo -e "${RED}❌ PRODUCTION VALIDATION FAILED!${NC}"
            echo -e "${RED}Services need fixes before deployment!${NC}"
            exit 1
        fi
    fi
}

main "$@"