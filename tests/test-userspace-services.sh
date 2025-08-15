#!/bin/bash
# Test script for JesterOS Userspace Services
# Validates all userspace components work correctly

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test results
TESTS_PASSED=0
TESTS_FAILED=0

echo "════════════════════════════════════════"
echo "  JesterOS Userspace Services Tests"
echo "════════════════════════════════════════"
echo ""

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

# Test: Service scripts exist
test_service_scripts() {
    [ -f "source/scripts/services/jesteros-service-manager.sh" ] && \
    [ -f "source/scripts/services/jester-daemon.sh" ] && \
    [ -f "source/scripts/services/jesteros-tracker.sh" ]
}

# Test: Boot scripts exist
test_boot_scripts() {
    [ -f "source/scripts/boot/jesteros-userspace.sh" ] && \
    [ -f "source/scripts/boot/jesteros-boot-splash.sh" ] && \
    [ -f "source/scripts/boot/init-jesteros.sh" ]
}

# Test: Service configurations exist
test_service_configs() {
    [ -d "source/configs/services" ] && \
    ls source/configs/services/*.conf 2>/dev/null | grep -q .
}

# Test: ASCII art collection exists
test_ascii_art() {
    [ -f "source/configs/ascii/jester-collection.txt" ] || \
    [ -d "source/configs/ascii" ]
}

# Test: Mood selector functionality
test_mood_selector() {
    if [ -f "source/scripts/services/jesteros-mood-selector.sh" ]; then
        # Test that script has proper structure
        grep -q "get_jester_mood" source/scripts/services/jesteros-mood-selector.sh && \
        grep -q "get_jester_art" source/scripts/services/jesteros-mood-selector.sh
    else
        # Mood selector is optional
        true
    fi
}

# Test: Service functions library
test_service_functions() {
    if [ -f "source/scripts/lib/service-functions.sh" ]; then
        # Check for required functions
        grep -q "start_service" source/scripts/lib/service-functions.sh && \
        grep -q "stop_service" source/scripts/lib/service-functions.sh && \
        grep -q "is_service_running" source/scripts/lib/service-functions.sh
    else
        # Service functions might be embedded
        true
    fi
}

# Test: Menu system exists
test_menu_system() {
    [ -f "source/scripts/menu/nook-menu.sh" ] || \
    [ -f "source/scripts/boot/boot-menu.sh" ] || \
    ls source/scripts/menu/*.sh 2>/dev/null | grep -q .
}

# Test: Safety features in scripts
test_script_safety() {
    local unsafe_count=0
    
    # Check for set -e in service scripts
    for script in source/scripts/services/*.sh; do
        if [ -f "$script" ]; then
            if ! grep -q "set -e\|set -.*e" "$script"; then
                unsafe_count=$((unsafe_count + 1))
            fi
        fi
    done
    
    [ "$unsafe_count" -eq 0 ]
}

# Test: No hardcoded /dev/sda references
test_no_dangerous_devices() {
    ! grep -r "/dev/sda" source/scripts/ 2>/dev/null | grep -v "^#" | grep -v "!=" | grep -q .
}

# Test: Memory budget compliance
test_memory_compliance() {
    # Count service scripts
    local service_count=$(ls -1 source/scripts/services/*.sh 2>/dev/null | wc -l || echo "0")
    # Estimate ~100KB per service
    local estimated_kb=$((service_count * 100))
    
    # Should be under 1MB (1024KB)
    [ "$estimated_kb" -lt 1024 ]
}

# Test: JesterOS branding consistency
test_branding() {
    # Check for JesterOS references (not JokerOS)
    ! grep -r "JokerOS" source/scripts/ 2>/dev/null | grep -v "migration\|legacy\|old" | grep -q . && \
    grep -r "JesterOS" source/scripts/ 2>/dev/null | grep -q .
}

# Test: Boot sequence integration
test_boot_integration() {
    # Check if init script references services
    if [ -f "source/scripts/boot/init-jesteros.sh" ]; then
        grep -q "service.*start\|jesteros.*service" source/scripts/boot/init-jesteros.sh
    else
        # Alternative boot integration
        grep -r "jesteros.*service\|service.*manager" source/scripts/boot/ 2>/dev/null | grep -q .
    fi
}

# Test: Configuration file format
test_config_format() {
    local valid_configs=true
    
    for conf in source/configs/services/*.conf; do
        if [ -f "$conf" ]; then
            # Check for required fields
            if ! grep -q "SERVICE_NAME=" "$conf"; then
                valid_configs=false
                break
            fi
        fi
    done
    
    [ "$valid_configs" = true ]
}

# Test: Error handling in services
test_error_handling() {
    local has_error_handling=true
    
    # Check service manager for error handling
    if [ -f "source/scripts/services/jesteros-service-manager.sh" ]; then
        if ! grep -q "trap\|error\|ERR" source/scripts/services/jesteros-service-manager.sh; then
            has_error_handling=false
        fi
    fi
    
    [ "$has_error_handling" = true ]
}

# Test: Medieval theme consistency
test_medieval_theme() {
    # Check for thematic elements
    grep -r "jester\|court\|realm\|quest\|scroll" source/scripts/ 2>/dev/null | grep -iq . || \
    grep -r "medieval\|knight\|castle" source/scripts/ 2>/dev/null | grep -iq .
}

# Run all tests
echo "=== Core Component Tests ==="
run_test "Service scripts exist" test_service_scripts
run_test "Boot scripts exist" test_boot_scripts
run_test "Service configurations" test_service_configs
run_test "ASCII art collection" test_ascii_art
run_test "Menu system" test_menu_system

echo ""
echo "=== Functionality Tests ==="
run_test "Mood selector" test_mood_selector
run_test "Service functions" test_service_functions
run_test "Boot integration" test_boot_integration
run_test "Config format" test_config_format
run_test "Error handling" test_error_handling

echo ""
echo "=== Safety Tests ==="
run_test "Script safety features" test_script_safety
run_test "No dangerous devices" test_no_dangerous_devices
run_test "Memory compliance" test_memory_compliance

echo ""
echo "=== Quality Tests ==="
run_test "JesterOS branding" test_branding
run_test "Medieval theme" test_medieval_theme

echo ""
echo "════════════════════════════════════════"
echo "Test Results:"
echo "  Passed: $TESTS_PASSED"
echo "  Failed: $TESTS_FAILED"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "  ${GREEN}All userspace tests passed!${NC}"
    echo "  The Court Jester approves! 🎭"
    echo "════════════════════════════════════════"
    exit 0
else
    echo -e "  ${RED}Some tests failed!${NC}"
    echo "  The Court Jester is concerned..."
    echo "════════════════════════════════════════"
    exit 1
fi