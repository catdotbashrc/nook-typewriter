#!/bin/bash
# Boot Sequence Validation Test
# Validates the direct kernel boot configuration and sector 63 alignment

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "*** Boot Sequence Validation ***"
echo "================================"
echo ""
echo "Validating boot configuration for direct kernel boot..."
echo ""

# Track results
PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0

# Test functions
test_pass() {
    echo "  [PASS] $1"
    PASS_COUNT=$((PASS_COUNT + 1))
}

test_fail() {
    echo "  [FAIL] $1"
    FAIL_COUNT=$((FAIL_COUNT + 1))
}

test_warn() {
    echo "  [WARN] $1"
    WARN_COUNT=$((WARN_COUNT + 1))
}

# 1. Check kernel image
echo "-> Checking kernel image..."
KERNEL_IMAGE="$PROJECT_ROOT/firmware/boot/uImage"
if [ -f "$KERNEL_IMAGE" ]; then
    # Check size is reasonable (1-8MB typical for embedded)
    KERNEL_SIZE=$(stat -c%s "$KERNEL_IMAGE" 2>/dev/null || stat -f%z "$KERNEL_IMAGE" 2>/dev/null || echo "0")
    KERNEL_SIZE_MB=$((KERNEL_SIZE / 1048576))
    
    if [ "$KERNEL_SIZE" -gt 1048576 ] && [ "$KERNEL_SIZE" -lt 8388608 ]; then
        test_pass "Kernel size reasonable: ${KERNEL_SIZE_MB}MB"
    else
        test_warn "Kernel size unusual: ${KERNEL_SIZE_MB}MB"
    fi
    
    # Check it's a valid uImage
    if file "$KERNEL_IMAGE" | grep -q "u-boot\|uImage"; then
        test_pass "Valid U-Boot kernel image"
    else
        test_warn "May not be valid uImage format"
    fi
else
    test_warn "Kernel image not built yet"
fi
echo ""

# 2. Check for initrd/initramfs (should NOT exist)
echo "-> Checking for initrd absence..."
INITRD_FILES=(
    "$PROJECT_ROOT/firmware/boot/initrd"
    "$PROJECT_ROOT/firmware/boot/initramfs"
    "$PROJECT_ROOT/firmware/boot/ramdisk"
)

INITRD_FOUND=false
for initrd in "${INITRD_FILES[@]}"; do
    if [ -f "$initrd" ]; then
        test_fail "Found initrd: $(basename "$initrd") (should not exist)"
        INITRD_FOUND=true
    fi
done

if [ "$INITRD_FOUND" = false ]; then
    test_pass "No initrd/initramfs (direct boot configuration)"
fi
echo ""

# 3. Check boot configuration
echo "-> Checking boot configuration..."
BOOT_CONFIG="$PROJECT_ROOT/boot/uEnv.txt"
if [ -f "$BOOT_CONFIG" ]; then
    # Check for direct root= parameter
    if grep -q "root=/dev/mmcblk" "$BOOT_CONFIG"; then
        test_pass "Direct root device specified"
    else
        test_fail "No root device in boot config"
    fi
    
    # Check for no initrd references
    if grep -q "initrd\|initramfs\|ramdisk" "$BOOT_CONFIG"; then
        test_fail "Boot config references initrd (should not)"
    else
        test_pass "No initrd references in boot config"
    fi
    
    # Check for rootwait (important for SD card)
    if grep -q "rootwait" "$BOOT_CONFIG"; then
        test_pass "rootwait parameter present (SD card support)"
    else
        test_warn "Missing rootwait parameter"
    fi
else
    test_warn "Boot configuration not found"
fi
echo ""

# 4. Check sector 63 alignment configuration
echo "-> Checking sector 63 alignment..."
# Look for scripts that handle SD card partitioning
SD_SCRIPTS=(
    "$PROJECT_ROOT/create-boot-from-scratch.sh"
    "$PROJECT_ROOT/scripts/deployment/create-sd-image.sh"
)

SECTOR_63_FOUND=false
for script in "${SD_SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        if grep -q "sector.*63\|start=63\|offset.*63" "$script"; then
            test_pass "Sector 63 alignment in $(basename "$script")"
            SECTOR_63_FOUND=true
        fi
    fi
done

if [ "$SECTOR_63_FOUND" = false ]; then
    test_warn "No explicit sector 63 alignment found"
    echo "    Note: Nook requires partition start at sector 63"
fi
echo ""

# 5. Check boot scripts
echo "-> Checking boot scripts..."
BOOT_SCRIPTS=(
    "source/scripts/boot/boot-jester.sh"
    "source/scripts/boot/boot-with-jester.sh"
)

for script_path in "${BOOT_SCRIPTS[@]}"; do
    if [ -f "$PROJECT_ROOT/$script_path" ]; then
        # Check for proper error handling
        if grep -q "set -.*e" "$PROJECT_ROOT/$script_path"; then
            test_pass "$(basename "$script_path") has error handling"
        else
            test_warn "$(basename "$script_path") missing error handling"
        fi
        
        # Check for JesterOS loading
        if grep -q "jesteros" "$PROJECT_ROOT/$script_path"; then
            test_pass "$(basename "$script_path") loads JesterOS"
        else
            test_warn "$(basename "$script_path") doesn't load JesterOS"
        fi
    else
        test_warn "Boot script not found: $script_path"
    fi
done
echo ""

# 6. Check for boot loop prevention
echo "-> Checking boot loop prevention..."
BOOT_LOOP_DOC="$PROJECT_ROOT/docs/BOOT_LOOP_FIX.md"
if [ -f "$BOOT_LOOP_DOC" ]; then
    test_pass "Boot loop fix documentation exists"
else
    test_warn "No boot loop documentation found"
fi

# Check for watchdog or timeout in boot scripts
if grep -r "timeout\|watchdog\|sleep" "$PROJECT_ROOT/source/scripts/boot" >/dev/null 2>&1; then
    test_pass "Boot scripts have timeout/watchdog mechanisms"
else
    test_warn "No timeout mechanisms in boot scripts"
fi
echo ""

# 7. Check rootfs requirements
echo "-> Checking rootfs requirements..."
ROOTFS_ARCHIVE="$PROJECT_ROOT/nook-mvp-rootfs.tar.gz"
if [ -f "$ROOTFS_ARCHIVE" ]; then
    ROOTFS_SIZE=$(stat -c%s "$ROOTFS_ARCHIVE" 2>/dev/null || stat -f%z "$ROOTFS_ARCHIVE" 2>/dev/null || echo "0")
    ROOTFS_SIZE_MB=$((ROOTFS_SIZE / 1048576))
    
    if [ "$ROOTFS_SIZE_MB" -lt 100 ]; then
        test_pass "Rootfs size efficient: ${ROOTFS_SIZE_MB}MB"
    else
        test_warn "Rootfs may be too large: ${ROOTFS_SIZE_MB}MB"
    fi
else
    test_warn "Rootfs archive not found"
fi
echo ""

# Final assessment
echo "*** Boot Sequence Assessment ***"
echo "================================"
echo "Passed: $PASS_COUNT"
echo "Failed: $FAIL_COUNT"
echo "Warnings: $WARN_COUNT"
echo ""

if [ "$FAIL_COUNT" -eq 0 ]; then
    if [ "$WARN_COUNT" -le 3 ]; then
        echo "✅ Boot sequence validated!"
        echo ""
        echo "The Boot Master declares:"
        echo "  'Thy boot sequence is prepared for battle!'"
        echo "  'Direct kernel boot shall prevail!'"
    else
        echo "⚠️  Boot sequence has warnings"
        echo ""
        echo "The Boot Master cautions:"
        echo "  'Some concerns remain, but boot may proceed'"
    fi
    exit 0
else
    echo "❌ Boot sequence validation failed!"
    echo ""
    echo "The Boot Master forbids:"
    echo "  'This boot configuration shall not pass!'"
    echo "  'Fix these issues before deployment!'"
    exit 1
fi