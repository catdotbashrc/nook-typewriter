#!/bin/bash
# Test script for Makefile SD card deployment workflow
# This validates the complete build and deployment process

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
RESET='\033[0m'

echo -e "${BOLD}═══════════════════════════════════════════════════════════════${RESET}"
echo -e "${BOLD}       Makefile SD Card Deployment Test${RESET}"
echo -e "${BOLD}═══════════════════════════════════════════════════════════════${RESET}"
echo ""

# Function to run make target and check result
test_make_target() {
    local target="$1"
    local desc="$2"
    
    echo -e "${BLUE}Testing: make $target${RESET}"
    echo -e "  $desc"
    
    if make $target > /tmp/make_test.log 2>&1; then
        echo -e "  ${GREEN}✓${RESET} Success"
        return 0
    else
        echo -e "  ${RED}✗${RESET} Failed"
        echo "  Last 10 lines of output:"
        tail -10 /tmp/make_test.log | sed 's/^/    /'
        return 1
    fi
    echo ""
}

# Test targets
echo -e "${BOLD}1. Environment Check${RESET}"
test_make_target "check-tools" "Checking required build tools"
test_make_target "validate" "Validating build environment"
echo ""

echo -e "${BOLD}2. Build Status${RESET}"
test_make_target "build-status" "Checking current build status"
test_make_target "bootloader-status" "Checking bootloader files"
echo ""

echo -e "${BOLD}3. Docker Images${RESET}"
echo -e "${BLUE}Checking Docker images...${RESET}"
if docker images | grep -q jesteros-production; then
    echo -e "  ${GREEN}✓${RESET} jesteros-production image exists"
else
    echo -e "  ${YELLOW}⚠${RESET} Building jesteros-production..."
    test_make_target "docker-production" "Building production Docker image"
fi

if docker images | grep -q kernel-xda-proven; then
    echo -e "  ${GREEN}✓${RESET} kernel-xda-proven image exists"
else
    echo -e "  ${YELLOW}⚠${RESET} kernel-xda-proven not built (optional for kernel rebuild)"
fi
echo ""

echo -e "${BOLD}4. Build Components${RESET}"
# Check if kernel exists
if [ -f firmware/boot/uImage ]; then
    echo -e "  ${GREEN}✓${RESET} Kernel already built"
else
    echo -e "  ${YELLOW}⚠${RESET} Kernel missing - would need to run 'make kernel'"
fi

# Check if rootfs exists
if ls jesteros-production-rootfs-*.tar.gz >/dev/null 2>&1; then
    echo -e "  ${GREEN}✓${RESET} Rootfs already created"
    ls -lh jesteros-production-rootfs-*.tar.gz | tail -1 | sed 's/^/    /'
else
    echo -e "  ${YELLOW}⚠${RESET} No rootfs - run 'make lenny-rootfs'"
fi
echo ""

echo -e "${BOLD}5. SD Card Detection${RESET}"
test_make_target "detect-sd" "Detecting available SD cards"
echo ""

echo -e "${BOLD}6. Deployment Readiness${RESET}"
echo -e "${BLUE}Checking deployment requirements...${RESET}"

READY=true

# Check boot files
for file in MLO u-boot.bin uImage; do
    if [ -f firmware/boot/$file ]; then
        size=$(du -h firmware/boot/$file | cut -f1)
        echo -e "  ${GREEN}✓${RESET} $file: $size"
    else
        echo -e "  ${RED}✗${RESET} $file: missing"
        READY=false
    fi
done

# Check rootfs
if ls jesteros-production-rootfs-*.tar.gz >/dev/null 2>&1; then
    ROOTFS=$(ls -t jesteros-production-rootfs-*.tar.gz | head -1)
    size=$(du -h $ROOTFS | cut -f1)
    echo -e "  ${GREEN}✓${RESET} Rootfs: $ROOTFS ($size)"
else
    echo -e "  ${RED}✗${RESET} Rootfs: missing"
    READY=false
fi

# Check deployment script
if [ -f deploy-to-sd-gk61.sh ]; then
    echo -e "  ${GREEN}✓${RESET} Deployment script: deploy-to-sd-gk61.sh"
elif [ -f deploy-to-sd.sh ]; then
    echo -e "  ${GREEN}✓${RESET} Deployment script: deploy-to-sd.sh"
else
    echo -e "  ${RED}✗${RESET} Deployment script: missing"
    READY=false
fi
echo ""

echo -e "${BOLD}═══════════════════════════════════════════════════════════════${RESET}"
echo -e "${BOLD}                     TEST SUMMARY${RESET}"
echo -e "${BOLD}═══════════════════════════════════════════════════════════════${RESET}"

if [ "$READY" = "true" ]; then
    echo -e "${GREEN}✅ READY FOR SD CARD DEPLOYMENT${RESET}"
    echo ""
    echo "Next steps:"
    echo "1. Insert SD card"
    echo "2. Run: make detect-sd"
    echo "3. Deploy: make sd-deploy SD_DEVICE=/dev/sdX"
    echo ""
    echo "Or use the deployment script directly:"
    echo "  sudo ./deploy-to-sd-gk61.sh /dev/sdX"
else
    echo -e "${RED}❌ NOT READY FOR DEPLOYMENT${RESET}"
    echo ""
    echo "To prepare for deployment:"
    echo "1. Build kernel: make kernel"
    echo "2. Build rootfs: make lenny-rootfs"
    echo "3. Check files: make build-status"
fi

echo ""
echo -e "${BOLD}Makefile Workflow Commands:${RESET}"
echo "  make firmware        # Build everything (kernel + rootfs)"
echo "  make lenny-rootfs    # Create rootfs from Docker image"
echo "  make image          # Create SD card image file"
echo "  make sd-deploy      # Deploy directly to SD card"
echo "  make test-quick     # Run safety tests before deployment"