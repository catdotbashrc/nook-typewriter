#!/bin/bash
# Safety check - Make sure we won't brick the Nook
# This MUST pass before deploying to hardware!
#
# Usage: ./01-safety-check.sh
# Returns: 0 if safe, 1 if dangerous
# Critical: Run before ANY hardware deployment

set -euo pipefail

# Load test library for consistent functions
source "$(dirname "$0")/test-lib.sh" 2>/dev/null || {
    echo "Error: test-lib.sh not found"
    exit 1
}

# Initialize test
init_test "🛡️ SAFETY CHECK" "Don't brick the device!"

# Check 1: Kernel exists (prevents unbootable device)
info "Checking for kernel image..."
if check_file "../firmware/boot/uImage" "Kernel image" || 
   check_file "../source/kernel/src/arch/arm/boot/uImage" "Kernel (source)" || 
   check_file "../source/kernel/build/uImage" "Kernel (build)" ||
   check_file "../deployment_package/boot/uImage" "Kernel (deployment)"; then
    pass "Kernel image exists"
else
    fail "Kernel image missing - Build kernel first!"
fi

# Check 2: No dangerous device references (prevents data loss)
info "Checking for dangerous device references..."
if grep -r "/dev/sda" ../source/scripts 2>/dev/null | grep -v "sda-sdd" | grep -v "#" | grep -q .; then
    fail "DANGER! Found /dev/sda references!"
    grep -r "/dev/sda" ../source/scripts 2>/dev/null | grep -v "sda-sdd" | grep -v "#" | head -5
else
    pass "No dangerous /dev/sda references"
fi

# Check 3: SD card protection in Makefile (prevents wrong device)
info "Checking SD card protection..."
if grep -q "sda-sdd" ../Makefile 2>/dev/null; then
    pass "SD card protection enabled"
else
    warn "SD card protection not found - Be careful with device selection!"
fi

# Check 4: Build system exists (ensures complete deployment)
info "Checking build system..."
if check_file "../Makefile" "Makefile" && check_file "../build/scripts/build_kernel.sh" "Build script"; then
    pass "Build system ready"
else
    fail "Build system incomplete - Missing critical files!"
fi

# Final safety verdict
echo ""
if summarize_test; then
    info "Device should not brick if you:"
    info "  1. Use SD card (not internal storage)"
    info "  2. Double-check the device name"
    info "  3. Follow deployment checklist"
    exit $TEST_SUCCESS
else
    echo ""
    fail "Safety check failed - DO NOT DEPLOY TO HARDWARE!"
    exit $TEST_FAILURE
fi