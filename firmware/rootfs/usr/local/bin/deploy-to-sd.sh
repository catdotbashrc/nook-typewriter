#!/bin/bash
# SD Card Deployment Script for Nook Typewriter
# Safe, simple deployment with protection against system drives

set -euo pipefail

# Configuration
SD_DEVICE="${1:-auto}"
FORCE="${2:-no}"
BASE_IMAGE="images/2gb_clockwork-rc2.img"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Safety check function
is_safe_device() {
    local device="$1"
    # Reject system drives (sda-sdd)
    if echo "$device" | grep -qE "/dev/sd[a-d]"; then
        return 1
    fi
    # Accept SD cards and MMC devices
    if echo "$device" | grep -qE "/dev/sd[e-z]|/dev/mmcblk"; then
        return 0
    fi
    return 1
}

# Auto-detect SD card
if [ "$SD_DEVICE" = "auto" ]; then
    echo "Auto-detecting SD card..."
    SD_DEVICE=$(ls /dev/sd[e-z] /dev/mmcblk[0-9] 2>/dev/null | head -1)
    if [ -z "$SD_DEVICE" ]; then
        echo -e "${RED}No SD card detected!${NC}"
        echo "Available devices:"
        lsblk -d -o NAME,SIZE,MODEL | grep -E "sd|mmcblk"
        exit 1
    fi
fi

# Validate device safety
if ! is_safe_device "$SD_DEVICE"; then
    echo -e "${RED}ERROR: Cannot deploy to system drive!${NC}"
    echo "Device $SD_DEVICE is protected (system/Docker drive)"
    exit 1
fi

echo -e "${YELLOW}Target device: $SD_DEVICE${NC}"

# Get device info
if [ -b "$SD_DEVICE" ]; then
    SIZE=$(lsblk -b -d -o SIZE -n "$SD_DEVICE" 2>/dev/null || echo "unknown")
    MODEL=$(lsblk -d -o MODEL -n "$SD_DEVICE" 2>/dev/null || echo "unknown")
    echo "  Size: $(numfmt --to=iec-i --suffix=B "$SIZE" 2>/dev/null || echo "$SIZE")"
    echo "  Model: $MODEL"
else
    echo -e "${RED}Error: $SD_DEVICE is not a block device${NC}"
    exit 1
fi

# Confirmation
if [ "$FORCE" != "yes" ]; then
    echo -e "${RED}⚠️  WARNING: This will ERASE $SD_DEVICE!${NC}"
    read -p "Continue? (yes/NO): " -r confirm
    if [ "$confirm" != "yes" ]; then
        echo "Deployment cancelled"
        exit 0
    fi
fi

# Deployment process
echo "Starting deployment..."

# 1. Write base image
if [ -f "$BASE_IMAGE" ]; then
    echo "Writing base image..."
    sudo dd if="$BASE_IMAGE" of="$SD_DEVICE" bs=4M status=progress conv=fsync
else
    echo -e "${YELLOW}Warning: No base image found, creating partitions...${NC}"
    # Create basic partition structure
    sudo parted "$SD_DEVICE" mklabel msdos
    sudo parted "$SD_DEVICE" mkpart primary fat32 1MiB 100MiB
    sudo parted "$SD_DEVICE" mkpart primary ext4 100MiB 100%
    sudo mkfs.vfat "${SD_DEVICE}1" || sudo mkfs.vfat "${SD_DEVICE}p1"
    sudo mkfs.ext4 "${SD_DEVICE}2" || sudo mkfs.ext4 "${SD_DEVICE}p2"
fi

# 2. Mount partitions
echo "Mounting partitions..."
sudo mkdir -p /mnt/nook-boot /mnt/nook-root

# Handle both /dev/sdX1 and /dev/sdXp1 naming
BOOT_PART="${SD_DEVICE}1"
ROOT_PART="${SD_DEVICE}2"
if [ ! -b "$BOOT_PART" ]; then
    BOOT_PART="${SD_DEVICE}p1"
    ROOT_PART="${SD_DEVICE}p2"
fi

sudo mount "$BOOT_PART" /mnt/nook-boot
sudo mount "$ROOT_PART" /mnt/nook-root

# 3. Copy kernel
if [ -f firmware/boot/uImage ]; then
    echo "Copying kernel..."
    sudo cp firmware/boot/uImage /mnt/nook-boot/
    echo -e "${GREEN}✓ Kernel installed${NC}"
fi

# 4. Copy bootloaders
if [ -f firmware/boot/MLO ] && [ -f firmware/boot/u-boot.bin ]; then
    echo "Copying bootloaders..."
    sudo cp firmware/boot/MLO /mnt/nook-boot/
    sudo cp firmware/boot/u-boot.bin /mnt/nook-boot/
    echo -e "${GREEN}✓ Bootloaders installed${NC}"
fi

# 5. Copy root filesystem
if [ -d firmware/rootfs ]; then
    echo "Copying root filesystem..."
    sudo cp -r firmware/rootfs/* /mnt/nook-root/
    echo -e "${GREEN}✓ Root filesystem installed${NC}"
fi

# 6. Unmount and sync
echo "Finalizing..."
sudo umount /mnt/nook-boot
sudo umount /mnt/nook-root
sync

echo -e "${GREEN}✅ SD card ready!${NC}"
echo ""
echo "Next steps:"
echo "1. Remove SD card safely"
echo "2. Insert into powered-off Nook"
echo "3. Power on - it will boot from SD card"
echo ""
echo "If it doesn't boot:"
echo "- Hold power for 20 seconds to fully power off"
echo "- Try again with the N button held during power on"