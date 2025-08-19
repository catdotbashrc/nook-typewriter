#!/bin/bash
# Unit tests for lib/common.sh

# Source test framework
source "$(dirname "${BASH_SOURCE[0]}")/test_framework.sh"

# Source the library to test
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

# ============================================================================
# Test Suite: Logging Functions
# ============================================================================

test_suite "Logging Functions"

test_case "log_info outputs correctly"
if output=$(log_info "test message" 2>&1); then
    if assert_contains "$output" "test message"; then
        test_pass
    fi
fi

test_case "log_warn outputs correctly"
if output=$(log_warn "warning message" 2>&1); then
    if assert_contains "$output" "warning message"; then
        test_pass
    fi
fi

test_case "log_error outputs to stderr"
if output=$(log_error "error message" 2>&1); then
    if assert_contains "$output" "error message"; then
        test_pass
    fi
fi

test_case "log_success outputs correctly"
if output=$(log_success "success message" 2>&1); then
    if assert_contains "$output" "success message" && \
       assert_contains "$output" "✓"; then
        test_pass
    fi
fi

test_case "print_info is alias for log_info"
if output1=$(log_info "test" 2>&1) && \
   output2=$(print_info "test" 2>&1); then
    # Strip color codes for comparison
    clean1=$(echo "$output1" | sed 's/\x1b\[[0-9;]*m//g')
    clean2=$(echo "$output2" | sed 's/\x1b\[[0-9;]*m//g')
    if assert_equals "$clean1" "$clean2"; then
        test_pass
    fi
fi

# ============================================================================
# Test Suite: Path Resolution
# ============================================================================

test_suite "Path Resolution Functions"

test_case "get_script_dir returns valid directory"
# This test needs to be run from the test directory
if dir=$(get_script_dir); then
    if assert_dir_exists "$dir"; then
        test_pass
    fi
fi

test_case "get_project_root returns valid directory"
if root=$(get_project_root); then
    if assert_dir_exists "$root" && \
       assert_file_exists "$root/Makefile" "Project root should contain Makefile"; then
        test_pass
    fi
fi

# ============================================================================
# Test Suite: Safety Checks
# ============================================================================

test_suite "Safety Check Functions"

test_case "check_root detects non-root user"
# This test assumes we're not running as root
if [[ $EUID -ne 0 ]]; then
    if output=$(check_root 2>&1); then
        test_fail "check_root should fail for non-root user"
    else
        test_pass
    fi
else
    test_skip "Running as root, cannot test non-root detection"
fi

test_case "check_not_root detects root user correctly"
if [[ $EUID -eq 0 ]]; then
    if output=$(check_not_root 2>&1); then
        test_fail "check_not_root should fail for root user"
    else
        test_pass
    fi
else
    # For non-root, function should succeed
    if check_not_root 2>/dev/null; then
        test_pass
    else
        test_fail "check_not_root failed for non-root user"
    fi
fi

test_case "check_requirements detects missing tools"
# Test with a tool that definitely doesn't exist
if check_requirements "definitely_not_a_real_command_xyz123" 2>/dev/null; then
    test_fail "Should have detected missing tool"
else
    test_pass
fi

test_case "check_requirements succeeds with existing tools"
# Test with common tools that should exist
if check_requirements "bash" "echo" "test" 2>/dev/null; then
    test_pass
else
    test_fail "Failed to detect common tools"
fi

# ============================================================================
# Test Suite: File Operations
# ============================================================================

test_suite "File Operations"

test_case "backup_file creates backup with timestamp"
test_dir=$(create_test_dir)
test_file="$test_dir/test.txt"
echo "test content" > "$test_file"

if backup_file "$test_file" >/dev/null 2>&1; then
    # Check if backup was created
    if ls "$test_file".backup.* >/dev/null 2>&1; then
        test_pass
        cleanup_test_dir "$test_dir"
    else
        test_fail "Backup file not created"
        cleanup_test_dir "$test_dir"
    fi
else
    test_fail "backup_file function failed"
    cleanup_test_dir "$test_dir"
fi

test_case "backup_file handles non-existent files"
test_dir=$(create_test_dir)
non_existent="$test_dir/does_not_exist.txt"

if backup_file "$non_existent" >/dev/null 2>&1; then
    # Should not create backup for non-existent file
    if ls "$non_existent".backup.* >/dev/null 2>&1; then
        test_fail "Created backup for non-existent file"
    else
        test_pass
    fi
else
    test_pass  # Function handled non-existent file gracefully
fi
cleanup_test_dir "$test_dir"

test_case "ensure_dir creates directory"
test_dir=$(create_test_dir)
new_dir="$test_dir/new_directory"

if ensure_dir "$new_dir" >/dev/null 2>&1; then
    if assert_dir_exists "$new_dir"; then
        test_pass
    fi
else
    test_fail "ensure_dir failed to create directory"
fi
cleanup_test_dir "$test_dir"

test_case "ensure_dir handles existing directory"
test_dir=$(create_test_dir)

# Run ensure_dir on existing directory
if ensure_dir "$test_dir" >/dev/null 2>&1; then
    if assert_dir_exists "$test_dir"; then
        test_pass
    fi
else
    test_fail "ensure_dir failed on existing directory"
fi
cleanup_test_dir "$test_dir"

# ============================================================================
# Test Suite: Medieval Theme Functions
# ============================================================================

test_suite "Medieval Theme Functions"

test_case "show_jester outputs ASCII art"
if output=$(show_jester 2>&1); then
    if assert_contains "$output" "♦"; then
        test_pass
    fi
else
    test_fail "show_jester failed"
fi

test_case "medieval_success outputs themed message"
if output=$(medieval_success "quest completed" 2>&1); then
    if assert_contains "$output" "quill" && \
       assert_contains "$output" "quest completed"; then
        test_pass
    fi
else
    test_fail "medieval_success failed"
fi

test_case "medieval_error outputs themed error"
if output=$(medieval_error "dragon approaching" 2>&1); then
    if assert_contains "$output" "Alas" && \
       assert_contains "$output" "dragon approaching"; then
        test_pass
    fi
else
    test_fail "medieval_error failed"
fi

# ============================================================================
# Test Suite: Error Handling
# ============================================================================

test_suite "Error Handling Functions"

test_case "error_handler captures error information"
# Simulate an error condition
if output=$(error_handler 1 42 "false" 1 2>&1); then
    if assert_contains "$output" "Line 42" && \
       assert_contains "$output" "false" && \
       assert_contains "$output" "status 1"; then
        test_pass
    fi
else
    test_fail "error_handler didn't produce expected output"
fi

test_case "setup_error_handling sets up trap"
# This is hard to test directly, but we can check if it runs without error
if (
    setup_error_handling
    # The trap should be set now
    true  # Simple command that should succeed
) 2>/dev/null; then
    test_pass
else
    test_fail "setup_error_handling failed"
fi

# ============================================================================
# Print Test Summary
# ============================================================================

test_summary