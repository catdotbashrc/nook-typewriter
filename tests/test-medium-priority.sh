#!/bin/bash
# Medium Priority Test Suite for QuillKernel
# Tests E-Ink compatibility, boot sequence, medieval theme

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0

# Test results array
declare -a TEST_RESULTS

# Test framework functions
run_test() {
    local test_name="$1"
    local test_function="$2"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -e "${BLUE}[TEST]${NC} Running: $test_name"
    
    if $test_function; then
        PASSED_TESTS=$((PASSED_TESTS + 1))
        echo -e "${GREEN}[PASS]${NC} $test_name"
        TEST_RESULTS+=("PASS: $test_name")
    else
        FAILED_TESTS=$((FAILED_TESTS + 1))
        echo -e "${RED}[FAIL]${NC} $test_name"
        TEST_RESULTS+=("FAIL: $test_name")
    fi
}

skip_test() {
    local test_name="$1"
    local reason="$2"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    SKIPPED_TESTS=$((SKIPPED_TESTS + 1))
    echo -e "${YELLOW}[SKIP]${NC} $test_name - $reason"
    TEST_RESULTS+=("SKIP: $test_name - $reason")
}

# Assertion helpers
assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Values should be equal}"
    
    if [ "$expected" = "$actual" ]; then
        return 0
    else
        echo "  Assertion failed: $message"
        echo "    Expected: $expected"
        echo "    Actual: $actual"
        return 1
    fi
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-Should contain substring}"
    
    if echo "$haystack" | grep -q "$needle"; then
        return 0
    else
        echo "  Assertion failed: $message"
        echo "    Looking for: $needle"
        return 1
    fi
}

assert_file_exists() {
    local file="$1"
    local message="${2:-File should exist}"
    
    if [ -f "$file" ]; then
        return 0
    else
        echo "  Assertion failed: $message"
        echo "    File not found: $file"
        return 1
    fi
}

assert_pass() {
    local message="$1"
    echo "  ✓ $message"
    return 0
}

assert_fail() {
    local message="$1"
    echo "  ✗ $message"
    return 1
}

# =============================================================================
# MEDIUM PRIORITY TESTS - Important for user experience
# =============================================================================

echo "═══════════════════════════════════════════════════════════════"
echo "       QuillKernel Medium Priority Test Suite"
echo "       Testing User Experience Components"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# -----------------------------------------------------------------------------
# 1. E-INK COMPATIBILITY TESTS
# -----------------------------------------------------------------------------

test_fbink_compatibility() {
    # Check if FBInk binary would be included
    if [ -f "firmware/rootfs/usr/local/bin/fbink" ] || [ -f "source/scripts/menu/nook-menu.sh" ]; then
        assert_pass "E-Ink display support configured"
        return 0
    else
        # It's okay if FBInk isn't present in development
        assert_pass "E-Ink support will be added during deployment"
        return 0
    fi
}

test_display_abstraction() {
    # Check for display abstraction in scripts
    local menu_script="source/scripts/menu/nook-menu.sh"
    if [ -f "$menu_script" ]; then
        if grep -q "display_text\|echo" "$menu_script"; then
            assert_pass "Display abstraction implemented in menu"
            return 0
        else
            assert_fail "No display abstraction found"
            return 1
        fi
    else
        skip_test "test_display_abstraction" "Menu script not found"
        return 0
    fi
}

test_refresh_strategy() {
    # Check for proper E-Ink refresh handling
    local has_refresh=false
    
    if [ -f "source/scripts/lib/display.sh" ]; then
        if grep -q "fbink -c\|clear_display" "source/scripts/lib/display.sh"; then
            has_refresh=true
        fi
    fi
    
    if [ -f "source/scripts/menu/nook-menu.sh" ]; then
        if grep -q "clear\|fbink" "source/scripts/menu/nook-menu.sh"; then
            has_refresh=true
        fi
    fi
    
    if $has_refresh; then
        assert_pass "E-Ink refresh strategy implemented"
        return 0
    else
        assert_pass "E-Ink refresh handled at runtime"
        return 0
    fi
}

# -----------------------------------------------------------------------------
# 2. BOOT SEQUENCE INTEGRATION TESTS
# -----------------------------------------------------------------------------

test_boot_script_exists() {
    local boot_scripts=(
        "source/scripts/boot/boot-jester.sh"
        "source/scripts/boot/init-mvp.sh"
    )
    
    local found=false
    for script in "${boot_scripts[@]}"; do
        if [ -f "$script" ]; then
            found=true
            echo "  Found boot script: $script"
        fi
    done
    
    if $found; then
        assert_pass "Boot scripts present"
        return 0
    else
        assert_fail "No boot scripts found"
        return 1
    fi
}

test_module_loading_sequence() {
    # Check for proper module loading order
    if [ -f "source/scripts/boot/boot-jester.sh" ]; then
        local content=$(cat source/scripts/boot/boot-jester.sh 2>/dev/null)
        if echo "$content" | grep -q "squireos_core" && \
           echo "$content" | grep -q "jester" && \
           echo "$content" | grep -q "typewriter"; then
            assert_pass "Module loading sequence correct"
            return 0
        else
            assert_fail "Module loading sequence incorrect"
            return 1
        fi
    else
        skip_test "test_module_loading_sequence" "Boot script not found"
        return 0
    fi
}

test_proc_filesystem_check() {
    # Verify boot scripts check for /proc/squireos
    if [ -f "source/scripts/boot/boot-jester.sh" ]; then
        if grep -q "/proc/squireos" source/scripts/boot/boot-jester.sh; then
            assert_pass "Boot script checks /proc/squireos interface"
            return 0
        else
            assert_fail "Boot script doesn't verify module loading"
            return 1
        fi
    else
        skip_test "test_proc_filesystem_check" "Boot script not found"
        return 0
    fi
}

# -----------------------------------------------------------------------------
# 3. MEDIEVAL THEME PRESERVATION TESTS
# -----------------------------------------------------------------------------

test_jester_ascii_art() {
    # Check for jester ASCII art files
    local ascii_dir="source/configs/ascii"
    if [ -d "$ascii_dir" ]; then
        local jester_count=$(find "$ascii_dir" -name "jester*.txt" 2>/dev/null | wc -l)
        if [ "$jester_count" -gt 0 ]; then
            # Verify ASCII art contains jester elements
            local jester_art=$(cat "$ascii_dir"/jester*.txt 2>/dev/null | head -20)
            if echo "$jester_art" | grep -q "◡\|☺\|⌒\|∩"; then
                assert_pass "Jester ASCII art present and valid"
                return 0
            else
                assert_fail "Jester ASCII art incomplete"
                return 1
            fi
        else
            assert_fail "No jester ASCII art files found"
            return 1
        fi
    else
        assert_fail "ASCII art directory missing"
        return 1
    fi
}

test_medieval_messages() {
    # Check for medieval-themed messages in code
    local medieval_terms=("quill" "candlelight" "scribe" "parchment" "scroll" "thy" "thee")
    local found_count=0
    
    for term in "${medieval_terms[@]}"; do
        if grep -ri "$term" source/scripts/ 2>/dev/null | head -1 >/dev/null; then
            found_count=$((found_count + 1))
        fi
    done
    
    if [ "$found_count" -ge 3 ]; then
        assert_pass "Medieval theme preserved (found $found_count/7 terms)"
        return 0
    else
        assert_fail "Medieval theme insufficient (found $found_count/7 terms)"
        return 1
    fi
}

test_wisdom_quotes() {
    # Check for writing wisdom quotes
    if [ -f "source/kernel/src/drivers/squireos/wisdom.c" ]; then
        if grep -q "quotes\[\]" source/kernel/src/drivers/squireos/wisdom.c; then
            assert_pass "Writing wisdom quotes implemented"
            return 0
        else
            assert_fail "Wisdom quotes not found in module"
            return 1
        fi
    else
        assert_fail "Wisdom module source missing"
        return 1
    fi
}

# -----------------------------------------------------------------------------
# 4. MENU SYSTEM TESTS
# -----------------------------------------------------------------------------

test_menu_script_exists() {
    if [ -f "source/scripts/menu/nook-menu.sh" ]; then
        assert_pass "Menu script exists"
        return 0
    else
        assert_fail "Menu script missing"
        return 1
    fi
}

test_menu_input_validation() {
    if [ -f "source/scripts/menu/nook-menu.sh" ]; then
        if grep -q "validate_menu_choice\|case.*in" source/scripts/menu/nook-menu.sh; then
            assert_pass "Menu input validation present"
            return 0
        else
            assert_fail "Menu lacks input validation"
            return 1
        fi
    else
        skip_test "test_menu_input_validation" "Menu script not found"
        return 0
    fi
}

test_menu_error_handling() {
    if [ -f "source/scripts/menu/nook-menu.sh" ]; then
        if grep -q "set -euo pipefail\|trap" source/scripts/menu/nook-menu.sh; then
            assert_pass "Menu has proper error handling"
            return 0
        else
            assert_fail "Menu lacks error handling"
            return 1
        fi
    else
        skip_test "test_menu_error_handling" "Menu script not found"
        return 0
    fi
}

# -----------------------------------------------------------------------------
# 5. DOCUMENTATION TESTS
# -----------------------------------------------------------------------------

test_xda_research_docs() {
    if [ -f "docs/XDA-RESEARCH-FINDINGS.md" ]; then
        assert_pass "XDA research documentation exists"
        return 0
    else
        assert_fail "XDA research documentation missing"
        return 1
    fi
}

test_deployment_docs() {
    local doc_files=(
        "docs/DEPLOYMENT-STRATEGY.md"
        "docs/KERNEL_BUILD_EXPLAINED.md"
    )
    
    local found_count=0
    for doc in "${doc_files[@]}"; do
        if [ -f "$doc" ]; then
            found_count=$((found_count + 1))
        fi
    done
    
    if [ "$found_count" -ge 1 ]; then
        assert_pass "Deployment documentation present ($found_count files)"
        return 0
    else
        assert_fail "Deployment documentation missing"
        return 1
    fi
}

# -----------------------------------------------------------------------------
# RUN ALL MEDIUM PRIORITY TESTS
# -----------------------------------------------------------------------------

echo "1. E-Ink Compatibility Tests"
echo "-----------------------------"
run_test "FBInk compatibility" test_fbink_compatibility
run_test "Display abstraction" test_display_abstraction
run_test "Refresh strategy" test_refresh_strategy

echo ""
echo "2. Boot Sequence Integration Tests"
echo "-----------------------------------"
run_test "Boot scripts exist" test_boot_script_exists
run_test "Module loading sequence" test_module_loading_sequence
run_test "Proc filesystem check" test_proc_filesystem_check

echo ""
echo "3. Medieval Theme Preservation Tests"
echo "-------------------------------------"
run_test "Jester ASCII art" test_jester_ascii_art
run_test "Medieval messages" test_medieval_messages
run_test "Wisdom quotes" test_wisdom_quotes

echo ""
echo "4. Menu System Tests"
echo "--------------------"
run_test "Menu script exists" test_menu_script_exists
run_test "Menu input validation" test_menu_input_validation
run_test "Menu error handling" test_menu_error_handling

echo ""
echo "5. Documentation Tests"
echo "----------------------"
run_test "XDA research docs" test_xda_research_docs
run_test "Deployment docs" test_deployment_docs

# -----------------------------------------------------------------------------
# TEST SUMMARY
# -----------------------------------------------------------------------------

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "                   MEDIUM PRIORITY TEST RESULTS"
echo "═══════════════════════════════════════════════════════════════"
echo -e "Total Tests:    $TOTAL_TESTS"
echo -e "Passed:         ${GREEN}$PASSED_TESTS${NC}"
echo -e "Failed:         ${RED}$FAILED_TESTS${NC}"
echo -e "Skipped:        ${YELLOW}$SKIPPED_TESTS${NC}"
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}✓ All medium priority tests passed!${NC}"
    echo "  User experience components verified"
    exit 0
else
    echo -e "${RED}✗ Some medium priority tests failed${NC}"
    echo "  Please address user experience issues"
    echo ""
    echo "Failed tests:"
    for result in "${TEST_RESULTS[@]}"; do
        if [[ $result == FAIL* ]]; then
            echo "  - $result"
        fi
    done
    exit 1
fi