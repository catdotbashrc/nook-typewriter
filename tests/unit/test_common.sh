#!/bin/bash
# Unit tests for lib/common.sh

# Source the centralized path configuration
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/config/paths.sh"

# Source test framework using absolute path
source "$JESTEROS_TEST_FRAMEWORK"

# Source the library to test using absolute path
source "$JESTEROS_COMMON_LIB"

# ============================================================================
# Test Suite: Logging Functions
# ============================================================================

test_suite "common.sh - Logging Functions"

test_case "log_info outputs correctly"
output=$(log_info "Test message" 2>&1)
if assert_contains "$output" "Test message"; then
    test_pass
else
    test_fail "log_info did not output expected message"
fi

test_case "log_success outputs with success indicator"
output=$(log_success "Success message" 2>&1)
if assert_contains "$output" "Success message"; then
    test_pass
else
    test_fail "log_success did not output expected message"
fi

test_case "log_warning outputs to stderr"
output=$(log_warning "Warning message" 2>&1)
if assert_contains "$output" "Warning message"; then
    test_pass
else
    test_fail "log_warning did not output to stderr"
fi

test_case "log_error outputs to stderr"
output=$(log_error "Error message" 2>&1)
if assert_contains "$output" "Error message"; then
    test_pass
else
    test_fail "log_error did not output to stderr"
fi

# ============================================================================
# Test Suite: Path Resolution Functions
# ============================================================================

test_suite "common.sh - Path Resolution"

test_case "resolve_path handles absolute paths"
result=$(resolve_path "/absolute/path")
assert_equals "$result" "/absolute/path"

test_case "resolve_path handles relative paths"
cd /tmp
result=$(resolve_path "./relative")
assert_equals "$result" "/tmp/relative"

test_case "get_script_dir returns correct directory"
# Create a temporary script
temp_script=$(mktemp)
echo '#!/bin/bash
source "'"$JESTEROS_COMMON_LIB"'"
echo "$(get_script_dir)"' > "$temp_script"
chmod +x "$temp_script"
result=$("$temp_script")
expected=$(dirname "$temp_script")
assert_equals "$result" "$expected"
rm -f "$temp_script"

# ============================================================================
# Test Suite: Validation Functions
# ============================================================================

test_suite "common.sh - Validation Functions"

test_case "validate_required_commands detects missing commands"
output=$(validate_required_commands "nonexistentcommand123" 2>&1)
if assert_contains "$output" "not found"; then
    test_pass
else
    test_fail "Should detect missing command"
fi

test_case "validate_required_commands passes for existing commands"
if validate_required_commands "bash" "echo" "test"; then
    test_pass
else
    test_fail "Should pass for existing commands"
fi

test_case "validate_file_exists detects missing files"
if ! validate_file_exists "/nonexistent/file"; then
    test_pass
else
    test_fail "Should fail for non-existent file"
fi

test_case "validate_file_exists passes for existing files"
temp_file=$(mktemp)
if validate_file_exists "$temp_file"; then
    test_pass
    rm -f "$temp_file"
else
    test_fail "Should pass for existing file"
    rm -f "$temp_file"
fi

# ============================================================================
# Test Suite: Error Handling
# ============================================================================

test_suite "common.sh - Error Handling"

test_case "die function exits with error code"
# Test in subshell to avoid exiting the test script
(die "Test error" 2>/dev/null)
exit_code=$?
assert_equals "$exit_code" "1"

test_case "die function outputs error message"
output=$( (die "Test error message" 2>&1) || true )
if assert_contains "$output" "Test error message"; then
    test_pass
else
    test_fail "die function should output error message"
fi

# ============================================================================
# Test Summary
# ============================================================================

print_test_summary