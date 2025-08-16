#!/bin/bash
# Safety check - Make sure we won't brick the Nook
# This MUST pass before deploying to hardware!

set -euo pipefail

echo "🛡️  SAFETY CHECK - Don't brick the device!"
echo "=========================================="
echo ""

SAFE=true

# Check 1: Kernel exists
echo -n "✓ Kernel image exists... "
if [ -f "../firmware/boot/uImage" ] || 
   [ -f "../source/kernel/src/arch/arm/boot/uImage" ] || 
   [ -f "../source/kernel/build/uImage" ] ||
   [ -f "../deployment_package/boot/uImage" ]; then
    echo "YES"
else
    echo "NO - Build kernel first!"
    SAFE=false
fi

# Check 2: No dangerous device references
echo -n "✓ No /dev/sda references... "
if grep -r "/dev/sda" ../source/scripts 2>/dev/null | grep -v "sda-sdd" | grep -v "#" | grep -q .; then
    echo "DANGER! Found /dev/sda references!"
    SAFE=false
else
    echo "SAFE"
fi

# Check 3: SD card protection in Makefile
echo -n "✓ SD card protection enabled... "
if grep -q "sda-sdd" ../Makefile 2>/dev/null; then
    echo "YES"
else
    echo "WARNING - Be careful with SD device!"
fi

# Check 4: Build system exists
echo -n "✓ Build system ready... "
if [ -f "../Makefile" ] && [ -f "../build/scripts/build_kernel.sh" ]; then
    echo "YES"
else
    echo "NO - Missing build files!"
    SAFE=false
fi

echo ""
if [ "$SAFE" = true ]; then
    echo "✅ SAFE TO PROCEED"
    echo "Device should not brick if you:"
    echo "  1. Use SD card (not internal storage)"
    echo "  2. Double-check the device name"
    exit 0
else
    echo "❌ NOT SAFE - FIX ISSUES FIRST!"
    exit 1
fi