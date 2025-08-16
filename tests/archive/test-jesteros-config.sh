#!/bin/bash
# JesterOS Kconfig Integration Test Script
# Tests if JesterOS configuration is properly integrated with Linux 2.6.29

set -euo pipefail

echo "═══════════════════════════════════════════════════════════════"
echo "           JesterOS Kconfig Integration Test"
echo "═══════════════════════════════════════════════════════════════"

cd source/kernel/src

# Enable warnings for unknown symbols (2.6.29 feature)
export KCONFIG_WARN_UNKNOWN_SYMBOLS=1

echo "→ Phase 1: Testing Kconfig File Structure"
echo ""

# Test 1: Verify Kconfig files exist and are readable
echo "1. Checking Kconfig files..."
if [ -f "drivers/jesteros/Kconfig" ]; then
    echo "   ✓ drivers/jesteros/Kconfig exists"
    wc -l drivers/jesteros/Kconfig | awk '{print "   " $1 " lines"}'
else
    echo "   ❌ drivers/jesteros/Kconfig MISSING"
    exit 1
fi

# Test 2: Verify main Kconfig includes our file
echo ""
echo "2. Checking Kconfig integration..."
if grep -q "drivers/jesteros/Kconfig" drivers/Kconfig; then
    echo "   ✓ drivers/Kconfig includes jesteros/Kconfig"
    grep -n "jesteros" drivers/Kconfig
else
    echo "   ❌ drivers/Kconfig does NOT include jesteros/Kconfig"
    exit 1
fi

# Test 3: Validate Kconfig syntax basics
echo ""
echo "3. Checking Kconfig syntax..."
if grep -q "^menuconfig JESTEROS" drivers/jesteros/Kconfig; then
    echo "   ✓ Main JESTEROS menuconfig found"
else
    echo "   ❌ Main JESTEROS menuconfig MISSING"
    exit 1
fi

if grep -q "^config JESTEROS_" drivers/jesteros/Kconfig; then
    echo "   ✓ Sub-options found:"
    grep "^config JESTEROS_" drivers/jesteros/Kconfig | sed 's/^/     /'
else
    echo "   ❌ No JESTEROS sub-options found"
    exit 1
fi

echo ""
echo "→ Phase 2: Testing Build System Integration"
echo ""

# Test 4: Check Makefile integration
echo "4. Checking Makefile integration..."
if grep -q "CONFIG_JESTEROS" drivers/Makefile; then
    echo "   ✓ drivers/Makefile includes JESTEROS"
    grep -n "JESTEROS" drivers/Makefile
else
    echo "   ❌ drivers/Makefile missing JESTEROS"
    exit 1
fi

if [ -f "drivers/jesteros/Makefile" ]; then
    echo "   ✓ drivers/jesteros/Makefile exists"
    if grep -q "CONFIG_JESTEROS" drivers/jesteros/Makefile; then
        echo "   ✓ Module Makefile uses CONFIG_JESTEROS"
    else
        echo "   ❌ Module Makefile missing CONFIG_JESTEROS"
        exit 1
    fi
else
    echo "   ❌ drivers/jesteros/Makefile MISSING"
    exit 1
fi

echo ""
echo "→ Phase 3: Testing Kernel Configuration System"
echo ""

# Test 5: Create clean config
echo "5. Testing configuration system recognition..."
echo "   → Creating base config..."
make ARCH=arm omap3621_gossamer_evt1c_defconfig >/dev/null 2>&1

echo "   → Checking if JESTEROS is in allyesconfig..."
cp .config .config.base
make ARCH=arm allyesconfig >/dev/null 2>&1

if grep -q "CONFIG_JESTEROS" .config; then
    echo "   ✓ JESTEROS found in allyesconfig!"
    grep "JESTEROS" .config | head -5
    INTEGRATION_STATUS="SUCCESS"
else
    echo "   ❌ JESTEROS NOT found in allyesconfig"
    echo "   This means Kconfig integration is broken!"
    INTEGRATION_STATUS="FAILED"
fi

# Test 6: Manual config test
echo ""
echo "6. Testing manual configuration..."
cp .config.base .config
echo "   → Adding JESTEROS manually..."
cat >> .config << 'EOF'

# JesterOS Configuration Test
CONFIG_JESTEROS=m
CONFIG_JESTEROS_JESTER=y
CONFIG_JESTEROS_TYPEWRITER=y
CONFIG_JESTEROS_WISDOM=y
# CONFIG_JESTEROS_DEBUG is not set
EOF

echo "   ✓ Manual config added"

echo "   → Testing oldconfig processing..."
make ARCH=arm oldconfig >/dev/null 2>&1

if grep -q "CONFIG_JESTEROS" .config; then
    echo "   ✓ JESTEROS survived oldconfig!"
    grep "JESTEROS" .config
    OLDCONFIG_STATUS="SUCCESS"
else
    echo "   ❌ JESTEROS was REMOVED by oldconfig!"
    echo "   This confirms Kconfig integration is broken"
    OLDCONFIG_STATUS="FAILED"
fi

echo ""
echo "→ Phase 4: Source File Validation"
echo ""

# Test 7: Check source files
echo "7. Validating source files..."
MISSING_FILES=0
for file in jesteros_core.c jester.c typewriter.c wisdom.c; do
    if [ -f "drivers/jesteros/$file" ]; then
        echo "   ✓ $file exists"
        # Check for essential includes
        if grep -q "#include <linux/module.h>" "drivers/jesteros/$file"; then
            echo "     ✓ Has linux/module.h include"
        else
            echo "     ⚠️  Missing linux/module.h include"
        fi
    else
        echo "   ❌ $file MISSING"
        MISSING_FILES=$((MISSING_FILES + 1))
    fi
done

if [ $MISSING_FILES -eq 0 ]; then
    SOURCE_STATUS="SUCCESS"
else
    SOURCE_STATUS="FAILED"
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "                      TEST RESULTS"
echo "═══════════════════════════════════════════════════════════════"

echo "Kconfig Integration: $INTEGRATION_STATUS"
echo "Oldconfig Test:      $OLDCONFIG_STATUS" 
echo "Source Files:        $SOURCE_STATUS"

if [ "$INTEGRATION_STATUS" = "SUCCESS" ] && [ "$OLDCONFIG_STATUS" = "SUCCESS" ] && [ "$SOURCE_STATUS" = "SUCCESS" ]; then
    echo ""
    echo "🎉 ALL TESTS PASSED - JesterOS should build successfully!"
    echo ""
    echo "Next steps:"
    echo "  1. Run ./build_kernel.sh"
    echo "  2. Check for jesteros.ko in build output"
    echo "  3. Test module loading on device"
    exit 0
else
    echo ""
    echo "❌ TESTS FAILED - Issues found in JesterOS integration"
    echo ""
    echo "Likely causes:"
    if [ "$INTEGRATION_STATUS" = "FAILED" ]; then
        echo "  • Kconfig file not properly sourced by main kernel config"
        echo "  • Kconfig syntax errors preventing symbol recognition"
        echo "  • Missing dependencies in Kconfig definitions"
    fi
    
    if [ "$OLDCONFIG_STATUS" = "FAILED" ]; then
        echo "  • Configuration symbols not recognized by kconfig system"
        echo "  • Kconfig file not being processed during config resolution"
    fi
    
    if [ "$SOURCE_STATUS" = "FAILED" ]; then
        echo "  • Missing source files will prevent module compilation"
    fi
    
    echo ""
    echo "Debug steps:"
    echo "  1. Check Kconfig syntax with: make menuconfig (search for JESTEROS)"  
    echo "  2. Verify Kconfig integration chain"
    echo "  3. Test module compilation directly: make M=drivers/jesteros"
    exit 1
fi