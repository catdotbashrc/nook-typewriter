#!/bin/bash
# QuillKernel Build Verification Script
# Ensures our medieval modifications don't break the build

set -e

echo "═══════════════════════════════════════════════════════════════"
echo "         QuillKernel Build Verification"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "     .~\"~.~\"~."
echo "    /  o   o  \\    Testing thy kernel build..."
echo "   |  >  ◡  <  |   "
echo "    \\  ___  /      "
echo "     |~|♦|~|       "
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test results
TESTS_PASSED=0
TESTS_FAILED=0

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo -n "Testing $test_name... "
    if eval "$test_command" > /dev/null 2>&1; then
        echo -e "${GREEN}[PASSED]${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}[FAILED]${NC}"
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

# Function to check configuration option
check_config() {
    local config="$1"
    local expected="$2"
    local description="$3"
    
    if [ -f .config ]; then
        run_test "$description" "grep -q '^$config=$expected' .config"
    else
        echo -e "${YELLOW}[SKIP]${NC} $description - .config not found"
    fi
}

# Change to kernel source directory
cd "$(dirname "$0")/../src" || exit 1

echo ""
echo "1. Checking Source Files"
echo "------------------------"
check_file "Makefile" "Main Makefile exists"
check_file "include/linux/squireos.h" "SquireOS header exists"
check_file "arch/arm/mach-omap2/board-omap3621_gossamer-squire.c" "Board customizations exist"
check_file "drivers/squireos/typewriter.c" "Typewriter module exists"
check_file "drivers/squireos/Makefile" "SquireOS driver Makefile exists"

echo ""
echo "2. Checking Patches Applied"
echo "---------------------------"
run_test "Kernel name changed" "grep -q 'Derpy Court Jester' Makefile"
run_test "Version string updated" "grep -q 'quill-scribe' Makefile"
run_test "SquireOS header included" "grep -q 'SQUIREOS_VERSION' include/linux/squireos.h"

echo ""
echo "3. Checking Configuration"
echo "-------------------------"
check_file "arch/arm/configs/quill_typewriter_defconfig" "QuillKernel config exists"

# If config exists, check critical options
if [ -f arch/arm/configs/quill_typewriter_defconfig ]; then
    echo ""
    echo "4. Validating Critical E-Reader Options"
    echo "---------------------------------------"
    
    # Create temporary config to check
    cp arch/arm/configs/quill_typewriter_defconfig .config.test
    
    # Check using the test config
    run_test "E-Ink framebuffer enabled" "grep -q 'CONFIG_FB_OMAP3EP=y' .config.test"
    run_test "USB host support enabled" "grep -q 'CONFIG_USB_MUSB_HDRC=y' .config.test"
    run_test "Power management enabled" "grep -q 'CONFIG_PM=y' .config.test"
    run_test "Battery driver enabled" "grep -q 'CONFIG_BATTERY_BQ27x00=y' .config.test"
    run_test "F2FS filesystem enabled" "grep -q 'CONFIG_F2FS_FS=y' .config.test"
    run_test "SquireOS branding enabled" "grep -q 'CONFIG_SQUIREOS_BRANDING=y' .config.test"
    run_test "QuillMode enabled" "grep -q 'CONFIG_QUILL_MODE=y' .config.test"
    
    rm -f .config.test
fi

echo ""
echo "5. Build Environment Check"
echo "--------------------------"
run_test "Cross compiler accessible" "which arm-linux-androideabi-gcc || which \$CROSS_COMPILE"
run_test "Build directory writable" "touch test.tmp && rm -f test.tmp"

echo ""
echo "6. Checking for Potential Issues"
echo "---------------------------------"

# Check for risky delays
if grep -q "mdelay" arch/arm/mach-omap2/board-omap3621_gossamer-squire.c; then
    echo -e "${YELLOW}[WARNING]${NC} Boot delays found - may increase boot time"
fi

# Check for Unicode in kernel files
if grep -q "[♦◡]" arch/arm/mach-omap2/board-omap3621_gossamer-squire.c; then
    echo -e "${YELLOW}[WARNING]${NC} Unicode characters in kernel - test on actual hardware"
fi

# Check module dependencies
if ! grep -q "depends on SQUIREOS_BRANDING" drivers/squireos/Kconfig 2>/dev/null; then
    echo -e "${YELLOW}[WARNING]${NC} Module dependencies might not be properly configured"
fi

echo ""
echo "7. Dry Run Build Test"
echo "---------------------"
echo "Running make dry-run to check for obvious errors..."

if make -n uImage > /dev/null 2>&1; then
    echo -e "${GREEN}[PASSED]${NC} Make dry-run successful"
    ((TESTS_PASSED++))
else
    echo -e "${RED}[FAILED]${NC} Make dry-run failed"
    ((TESTS_FAILED++))
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "                    Test Results"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "Tests Passed: $TESTS_PASSED"
echo "Tests Failed: $TESTS_FAILED"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC} The kernel is ready to build."
    echo ""
    echo "     .~\"~.~\"~."
    echo "    /  ^   ^  \\    Huzzah! Ready to compile!"
    echo "   |  >  ◡  <  |   Run ./build-kernel.sh"
    echo "    \\  ___  /      "
    echo "     |~|♦|~|       "
    exit 0
else
    echo -e "${RED}Some tests failed!${NC} Please fix issues before building."
    echo ""
    echo "     .~!!!~."
    echo "    / O   O \\    The jester is concerned!"
    echo "   |  >   <  |   Fix the issues above."
    echo "    \\  ~~~  /    "
    echo "     |~|♦|~|     "
    exit 1
fi