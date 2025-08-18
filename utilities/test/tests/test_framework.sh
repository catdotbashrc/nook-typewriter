#!/bin/bash
# Bash Unit Testing Framework for Nook Scripts
# Provides assertion functions and test runners

set -euo pipefail

# ============================================================================
# Test Framework Configuration
# ============================================================================

# Colors for test output
readonly TEST_RED='\033[0;31m'
readonly TEST_GREEN='\033[0;32m'
readonly TEST_YELLOW='\033[1;33m'
readonly TEST_BLUE='\033[0;34m'
readonly TEST_NC='\033[0m'

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

# Test context
CURRENT_TEST=""
CURRENT_SUITE=""

# ============================================================================
# Core Test Functions
# ============================================================================

# Start a test suite
test_suite() {
    local suite_name="$1"
    CURRENT_SUITE="$suite_name"
    echo -e "\n${TEST_BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${TEST_NC}"
    echo -e "${TEST_BLUE}Test Suite: $suite_name${TEST_NC}"
    echo -e "${TEST_BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${TEST_NC}"
}

# Define a test case
test_case() {
    local test_name="$1"
    CURRENT_TEST="$test_name"
    TESTS_RUN=$((TESTS_RUN + 1))
    echo -n "  ▸ $test_name ... "
}

# Mark test as passed
test_pass() {
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo -e "${TEST_GREEN}✓ PASS${TEST_NC}"
}

# Mark test as failed with message
test_fail() {
    local message="${1:-Assertion failed}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo -e "${TEST_RED}✗ FAIL${TEST_NC}"
    echo -e "    ${TEST_RED}└─ $message${TEST_NC}"
}

# Skip a test
test_skip() {
    local reason="${1:-No reason provided}"
    TESTS_SKIPPED=$((TESTS_SKIPPED + 1))
    echo -e "${TEST_YELLOW}⊗ SKIP${TEST_NC} - $reason"
}

# ============================================================================
# Assertion Functions
# ============================================================================

# Assert that two values are equal
assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Values are not equal}"
    
    if [[ "$expected" == "$actual" ]]; then
        return 0
    else
        test_fail "$message: expected='$expected', actual='$actual'"
        return 1
    fi
}

# Assert that two values are not equal
assert_not_equals() {
    local unexpected="$1"
    local actual="$2"
    local message="${3:-Values should not be equal}"
    
    if [[ "$unexpected" != "$actual" ]]; then
        return 0
    else
        test_fail "$message: both values='$actual'"
        return 1
    fi
}

# Assert that a value is true (0 in bash)
assert_true() {
    local condition="$1"
    local message="${2:-Condition is not true}"
    
    if [[ "$condition" -eq 0 ]]; then
        return 0
    else
        test_fail "$message: condition returned $condition"
        return 1
    fi
}

# Assert that a value is false (non-0 in bash)
assert_false() {
    local condition="$1"
    local message="${2:-Condition is not false}"
    
    if [[ "$condition" -ne 0 ]]; then
        return 0
    else
        test_fail "$message: condition returned $condition"
        return 1
    fi
}

# Assert that a string contains a substring
assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-String does not contain substring}"
    
    if [[ "$haystack" == *"$needle"* ]]; then
        return 0
    else
        test_fail "$message: '$needle' not found in '$haystack'"
        return 1
    fi
}

# Assert that a string matches a regex pattern
assert_matches() {
    local string="$1"
    local pattern="$2"
    local message="${3:-String does not match pattern}"
    
    if [[ "$string" =~ $pattern ]]; then
        return 0
    else
        test_fail "$message: '$string' does not match pattern '$pattern'"
        return 1
    fi
}

# Assert that a file exists
assert_file_exists() {
    local file="$1"
    local message="${2:-File does not exist}"
    
    if [[ -f "$file" ]]; then
        return 0
    else
        test_fail "$message: $file"
        return 1
    fi
}

# Assert that a directory exists
assert_dir_exists() {
    local dir="$1"
    local message="${2:-Directory does not exist}"
    
    if [[ -d "$dir" ]]; then
        return 0
    else
        test_fail "$message: $dir"
        return 1
    fi
}

# Assert that a command succeeds (returns 0)
assert_success() {
    local command="$1"
    local message="${2:-Command failed}"
    
    if eval "$command" >/dev/null 2>&1; then
        return 0
    else
        local exit_code=$?
        test_fail "$message: '$command' returned $exit_code"
        return 1
    fi
}

# Assert that a command fails (returns non-0)
assert_failure() {
    local command="$1"
    local message="${2:-Command should have failed}"
    
    if ! eval "$command" >/dev/null 2>&1; then
        return 0
    else
        test_fail "$message: '$command' succeeded when it should have failed"
        return 1
    fi
}

# Assert that a function exists
assert_function_exists() {
    local func="$1"
    local message="${2:-Function does not exist}"
    
    if declare -f "$func" >/dev/null; then
        return 0
    else
        test_fail "$message: $func"
        return 1
    fi
}

# Assert that a variable is set
assert_var_set() {
    local var_name="$1"
    local message="${2:-Variable is not set}"
    
    if [[ -n "${!var_name+x}" ]]; then
        return 0
    else
        test_fail "$message: $var_name"
        return 1
    fi
}

# Assert that output contains expected text
assert_output_contains() {
    local command="$1"
    local expected="$2"
    local message="${3:-Output does not contain expected text}"
    
    local output
    output=$(eval "$command" 2>&1)
    
    if [[ "$output" == *"$expected"* ]]; then
        return 0
    else
        test_fail "$message: '$expected' not found in command output"
        return 1
    fi
}

# ============================================================================
# Test Utilities
# ============================================================================

# Create a temporary test directory
create_test_dir() {
    local test_dir
    test_dir=$(mktemp -d /tmp/nook-test.XXXXXX)
    echo "$test_dir"
}

# Clean up test directory
cleanup_test_dir() {
    local test_dir="$1"
    if [[ -d "$test_dir" ]]; then
        rm -rf "$test_dir"
    fi
}

# Mock a command for testing
mock_command() {
    local cmd_name="$1"
    local mock_behavior="$2"
    
    # Create a function that overrides the command
    eval "function $cmd_name() { $mock_behavior; }"
    export -f "$cmd_name"
}

# Restore original command
unmock_command() {
    local cmd_name="$1"
    unset -f "$cmd_name" 2>/dev/null || true
}

# ============================================================================
# Test Runner
# ============================================================================

# Run all test files in a directory
run_tests() {
    local test_dir="${1:-$(dirname "${BASH_SOURCE[0]}")}"
    local pattern="${2:-test_*.sh}"
    
    echo -e "${TEST_BLUE}╔════════════════════════════════════════╗${TEST_NC}"
    echo -e "${TEST_BLUE}║     Nook Scripts Test Runner           ║${TEST_NC}"
    echo -e "${TEST_BLUE}╚════════════════════════════════════════╝${TEST_NC}"
    
    # Find and run all test files
    for test_file in "$test_dir"/$pattern; do
        if [[ -f "$test_file" ]]; then
            # Source the test file in a subshell to isolate tests
            (source "$test_file")
        fi
    done
}

# Print test summary
test_summary() {
    echo -e "\n${TEST_BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${TEST_NC}"
    echo -e "${TEST_BLUE}Test Summary${TEST_NC}"
    echo -e "${TEST_BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${TEST_NC}"
    
    echo -e "Tests run:     $TESTS_RUN"
    echo -e "${TEST_GREEN}Tests passed:  $TESTS_PASSED${TEST_NC}"
    
    if [[ $TESTS_FAILED -gt 0 ]]; then
        echo -e "${TEST_RED}Tests failed:  $TESTS_FAILED${TEST_NC}"
    else
        echo -e "Tests failed:  $TESTS_FAILED"
    fi
    
    if [[ $TESTS_SKIPPED -gt 0 ]]; then
        echo -e "${TEST_YELLOW}Tests skipped: $TESTS_SKIPPED${TEST_NC}"
    else
        echo -e "Tests skipped: $TESTS_SKIPPED"
    fi
    
    # Calculate pass rate
    if [[ $TESTS_RUN -gt 0 ]]; then
        local pass_rate=$((TESTS_PASSED * 100 / TESTS_RUN))
        echo -e "\nPass rate: ${pass_rate}%"
    fi
    
    # Return exit code based on failures
    if [[ $TESTS_FAILED -gt 0 ]]; then
        echo -e "\n${TEST_RED}✗ TEST SUITE FAILED${TEST_NC}"
        return 1
    else
        echo -e "\n${TEST_GREEN}✓ TEST SUITE PASSED${TEST_NC}"
        return 0
    fi
}

# Setup test environment
setup_test_env() {
    # Set strict mode for tests
    set -euo pipefail
    
    # Trap errors to fail tests
    trap 'test_fail "Unexpected error at line $LINENO"' ERR
}

# Export all functions for use in test files
export -f test_suite test_case test_pass test_fail test_skip
export -f assert_equals assert_not_equals assert_true assert_false
export -f assert_contains assert_matches assert_file_exists assert_dir_exists
export -f assert_success assert_failure assert_function_exists assert_var_set
export -f assert_output_contains
export -f create_test_dir cleanup_test_dir mock_command unmock_command
export -f run_tests test_summary setup_test_env