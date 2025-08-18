#!/bin/bash
# test-gk61-docker.sh - Docker-based validation for GK61 keyboard integration
# Tests the implementation in a proper JesterOS container environment
set -euo pipefail

# Test configuration
TEST_LOG="/tmp/gk61-docker-test-$(date +%Y%m%d_%H%M%S).log"
DOCKER_IMAGE="nook-writer"
ERRORS=0

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
    echo -e "${BLUE}           GK61 Keyboard Integration - Docker Tests         ${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    log_test "Starting GK61 Docker integration tests"
}

# Check if Docker image exists
check_docker_image() {
    echo -e "${BLUE}🐳 Checking Docker Environment${NC}"
    echo "───────────────────────────────────────────────────────────────"
    
    if ! command -v docker >/dev/null 2>&1; then
        test_fail "Docker command not available"
        return 1
    fi
    
    test_pass "Docker command available"
    
    if docker images | grep -q "$DOCKER_IMAGE"; then
        test_pass "Docker image '$DOCKER_IMAGE' found"
        return 0
    else
        test_warn "Docker image '$DOCKER_IMAGE' not found"
        echo "Building Docker image for testing..."
        
        if docker build -t "$DOCKER_IMAGE" --build-arg BUILD_MODE=writer -f nookwriter-optimized.dockerfile . >/dev/null 2>&1; then
            test_pass "Docker image built successfully"
            return 0
        else
            test_fail "Failed to build Docker image"
            return 1
        fi
    fi
}

# Test USB manager in Docker
test_usb_manager_docker() {
    echo -e "${BLUE}🔌 Testing USB Manager in Docker${NC}"
    echo "───────────────────────────────────────────────────────────────"
    
    # Test help command
    if docker run --rm "$DOCKER_IMAGE" /runtime/3-system/services/usb-keyboard-manager.sh help >/dev/null 2>&1; then
        test_pass "USB manager help command works in Docker"
    else
        test_fail "USB manager help command failed in Docker"
    fi
    
    # Test status command
    if docker run --rm "$DOCKER_IMAGE" /runtime/3-system/services/usb-keyboard-manager.sh status >/dev/null 2>&1; then
        test_pass "USB manager status command works in Docker"
    else
        test_warn "USB manager status failed (expected without USB hardware)"
    fi
    
    # Test that script exists and is executable
    if docker run --rm "$DOCKER_IMAGE" test -x /runtime/3-system/services/usb-keyboard-manager.sh; then
        test_pass "USB manager is executable in Docker"
    else
        test_fail "USB manager not executable in Docker"
    fi
    
    echo ""
}

# Test input handler in Docker
test_input_handler_docker() {
    echo -e "${BLUE}🎮 Testing Input Handler in Docker${NC}"
    echo "───────────────────────────────────────────────────────────────"
    
    # Test help command
    if docker run --rm "$DOCKER_IMAGE" /runtime/4-hardware/input/button-handler.sh help >/dev/null 2>&1; then
        test_pass "Input handler help command works in Docker"
    else
        test_fail "Input handler help command failed in Docker"
    fi
    
    # Test status command
    if docker run --rm "$DOCKER_IMAGE" /runtime/4-hardware/input/button-handler.sh status >/dev/null 2>&1; then
        test_pass "Input handler status command works in Docker"
    else
        test_warn "Input handler status failed (expected without input devices)"
    fi
    
    # Test list command
    if docker run --rm "$DOCKER_IMAGE" /runtime/4-hardware/input/button-handler.sh list >/dev/null 2>&1; then
        test_pass "Input handler list command works in Docker"
    else
        test_warn "Input handler list failed (expected without input devices)"
    fi
    
    # Test that script exists and is executable
    if docker run --rm "$DOCKER_IMAGE" test -x /runtime/4-hardware/input/button-handler.sh; then
        test_pass "Input handler is executable in Docker"
    else
        test_fail "Input handler not executable in Docker"
    fi
    
    echo ""
}

# Test setup script in Docker
test_setup_script_docker() {
    echo -e "${BLUE}⚙️  Testing Setup Script in Docker${NC}"
    echo "───────────────────────────────────────────────────────────────"
    
    # Test help command
    if docker run --rm "$DOCKER_IMAGE" /runtime/1-ui/setup/usb-keyboard-setup.sh help >/dev/null 2>&1; then
        test_pass "Setup script help command works in Docker"
    else
        test_fail "Setup script help command failed in Docker"
    fi
    
    # Test that script exists and is executable
    if docker run --rm "$DOCKER_IMAGE" test -x /runtime/1-ui/setup/usb-keyboard-setup.sh; then
        test_pass "Setup script is executable in Docker"
    else
        test_fail "Setup script not executable in Docker"
    fi
    
    echo ""
}

# Test file structure in Docker
test_file_structure_docker() {
    echo -e "${BLUE}📁 Testing File Structure in Docker${NC}"
    echo "───────────────────────────────────────────────────────────────"
    
    # Test that all required files exist
    local files=(
        "/runtime/3-system/services/usb-keyboard-manager.sh"
        "/runtime/4-hardware/input/button-handler.sh"
        "/runtime/1-ui/setup/usb-keyboard-setup.sh"
    )
    
    for file in "${files[@]}"; do
        if docker run --rm "$DOCKER_IMAGE" test -f "$file"; then
            test_pass "File exists: $file"
        else
            test_fail "File missing: $file"
        fi
    done
    
    # Test directory structure
    local dirs=(
        "/var/jesteros"
        "/var/log"
        "/runtime/3-system/services"
        "/runtime/4-hardware/input"
        "/runtime/1-ui/setup"
    )
    
    for dir in "${dirs[@]}"; do
        if docker run --rm "$DOCKER_IMAGE" test -d "$dir"; then
            test_pass "Directory exists: $dir"
        else
            test_fail "Directory missing: $dir"
        fi
    done
    
    echo ""
}

# Test JesterOS integration in Docker
test_jesteros_integration_docker() {
    echo -e "${BLUE}🃏 Testing JesterOS Integration in Docker${NC}"
    echo "───────────────────────────────────────────────────────────────"
    
    # Test that JesterOS services directory exists
    if docker run --rm "$DOCKER_IMAGE" test -d /usr/local/bin; then
        test_pass "JesterOS services directory exists"
    else
        test_fail "JesterOS services directory missing"
    fi
    
    # Test that keyboard status directories can be created
    if docker run --rm "$DOCKER_IMAGE" bash -c "mkdir -p /var/jesteros/keyboard && echo 'test' > /var/jesteros/keyboard/status"; then
        test_pass "Keyboard status files can be created"
    else
        test_fail "Cannot create keyboard status files"
    fi
    
    # Test that logs can be written
    if docker run --rm "$DOCKER_IMAGE" bash -c "echo 'test log' >> /var/log/jesteros-keyboard.log"; then
        test_pass "Keyboard logs can be written"
    else
        test_fail "Cannot write keyboard logs"
    fi
    
    echo ""
}

# Test simulated keyboard workflow
test_keyboard_workflow_docker() {
    echo -e "${BLUE}⌨️  Testing Keyboard Workflow in Docker${NC}"
    echo "───────────────────────────────────────────────────────────────"
    
    # Create a test script that simulates the keyboard setup workflow
    cat > /tmp/test-workflow.sh << 'EOF'
#!/bin/bash
set -e

# Simulate USB manager setup
echo "Testing USB manager workflow..."
/runtime/3-system/services/usb-keyboard-manager.sh check || echo "USB OTG check failed (expected)"

# Create mock keyboard status
mkdir -p /var/jesteros/keyboard
echo "connected" > /var/jesteros/keyboard/status
echo "GK61 Test Keyboard" > /var/jesteros/keyboard/name
echo "1a2c:3013" > /var/jesteros/keyboard/vendor_product
echo "/dev/input/event3" > /var/jesteros/keyboard/event_device

# Test input handler can read status
echo "Testing input handler integration..."
/runtime/4-hardware/input/button-handler.sh status

echo "Workflow test completed successfully"
EOF

    chmod +x /tmp/test-workflow.sh
    
    if docker run --rm -v /tmp/test-workflow.sh:/test-workflow.sh "$DOCKER_IMAGE" /test-workflow.sh >/dev/null 2>&1; then
        test_pass "Keyboard workflow simulation successful"
    else
        test_fail "Keyboard workflow simulation failed"
    fi
    
    rm -f /tmp/test-workflow.sh
    echo ""
}

# Test memory usage in Docker
test_memory_usage_docker() {
    echo -e "${BLUE}💾 Testing Memory Usage in Docker${NC}"
    echo "───────────────────────────────────────────────────────────────"
    
    # Run container and check memory usage
    local memory_mb=$(docker run --rm "$DOCKER_IMAGE" bash -c "free -m | awk '/^Mem:/ {print \$3}'")
    
    if [ -n "$memory_mb" ] && [ "$memory_mb" -lt 100 ]; then
        test_pass "Memory usage within limits: ${memory_mb}MB"
    else
        test_warn "Memory usage: ${memory_mb}MB (check if within device constraints)"
    fi
    
    echo ""
}

# Test summary
show_test_summary() {
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}                        Test Summary                        ${NC}"
    echo -e "${BLUE}══════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    if [ $ERRORS -eq 0 ]; then
        echo -e "${GREEN}🎉 ALL DOCKER TESTS PASSED!${NC}"
        echo "The GK61 keyboard integration is ready for deployment to actual hardware."
        log_test "All Docker tests passed successfully"
    else
        echo -e "${RED}❌ $ERRORS DOCKER TEST(S) FAILED${NC}"
        echo "Review the failed tests and fix issues before hardware deployment."
        log_test "$ERRORS Docker tests failed"
    fi
    
    echo ""
    echo "Docker test log saved to: $TEST_LOG"
    echo ""
    echo "Next steps:"
    echo "  1. If tests pass: Deploy to SD card and test on actual hardware"
    echo "  2. Test with real GK61 keyboard and OTG setup"
    echo "  3. Validate all function keys work as expected"
    echo "  4. Test mode switching between ADB and keyboard"
    echo ""
    
    return $ERRORS
}

# Main test execution
main() {
    show_test_banner
    
    if ! check_docker_image; then
        echo "Cannot proceed without Docker image"
        return 1
    fi
    
    test_file_structure_docker
    test_usb_manager_docker
    test_input_handler_docker
    test_setup_script_docker
    test_jesteros_integration_docker
    test_keyboard_workflow_docker
    test_memory_usage_docker
    
    show_test_summary
}

# Run tests if script is executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi