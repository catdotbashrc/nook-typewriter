#!/bin/bash
# test-gk61-integration.sh - Validation tests for GK61 keyboard integration
# Validates the complete USB keyboard implementation
set -euo pipefail

# Test configuration
TEST_LOG="/tmp/gk61-test-$(date +%Y%m%d_%H%M%S).log"
ERRORS=0

# Paths to test
USB_MANAGER="/home/jyeary/projects/personal/nook/runtime/3-system/services/usb-keyboard-manager.sh"
INPUT_HANDLER="/home/jyeary/projects/personal/nook/runtime/4-hardware/input/button-handler.sh"
SETUP_SCRIPT="/home/jyeary/projects/personal/nook/runtime/1-ui/setup/usb-keyboard-setup.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging
log_test() {
    echo "[$(date '+%H:%M:%S')] $1" | tee -a "$TEST_LOG"
}

# Test result tracking
test_pass() {
    echo -e "${GREEN}✓ PASS${NC}: $1"
    log_test "PASS: $1"
}

test_fail() {
    echo -e "${RED}✗ FAIL${NC}: $1"
    log_test "FAIL: $1"
    ERRORS=$((ERRORS + 1))
}

test_warn() {
    echo -e "${YELLOW}⚠ WARN${NC}: $1"
    log_test "WARN: $1"
}

# Test banner
show_test_banner() {
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}              GK61 Keyboard Integration Tests               ${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    log_test "Starting GK61 integration tests"
}

# Test 1: File existence and permissions
test_file_structure() {
    echo -e "${BLUE}📁 Testing File Structure${NC}"
    echo "───────────────────────────────────────────────────────────────"
    
    # USB Manager
    if [ -f "$USB_MANAGER" ]; then
        test_pass "USB manager exists: $USB_MANAGER"
    else
        test_fail "USB manager missing: $USB_MANAGER"
    fi
    
    if [ -x "$USB_MANAGER" ]; then
        test_pass "USB manager is executable"
    else
        test_fail "USB manager not executable"
    fi
    
    # Input Handler
    if [ -f "$INPUT_HANDLER" ]; then
        test_pass "Input handler exists: $INPUT_HANDLER"
    else
        test_fail "Input handler missing: $INPUT_HANDLER"
    fi
    
    if [ -x "$INPUT_HANDLER" ]; then
        test_pass "Input handler is executable"
    else
        test_fail "Input handler not executable"
    fi
    
    # Setup Script
    if [ -f "$SETUP_SCRIPT" ]; then
        test_pass "Setup script exists: $SETUP_SCRIPT"
    else
        test_fail "Setup script missing: $SETUP_SCRIPT"
    fi
    
    if [ -x "$SETUP_SCRIPT" ]; then
        test_pass "Setup script is executable"
    else
        test_fail "Setup script not executable"
    fi
    
    echo ""
}

# Test 2: Script syntax validation
test_script_syntax() {
    echo -e "${BLUE}✅ Testing Script Syntax${NC}"
    echo "───────────────────────────────────────────────────────────────"
    
    # Test USB manager syntax
    if bash -n "$USB_MANAGER" 2>/dev/null; then
        test_pass "USB manager syntax valid"
    else
        test_fail "USB manager syntax error"
    fi
    
    # Test input handler syntax
    if bash -n "$INPUT_HANDLER" 2>/dev/null; then
        test_pass "Input handler syntax valid"
    else
        test_fail "Input handler syntax error"
    fi
    
    # Test setup script syntax
    if bash -n "$SETUP_SCRIPT" 2>/dev/null; then
        test_pass "Setup script syntax valid"
    else
        test_fail "Setup script syntax error"
    fi
    
    echo ""
}

# Test 3: USB manager functionality
test_usb_manager() {
    echo -e "${BLUE}🔌 Testing USB Manager${NC}"
    echo "───────────────────────────────────────────────────────────────"
    
    # Test help command
    if "$USB_MANAGER" help >/dev/null 2>&1; then
        test_pass "USB manager help command works"
    else
        test_fail "USB manager help command failed"
    fi
    
    # Test status command
    if "$USB_MANAGER" status >/dev/null 2>&1; then
        test_pass "USB manager status command works"
    else
        test_fail "USB manager status command failed"
    fi
    
    # Test check command (this should work even without hardware)
    if "$USB_MANAGER" check >/dev/null 2>&1; then
        test_pass "USB OTG controller available"
    else
        test_warn "USB OTG controller not available (normal in test environment)"
    fi
    
    echo ""
}

# Test 4: Input handler functionality
test_input_handler() {
    echo -e "${BLUE}🎮 Testing Input Handler${NC}"
    echo "───────────────────────────────────────────────────────────────"
    
    # Test help command
    if "$INPUT_HANDLER" help >/dev/null 2>&1; then
        test_pass "Input handler help command works"
    else
        test_fail "Input handler help command failed"
    fi
    
    # Test status command
    if "$INPUT_HANDLER" status >/dev/null 2>&1; then
        test_pass "Input handler status command works"
    else
        test_fail "Input handler status command failed"
    fi
    
    # Test list command
    if "$INPUT_HANDLER" list >/dev/null 2>&1; then
        test_pass "Input handler list command works"
    else
        test_fail "Input handler list command failed"
    fi
    
    echo ""
}

# Test 5: Setup script functionality
test_setup_script() {
    echo -e "${BLUE}⚙️  Testing Setup Script${NC}"
    echo "───────────────────────────────────────────────────────────────"
    
    # Test help command
    if "$SETUP_SCRIPT" help >/dev/null 2>&1; then
        test_pass "Setup script help command works"
    else
        test_fail "Setup script help command failed"
    fi
    
    # Test check command
    if "$SETUP_SCRIPT" check >/dev/null 2>&1; then
        test_pass "Setup script check command works"
    else
        test_warn "Setup script check failed (may need actual hardware)"
    fi
    
    echo ""
}

# Test 6: Key code definitions
test_key_codes() {
    echo -e "${BLUE}⌨️  Testing Key Code Definitions${NC}"
    echo "───────────────────────────────────────────────────────────────"
    
    # Check if key codes are defined in input handler
    local key_codes=("KEY_ESC" "KEY_F1" "KEY_F2" "KEY_F3" "KEY_F4" "KEY_F5" "KEY_F10")
    
    for key in "${key_codes[@]}"; do
        if grep -q "^$key=" "$INPUT_HANDLER"; then
            test_pass "$key definition found"
        else
            test_fail "$key definition missing"
        fi
    done
    
    echo ""
}

# Test 7: JesterOS integration
test_jesteros_integration() {
    echo -e "${BLUE}🃏 Testing JesterOS Integration${NC}"
    echo "───────────────────────────────────────────────────────────────"
    
    # Check for JesterOS interface paths
    if grep -q "/var/jesteros/keyboard" "$INPUT_HANDLER"; then
        test_pass "JesterOS keyboard interface integration found"
    else
        test_fail "JesterOS keyboard interface integration missing"
    fi
    
    # Check for keyboard event handling
    if grep -q "handle_keyboard_event" "$INPUT_HANDLER"; then
        test_pass "Keyboard event handling function found"
    else
        test_fail "Keyboard event handling function missing"
    fi
    
    # Check for USB keyboard monitoring
    if grep -q "USB keyboard" "$INPUT_HANDLER"; then
        test_pass "USB keyboard monitoring integration found"
    else
        test_fail "USB keyboard monitoring integration missing"
    fi
    
    echo ""
}

# Test 8: Error handling
test_error_handling() {
    echo -e "${BLUE}🛡️  Testing Error Handling${NC}"
    echo "───────────────────────────────────────────────────────────────"
    
    # Check for set -euo pipefail
    if grep -q "set -euo pipefail" "$USB_MANAGER"; then
        test_pass "USB manager has proper error handling"
    else
        test_fail "USB manager missing error handling"
    fi
    
    if grep -q "set -euo pipefail" "$INPUT_HANDLER"; then
        test_pass "Input handler has proper error handling"
    else
        test_fail "Input handler missing error handling"
    fi
    
    if grep -q "set -euo pipefail" "$SETUP_SCRIPT"; then
        test_pass "Setup script has proper error handling"
    else
        test_fail "Setup script missing error handling"
    fi
    
    # Check for error_handler function
    if grep -q "error_handler" "$USB_MANAGER"; then
        test_pass "USB manager has error handler function"
    else
        test_fail "USB manager missing error handler function"
    fi
    
    echo ""
}

# Test 9: Documentation completeness
test_documentation() {
    echo -e "${BLUE}📚 Testing Documentation${NC}"
    echo "───────────────────────────────────────────────────────────────"
    
    # Check for help text in scripts
    if grep -q "Usage:" "$USB_MANAGER"; then
        test_pass "USB manager has usage documentation"
    else
        test_fail "USB manager missing usage documentation"
    fi
    
    if grep -q "Usage:" "$INPUT_HANDLER"; then
        test_pass "Input handler has usage documentation"
    else
        test_fail "Input handler missing usage documentation"
    fi
    
    if grep -q "Usage:" "$SETUP_SCRIPT"; then
        test_pass "Setup script has usage documentation"
    else
        test_fail "Setup script missing usage documentation"
    fi
    
    # Check for GK61-specific documentation
    if grep -q "GK61" "$INPUT_HANDLER"; then
        test_pass "GK61-specific documentation found"
    else
        test_fail "GK61-specific documentation missing"
    fi
    
    echo ""
}

# Test 10: Integration workflow
test_integration_workflow() {
    echo -e "${BLUE}🔄 Testing Integration Workflow${NC}"
    echo "───────────────────────────────────────────────────────────────"
    
    # Test if input handler can detect USB manager status
    if grep -q "check_usb_keyboard" "$INPUT_HANDLER"; then
        test_pass "Input handler can check USB keyboard status"
    else
        test_fail "Input handler missing USB keyboard detection"
    fi
    
    # Test if setup script references other components
    if grep -q "usb-keyboard-manager.sh" "$SETUP_SCRIPT"; then
        test_pass "Setup script references USB manager"
    else
        test_fail "Setup script missing USB manager reference"
    fi
    
    if grep -q "button-handler.sh" "$SETUP_SCRIPT"; then
        test_pass "Setup script references input handler"
    else
        test_fail "Setup script missing input handler reference"
    fi
    
    echo ""
}

# Test summary
show_test_summary() {
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}                        Test Summary                        ${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    
    if [ $ERRORS -eq 0 ]; then
        echo -e "${GREEN}🎉 ALL TESTS PASSED!${NC}"
        echo "The GK61 keyboard integration is ready for deployment."
        log_test "All tests passed successfully"
    else
        echo -e "${RED}❌ $ERRORS TEST(S) FAILED${NC}"
        echo "Review the failed tests and fix issues before deployment."
        log_test "$ERRORS tests failed"
    fi
    
    echo ""
    echo "Test log saved to: $TEST_LOG"
    echo ""
    
    return $ERRORS
}

# Main test execution
main() {
    show_test_banner
    
    test_file_structure
    test_script_syntax
    test_usb_manager
    test_input_handler
    test_setup_script
    test_key_codes
    test_jesteros_integration
    test_error_handling
    test_documentation
    test_integration_workflow
    
    show_test_summary
}

# Run tests if script is executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi