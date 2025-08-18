#!/bin/bash
# Test script for bootloader setup and SD card creation requirements
# Validates that all components are present and correctly configured

set -euo pipefail

# Source test framework if available
if [ -f "$(dirname "${BASH_SOURCE[0]}")/test-framework.sh" ]; then
    source "$(dirname "${BASH_SOURCE[0]}")/test-framework.sh"
else
    # Define minimal functions if framework not available
    init_test() { echo "Testing: $1"; }
    pass_test() { echo "PASS: $1"; exit 0; }
    fail_test() { echo "FAIL: $1"; exit 1; }
fi

# Initialize test
init_test "Bootloader and SD Card Setup"

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FIRMWARE_DIR="${PROJECT_ROOT}/firmware/boot"
IMAGES_DIR="${PROJECT_ROOT}/images"

# Test results
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
RESET='\033[0m'

echo "═══════════════════════════════════════════════════════════════"
echo "       Bootloader and SD Card Setup Test Suite"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Test 1: Check for ClockworkMod base image
test_cwm_image() {
    echo "Test 1: ClockworkMod Base Image"
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if [ -f "${IMAGES_DIR}/2gb_clockwork-rc2.img" ]; then
        echo -e "  ${GREEN}✓ ClockworkMod image found${RESET}"
        size=$(ls -lh "${IMAGES_DIR}/2gb_clockwork-rc2.img" | awk '{print $5}')
        echo "    Size: $size"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "  ${RED}✗ ClockworkMod image not found${RESET}"
        echo "    Expected: ${IMAGES_DIR}/2gb_clockwork-rc2.img"
        echo "    Download from XDA Forums Project Phoenix"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Test 2: Check for extraction script
test_extraction_script() {
    echo "Test 2: Bootloader Extraction Script"
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if [ -f "${PROJECT_ROOT}/build/scripts/extract-bootloaders.sh" ]; then
        if [ -x "${PROJECT_ROOT}/build/scripts/extract-bootloaders.sh" ]; then
            echo -e "  ${GREEN}✓ Extraction script found and executable${RESET}"
            TESTS_PASSED=$((TESTS_PASSED + 1))
        else
            echo -e "  ${YELLOW}⚠ Extraction script found but not executable${RESET}"
            echo "    Run: chmod +x build/scripts/extract-bootloaders.sh"
            TESTS_FAILED=$((TESTS_FAILED + 1))
        fi
    else
        echo -e "  ${RED}✗ Extraction script not found${RESET}"
        echo "    Expected: build/scripts/extract-bootloaders.sh"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Test 3: Check for bootloader files
test_bootloader_files() {
    echo "Test 3: Bootloader Files (MLO and U-Boot)"
    TESTS_RUN=$((TESTS_RUN + 1))
    
    local mlo_found=false
    local uboot_found=false
    
    if [ -f "${FIRMWARE_DIR}/MLO" ]; then
        echo -e "  ${GREEN}✓ MLO found${RESET}"
        size=$(ls -lh "${FIRMWARE_DIR}/MLO" | awk '{print $5}')
        echo "    Size: $size"
        mlo_found=true
    else
        echo -e "  ${RED}✗ MLO not found${RESET}"
        echo "    Run: make bootloaders"
    fi
    
    if [ -f "${FIRMWARE_DIR}/u-boot.bin" ]; then
        echo -e "  ${GREEN}✓ u-boot.bin found${RESET}"
        size=$(ls -lh "${FIRMWARE_DIR}/u-boot.bin" | awk '{print $5}')
        echo "    Size: $size"
        uboot_found=true
    else
        echo -e "  ${RED}✗ u-boot.bin not found${RESET}"
        echo "    Run: make bootloaders"
    fi
    
    if $mlo_found && $uboot_found; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Test 4: Check for kernel image
test_kernel_image() {
    echo "Test 4: Kernel Image (uImage)"
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if [ -f "${FIRMWARE_DIR}/uImage" ]; then
        echo -e "  ${GREEN}✓ Kernel image found${RESET}"
        size=$(ls -lh "${FIRMWARE_DIR}/uImage" | awk '{print $5}')
        echo "    Size: $size"
        
        # Check if it's a valid uImage
        if file "${FIRMWARE_DIR}/uImage" | grep -q "u-boot legacy uImage"; then
            echo -e "  ${GREEN}✓ Valid U-Boot image format${RESET}"
            TESTS_PASSED=$((TESTS_PASSED + 1))
        else
            echo -e "  ${YELLOW}⚠ File exists but may not be valid uImage${RESET}"
            TESTS_FAILED=$((TESTS_FAILED + 1))
        fi
    else
        echo -e "  ${RED}✗ Kernel image not found${RESET}"
        echo "    Run: make kernel"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Test 5: Check for boot scripts
test_boot_scripts() {
    echo "Test 5: Boot Scripts"
    TESTS_RUN=$((TESTS_RUN + 1))
    
    local script_found=false
    
    for script in boot.scr u-boot.scr boot.scr.uimg boot.cmd; do
        if [ -f "${FIRMWARE_DIR}/$script" ]; then
            echo -e "  ${GREEN}✓ Found $script${RESET}"
            script_found=true
        fi
    done
    
    if $script_found; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "  ${YELLOW}⚠ No boot scripts found${RESET}"
        echo "    Run: make boot-script"
        echo "    Note: Boot scripts are optional but recommended"
        TESTS_SKIPPED=$((TESTS_SKIPPED + 1))
    fi
}

# Test 6: Check for mkimage tool
test_mkimage_tool() {
    echo "Test 6: mkimage Tool (for boot script compilation)"
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if command -v mkimage >/dev/null 2>&1; then
        echo -e "  ${GREEN}✓ mkimage found${RESET}"
        version=$(mkimage -V 2>&1 | head -1)
        echo "    Version: $version"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "  ${YELLOW}⚠ mkimage not found${RESET}"
        echo "    Install with: sudo apt-get install u-boot-tools"
        echo "    Note: Optional but needed for boot script compilation"
        TESTS_SKIPPED=$((TESTS_SKIPPED + 1))
    fi
}

# Test 7: Check deployment script
test_deployment_script() {
    echo "Test 7: SD Card Deployment Script"
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if [ -f "${PROJECT_ROOT}/deploy-to-sd.sh" ]; then
        # Check if it has the new validation logic
        if grep -q "MLO_FILE=" "${PROJECT_ROOT}/deploy-to-sd.sh"; then
            echo -e "  ${GREEN}✓ Deployment script updated with bootloader support${RESET}"
            TESTS_PASSED=$((TESTS_PASSED + 1))
        else
            echo -e "  ${YELLOW}⚠ Deployment script found but may need updates${RESET}"
            TESTS_FAILED=$((TESTS_FAILED + 1))
        fi
    else
        echo -e "  ${RED}✗ Deployment script not found${RESET}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Test 8: Check Makefile targets
test_makefile_targets() {
    echo "Test 8: Makefile Bootloader Targets"
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if [ -f "${PROJECT_ROOT}/Makefile" ]; then
        local targets_found=0
        
        if grep -q "^bootloaders:" "${PROJECT_ROOT}/Makefile"; then
            echo -e "  ${GREEN}✓ 'bootloaders' target found${RESET}"
            targets_found=$((targets_found + 1))
        fi
        
        if grep -q "^boot-script:" "${PROJECT_ROOT}/Makefile"; then
            echo -e "  ${GREEN}✓ 'boot-script' target found${RESET}"
            targets_found=$((targets_found + 1))
        fi
        
        if [ $targets_found -eq 2 ]; then
            TESTS_PASSED=$((TESTS_PASSED + 1))
        else
            echo -e "  ${YELLOW}⚠ Some Makefile targets missing${RESET}"
            TESTS_FAILED=$((TESTS_FAILED + 1))
        fi
    else
        echo -e "  ${RED}✗ Makefile not found${RESET}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Test 9: Verify complete firmware build
test_complete_firmware() {
    echo "Test 9: Complete Firmware Package"
    TESTS_RUN=$((TESTS_RUN + 1))
    
    local all_present=true
    local required_files=(
        "${FIRMWARE_DIR}/MLO"
        "${FIRMWARE_DIR}/u-boot.bin"
        "${FIRMWARE_DIR}/uImage"
    )
    
    for file in "${required_files[@]}"; do
        if [ ! -f "$file" ]; then
            all_present=false
            break
        fi
    done
    
    if $all_present; then
        echo -e "  ${GREEN}✓ All required firmware components present${RESET}"
        echo "    Ready for SD card creation!"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "  ${YELLOW}⚠ Some firmware components missing${RESET}"
        echo "    Run: make firmware"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Run all tests
echo "Running tests..."
echo ""

test_cwm_image
echo ""
test_extraction_script
echo ""
test_bootloader_files
echo ""
test_kernel_image
echo ""
test_boot_scripts
echo ""
test_mkimage_tool
echo ""
test_deployment_script
echo ""
test_makefile_targets
echo ""
test_complete_firmware
echo ""

# Summary
echo "═══════════════════════════════════════════════════════════════"
echo "                        TEST SUMMARY"
echo "═══════════════════════════════════════════════════════════════"
echo "Tests Run:     $TESTS_RUN"
echo -e "Tests Passed:  ${GREEN}$TESTS_PASSED${RESET}"
echo -e "Tests Failed:  ${RED}$TESTS_FAILED${RESET}"
echo -e "Tests Skipped: ${YELLOW}$TESTS_SKIPPED${RESET}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ ALL CRITICAL TESTS PASSED!${RESET}"
    echo "Your build environment is ready for SD card creation."
    echo ""
    echo "Next steps:"
    echo "1. Run 'make firmware' to build everything"
    echo "2. Run './deploy-to-sd.sh /dev/sdX' to create SD card"
    pass_test "Bootloader setup complete"
else
    echo -e "${RED}❌ SOME TESTS FAILED${RESET}"
    echo "Please address the issues above before creating SD cards."
    echo ""
    echo "Quick fix:"
    echo "  make firmware  # This will extract bootloaders and build kernel"
    fail_test "$TESTS_FAILED tests failed"
fi