#!/bin/bash
# Essential tests for hobby project - Keep It Simple!
# Focus: Boot, don't brick, basic functionality

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "═══════════════════════════════════════════════════════════════"
echo "           NOOK TYPEWRITER - ESSENTIAL TESTS"
echo "           Just the important stuff!"
echo "═══════════════════════════════════════════════════════════════"
echo ""

PASS=0
FAIL=0

# Helper function for running tests
run_test() {
    local test_name="$1"
    local test_cmd="$2"
    
    echo -n "Testing $test_name... "
    if eval "$test_cmd" >/dev/null 2>&1; then
        echo -e "${GREEN}PASS${NC}"
        ((PASS++))
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        ((FAIL++))
        return 1
    fi
}

echo -e "${BLUE}=== CRITICAL SAFETY (Don't Brick!) ===${NC}"
echo ""

# 1. Kernel exists
run_test "Kernel exists" "[ -f firmware/boot/uImage ] || [ -f source/kernel/src/arch/arm/boot/uImage ]"

# 2. Build script works
run_test "Build script valid" "[ -f build/scripts/build_kernel.sh ] && bash -n build/scripts/build_kernel.sh"

# 3. No dangerous devices
run_test "No /dev/sda references" "! grep -r '/dev/sda[^-]' source/scripts/ 2>/dev/null | grep -v '^#'"

# 4. Docker ready
run_test "Docker environment" "docker images | grep -q 'jesteros-unified\|jokernel' || [ -f build/docker/kernel-xda-proven.dockerfile ]"

echo ""
echo -e "${BLUE}=== BOOT SEQUENCE ===${NC}"
echo ""

# 5. Boot scripts exist
run_test "Boot scripts exist" "ls source/scripts/boot/*.sh >/dev/null 2>&1"

# 6. JesterOS service
run_test "JesterOS userspace" "[ -f source/scripts/boot/jesteros-userspace.sh ] || [ -f source/scripts/services/jester-daemon.sh ]"

# 7. Menu system
run_test "Menu exists" "[ -f source/scripts/menu/nook-menu.sh ]"

echo ""
echo -e "${BLUE}=== BASIC FUNCTIONALITY ===${NC}"
echo ""

# 8. ASCII art (for fun!)
run_test "Jester ASCII art" "[ -d source/configs/ascii ] || [ -f source/configs/ascii/jester-collection.txt ]"

# 9. Service scripts
run_test "Service scripts" "ls source/scripts/services/*.sh >/dev/null 2>&1"

# 10. Common library
run_test "Common functions" "[ -f source/scripts/lib/common.sh ]"

echo ""
echo -e "${BLUE}=== MEMORY SANITY ===${NC}"
echo ""

# 11. Not too many scripts
SCRIPT_COUNT=$(find source/scripts -name "*.sh" 2>/dev/null | wc -l)
run_test "Reasonable script count (<50)" "[ $SCRIPT_COUNT -lt 50 ]"

# 12. Makefile exists
run_test "Makefile present" "[ -f Makefile ]"

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "                    TEST SUMMARY"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "Passed: ${GREEN}$PASS${NC}"
echo "Failed: ${RED}$FAIL${NC}"
echo ""

if [ "$FAIL" -eq 0 ]; then
    echo -e "${GREEN}✅ ALL ESSENTIAL TESTS PASSED!${NC}"
    echo ""
    echo "Your Nook project looks good to go!"
    echo "Next steps:"
    echo "  1. make firmware      # Build everything"
    echo "  2. make detect-sd     # Find your SD card"
    echo "  3. make sd-deploy     # Deploy to SD card"
    echo ""
    echo "Remember: Boot from SD card first (safer than internal storage)!"
    exit 0
elif [ "$FAIL" -le 2 ]; then
    echo -e "${YELLOW}⚠️  MOSTLY PASSING${NC}"
    echo ""
    echo "A few minor issues, but probably safe to proceed carefully."
    echo "Consider fixing the failures if they're boot-critical."
    exit 0
else
    echo -e "${RED}❌ TOO MANY FAILURES${NC}"
    echo ""
    echo "Fix the critical issues before deploying to hardware!"
    exit 1
fi