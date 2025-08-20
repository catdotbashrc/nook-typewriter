#!/bin/bash
# Boot validation test for JesterOS
# Validates boot infrastructure components

set -euo pipefail

# Source test configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test-config.sh" 2>/dev/null || true

# Test configuration
TEST_NAME="Boot Validation"
TEST_CRITICAL=true

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0

# Test functions
log_test() {
    echo -e "${GREEN}[TEST]${NC} $1"
}

log_pass() {
    echo -e "${GREEN}✓${NC} $1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

log_fail() {
    echo -e "${RED}✗${NC} $1"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

log_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Test Android init.rc
test_init_rc() {
    log_test "Testing Android init.rc..."
    
    if [ ! -f "platform/nook-touch/init.rc" ]; then
        log_fail "init.rc not found"
        return 1
    fi
    
    # Check size (should be <5KB)
    SIZE=$(stat -c%s "platform/nook-touch/init.rc")
    if [ $SIZE -gt 5120 ]; then
        log_warn "init.rc exceeds 5KB target ($SIZE bytes)"
    else
        log_pass "init.rc size OK ($SIZE bytes)"
    fi
    
    # Check for critical services
    if grep -q "service omap-edpd" "platform/nook-touch/init.rc"; then
        log_pass "E-ink daemon service defined"
    else
        log_fail "E-ink daemon service missing"
    fi
    
    if grep -q "service jesteros-init" "platform/nook-touch/init.rc"; then
        log_pass "JesterOS init service defined"
    else
        log_fail "JesterOS init service missing"
    fi
    
    # Check for memory settings
    if grep -q "write /proc/sys/vm/" "platform/nook-touch/init.rc"; then
        log_pass "Memory tuning present"
    else
        log_warn "Memory tuning not configured"
    fi
}

# Test default.prop
test_default_prop() {
    log_test "Testing default.prop..."
    
    if [ ! -f "platform/nook-touch/default.prop" ]; then
        log_fail "default.prop not found"
        return 1
    fi
    
    # Check size (should be <2KB)
    SIZE=$(stat -c%s "platform/nook-touch/default.prop")
    if [ $SIZE -gt 2048 ]; then
        log_warn "default.prop exceeds 2KB target ($SIZE bytes)"
    else
        log_pass "default.prop size OK ($SIZE bytes)"
    fi
    
    # Check for JesterOS properties
    if grep -q "ro.jesteros.version" "platform/nook-touch/default.prop"; then
        log_pass "JesterOS version property present"
    else
        log_fail "JesterOS version property missing"
    fi
    
    if grep -q "ro.jesteros.memory.limit=95" "platform/nook-touch/default.prop"; then
        log_pass "Memory limit property correct"
    else
        log_fail "Memory limit property incorrect"
    fi
}

# Test ramdisk build script
test_ramdisk_script() {
    log_test "Testing ramdisk build script..."
    
    if [ ! -f "scripts/build-ramdisk.sh" ]; then
        log_fail "build-ramdisk.sh not found"
        return 1
    fi
    
    if [ ! -x "scripts/build-ramdisk.sh" ]; then
        log_fail "build-ramdisk.sh not executable"
    else
        log_pass "build-ramdisk.sh is executable"
    fi
    
    # Check for required tools
    if command -v mkimage >/dev/null 2>&1; then
        log_pass "mkimage tool available"
    else
        log_fail "mkimage tool not found (install u-boot-tools)"
    fi
    
    if command -v cpio >/dev/null 2>&1; then
        log_pass "cpio tool available"
    else
        log_fail "cpio tool not found"
    fi
}

# Test boot scripts
test_boot_scripts() {
    log_test "Testing boot scripts..."
    
    if [ ! -f "platform/nook-touch/boot/boot.cmd" ]; then
        log_fail "boot.cmd not found"
        return 1
    fi
    
    if [ -f "platform/nook-touch/boot/uEnv.txt" ]; then
        log_pass "uEnv.txt present"
        
        # Check for correct memory addresses
        if grep -q "loadaddr=0x80008000" "platform/nook-touch/boot/uEnv.txt"; then
            log_pass "Kernel load address correct"
        else
            log_fail "Kernel load address incorrect"
        fi
        
        if grep -q "rdaddr=0x81600000" "platform/nook-touch/boot/uEnv.txt"; then
            log_pass "Ramdisk load address correct"
        else
            log_fail "Ramdisk load address incorrect"
        fi
    else
        log_fail "uEnv.txt not found"
    fi
}

# Test JesterOS init script
test_jesteros_init() {
    log_test "Testing JesterOS init script..."
    
    if [ ! -f "src/init/jesteros-init.sh" ]; then
        log_fail "jesteros-init.sh not found"
        return 1
    fi
    
    # Check for safety settings
    if grep -q "set -eu" "src/init/jesteros-init.sh"; then
        log_pass "Safety settings present"
    else
        log_fail "Safety settings missing"
    fi
    
    # Check for filesystem setup
    if grep -q "setup_filesystem" "src/init/jesteros-init.sh"; then
        log_pass "Filesystem setup function present"
    else
        log_fail "Filesystem setup function missing"
    fi
    
    # Check for service startup
    if grep -q "start_services" "src/init/jesteros-init.sh"; then
        log_pass "Service startup function present"
    else
        log_fail "Service startup function missing"
    fi
}

# Test critical boot files
test_boot_files() {
    log_test "Testing critical boot files..."
    
    # Check bootloaders
    if [ -f "platform/nook-touch/boot/MLO" ]; then
        SIZE=$(stat -c%s "platform/nook-touch/boot/MLO")
        if [ $SIZE -eq 16004 ]; then
            log_pass "MLO present and correct size"
        else
            log_warn "MLO size unexpected ($SIZE bytes)"
        fi
    else
        log_fail "MLO bootloader missing"
    fi
    
    if [ -f "platform/nook-touch/boot/u-boot.bin" ]; then
        SIZE=$(stat -c%s "platform/nook-touch/boot/u-boot.bin")
        if [ $SIZE -eq 159040 ]; then
            log_pass "u-boot.bin present and correct size"
        else
            log_warn "u-boot.bin size unexpected ($SIZE bytes)"
        fi
    else
        log_fail "u-boot.bin bootloader missing"
    fi
    
    # Check Android init binary
    if [ -f "platform/nook-touch/android/init" ]; then
        SIZE=$(stat -c%s "platform/nook-touch/android/init")
        if [ $SIZE -eq 128000 ]; then
            log_pass "Android init binary present and correct size"
        else
            log_warn "Android init size unexpected ($SIZE bytes)"
        fi
    else
        log_fail "Android init binary missing"
    fi
}

# Test Makefile targets
test_makefile_targets() {
    log_test "Testing Makefile targets..."
    
    if grep -q "^ramdisk:" Makefile; then
        log_pass "ramdisk target present"
    else
        log_fail "ramdisk target missing"
    fi
    
    if grep -q "^boot-script:" Makefile; then
        log_pass "boot-script target present"
    else
        log_fail "boot-script target missing"
    fi
    
    if grep -q "^sd-image:" Makefile; then
        log_pass "sd-image target present"
    else
        log_fail "sd-image target missing"
    fi
}

# Main test execution
main() {
    echo "================================"
    echo "    JesterOS Boot Validation"
    echo "================================"
    echo ""
    
    test_init_rc
    test_default_prop
    test_ramdisk_script
    test_boot_scripts
    test_jesteros_init
    test_boot_files
    test_makefile_targets
    
    echo ""
    echo "================================"
    echo "    Test Results"
    echo "================================"
    echo -e "${GREEN}Passed:${NC} $TESTS_PASSED"
    echo -e "${RED}Failed:${NC} $TESTS_FAILED"
    
    if [ $TESTS_FAILED -gt 0 ]; then
        echo ""
        echo -e "${RED}Boot validation failed!${NC}"
        echo "Please fix the issues above before deployment."
        exit 1
    else
        echo ""
        echo -e "${GREEN}✓ Boot validation passed!${NC}"
        echo "JesterOS boot infrastructure is ready."
        exit 0
    fi
}

# Run tests
main "$@"