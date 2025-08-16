#!/bin/bash
# JesterOS Security Test Suite
# Validates security improvements and best practices

set -euo pipefail
trap 'echo "Error at line $LINENO: $BASH_COMMAND"' ERR

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TEST_RESULTS=()
FAILED_TESTS=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test result tracking
pass_test() {
    local test_name="$1"
    TEST_RESULTS+=("✅ PASS: $test_name")
    echo -e "${GREEN}✅ PASS${NC}: $test_name"
}

fail_test() {
    local test_name="$1"
    local reason="$2"
    TEST_RESULTS+=("❌ FAIL: $test_name - $reason")
    echo -e "${RED}❌ FAIL${NC}: $test_name"
    echo -e "   Reason: $reason"
    ((FAILED_TESTS++))
}

warn_test() {
    local test_name="$1"
    local reason="$2"
    TEST_RESULTS+=("⚠️  WARN: $test_name - $reason")
    echo -e "${YELLOW}⚠️  WARN${NC}: $test_name"
    echo -e "   Warning: $reason"
}

# Test 1: Check for hardcoded passwords
test_hardcoded_passwords() {
    echo -e "\n${BLUE}Test 1: Checking for hardcoded passwords...${NC}"
    
    local found_passwords=0
    local patterns=(
        "password="
        "passwd="
        "PASSWORD="
        "PASSWD="
        "secret="
        "SECRET="
        "token="
        "TOKEN="
        "api_key="
        "API_KEY="
    )
    
    for pattern in "${patterns[@]}"; do
        if grep -r "$pattern" "$PROJECT_ROOT/source/scripts" 2>/dev/null | grep -v "^Binary" | grep -v ".git" > /dev/null; then
            found_passwords=1
            local files=$(grep -r "$pattern" "$PROJECT_ROOT/source/scripts" 2>/dev/null | cut -d: -f1 | sort -u)
            fail_test "No hardcoded passwords" "Found '$pattern' in: $files"
            return
        fi
    done
    
    if [[ $found_passwords -eq 0 ]]; then
        pass_test "No hardcoded passwords"
    fi
}

# Test 2: Check for proper input validation
test_input_validation() {
    echo -e "\n${BLUE}Test 2: Checking for input validation...${NC}"
    
    local scripts_with_validation=0
    local scripts_without_validation=0
    local problem_scripts=()
    
    # Use find to get scripts more efficiently
    while IFS= read -r script; do
        [[ ! -f "$script" ]] && continue
        
        # Check if script has user input
        if grep -q "read " "$script" 2>/dev/null; then
            # Check for validation functions
            if grep -q "validate_menu_choice\|validate_path\|sanitize_input" "$script" 2>/dev/null; then
                ((scripts_with_validation++))
            else
                ((scripts_without_validation++))
                problem_scripts+=("$(basename "$script")")
            fi
        fi
    done < <(find "$PROJECT_ROOT/source/scripts" -name "*.sh" -type f 2>/dev/null)
    
    if [[ $scripts_without_validation -eq 0 ]]; then
        pass_test "All scripts with user input have validation"
    elif [[ $scripts_without_validation -lt 3 ]]; then
        warn_test "Input validation" "Scripts without validation: ${problem_scripts[*]}"
    else
        fail_test "Input validation" "$scripts_without_validation scripts lack input validation"
    fi
}

# Test 3: Check for unsafe shell practices
test_shell_safety() {
    echo -e "\n${BLUE}Test 3: Checking for unsafe shell practices...${NC}"
    
    local unsafe_count=0
    local issues=()
    
    # Check for eval usage
    if grep -r "eval " "$PROJECT_ROOT/source/scripts" 2>/dev/null | grep -v "^Binary" | grep -v ".git" > /dev/null; then
        ((unsafe_count++))
        issues+=("eval usage found")
    fi
    
    # Check for unquoted variables in dangerous contexts
    if grep -r 'rm -rf \$' "$PROJECT_ROOT/source/scripts" 2>/dev/null | grep -v '"' > /dev/null; then
        ((unsafe_count++))
        issues+=("unquoted rm -rf found")
    fi
    
    # Check for command injection vulnerabilities
    if grep -r '\$(' "$PROJECT_ROOT/source/scripts" 2>/dev/null | grep -E 'user_input|USER_INPUT|input' > /dev/null; then
        ((unsafe_count++))
        issues+=("potential command injection")
    fi
    
    if [[ $unsafe_count -eq 0 ]]; then
        pass_test "No unsafe shell practices detected"
    else
        fail_test "Shell safety" "Found issues: ${issues[*]}"
    fi
}

# Test 4: Check for proper error handling
test_error_handling() {
    echo -e "\n${BLUE}Test 4: Checking for proper error handling...${NC}"
    
    local scripts_with_trap=0
    local scripts_without_trap=0
    local scripts_with_set_e=0
    
    while IFS= read -r script; do
        [[ ! -f "$script" ]] && continue
        
        if grep -q "^set -e" "$script" 2>/dev/null; then
            ((scripts_with_set_e++))
        fi
        
        if grep -q "^trap " "$script" 2>/dev/null; then
            ((scripts_with_trap++))
        else
            ((scripts_without_trap++))
        fi
    done < <(find "$PROJECT_ROOT/source/scripts" -name "*.sh" -type f 2>/dev/null)
    
    local total_scripts=$(find "$PROJECT_ROOT/source/scripts" -name "*.sh" | wc -l)
    local percentage=$((scripts_with_trap * 100 / total_scripts))
    
    if [[ $percentage -gt 80 ]]; then
        pass_test "Good error handling coverage ($percentage% with trap)"
    elif [[ $percentage -gt 50 ]]; then
        warn_test "Error handling" "$percentage% of scripts have trap handlers"
    else
        fail_test "Error handling" "Only $percentage% of scripts have proper error handling"
    fi
}

# Test 5: Check file permissions
test_file_permissions() {
    echo -e "\n${BLUE}Test 5: Checking file permissions...${NC}"
    
    local world_writable=()
    local setuid_files=()
    
    # Check for world-writable files
    while IFS= read -r -d '' file; do
        if [[ -w "$file" ]]; then
            local perms=$(stat -c %a "$file" 2>/dev/null || stat -f %A "$file" 2>/dev/null)
            if [[ "${perms: -1}" == "7" ]] || [[ "${perms: -1}" == "6" ]] || [[ "${perms: -1}" == "2" ]]; then
                world_writable+=("$(basename "$file")")
            fi
        fi
    done < <(find "$PROJECT_ROOT/source/scripts" -type f -print0 2>/dev/null)
    
    # Check for setuid/setgid files
    while IFS= read -r file; do
        setuid_files+=("$(basename "$file")")
    done < <(find "$PROJECT_ROOT/source/scripts" -type f \( -perm -4000 -o -perm -2000 \) 2>/dev/null)
    
    if [[ ${#world_writable[@]} -eq 0 ]] && [[ ${#setuid_files[@]} -eq 0 ]]; then
        pass_test "No insecure file permissions"
    elif [[ ${#setuid_files[@]} -gt 0 ]]; then
        fail_test "File permissions" "Found setuid/setgid files: ${setuid_files[*]}"
    else
        warn_test "File permissions" "Found world-writable files: ${world_writable[*]}"
    fi
}

# Test 6: Check for use of install command instead of chmod
test_install_command_usage() {
    echo -e "\n${BLUE}Test 6: Checking for install command usage...${NC}"
    
    local chmod_count=0
    local install_count=0
    local scripts_with_chmod=()
    
    while IFS= read -r script; do
        [[ ! -f "$script" ]] && continue
        
        if grep -q "chmod [0-9]" "$script" 2>/dev/null; then
            ((chmod_count++))
            scripts_with_chmod+=("$(basename "$script")")
        fi
        
        if grep -q "install -m" "$script" 2>/dev/null; then
            ((install_count++))
        fi
    done < <(find "$PROJECT_ROOT/source/scripts" -name "*.sh" -type f 2>/dev/null)
    
    if [[ $chmod_count -eq 0 ]]; then
        pass_test "No direct chmod usage (using install command)"
    elif [[ $chmod_count -le 2 ]]; then
        warn_test "chmod usage" "Found in: ${scripts_with_chmod[*]}"
    else
        fail_test "chmod usage" "$chmod_count scripts still use chmod instead of install"
    fi
}

# Test 7: Check for non-root user setup
test_nonroot_user() {
    echo -e "\n${BLUE}Test 7: Checking for non-root user configuration...${NC}"
    
    if [[ -f "$PROJECT_ROOT/scripts/setup-writer-user.sh" ]]; then
        # Check if script creates non-root user
        if grep -q "useradd" "$PROJECT_ROOT/scripts/setup-writer-user.sh" 2>/dev/null; then
            if grep -q "WRITER_USER=" "$PROJECT_ROOT/scripts/setup-writer-user.sh" 2>/dev/null; then
                pass_test "Non-root user setup script exists"
            else
                warn_test "Non-root user" "Setup script exists but may be incomplete"
            fi
        else
            fail_test "Non-root user" "Setup script doesn't create user"
        fi
    else
        fail_test "Non-root user" "No setup-writer-user.sh script found"
    fi
}

# Test 8: Check for path traversal prevention
test_path_traversal() {
    echo -e "\n${BLUE}Test 8: Checking for path traversal prevention...${NC}"
    
    local unsafe_paths=0
    local scripts_with_issues=()
    
    while IFS= read -r script; do
        [[ ! -f "$script" ]] && continue
        
        # Check for unvalidated path operations
        if grep -E 'cd \$|cat \$|rm \$|cp \$' "$script" 2>/dev/null | grep -v validate_path > /dev/null; then
            ((unsafe_paths++))
            scripts_with_issues+=("$(basename "$script")")
        fi
    done < <(find "$PROJECT_ROOT/source/scripts" -name "*.sh" -type f 2>/dev/null)
    
    if [[ $unsafe_paths -eq 0 ]]; then
        pass_test "Path traversal prevention in place"
    elif [[ $unsafe_paths -le 2 ]]; then
        warn_test "Path traversal" "Potential issues in: ${scripts_with_issues[*]}"
    else
        fail_test "Path traversal" "$unsafe_paths scripts have unvalidated path operations"
    fi
}

# Test 9: Check for secure temporary file handling
test_temp_files() {
    echo -e "\n${BLUE}Test 9: Checking for secure temporary file handling...${NC}"
    
    local insecure_temp=0
    local secure_temp=0
    
    while IFS= read -r script; do
        [[ ! -f "$script" ]] && continue
        
        # Check for insecure temp file creation
        if grep -E '/tmp/\$\$|/tmp/temp' "$script" 2>/dev/null > /dev/null; then
            ((insecure_temp++))
        fi
        
        # Check for secure mktemp usage
        if grep -q "mktemp" "$script" 2>/dev/null; then
            ((secure_temp++))
        fi
    done < <(find "$PROJECT_ROOT/source/scripts" -name "*.sh" -type f 2>/dev/null)
    
    if [[ $insecure_temp -eq 0 ]]; then
        pass_test "Secure temporary file handling"
    else
        fail_test "Temporary files" "$insecure_temp scripts use insecure temp files"
    fi
}

# Test 10: Check for privilege escalation protection
test_privilege_escalation() {
    echo -e "\n${BLUE}Test 10: Checking for privilege escalation protection...${NC}"
    
    local sudo_nopasswd=0
    local unrestricted_sudo=0
    
    # Check sudoers configuration if available
    if [[ -f "$PROJECT_ROOT/scripts/setup-writer-user.sh" ]]; then
        # Check for NOPASSWD with specific commands (good)
        if grep -q "NOPASSWD.*specific" "$PROJECT_ROOT/scripts/setup-writer-user.sh" 2>/dev/null; then
            pass_test "Sudo configuration uses specific commands"
            return
        fi
        
        # Check for unrestricted NOPASSWD (bad)
        if grep -q "NOPASSWD.*ALL" "$PROJECT_ROOT/scripts/setup-writer-user.sh" 2>/dev/null; then
            fail_test "Privilege escalation" "Unrestricted NOPASSWD sudo found"
            return
        fi
    fi
    
    pass_test "No obvious privilege escalation vectors"
}

# Main test execution
main() {
    echo "════════════════════════════════════════════════════════════════"
    echo "                JesterOS Security Test Suite"
    echo "════════════════════════════════════════════════════════════════"
    echo ""
    echo "Running security tests..."
    
    # Run all tests
    test_hardcoded_passwords
    test_input_validation
    test_shell_safety
    test_error_handling
    test_file_permissions
    test_install_command_usage
    test_nonroot_user
    test_path_traversal
    test_temp_files
    test_privilege_escalation
    
    # Summary
    echo ""
    echo "════════════════════════════════════════════════════════════════"
    echo "                        Test Summary"
    echo "════════════════════════════════════════════════════════════════"
    
    local total_tests=${#TEST_RESULTS[@]}
    local passed_tests=$((total_tests - FAILED_TESTS))
    
    echo "Total Tests: $total_tests"
    echo "Passed: $passed_tests"
    echo "Failed: $FAILED_TESTS"
    echo ""
    
    # Display all results
    for result in "${TEST_RESULTS[@]}"; do
        echo "$result"
    done
    
    echo ""
    if [[ $FAILED_TESTS -eq 0 ]]; then
        echo -e "${GREEN}✅ All security tests passed!${NC}"
        echo "════════════════════════════════════════════════════════════════"
        exit 0
    else
        echo -e "${RED}❌ $FAILED_TESTS security tests failed${NC}"
        echo "════════════════════════════════════════════════════════════════"
        exit 1
    fi
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi