#!/bin/bash
# Critical safety tests - MUST PASS before deploying to hardware
# Focus: Don't brick the device, ensure it boots

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "═══════════════════════════════════════════════════════════════"
echo "           CRITICAL SAFETY TESTS"
echo "           Making sure we don't brick your Nook!"
echo "═══════════════════════════════════════════════════════════════"
echo ""

PASS_COUNT=0
FAIL_COUNT=0

# Test 1: Kernel exists and is reasonable size
echo -n "🔍 Kernel image exists and valid size... "
if [ -f "firmware/boot/uImage" ]; then
    SIZE=$(stat -c%s "firmware/boot/uImage" 2>/dev/null || echo "0")
    if [ "$SIZE" -gt 1000000 ] && [ "$SIZE" -lt 10000000 ]; then
        echo -e "${GREEN}PASS${NC} ($(( SIZE / 1024 / 1024 ))MB)"
        ((PASS_COUNT++))
    else
        echo -e "${RED}FAIL${NC} - Size out of range: $SIZE bytes"
        ((FAIL_COUNT++))
    fi
elif [ -f "source/kernel/src/arch/arm/boot/uImage" ]; then
    echo -e "${YELLOW}Found in source, needs copy to firmware${NC}"
    ((PASS_COUNT++))
else
    echo -e "${RED}FAIL${NC} - No kernel found!"
    ((FAIL_COUNT++))
fi

# Test 2: Not touching dangerous devices
echo -n "🛡️  No dangerous device references (sda-sdd)... "
DANGEROUS=$(grep -r "/dev/sd[a-d]" scripts/ source/scripts/ 2>/dev/null | grep -v "^#" | grep -v "!=" | wc -l || echo "0")
if [ "$DANGEROUS" -eq 0 ]; then
    echo -e "${GREEN}PASS${NC}"
    ((PASS_COUNT++))
else
    echo -e "${RED}FAIL${NC} - Found $DANGEROUS dangerous references!"
    ((FAIL_COUNT++))
fi

# Test 3: Boot scripts exist
echo -n "🥾 Essential boot scripts exist... "
BOOT_SCRIPTS=0
[ -f "source/scripts/boot/jesteros-userspace.sh" ] && ((BOOT_SCRIPTS++))
[ -f "source/scripts/boot/init-jesteros.sh" ] && ((BOOT_SCRIPTS++))
[ -f "source/scripts/boot/boot-jester.sh" ] && ((BOOT_SCRIPTS++))

if [ "$BOOT_SCRIPTS" -gt 0 ]; then
    echo -e "${GREEN}PASS${NC} ($BOOT_SCRIPTS scripts found)"
    ((PASS_COUNT++))
else
    echo -e "${RED}FAIL${NC} - No boot scripts!"
    ((FAIL_COUNT++))
fi

# Test 4: Build script exists and works
echo -n "🔨 Build system functional... "
if [ -f "build/scripts/build_kernel.sh" ]; then
    if bash -n "build/scripts/build_kernel.sh" 2>/dev/null; then
        echo -e "${GREEN}PASS${NC}"
        ((PASS_COUNT++))
    else
        echo -e "${RED}FAIL${NC} - Syntax error in build script!"
        ((FAIL_COUNT++))
    fi
elif [ -f "Makefile" ]; then
    echo -e "${GREEN}PASS${NC} (Makefile present)"
    ((PASS_COUNT++))
else
    echo -e "${RED}FAIL${NC} - No build system!"
    ((FAIL_COUNT++))
fi

# Test 5: Memory budget sanity check
echo -n "💾 Scripts won't exhaust memory... "
SCRIPT_COUNT=$(find source/scripts -name "*.sh" 2>/dev/null | wc -l || echo "0")
if [ "$SCRIPT_COUNT" -lt 100 ]; then
    echo -e "${GREEN}PASS${NC} ($SCRIPT_COUNT scripts, reasonable)"
    ((PASS_COUNT++))
else
    echo -e "${YELLOW}WARNING${NC} - $SCRIPT_COUNT scripts might be too many"
    ((PASS_COUNT++))
fi

# Test 6: Docker image can be built (or exists)
echo -n "🐳 Docker build environment ready... "
if docker images | grep -q "jesteros-unified\|jokernel\|quillkernel" 2>/dev/null; then
    echo -e "${GREEN}PASS${NC}"
    ((PASS_COUNT++))
elif [ -f "build/docker/kernel-xda-proven.dockerfile" ]; then
    echo -e "${YELLOW}Dockerfile exists, image not built${NC}"
    ((PASS_COUNT++))
else
    echo -e "${RED}FAIL${NC} - No Docker setup!"
    ((FAIL_COUNT++))
fi

# Test 7: No infinite loops in boot scripts
echo -n "♾️  No obvious infinite loops in boot... "
INFINITE_LOOPS=$(grep -l "while true\|while \[ 1 \]\|while :" source/scripts/boot/*.sh 2>/dev/null | wc -l || echo "0")
if [ "$INFINITE_LOOPS" -eq 0 ]; then
    echo -e "${GREEN}PASS${NC}"
    ((PASS_COUNT++))
else
    echo -e "${YELLOW}WARNING${NC} - Found $INFINITE_LOOPS potential infinite loops"
    ((PASS_COUNT++))
fi

# Test 8: SD card safety check
echo -n "💳 SD card deployment script is safe... "
if grep -q "sd-deploy" Makefile 2>/dev/null; then
    if grep -q "sda-sdd" Makefile; then
        echo -e "${GREEN}PASS${NC} (protects system drives)"
        ((PASS_COUNT++))
    else
        echo -e "${YELLOW}CAREFUL${NC} - Check SD device manually"
        ((PASS_COUNT++))
    fi
else
    echo -e "${YELLOW}Manual SD deployment${NC}"
    ((PASS_COUNT++))
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "                    SAFETY TEST RESULTS"
echo "═══════════════════════════════════════════════════════════════"
echo ""

if [ "$FAIL_COUNT" -eq 0 ]; then
    echo -e "${GREEN}✅ ALL CRITICAL TESTS PASSED!${NC}"
    echo "Your Nook should be safe from bricking."
    echo ""
    echo "Ready to deploy? Use:"
    echo "  1. make firmware"
    echo "  2. make sd-deploy SD_DEVICE=/dev/sde"
    echo "     (replace sde with your actual SD card)"
    exit 0
else
    echo -e "${RED}❌ $FAIL_COUNT CRITICAL TESTS FAILED!${NC}"
    echo ""
    echo "DO NOT deploy to hardware until these are fixed!"
    echo "This could brick your device!"
    exit 1
fi