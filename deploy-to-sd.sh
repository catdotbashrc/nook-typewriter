#!/bin/bash
# Nook SD Card Deployment Script
# Deploy JesterOS kernel and rootfs to SD card

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
RESET='\033[0m'

# Configuration
SD_DEVICE="${1:-/dev/sde}"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KERNEL_IMAGE="${PROJECT_ROOT}/firmware/boot/uImage"
MLO_FILE="${PROJECT_ROOT}/firmware/boot/MLO"
UBOOT_FILE="${PROJECT_ROOT}/firmware/boot/u-boot.bin"
BOOT_SCRIPT="${PROJECT_ROOT}/firmware/boot/boot.scr"
BASE_IMAGE="${PROJECT_ROOT}/images/2gb_clockwork-rc2.img"
ROOTFS_ARCHIVE="${PROJECT_ROOT}/nook-mvp-rootfs.tar.gz"

echo -e "${BOLD}═══════════════════════════════════════════════════════════════${RESET}"
echo -e "${BOLD}       Nook JesterOS SD Card Deployment${RESET}"
echo -e "${BOLD}═══════════════════════════════════════════════════════════════${RESET}"
echo ""

# Safety checks
if [[ ! -b "$SD_DEVICE" ]]; then
    echo -e "${RED}Error: Device $SD_DEVICE not found!${RESET}"
    exit 1
fi

if [[ "$SD_DEVICE" =~ /dev/sd[a-d] ]]; then
    echo -e "${RED}Error: Cannot deploy to system drives (sda-sdd)!${RESET}"
    echo "These are protected system/Windows/Docker drives."
    exit 1
fi

# Show device info
echo -e "${YELLOW}Target device: $SD_DEVICE${RESET}"
lsblk -d -o NAME,SIZE,MODEL "$SD_DEVICE" 2>/dev/null || true
echo ""

# Check for required files
echo "Checking required files..."

# Check critical boot files
MISSING_FILES=()
if [[ ! -f "$KERNEL_IMAGE" ]]; then
    MISSING_FILES+=("Kernel (uImage)")
fi
if [[ ! -f "$MLO_FILE" ]]; then
    MISSING_FILES+=("MLO bootloader")
fi
if [[ ! -f "$UBOOT_FILE" ]]; then
    MISSING_FILES+=("U-Boot bootloader")
fi

if [[ ${#MISSING_FILES[@]} -gt 0 ]]; then
    echo -e "${RED}Error: Required files missing:${RESET}"
    for file in "${MISSING_FILES[@]}"; do
        echo "  - $file"
    done
    echo ""
    echo "Run 'make firmware' to build all components"
    echo "This will extract bootloaders and build the kernel"
    exit 1
fi

echo -e "${GREEN}✓ Kernel found: $(ls -lh "$KERNEL_IMAGE" | awk '{print $5}')${RESET}"
echo -e "${GREEN}✓ MLO found: $(ls -lh "$MLO_FILE" | awk '{print $5}')${RESET}"
echo -e "${GREEN}✓ U-Boot found: $(ls -lh "$UBOOT_FILE" | awk '{print $5}')${RESET}"

if [[ -f "$BOOT_SCRIPT" ]]; then
    echo -e "${GREEN}✓ Boot script found: $(ls -lh "$BOOT_SCRIPT" | awk '{print $5}')${RESET}"
else
    echo -e "${YELLOW}⚠ Boot script not found, will use defaults${RESET}"
fi

if [[ ! -f "$BASE_IMAGE" ]]; then
    echo -e "${RED}Error: Base image not found at $BASE_IMAGE${RESET}"
    echo "Download the ClockworkMod recovery image first"
    exit 1
fi
echo -e "${GREEN}✓ Base image found: $(ls -lh "$BASE_IMAGE" | awk '{print $5}')${RESET}"

# Optional rootfs check
if [[ -f "$ROOTFS_ARCHIVE" ]]; then
    echo -e "${GREEN}✓ Root filesystem found: $(ls -lh "$ROOTFS_ARCHIVE" | awk '{print $5}')${RESET}"
    DEPLOY_ROOTFS=true
else
    echo -e "${YELLOW}⚠ No rootfs archive found, will deploy kernel only${RESET}"
    DEPLOY_ROOTFS=false
fi

echo ""
echo -e "${RED}⚠️  WARNING: This will ERASE all data on $SD_DEVICE!${RESET}"
read -p "Type 'yes' to continue: " confirm

if [[ "$confirm" != "yes" ]]; then
    echo "Deployment cancelled"
    exit 0
fi

echo ""
echo -e "${BOLD}Starting deployment...${RESET}"

# Write base image
echo "1. Writing base image to SD card..."
echo "   This will take 5-10 minutes..."
sudo dd if="$BASE_IMAGE" of="$SD_DEVICE" bs=4M status=progress conv=fsync
sync

echo ""
echo "2. Waiting for partitions to appear..."
sleep 5
partprobe "$SD_DEVICE" 2>/dev/null || true

# Mount boot partition
echo "3. Mounting boot partition..."
sudo mkdir -p /mnt/nook-boot
BOOT_PART="${SD_DEVICE}1"
[[ ! -b "$BOOT_PART" ]] && BOOT_PART="${SD_DEVICE}p1"

if sudo mount "$BOOT_PART" /mnt/nook-boot; then
    echo -e "${GREEN}✓ Boot partition mounted${RESET}"
else
    echo -e "${RED}Failed to mount boot partition!${RESET}"
    exit 1
fi

# Copy bootloaders in CRITICAL ORDER
echo "4. Copying bootloaders (CRITICAL ORDER)..."
echo "   MLO must be copied FIRST for contiguous storage!"
sudo cp "$MLO_FILE" /mnt/nook-boot/MLO
sync  # Force immediate write
echo -e "${GREEN}   ✓ MLO deployed (first)${RESET}"

sudo cp "$UBOOT_FILE" /mnt/nook-boot/u-boot.bin
sync
echo -e "${GREEN}   ✓ U-Boot deployed${RESET}"

# Copy kernel
echo "5. Copying JesterOS kernel..."
sudo cp "$KERNEL_IMAGE" /mnt/nook-boot/uImage
sync
echo -e "${GREEN}   ✓ Kernel deployed${RESET}"

# Copy boot script if available
if [[ -f "$BOOT_SCRIPT" ]]; then
    echo "6. Copying boot script..."
    sudo cp "$BOOT_SCRIPT" /mnt/nook-boot/boot.scr
    sudo cp "$BOOT_SCRIPT" /mnt/nook-boot/u-boot.scr
    sudo cp "$BOOT_SCRIPT" /mnt/nook-boot/boot.scr.uimg
    echo -e "${GREEN}   ✓ Boot scripts deployed${RESET}"
fi

# Unmount boot
sudo umount /mnt/nook-boot

# Deploy rootfs if available
if [[ "$DEPLOY_ROOTFS" == "true" ]]; then
    echo "6. Deploying root filesystem..."
    ROOT_PART="${SD_DEVICE}2"
    [[ ! -b "$ROOT_PART" ]] && ROOT_PART="${SD_DEVICE}p2"
    
    sudo mkdir -p /mnt/nook-root
    if sudo mount "$ROOT_PART" /mnt/nook-root; then
        echo "   Extracting rootfs (this may take a while)..."
        sudo tar -xzf "$ROOTFS_ARCHIVE" -C /mnt/nook-root/
        sudo umount /mnt/nook-root
        echo -e "${GREEN}✓ Root filesystem deployed${RESET}"
    else
        echo -e "${YELLOW}⚠ Could not mount root partition, skipping rootfs${RESET}"
    fi
fi

# Final sync
echo ""
echo "7. Syncing filesystems..."
sync
echo -e "${GREEN}✓ Sync complete${RESET}"

echo ""
echo -e "${BOLD}═══════════════════════════════════════════════════════════════${RESET}"
echo -e "${GREEN}✅ SD card ready!${RESET}"
echo ""
echo "Next steps:"
echo "1. Safely eject the SD card"
echo "2. Insert it into your Nook"
echo "3. Power on while holding the 'n' button"
echo "4. The Nook should boot into JesterOS!"
echo ""
echo -e "${BOLD}By quill and candlelight, happy writing! 🕯️📜${RESET}"
echo -e "${BOLD}═══════════════════════════════════════════════════════════════${RESET}"