#!/bin/bash
# QuillKernel Build Verification Script - Simplified Version
# Ensures our medieval modifications don't break the build

echo "═══════════════════════════════════════════════════════════════"
echo "         QuillKernel Build Verification (Simple)"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Test results
TESTS_PASSED=0
TESTS_FAILED=0
WARNINGS=0

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo -n "Testing $test_name... "
    if eval "$test_command" > /dev/null 2>&1; then
        echo "[PASSED]"
        ((TESTS_PASSED++))
        return 0
    else
        echo "[FAILED]"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Function to check file exists
check_file() {
    local file="$1"
    local description="$2"
    run_test "$description" "[ -f '$file' ]"
}

echo ""
echo "1. Checking Source Files"
echo "------------------------"

# Check main kernel files
check_file "../src/Makefile" "Main Makefile exists"
check_file "../src/include/linux/squireos.h" "SquireOS header exists"
check_file "../arch/arm/configs/quill_typewriter_defconfig" "QuillKernel config exists"

echo ""
echo "2. Checking Medieval Modifications"
echo "----------------------------------"

# Check if patches were applied
echo -n "Checking Makefile for QuillKernel branding... "
if grep -q "Derpy Court Jester" ../src/Makefile 2>/dev/null; then
    echo "[PASSED]"
    ((TESTS_PASSED++))
else
    echo "[FAILED]"
    ((TESTS_FAILED++))
fi

echo -n "Checking for medieval boot messages... "
if [ -f ../src/arch/arm/mach-omap2/board-omap3621_gossamer-squire.c ]; then
    echo "[PASSED]"
    ((TESTS_PASSED++))
else
    echo "[FAILED]"
    ((TESTS_FAILED++))
fi

echo ""
echo "3. Checking Configuration"
echo "------------------------"

echo -n "Checking for E-Ink driver support... "
if [ -f ../arch/arm/configs/quill_typewriter_defconfig ] && grep -q "CONFIG_FB_OMAP3EP=y" ../arch/arm/configs/quill_typewriter_defconfig 2>/dev/null; then
    echo "[PASSED]"
    ((TESTS_PASSED++))
else
    echo "[FAILED]"
    ((TESTS_FAILED++))
fi

echo -n "Checking for USB host support... "
if [ -f ../arch/arm/configs/quill_typewriter_defconfig ] && grep -q "CONFIG_USB_MUSB_OTG=y" ../arch/arm/configs/quill_typewriter_defconfig 2>/dev/null; then
    echo "[PASSED]"
    ((TESTS_PASSED++))
else
    echo "[FAILED]"
    ((TESTS_FAILED++))
fi

echo ""
echo "4. Checking Build Environment"
echo "----------------------------"

echo -n "Checking for cross-compiler... "
if command -v arm-linux-gnueabi-gcc > /dev/null 2>&1 || command -v arm-none-linux-gnueabi-gcc > /dev/null 2>&1; then
    echo "[PASSED]"
    ((TESTS_PASSED++))
else
    echo "[WARNING] - Cross-compiler not found in PATH"
    ((WARNINGS++))
fi

echo -n "Checking kernel source permissions... "
if [ -w ../src/Makefile ]; then
    echo "[PASSED]"
    ((TESTS_PASSED++))
else
    echo "[FAILED]"
    ((TESTS_FAILED++))
fi

echo ""
echo "5. Checking for Potential Issues"
echo "--------------------------------"

echo -n "Checking for Unicode in critical files... "
if grep -r "♦" ../src/arch/arm/mach-omap2/ 2>/dev/null | grep -v ".txt" > /dev/null; then
    echo "[WARNING] - Unicode found in boot files"
    ((WARNINGS++))
else
    echo "[PASSED]"
    ((TESTS_PASSED++))
fi

echo -n "Checking for excessive boot delays... "
if grep -r "mdelay(3000)" ../src/ 2>/dev/null | grep -v ".txt" > /dev/null; then
    echo "[WARNING] - Long delays found"
    ((WARNINGS++))
else
    echo "[PASSED]"
    ((TESTS_PASSED++))
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "                    Test Summary"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "Tests Passed: $TESTS_PASSED"
echo "Tests Failed: $TESTS_FAILED"
echo "Warnings: $WARNINGS"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo "     .~\"~.~\"~."
    echo "    /  ^   ^  \\    All tests passed!"
    echo "   |  >  ◡  <  |   The kernel is ready to build."
    echo "    \\  ___  /      "
    echo "     |~|♦|~|       "
    echo ""
    echo "Next steps:"
    echo "1. cd ../src"
    echo "2. make quill_typewriter_defconfig"
    echo "3. make uImage"
    exit 0
else
    echo "     .~!!!~."
    echo "    / O   O \\    $TESTS_FAILED tests failed!"
    echo "   |  >   <  |   Fix the issues above."
    echo "    \\  ~~~  /    "
    echo "     |~|♦|~|     "
    exit 1
fi