#!/bin/bash
# Simple MVP SD Card Creator for Nook Simple Touch
# Based on XDA-proven methods

set -euo pipefail

echo "==================================="
echo "  Nook MVP SD Card Creator"
echo "  Following XDA-proven methods"
echo "==================================="
echo ""

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (for SD card access)" 
   echo "Usage: sudo ./create-mvp-sd.sh /dev/sdX"
   exit 1
fi

# Check arguments
if [ $# -ne 1 ]; then
    echo "Usage: sudo $0 /dev/sdX"
    echo "  where /dev/sdX is your SD card device"
    echo ""
    echo "WARNING: This will ERASE the SD card!"
    exit 1
fi

DEVICE=$1

# Safety check - CRITICAL: Prevent system drive targeting
if [[ "$DEVICE" == "/dev/sda" ]]; then
    echo "FATAL: Cannot target /dev/sda (system drive)"
    echo "This would destroy your system! Please use a different device."
    exit 1
fi

if [[ ! "$DEVICE" =~ ^/dev/sd[b-z]$ ]] && [[ ! "$DEVICE" =~ ^/dev/mmcblk[0-9]$ ]]; then
    echo "ERROR: Invalid device $DEVICE"
    echo "Expected format: /dev/sdX (except sda) or /dev/mmcblkX"
    exit 1
fi

# Confirm with user
echo "WARNING: This will COMPLETELY ERASE $DEVICE"
echo "Make sure this is the correct SD card!"
echo ""
read -p "Type 'yes' to continue: " confirm
if [ "$confirm" != "yes" ]; then
    echo "Aborted."
    exit 1
fi

echo ""
echo "→ Unmounting any existing partitions..."
umount ${DEVICE}* 2>/dev/null || true

echo "→ Creating partition table..."
# Clear the device and create new partition table
dd if=/dev/zero of=$DEVICE bs=1M count=10 2>/dev/null
parted -s $DEVICE mklabel msdos

echo "→ Creating boot partition (100MB FAT32)..."
parted -s $DEVICE mkpart primary fat32 1MiB 101MiB
parted -s $DEVICE set 1 boot on

echo "→ Creating root partition (rest of card, ext4)..."
parted -s $DEVICE mkpart primary ext4 101MiB 100%

# Handle different device naming schemes
if [[ "$DEVICE" =~ ^/dev/mmcblk ]]; then
    PART1="${DEVICE}p1"
    PART2="${DEVICE}p2"
else
    PART1="${DEVICE}1"
    PART2="${DEVICE}2"
fi

echo "→ Formatting partitions..."
mkfs.vfat -F 32 -n BOOT $PART1
mkfs.ext4 -L rootfs $PART2

echo "→ Mounting partitions..."
mkdir -p /tmp/nook_boot /tmp/nook_root
mount $PART1 /tmp/nook_boot
mount $PART2 /tmp/nook_root

echo "→ Copying kernel..."
if [ -f firmware/boot/uImage ]; then
    cp firmware/boot/uImage /tmp/nook_boot/
    echo "  ✓ Kernel copied"
else
    echo "  ERROR: firmware/boot/uImage not found!"
    umount /tmp/nook_boot
    umount /tmp/nook_root
    exit 1
fi

echo "→ Creating boot script..."
cat > /tmp/nook_boot/boot.scr.txt << 'EOF'
# Nook Simple Touch Boot Script
setenv bootargs console=ttyS0,115200n8 root=/dev/mmcblk0p2 rootfstype=ext4 rootwait rw init=/init
fatload mmc 0:1 0x80000000 uImage
bootm 0x80000000
EOF
echo "  ✓ Boot script created"

echo "→ Extracting root filesystem..."
if [ -f nook-mvp-rootfs.tar.gz ]; then
    tar -xzf nook-mvp-rootfs.tar.gz -C /tmp/nook_root/
    echo "  ✓ Root filesystem extracted"
else
    echo "  ERROR: nook-mvp-rootfs.tar.gz not found!"
    umount /tmp/nook_boot
    umount /tmp/nook_root
    exit 1
fi

echo "→ Setting up init system..."
# Make sure init is executable
chmod +x /tmp/nook_root/init 2>/dev/null || true

echo "→ Syncing to SD card..."
sync

echo "→ Unmounting partitions..."
umount /tmp/nook_boot
umount /tmp/nook_root
rmdir /tmp/nook_boot /tmp/nook_root

echo ""
echo "====================================="
echo "✓ SD Card prepared successfully!"
echo "====================================="
echo ""
echo "Next steps:"
echo "1. Remove SD card from computer"
echo "2. Power off your Nook completely"
echo "3. Insert SD card into Nook"
echo "4. Power on Nook"
echo "5. It should boot from SD card!"
echo ""
echo "If it doesn't work:"
echo "- Remove SD card and Nook boots normally"
echo "- No risk to internal storage!"
echo ""
echo "The Jester says: 'Thy kernel awaits its maiden voyage!'"