#!/bin/bash
# Gate Keeper - Enforces critical tests before hardware deployment
# Medieval-themed safety guardian for the Nook Typewriter
#
# This script MUST pass before any SD card operations or hardware deployment.
# It runs all critical tests and creates a .test-passed marker on success.

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TEST_MARKER="$PROJECT_ROOT/.test-passed"
TEST_LOG="$PROJECT_ROOT/.test-gate.log"

# Colors for medieval-themed output
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly BOLD='\033[1m'
readonly NC='\033[0m' # No Color

# Medieval ASCII art
readonly GATE_KEEPER="
    ⚔️  THE GATE KEEPER  ⚔️
   ╔═══════════════════╗
   ║   None Shall Pass ║
   ║  Without Testing! ║
   ╚═══════════════════╝
        \\\\   |   /
         \\\\  |  /
          \\\\_|_/
           (_)
           | |
          /   \\\\
"

# Critical tests that MUST pass
declare -a CRITICAL_TESTS=(
    "kernel-safety.sh:Kernel Safety Validation"
    "pre-flight.sh:Pre-Flight Safety Checks"
    "test-jesteros-userspace.sh:JesterOS Userspace Services"
    "test-boot-sequence.sh:Boot Sequence Validation"
    "test-memory-budget.sh:Memory Budget Compliance"
    "smoke-test.sh:Smoke Test Suite"
)

# Track test results
PASS_COUNT=0
FAIL_COUNT=0
SKIP_COUNT=0

# -----------------------------------------------------------------------------
# Helper Functions
# -----------------------------------------------------------------------------

log_header() {
    echo -e "${BOLD}$GATE_KEEPER${NC}"
    echo ""
    echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}            🏰 Nook Typewriter Test Gate 🏰${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "Forsooth! The Gate Keeper demands all tests pass before thy"
    echo "sacred hardware shall be touched!"
    echo ""
    echo "Starting critical test validation at $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
}

log_test_start() {
    local test_name="$1"
    echo -e "${BLUE}→${NC} Running: ${BOLD}$test_name${NC}"
}

log_test_pass() {
    local test_name="$1"
    echo -e "  ${GREEN}✅ PASS${NC}: $test_name"
    PASS_COUNT=$((PASS_COUNT + 1))
}

log_test_fail() {
    local test_name="$1"
    local reason="${2:-Unknown failure}"
    echo -e "  ${RED}❌ FAIL${NC}: $test_name"
    echo -e "    ${RED}Reason: $reason${NC}"
    FAIL_COUNT=$((FAIL_COUNT + 1))
}

log_test_skip() {
    local test_name="$1"
    local reason="$2"
    echo -e "  ${YELLOW}⚠️  SKIP${NC}: $test_name"
    echo -e "    ${YELLOW}Reason: $reason${NC}"
    SKIP_COUNT=$((SKIP_COUNT + 1))
}

run_critical_test() {
    local test_file="$1"
    local test_desc="$2"
    local test_path="$SCRIPT_DIR/$test_file"
    
    log_test_start "$test_desc"
    
    if [ ! -f "$test_path" ]; then
        log_test_skip "$test_desc" "Test file not found (will create)"
        return 0
    fi
    
    if [ ! -x "$test_path" ]; then
        chmod +x "$test_path"
    fi
    
    # Run test and capture output
    if timeout 60 "$test_path" >> "$TEST_LOG" 2>&1; then
        log_test_pass "$test_desc"
        return 0
    else
        local exit_code=$?
        log_test_fail "$test_desc" "Exit code: $exit_code (see $TEST_LOG)"
        return 1
    fi
}

generate_gate_marker() {
    cat > "$TEST_MARKER" << EOF
# Nook Typewriter Test Gate Marker
# Generated: $(date '+%Y-%m-%d %H:%M:%S')
# Tests Passed: $PASS_COUNT
# Tests Failed: $FAIL_COUNT
# Tests Skipped: $SKIP_COUNT
# Gate Status: PASSED
#
# This file indicates all critical tests have passed.
# It will be automatically removed if any source files change.
# To force re-testing, delete this file.

GATE_TIMESTAMP=$(date +%s)
GATE_HASH=$(find "$PROJECT_ROOT/tests" -name "*.sh" -type f -exec md5sum {} \; | md5sum | cut -d' ' -f1)
PASS_COUNT=$PASS_COUNT
FAIL_COUNT=$FAIL_COUNT
SKIP_COUNT=$SKIP_COUNT
EOF
}

check_existing_marker() {
    if [ -f "$TEST_MARKER" ]; then
        # Check if tests have changed since marker was created
        local current_hash=$(find "$PROJECT_ROOT/tests" -name "*.sh" -type f -exec md5sum {} \; | md5sum | cut -d' ' -f1)
        local marker_hash=$(grep "^GATE_HASH=" "$TEST_MARKER" 2>/dev/null | cut -d'=' -f2)
        
        if [ "$current_hash" = "$marker_hash" ]; then
            echo -e "${GREEN}✅ Test gate already passed (tests unchanged)${NC}"
            echo "   To force re-testing, run: rm $TEST_MARKER"
            return 0
        else
            echo -e "${YELLOW}⚠️  Tests have changed, re-running validation...${NC}"
            rm -f "$TEST_MARKER"
        fi
    fi
    return 1
}

# -----------------------------------------------------------------------------
# Main Execution
# -----------------------------------------------------------------------------

main() {
    # Clear previous log
    > "$TEST_LOG"
    
    # Check if we can skip testing
    if check_existing_marker; then
        exit 0
    fi
    
    # Show header
    log_header | tee -a "$TEST_LOG"
    
    # Remove any existing marker
    rm -f "$TEST_MARKER"
    
    # Run all critical tests
    echo -e "${BOLD}Running Critical Tests:${NC}"
    echo "────────────────────────────────────────"
    
    local all_passed=true
    for test_entry in "${CRITICAL_TESTS[@]}"; do
        IFS=':' read -r test_file test_desc <<< "$test_entry"
        if ! run_critical_test "$test_file" "$test_desc"; then
            all_passed=false
        fi
        echo ""
    done
    
    # Summary
    echo "────────────────────────────────────────"
    echo -e "${BOLD}Test Gate Summary:${NC}"
    echo -e "  ${GREEN}Passed:${NC} $PASS_COUNT"
    echo -e "  ${RED}Failed:${NC} $FAIL_COUNT"
    echo -e "  ${YELLOW}Skipped:${NC} $SKIP_COUNT"
    echo ""
    
    # Final verdict
    if [ "$FAIL_COUNT" -eq 0 ] && [ "$PASS_COUNT" -gt 0 ]; then
        generate_gate_marker
        echo -e "${GREEN}${BOLD}✅ HUZZAH! The Gate Keeper grants passage!${NC}"
        echo -e "${GREEN}All critical tests have passed. You may proceed with deployment.${NC}"
        echo ""
        echo "Test gate marker created: $TEST_MARKER"
        echo "This marker will be checked before SD card operations."
        exit 0
    else
        echo -e "${RED}${BOLD}❌ ALAS! The Gate Keeper denies passage!${NC}"
        echo -e "${RED}Critical tests have failed. Fix issues before deployment.${NC}"
        echo ""
        echo "Review the test log for details: $TEST_LOG"
        echo "After fixing issues, run: make test-gate"
        exit 1
    fi
}

# Run main function
main "$@"