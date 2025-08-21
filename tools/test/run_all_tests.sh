#!/bin/bash
# Main test runner for Nook scripts
# Runs all test suites and provides comprehensive reporting

set -euo pipefail

# Script location
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$(dirname "$TEST_DIR")"
PROJECT_ROOT="$(dirname "$SCRIPTS_DIR")"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# Test results
TOTAL_SUITES=0
PASSED_SUITES=0
FAILED_SUITES=0
ALL_RESULTS=""

# ============================================================================
# Helper Functions
# ============================================================================

print_header() {
    echo -e "\n${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║           Nook Scripts - Comprehensive Test Suite      ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
    echo -e "\nTest Directory: ${TEST_DIR}"
    echo -e "Scripts Directory: ${SCRIPTS_DIR}"
    echo -e "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')\n"
}

run_test_file() {
    local test_file="$1"
    local test_name=$(basename "$test_file" .sh)
    
    echo -e "\n${BOLD}Running: $test_name${NC}"
    echo -e "${BLUE}────────────────────────────────────────${NC}"
    
    TOTAL_SUITES=$((TOTAL_SUITES + 1))
    
    # Run test in subshell to isolate it
    if output=$(bash "$test_file" 2>&1); then
        echo "$output"
        PASSED_SUITES=$((PASSED_SUITES + 1))
        ALL_RESULTS="${ALL_RESULTS}\n  ${GREEN}✓${NC} $test_name"
    else
        echo "$output"
        FAILED_SUITES=$((FAILED_SUITES + 1))
        ALL_RESULTS="${ALL_RESULTS}\n  ${RED}✗${NC} $test_name"
    fi
}

print_summary() {
    echo -e "\n${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                   Overall Test Summary                  ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
    
    echo -e "\n${BOLD}Test Suites Run:${NC} $TOTAL_SUITES"
    echo -e "${GREEN}Passed:${NC} $PASSED_SUITES"
    
    if [[ $FAILED_SUITES -gt 0 ]]; then
        echo -e "${RED}Failed:${NC} $FAILED_SUITES"
    else
        echo -e "Failed: 0"
    fi
    
    echo -e "\n${BOLD}Results by Suite:${NC}"
    echo -e "$ALL_RESULTS"
    
    # Calculate overall pass rate
    if [[ $TOTAL_SUITES -gt 0 ]]; then
        local pass_rate=$((PASSED_SUITES * 100 / TOTAL_SUITES))
        echo -e "\n${BOLD}Overall Pass Rate:${NC} ${pass_rate}%"
    fi
    
    # Generate exit code
    if [[ $FAILED_SUITES -eq 0 ]]; then
        echo -e "\n${GREEN}${BOLD}✓ ALL TESTS PASSED${NC}"
        return 0
    else
        echo -e "\n${RED}${BOLD}✗ SOME TESTS FAILED${NC}"
        return 1
    fi
}

check_requirements() {
    echo -e "${BOLD}Checking test requirements...${NC}"
    
    # Check for required commands
    local missing=()
    for cmd in bash awk sed grep; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo -e "${RED}Missing required commands: ${missing[*]}${NC}"
        exit 1
    fi
    
    # Check that test framework exists
    if [[ ! -f "$TEST_DIR/test_framework.sh" ]]; then
        echo -e "${RED}Test framework not found: $TEST_DIR/test_framework.sh${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ All requirements met${NC}\n"
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
    print_header
    check_requirements
    
    # Find all test files
    echo -e "${BOLD}Discovering test files...${NC}"
    test_files=()
    while IFS= read -r -d '' file; do
        test_files+=("$file")
    done < <(find "$TEST_DIR" -name "test_*.sh" -type f -print0 | sort -z)
    
    if [[ ${#test_files[@]} -eq 0 ]]; then
        echo -e "${YELLOW}No test files found matching pattern: test_*.sh${NC}"
        exit 0
    fi
    
    echo -e "Found ${#test_files[@]} test file(s)\n"
    
    # Run each test file
    for test_file in "${test_files[@]}"; do
        run_test_file "$test_file"
    done
    
    # Print overall summary
    print_summary
}

# Run with optional pattern filter
if [[ $# -gt 0 ]]; then
    # Filter test files by pattern
    pattern="$1"
    echo -e "${BOLD}Running tests matching pattern: $pattern${NC}"
    
    for test_file in "$TEST_DIR"/test_*"$pattern"*.sh; do
        if [[ -f "$test_file" ]]; then
            run_test_file "$test_file"
        fi
    done
    
    print_summary
else
    # Run all tests
    main
fi