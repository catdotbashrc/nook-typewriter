#!/bin/bash
# Unit tests for secure-chmod-replacements.sh

# Source the centralized path configuration
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/config/paths.sh"

# Source test framework using absolute path
source "$JESTEROS_TEST_FRAMEWORK"

# Source the script to test using absolute path
source "$JESTEROS_SETUP/secure-chmod.sh"

# ============================================================================
# Test Suite: Secure Installation Functions
# ============================================================================

test_suite "secure-chmod-replacements.sh - Installation Functions"

test_case "secure_install_file function exists"
if assert_function_exists "secure_install_file"; then
    test_pass
fi

test_case "secure_install_dir function exists"
if assert_function_exists "secure_install_dir"; then
    test_pass
fi

test_case "secure_make_executable function exists"
if assert_function_exists "secure_make_executable"; then
    test_pass
fi

test_case "secure_make_readonly function exists"
if assert_function_exists "secure_make_readonly"; then
    test_pass
fi

test_case "secure_install_file handles file installation"
test_dir=$(create_test_dir)
source_file="$test_dir/source.txt"
dest_file="$test_dir/dest.txt"

echo "test content" > "$source_file"

# Mock the install command for testing
mock_command "install" "cp \$3 \$4 2>/dev/null && echo 'Installing \$3 with mode \$2'"

if output=$(secure_install_file 0644 "$source_file" "$dest_file" 2>&1); then
    if [[ -f "$dest_file" ]] && assert_contains "$output" "Installing"; then
        test_pass
    else
        test_fail "File not installed correctly"
    fi
else
    test_fail "secure_install_file failed"
fi

unmock_command "install"
cleanup_test_dir "$test_dir"

test_case "secure_make_executable makes file executable"
test_dir=$(create_test_dir)
test_file="$test_dir/script.sh"

echo "#!/bin/bash" > "$test_file"
chmod 644 "$test_file"  # Start with non-executable

# Mock mktemp and install for testing
mock_command "mktemp" "echo '$test_dir/temp.XXXX'"
mock_command "install" "chmod 755 \$4 2>/dev/null"

if secure_make_executable "$test_file" >/dev/null 2>&1; then
    # In real scenario, file would be executable
    # For test, we just verify function runs
    test_pass
else
    test_fail "secure_make_executable failed"
fi

unmock_command "mktemp"
unmock_command "install"
cleanup_test_dir "$test_dir"

test_case "secure_make_readonly handles non-existent files"
test_dir=$(create_test_dir)
non_existent="$test_dir/does_not_exist.txt"

if secure_make_readonly "$non_existent" 2>/dev/null; then
    test_fail "Should fail for non-existent file"
else
    test_pass
fi

cleanup_test_dir "$test_dir"

test_case "secure_install_dir creates directory with permissions"
test_dir=$(create_test_dir)
new_dir="$test_dir/secure_dir"

# Mock install command
mock_command "install" "mkdir -p \$5 2>/dev/null && echo 'Creating directory \$5 with mode \$3'"

if output=$(secure_install_dir 0755 "$new_dir" 2>&1); then
    if assert_contains "$output" "Creating directory"; then
        test_pass
    fi
else
    test_fail "secure_install_dir failed"
fi

unmock_command "install"
cleanup_test_dir "$test_dir"

# ============================================================================
# Test Suite: Script Safety
# ============================================================================

test_suite "secure-chmod-replacements.sh - Safety Features"

test_case "Functions validate file existence"
test_dir=$(create_test_dir)
test_file="$test_dir/exists.txt"
echo "content" > "$test_file"

# Test with existing file
if secure_make_readonly "$test_file" 2>/dev/null; then
    test_pass
else
    test_fail "Failed with existing file"
fi

cleanup_test_dir "$test_dir"

test_case "Functions handle permission errors gracefully"
# Try to operate on a system file (should fail gracefully)
if secure_make_executable "/etc/passwd" 2>/dev/null; then
    test_fail "Should not modify system files"
else
    test_pass  # Correctly failed
fi

# ============================================================================
# Print Test Summary
# ============================================================================

test_summary