#!/bin/bash
# JesterOS Authentic Lenny Test Runner
# Tests JesterOS services in the REAL Debian Lenny 5.0 environment
# "By quill and candlelight, we test with medieval authenticity!"

set -euo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEST_IMAGE="jesteros-lenny-authentic"
LENNY_TARBALL="$PROJECT_ROOT/lenny-rootfs.tar.gz"

log() {
    echo -e "${GREEN}[LENNY-TEST]${NC} $1"
}

error() {
    echo -e "${RED}[LENNY-TEST]${NC} $1" >&2
}

info() {
    echo -e "${BLUE}[LENNY-TEST]${NC} $1"
}

show_banner() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════════════╗"
    echo "║                JESTEROS AUTHENTIC LENNY TEST RUNNER                 ║"
    echo "║                                                                      ║"
    echo "║        Testing in AUTHENTIC Debian Lenny 5.0 from 2009!            ║"
    echo "║           \"True to the medieval spirit of the realm!\"                ║"
    echo "╚══════════════════════════════════════════════════════════════════════╝"
    echo ""
}

check_lenny_tarball() {
    log "Checking for authentic Lenny rootfs..."
    
    if [ ! -f "$LENNY_TARBALL" ]; then
        error "Lenny rootfs tarball not found: $LENNY_TARBALL"
        echo ""
        echo "To create the authentic Lenny environment, you need:"
        echo "1. Run the build-lenny-rootfs.sh script, OR"
        echo "2. Download/extract the Debian Lenny rootfs"
        echo ""
        exit 1
    fi
    
    local size=$(du -h "$LENNY_TARBALL" | cut -f1)
    log "✓ Found authentic Lenny rootfs: $size"
}

build_lenny_test() {
    log "Building authentic Debian Lenny test environment..."
    
    cd "$PROJECT_ROOT"
    
    # Build using the Lenny test Dockerfile
    docker build \
        -f tests/jesteros-lenny-test.dockerfile \
        -t "$TEST_IMAGE" \
        . || {
        error "Failed to build authentic Lenny test image"
        exit 1
    }
    
    log "✓ Authentic Lenny test environment built successfully"
}

run_lenny_tests() {
    log "Running JesterOS tests in authentic Debian Lenny 5.0..."
    
    # Remove any existing container
    docker rm -f jesteros-lenny-test 2>/dev/null || true
    
    # Run the authentic test
    if docker run \
        --name jesteros-lenny-test \
        --rm \
        -e "TERM=linux" \
        "$TEST_IMAGE"; then
        log "✓ Authentic Lenny tests PASSED!"
        return 0
    else
        error "✗ Authentic Lenny tests FAILED!"
        return 1
    fi
}

show_environment_info() {
    log "Authentic environment information..."
    
    echo ""
    echo -e "${BLUE}Authentic Nook Deployment Environment:${NC}"
    echo "  Base OS: Debian Lenny 5.0 (February 2009)"
    echo "  Period: Contemporary with original Nook release"
    echo "  Architecture: ARMEL (ARM EABI Little Endian)"
    echo "  Kernel Compatibility: Linux 2.6.29"
    echo "  Package Manager: APT 0.7.20 (Lenny era)"
    echo "  Shell: bash 3.2 / dash (POSIX)"
    echo ""
    
    echo -e "${BLUE}Test Environment Verification:${NC}"
    docker run --rm "$TEST_IMAGE" bash -c "
        echo '  Debian Version:' \$(cat /etc/debian_version 2>/dev/null || echo 'Unknown')
        echo '  Issue:' \$(head -1 /etc/issue 2>/dev/null || echo 'Unknown')
        echo '  Shell:' \$SHELL
        echo '  Available Tools:' \$(command -v bash sh grep awk sed | wc -l) 'basic tools'
        echo '  JesterOS Runtime:' \$(ls /runtime/ 2>/dev/null | wc -l) 'layers'
        echo '  Services Installed:' \$(ls /usr/local/bin/jester* 2>/dev/null | wc -l) 'services'
    "
    echo ""
}

run_interactive_lenny() {
    log "Starting interactive session in authentic Lenny environment..."
    
    echo ""
    echo -e "${YELLOW}Interactive commands for authentic testing:${NC}"
    echo "  /validate-lenny-authentic.sh     # Run full authentic validation"
    echo "  cat /etc/issue                   # Show Debian Lenny version"
    echo "  cat /var/jesteros/jester         # View jester in Lenny"
    echo "  /runtime/2-application/jesteros/manager.sh status all  # Service status"
    echo "  ls -la /runtime/                 # Explore authentic structure"
    echo "  cat /etc/debian_version          # Confirm Lenny version"
    echo ""
    
    docker run --rm -it "$TEST_IMAGE" /bin/bash || {
        error "Interactive session failed"
        return 1
    }
}

compare_environments() {
    log "Comparing Bullseye vs Lenny environments..."
    
    echo ""
    echo -e "${BLUE}Environment Comparison:${NC}"
    echo ""
    echo "┌─────────────────┬─────────────────┬─────────────────┐"
    echo "│ Aspect          │ Debian Lenny    │ Debian Bullseye │"
    echo "├─────────────────┼─────────────────┼─────────────────┤"
    echo "│ Release Year    │ 2009           │ 2021            │"
    echo "│ Kernel Support  │ 2.6.26+        │ 5.10+           │"
    echo "│ Package Count   │ ~23K           │ ~59K            │"
    echo "│ Base Size       │ ~14MB          │ ~30MB           │"
    echo "│ ARM Support     │ ARMEL native   │ ARMEL + ARMHF   │"
    echo "│ Period Correct  │ ✓ Authentic    │ ✗ Anachronistic │"
    echo "│ Package Updates │ Archived       │ Active          │"
    echo "│ Security        │ Archived       │ Supported       │"
    echo "└─────────────────┴─────────────────┴─────────────────┘"
    echo ""
    echo -e "${YELLOW}For authentic Nook experience: Use Lenny${NC}"
    echo -e "${YELLOW}For development convenience: Use Bullseye${NC}"
    echo ""
}

cleanup() {
    log "Cleaning up Lenny test resources..."
    docker rm -f jesteros-lenny-test 2>/dev/null || true
}

show_help() {
    cat << EOF
JesterOS Authentic Lenny Test Runner

Usage: $0 [OPTIONS]

Options:
  --build-only     Build authentic Lenny test environment only
  --run-only       Run tests only (assumes image exists)
  --interactive    Start interactive session in Lenny
  --compare        Compare Lenny vs Bullseye environments
  --check          Check if Lenny rootfs is available
  --clean          Clean up test resources
  --help           Show this help

This script tests JesterOS services in the AUTHENTIC Debian Lenny 5.0
environment that actually runs on Nook hardware. This ensures true
compatibility with the period-correct deployment environment.

Examples:
  $0                    # Build and run authentic Lenny tests
  $0 --check            # Verify Lenny rootfs is available
  $0 --interactive      # Explore authentic Lenny environment
  $0 --compare          # Compare environments
EOF
}

main() {
    local build_only=false
    local run_only=false
    local interactive=false
    local compare_only=false
    local check_only=false
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
            --interactive)
                interactive=true
                shift
                ;;
            --compare)
                compare_only=true
                shift
                ;;
            --check)
                check_only=true
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
        log "Lenny test resources cleaned up"
        exit 0
    fi
    
    show_banner
    
    # Check for Lenny tarball
    if [ "$check_only" = true ]; then
        check_lenny_tarball
        log "Lenny rootfs is ready for authentic testing!"
        exit 0
    fi
    
    # Environment comparison
    if [ "$compare_only" = true ]; then
        compare_environments
        exit 0
    fi
    
    # Always check for Lenny availability
    check_lenny_tarball
    
    trap cleanup EXIT
    
    # Build phase
    if [ "$run_only" != true ] && [ "$interactive" != true ]; then
        build_lenny_test
        
        if [ "$build_only" = true ]; then
            log "Authentic Lenny environment built. Use --run-only to test."
            exit 0
        fi
    fi
    
    # Interactive session
    if [ "$interactive" = true ]; then
        run_interactive_lenny
        exit 0
    fi
    
    # Test phase
    if [ "$build_only" != true ]; then
        if run_lenny_tests; then
            show_environment_info
            echo ""
            echo -e "${GREEN}🏰 AUTHENTIC LENNY VALIDATION COMPLETE!${NC}"
            echo -e "${GREEN}JesterOS works perfectly in the true 2009 environment!${NC}"
            echo ""
            echo -e "${BLUE}\"By quill and candlelight, authentically tested!\"${NC}"
            exit 0
        else
            echo ""
            echo -e "${RED}❌ AUTHENTIC LENNY VALIDATION FAILED!${NC}"
            echo -e "${RED}Services need fixes for authentic compatibility!${NC}"
            exit 1
        fi
    fi
}

main "$@"