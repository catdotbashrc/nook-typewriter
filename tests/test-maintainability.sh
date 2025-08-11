#!/bin/bash
#
# Test Script for Maintainability Improvements
# =============================================
# Validates that improved scripts maintain functionality
#

set -euo pipefail

# Source common library
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/common-lib.sh"

# Test results
TESTS_PASSED=0
TESTS_FAILED=0

# ============================================================================
# Test Functions
# ============================================================================

run_test() {
    local test_name="$1"
    local test_cmd="$2"
    
    echo -n "Testing $test_name... "
    
    if eval "$test_cmd" >/dev/null 2>&1; then
        log_success "PASSED"
        ((TESTS_PASSED++))
    else
        log_error "FAILED"
        ((TESTS_FAILED++))
    fi
}

# Test common library functions
test_common_lib() {
    echo "=== Testing Common Library ==="
    
    # Test logging functions
    run_test "log_info" "log_info 'Test message'"
    run_test "log_warn" "log_warn 'Warning message'"
    run_test "log_error" "log_error 'Error message'"
    run_test "log_success" "log_success 'Success message'"
    
    # Test directory creation
    local test_dir="/tmp/nook-test-$$"
    run_test "ensure_dir" "ensure_dir '$test_dir' && [[ -d '$test_dir' ]]"
    rm -rf "$test_dir"
    
    # Test system checks
    run_test "is_wsl check" "is_wsl || [[ \$? -eq 1 ]]"
    run_test "is_root check" "is_root || [[ \$? -eq 1 ]]"
    
    echo
}

# Test configuration file
test_config() {
    echo "=== Testing Configuration File ==="
    
    # Source configuration
    source "$SCRIPT_DIR/../config/nook.conf"
    
    # Test configuration values
    run_test "NOOK_PROJECT_DIR set" "[[ -n \"\$NOOK_PROJECT_DIR\" ]]"
    run_test "NOOK_TOTAL_RAM_MB valid" "[[ \$NOOK_TOTAL_RAM_MB -gt 0 ]]"
    run_test "get_config function" "[[ \$(get_config 'NOOK_EDITOR' 'nano') == 'vim' ]]"
    run_test "is_enabled function" "is_enabled 'NOOK_PLUGINS_ENABLED'"
    
    # Test configuration validation
    run_test "validate_config" "validate_config"
    
    echo
}

# Test deploy script syntax
test_deploy_script() {
    echo "=== Testing Deploy Script ==="
    
    local deploy_script="$SCRIPT_DIR/../deploy-to-nook.sh"
    
    # Check syntax
    run_test "deploy script syntax" "bash -n '$deploy_script'"
    
    # Check for required functions
    run_test "show_header function" "grep -q 'show_header()' '$deploy_script'"
    run_test "verify_tarball function" "grep -q 'verify_tarball()' '$deploy_script'"
    run_test "logging functions" "grep -q 'log_info' '$deploy_script'"
    
    echo
}

# Test menu script syntax
test_menu_script() {
    echo "=== Testing Menu Script ==="
    
    local menu_script="$SCRIPT_DIR/../config/scripts/nook-menu.sh"
    
    # Check syntax
    run_test "menu script syntax" "bash -n '$menu_script'"
    
    # Check for required functions
    run_test "display_menu function" "grep -q 'display_menu()' '$menu_script'"
    run_test "get_user_choice function" "grep -q 'get_user_choice()' '$menu_script'"
    run_test "error handling" "grep -q 'display_error()' '$menu_script'"
    
    echo
}

# Test script documentation
test_documentation() {
    echo "=== Testing Documentation ==="
    
    # Check for documentation headers
    for script in "$SCRIPT_DIR"/../scripts/*.sh "$SCRIPT_DIR"/../config/scripts/*.sh; do
        [[ -f "$script" ]] || continue
        basename_script="$(basename "$script")"
        
        # Skip kernel source scripts
        [[ "$script" == *"/nst-kernel/src/"* ]] && continue
        
        if grep -q "^# Usage:" "$script" || grep -q "^# Purpose" "$script"; then
            run_test "$basename_script has docs" "true"
        else
            run_test "$basename_script has docs" "false"
        fi
    done
    
    echo
}

# Test error handling
test_error_handling() {
    echo "=== Testing Error Handling ==="
    
    # Check for set -e in scripts
    for script in "$SCRIPT_DIR"/../scripts/*.sh "$SCRIPT_DIR"/../config/scripts/*.sh; do
        [[ -f "$script" ]] || continue
        basename_script="$(basename "$script")"
        
        # Skip kernel source scripts
        [[ "$script" == *"/nst-kernel/src/"* ]] && continue
        
        if grep -q "^set -e" "$script"; then
            run_test "$basename_script has error handling" "true"
        else
            run_test "$basename_script has error handling" "false"
        fi
    done
    
    echo
}

# ============================================================================
# Main Test Execution
# ============================================================================

main() {
    echo "════════════════════════════════════════"
    echo "    Maintainability Test Suite"
    echo "════════════════════════════════════════"
    echo
    
    # Run all tests
    test_common_lib
    test_config
    test_deploy_script
    test_menu_script
    test_documentation
    test_error_handling
    
    # Summary
    echo "════════════════════════════════════════"
    echo "Test Results:"
    echo "  Passed: $TESTS_PASSED"
    echo "  Failed: $TESTS_FAILED"
    echo
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        log_success "All tests passed!"
        exit 0
    else
        log_error "Some tests failed"
        exit 1
    fi
}

# Run tests if not sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi