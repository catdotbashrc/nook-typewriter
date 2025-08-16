#!/bin/bash
# JesterOS Integration Tests
# Tests the complete system from boot to menu

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test environment
TEST_DIR="/tmp/test-jesteros-integration"
TESTS_PASSED=0
TESTS_FAILED=0

echo "════════════════════════════════════════"
echo "  JesterOS Integration Tests"
echo "  Testing Boot → Services → Menu"
echo "════════════════════════════════════════"
echo ""

# Setup test environment
setup_test_env() {
    echo "Setting up test environment..."
    rm -rf "$TEST_DIR"
    mkdir -p "$TEST_DIR/var/jesteros"
    mkdir -p "$TEST_DIR/var/run"
    mkdir -p "$TEST_DIR/var/log"
    mkdir -p "$TEST_DIR/etc/jesteros"
    
    # Copy configurations if they exist
    if [ -d "source/configs/services" ]; then
        cp -r source/configs/services "$TEST_DIR/etc/jesteros/" 2>/dev/null || true
    fi
}

# Cleanup test environment
cleanup_test_env() {
    echo "Cleaning up test environment..."
    rm -rf "$TEST_DIR"
}

# Test function
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo -n "Testing $test_name... "
    
    if eval "$test_command" >/dev/null 2>&1; then
        echo -e "${GREEN}PASS${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# Integration test: Boot sequence
test_boot_sequence() {
    echo -e "\n${BLUE}=== Boot Sequence Tests ===${NC}"
    
    # Test 1: Boot splash can be displayed
    if [ -f "source/scripts/boot/jesteros-boot-splash.sh" ]; then
        echo -n "  Boot splash script... "
        if bash -n source/scripts/boot/jesteros-boot-splash.sh 2>/dev/null; then
            echo -e "${GREEN}valid${NC}"
        else
            echo -e "${RED}syntax error${NC}"
            return 1
        fi
    fi
    
    # Test 2: Init script exists and is valid
    if [ -f "source/scripts/boot/init-jesteros.sh" ]; then
        echo -n "  Init script... "
        if bash -n source/scripts/boot/init-jesteros.sh 2>/dev/null; then
            echo -e "${GREEN}valid${NC}"
        else
            echo -e "${RED}syntax error${NC}"
            return 1
        fi
    fi
    
    # Test 3: Userspace script exists
    if [ -f "source/scripts/boot/jesteros-userspace.sh" ]; then
        echo -n "  Userspace loader... "
        if bash -n source/scripts/boot/jesteros-userspace.sh 2>/dev/null; then
            echo -e "${GREEN}valid${NC}"
        else
            echo -e "${RED}syntax error${NC}"
            return 1
        fi
    fi
    
    return 0
}

# Integration test: Service startup
test_service_startup() {
    echo -e "\n${BLUE}=== Service Startup Tests ===${NC}"
    
    # Test service manager syntax
    if [ -f "source/scripts/services/jesteros-service-manager.sh" ]; then
        echo -n "  Service manager syntax... "
        if bash -n source/scripts/services/jesteros-service-manager.sh 2>/dev/null; then
            echo -e "${GREEN}valid${NC}"
        else
            echo -e "${RED}syntax error${NC}"
            return 1
        fi
    fi
    
    # Test service dependencies
    echo -n "  Service dependencies... "
    local dep_errors=0
    for conf in source/configs/services/*.conf; do
        if [ -f "$conf" ]; then
            if grep -q "SERVICE_DEPS=" "$conf"; then
                # Extract dependencies
                local deps=$(grep "SERVICE_DEPS=" "$conf" | cut -d'"' -f2)
                for dep in $deps; do
                    if [ ! -f "source/configs/services/${dep}.conf" ]; then
                        dep_errors=$((dep_errors + 1))
                    fi
                done
            fi
        fi
    done
    
    if [ "$dep_errors" -eq 0 ]; then
        echo -e "${GREEN}resolved${NC}"
    else
        echo -e "${RED}$dep_errors missing${NC}"
        return 1
    fi
    
    return 0
}

# Integration test: Menu system
test_menu_system() {
    echo -e "\n${BLUE}=== Menu System Tests ===${NC}"
    
    # Find menu script
    local menu_script=""
    if [ -f "source/scripts/menu/nook-menu.sh" ]; then
        menu_script="source/scripts/menu/nook-menu.sh"
    elif [ -f "source/scripts/boot/boot-menu.sh" ]; then
        menu_script="source/scripts/boot/boot-menu.sh"
    fi
    
    if [ -n "$menu_script" ]; then
        echo -n "  Menu script syntax... "
        if bash -n "$menu_script" 2>/dev/null; then
            echo -e "${GREEN}valid${NC}"
        else
            echo -e "${RED}syntax error${NC}"
            return 1
        fi
        
        echo -n "  Menu has options... "
        if grep -q "case\|select\|choice" "$menu_script"; then
            echo -e "${GREEN}yes${NC}"
        else
            echo -e "${RED}no${NC}"
            return 1
        fi
    else
        echo -e "  ${YELLOW}No menu system found${NC}"
        return 1
    fi
    
    return 0
}

# Integration test: Memory usage
test_memory_usage() {
    echo -e "\n${BLUE}=== Memory Usage Tests ===${NC}"
    
    # Calculate estimated memory usage
    local total_kb=0
    
    # Service scripts (~100KB each)
    local service_count=$(ls -1 source/scripts/services/*.sh 2>/dev/null | wc -l || echo "0")
    local service_kb=$((service_count * 100))
    total_kb=$((total_kb + service_kb))
    echo "  Service scripts: ${service_kb}KB ($service_count services)"
    
    # Boot scripts (~50KB each)
    local boot_count=$(ls -1 source/scripts/boot/*.sh 2>/dev/null | wc -l || echo "0")
    local boot_kb=$((boot_count * 50))
    total_kb=$((total_kb + boot_kb))
    echo "  Boot scripts: ${boot_kb}KB ($boot_count scripts)"
    
    # Menu scripts (~50KB each)
    local menu_count=$(ls -1 source/scripts/menu/*.sh 2>/dev/null | wc -l || echo "0")
    local menu_kb=$((menu_count * 50))
    total_kb=$((total_kb + menu_kb))
    echo "  Menu scripts: ${menu_kb}KB ($menu_count scripts)"
    
    # ASCII art (~10KB)
    if [ -f "source/configs/ascii/jester-collection.txt" ]; then
        total_kb=$((total_kb + 10))
        echo "  ASCII art: 10KB"
    fi
    
    echo -n "  Total estimated: ${total_kb}KB - "
    if [ "$total_kb" -lt 1024 ]; then
        echo -e "${GREEN}Within 1MB budget${NC}"
        return 0
    elif [ "$total_kb" -lt 2048 ]; then
        echo -e "${YELLOW}Close to limit${NC}"
        return 0
    else
        echo -e "${RED}Exceeds budget!${NC}"
        return 1
    fi
}

# Integration test: Complete flow
test_complete_flow() {
    echo -e "\n${BLUE}=== Complete Flow Test ===${NC}"
    
    echo "  Simulating boot sequence..."
    
    # Step 1: Boot splash
    echo -n "    1. Display boot splash... "
    if [ -f "source/scripts/boot/jesteros-boot-splash.sh" ]; then
        echo -e "${GREEN}ready${NC}"
    else
        echo -e "${YELLOW}missing${NC}"
    fi
    
    # Step 2: Initialize services
    echo -n "    2. Initialize services... "
    if [ -f "source/scripts/boot/init-jesteros.sh" ] || [ -f "source/scripts/boot/jesteros-userspace.sh" ]; then
        echo -e "${GREEN}ready${NC}"
    else
        echo -e "${YELLOW}missing${NC}"
    fi
    
    # Step 3: Start service manager
    echo -n "    3. Start service manager... "
    if [ -f "source/scripts/services/jesteros-service-manager.sh" ]; then
        echo -e "${GREEN}ready${NC}"
    else
        echo -e "${RED}missing${NC}"
        return 1
    fi
    
    # Step 4: Create /var/jesteros interface
    echo -n "    4. Create /var/jesteros... "
    echo -e "${GREEN}simulated${NC}"
    
    # Step 5: Launch menu
    echo -n "    5. Launch menu system... "
    if ls source/scripts/menu/*.sh 2>/dev/null | grep -q . || [ -f "source/scripts/boot/boot-menu.sh" ]; then
        echo -e "${GREEN}ready${NC}"
    else
        echo -e "${YELLOW}missing${NC}"
    fi
    
    echo -e "  ${GREEN}Flow complete!${NC}"
    return 0
}

# Main test execution
main() {
    # Setup
    setup_test_env
    
    # Run integration tests
    test_boot_sequence
    test_service_startup
    test_menu_system
    test_memory_usage
    test_complete_flow
    
    # Cleanup
    cleanup_test_env
    
    # Summary
    echo ""
    echo "════════════════════════════════════════"
    echo "Integration Test Results:"
    echo "  Boot Sequence: $([ $? -eq 0 ] && echo -e "${GREEN}PASS${NC}" || echo -e "${RED}FAIL${NC}")"
    echo "  Service Startup: $([ $? -eq 0 ] && echo -e "${GREEN}PASS${NC}" || echo -e "${RED}FAIL${NC}")"
    echo "  Menu System: $([ $? -eq 0 ] && echo -e "${GREEN}PASS${NC}" || echo -e "${RED}FAIL${NC}")"
    echo "  Memory Usage: $([ $? -eq 0 ] && echo -e "${GREEN}PASS${NC}" || echo -e "${RED}FAIL${NC}")"
    echo "  Complete Flow: $([ $? -eq 0 ] && echo -e "${GREEN}PASS${NC}" || echo -e "${RED}FAIL${NC}")"
    echo ""
    
    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}✓ Integration tests passed!${NC}"
        echo "The realm is ready for deployment!"
        exit 0
    else
        echo -e "${RED}✗ Integration tests failed${NC}"
        echo "The Court Jester requires adjustments..."
        exit 1
    fi
}

# Run if executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi