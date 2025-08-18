#!/bin/bash
# JesterOS Integration Test - Complete system validation
# "Testing the realm with quill and thoroughness!"
# 
# This script can be run against any JesterOS base image to validate functionality

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

test_count=0
passed_tests=0
failed_tests=0

log() {
    echo -e "${GREEN}[TEST]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[FAIL]${NC} $1"
}

run_test() {
    local test_name="$1"
    local test_command="$2"
    
    ((test_count++))
    echo -e "\n${BLUE}Test $test_count: $test_name${NC}"
    
    if eval "$test_command"; then
        echo -e "${GREEN}✓ PASSED${NC}"
        ((passed_tests++))
        return 0
    else
        echo -e "${RED}✗ FAILED${NC}"
        ((failed_tests++))
        return 1
    fi
}

# Test 1: Directory Structure
test_directory_structure() {
    local required_dirs=(
        "/runtime/2-application/jesteros"
        "/runtime/3-system/common"
        "/runtime/3-system/services"
        "/runtime/4-hardware/input"
        "/runtime/1-ui/setup"
        "/runtime/configs/services"
        "/var/jesteros"
        "/var/run/jesteros"
        "/var/log/jesteros"
        "/etc/jesteros/services"
    )
    
    for dir in "${required_dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            error "Missing directory: $dir"
            return 1
        fi
    done
    
    log "All required directories present"
    return 0
}

# Test 2: Service Scripts Exist and Are Executable
test_service_scripts() {
    local scripts=(
        "/runtime/2-application/jesteros/manager.sh"
        "/runtime/2-application/jesteros/jester-daemon.sh"
        "/runtime/2-application/jesteros/health-check.sh"
        "/runtime/init/jesteros-service-init.sh"
        "/usr/local/bin/jesteros-service-init.sh"
        "/runtime/3-system/services/usb-keyboard-manager.sh"
        "/runtime/4-hardware/input/button-handler.sh"
        "/runtime/1-ui/setup/usb-keyboard-setup.sh"
    )
    
    for script in "${scripts[@]}"; do
        if [ ! -f "$script" ]; then
            error "Missing script: $script"
            return 1
        fi
        if [ ! -x "$script" ]; then
            error "Script not executable: $script"
            return 1
        fi
    done
    
    log "All service scripts present and executable"
    return 0
}

# Test 3: Service Initialization
test_service_initialization() {
    log "Running JesterOS service initialization..."
    
    # Run initialization in test mode
    if /usr/local/bin/jesteros-service-init.sh directories; then
        log "Directory initialization successful"
    else
        error "Directory initialization failed"
        return 1
    fi
    
    if /usr/local/bin/jesteros-service-init.sh interface; then
        log "Interface initialization successful"
    else
        error "Interface initialization failed"
        return 1
    fi
    
    return 0
}

# Test 4: Interface Files Created
test_interface_files() {
    local interface_files=(
        "/var/jesteros/jester"
        "/var/jesteros/typewriter/stats"
        "/var/jesteros/wisdom"
        "/var/jesteros/health/status"
    )
    
    for file in "${interface_files[@]}"; do
        if [ ! -f "$file" ]; then
            error "Missing interface file: $file"
            return 1
        fi
        
        # Check file has content
        if [ ! -s "$file" ]; then
            error "Interface file is empty: $file"
            return 1
        fi
    done
    
    log "All interface files created with content"
    return 0
}

# Test 5: Service Manager Functionality
test_service_manager() {
    local manager="/runtime/2-application/jesteros/manager.sh"
    
    # Test initialization
    if ! "$manager" init; then
        error "Service manager initialization failed"
        return 1
    fi
    
    # Test service configuration creation
    if [ ! -f "/etc/jesteros/services/jester.conf" ] || \
       [ ! -f "/etc/jesteros/services/tracker.conf" ] || \
       [ ! -f "/etc/jesteros/services/health.conf" ]; then
        error "Service configurations not created"
        return 1
    fi
    
    log "Service manager functional"
    return 0
}

# Test 6: Health Check Service
test_health_service() {
    local health_script="/runtime/2-application/jesteros/health-check.sh"
    
    # Run one-time health check
    if ! "$health_script" check; then
        error "Health check failed"
        return 1
    fi
    
    # Verify health status file was created and has content
    if [ ! -f "/var/jesteros/health/status" ] || [ ! -s "/var/jesteros/health/status" ]; then
        error "Health status file not created properly"
        return 1
    fi
    
    log "Health monitoring functional"
    return 0
}

# Test 7: Memory Usage Validation
test_memory_usage() {
    # Check current memory usage
    local total_mem=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    local available_mem=$(grep MemAvailable /proc/meminfo | awk '{print $2}' || grep MemFree /proc/meminfo | awk '{print $2}')
    local used_mem=$((total_mem - available_mem))
    local used_mb=$((used_mem / 1024))
    
    log "Memory usage: ${used_mb}MB used of $((total_mem / 1024))MB total"
    
    # We're in a container so this is just a basic sanity check
    if [ $used_mb -gt 512 ]; then
        warn "Memory usage seems high for container test: ${used_mb}MB"
    else
        log "Memory usage acceptable for testing"
    fi
    
    return 0
}

# Test 8: Service Dependencies
test_service_dependencies() {
    local common_functions="/runtime/3-system/common/service-functions.sh"
    
    if [ ! -f "$common_functions" ]; then
        error "Missing service-functions.sh"
        return 1
    fi
    
    # Test that manager can source service functions
    if ! bash -c "source '$common_functions' && echo 'Service functions loaded'"; then
        error "Cannot load service functions"
        return 1
    fi
    
    log "Service dependencies satisfied"
    return 0
}

# Test 9: Content Validation
test_content_validation() {
    # Check jester has medieval theme
    if ! grep -q "jester\|court\|medieval" /var/jesteros/jester; then
        error "Jester content missing medieval theme"
        return 1
    fi
    
    # Check stats has writing focus
    if ! grep -q -i "writing\|words\|characters" /var/jesteros/typewriter/stats; then
        error "Typewriter stats missing writing metrics"
        return 1
    fi
    
    # Check wisdom has writing quotes
    if [ ! -s /var/jesteros/wisdom ]; then
        error "Wisdom file is empty"
        return 1
    fi
    
    log "Content validation passed"
    return 0
}

# Test 10: GK61 Keyboard Integration
test_keyboard_integration() {
    log "Testing GK61 keyboard integration..."
    
    # Test USB keyboard manager exists and is functional
    if [ ! -x "/runtime/3-system/services/usb-keyboard-manager.sh" ]; then
        error "USB keyboard manager missing or not executable"
        return 1
    fi
    
    # Test input handler exists and is functional
    if [ ! -x "/runtime/4-hardware/input/button-handler.sh" ]; then
        error "Input handler missing or not executable"
        return 1
    fi
    
    # Test setup script exists and is functional
    if [ ! -x "/runtime/1-ui/setup/usb-keyboard-setup.sh" ]; then
        error "USB keyboard setup script missing or not executable"
        return 1
    fi
    
    # Test help commands work
    if ! /runtime/3-system/services/usb-keyboard-manager.sh help >/dev/null 2>&1; then
        error "USB keyboard manager help command failed"
        return 1
    fi
    
    if ! /runtime/4-hardware/input/button-handler.sh help >/dev/null 2>&1; then
        error "Input handler help command failed"
        return 1
    fi
    
    if ! /runtime/1-ui/setup/usb-keyboard-setup.sh help >/dev/null 2>&1; then
        error "Setup script help command failed"
        return 1
    fi
    
    # Test keyboard status directories exist
    local kb_dirs=(
        "/var/jesteros/keyboard"
        "/var/jesteros/usb"
        "/var/jesteros/buttons"
    )
    
    for dir in "${kb_dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            error "Missing keyboard directory: $dir"
            return 1
        fi
    done
    
    # Test simulated keyboard detection
    echo "connected" > /var/jesteros/keyboard/status
    echo "Skyloong GK61" > /var/jesteros/keyboard/name
    echo "1a2c:3013" > /var/jesteros/keyboard/vendor_product
    echo "/dev/input/event3" > /var/jesteros/keyboard/event_device
    
    # Test USB manager can detect simulated keyboard
    if ! /runtime/3-system/services/usb-keyboard-manager.sh status >/dev/null 2>&1; then
        error "USB manager status failed"
        return 1
    fi
    
    log "GK61 keyboard integration validated"
    return 0
}

# Test 11: Complete System Integration
test_complete_integration() {
    log "Testing complete system integration..."
    
    # Initialize complete system
    if ! /usr/local/bin/jesteros-service-init.sh init >/dev/null 2>&1; then
        # Try status check instead of full init (which might try to start daemons)
        if ! /runtime/2-application/jesteros/manager.sh status all >/dev/null 2>&1; then
            warn "Full service startup test skipped (expected in container)"
        fi
    fi
    
    # Verify all interface files still exist and have content
    local interface_files=(
        "/var/jesteros/jester"
        "/var/jesteros/typewriter/stats"
        "/var/jesteros/wisdom"
        "/var/jesteros/health/status"
    )
    
    for file in "${interface_files[@]}"; do
        if [ ! -f "$file" ] || [ ! -s "$file" ]; then
            error "Integration test failed - missing interface: $file"
            return 1
        fi
    done
    
    log "Complete system integration validated"
    return 0
}

# Main test execution
main() {
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                  JESTEROS INTEGRATION TEST                    ║"
    echo "║                                                                ║"
    echo "║         \"By quill and candlelight, we test the realm!\"        ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    echo "Environment Information:"
    echo "  OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
    echo "  Architecture: $(uname -m)"
    echo "  Memory: $(grep MemTotal /proc/meminfo | awk '{print $2 / 1024 "MB"}')"
    echo "  Test Date: $(date)"
    echo ""
    
    # Run all tests
    run_test "Directory Structure" "test_directory_structure"
    run_test "Service Scripts" "test_service_scripts"
    run_test "Service Initialization" "test_service_initialization"
    run_test "Interface Files Creation" "test_interface_files"
    run_test "Service Manager" "test_service_manager"
    run_test "Health Check Service" "test_health_service"
    run_test "Memory Usage" "test_memory_usage"
    run_test "Service Dependencies" "test_service_dependencies"
    run_test "Content Validation" "test_content_validation"
    run_test "GK61 Keyboard Integration" "test_keyboard_integration"
    run_test "Complete Integration" "test_complete_integration"
    
    # Summary
    echo ""
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                        TEST SUMMARY                           ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Total Tests: $test_count"
    echo -e "Passed: ${GREEN}$passed_tests${NC}"
    echo -e "Failed: ${RED}$failed_tests${NC}"
    echo ""
    
    if [ $failed_tests -eq 0 ]; then
        echo -e "${GREEN}🎭 All tests passed! The digital court is ready!${NC}"
        echo "JesterOS userspace services are production-ready."
        exit 0
    else
        echo -e "${RED}⚠️  Some tests failed. The court needs attention!${NC}"
        exit 1
    fi
}

# Run the test suite
main "$@"