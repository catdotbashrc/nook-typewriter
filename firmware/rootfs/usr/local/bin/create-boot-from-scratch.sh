#!/bin/bash
# Create JesterOS boot SD card completely from scratch
# Method 3: Manual U-Boot Chain - No CWM dependencies!

set -euo pipefail

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (needed for partition and mount operations)"
    exit 1
fi

# Configuration
SD_DEVICE="${1:-}"
KERNEL_IMAGE="platform/nook-touch/boot/uImage"
ROOTFS_TAR="lenny-rootfs.tar.gz"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Usage
if [ -z "$SD_DEVICE" ]; then
    echo "Usage: $0 /dev/sdX"
    echo ""
    echo "This script creates a bootable SD card for JesterOS FROM SCRATCH"
    echo "No ClockworkMod, no legacy cruft - pure JesterOS boot!"
    echo ""
    echo "WARNING: This will COMPLETELY ERASE the SD card!"
    exit 1
fi

# Safety check - CRITICAL: Prevent system drive targeting
if [[ "$SD_DEVICE" == "/dev/sda" ]]; then
    print_error "FATAL: Cannot target /dev/sda (system drive)"
    echo "This would destroy your system! Please use a different device."
    exit 1
fi

if [[ ! "$SD_DEVICE" =~ ^/dev/sd[b-z]$ ]] && [[ ! "$SD_DEVICE" =~ ^/dev/mmcblk[0-9]$ ]]; then
    print_error "Invalid device: $SD_DEVICE"
    echo "Device should be like /dev/sdb or /dev/mmcblk0"
    echo "Note: /dev/sda is explicitly blocked for safety"
    exit 1
fi

# Check if device exists
if [ ! -b "$SD_DEVICE" ]; then
    print_error "Device $SD_DEVICE does not exist"
    exit 1
fi

# Check prerequisites
if [ ! -f "$KERNEL_IMAGE" ]; then
    print_error "Kernel image not found: $KERNEL_IMAGE"
    echo "Please build kernel first: ./build_kernel.sh"
    exit 1
fi

# We need MLO and u-boot.bin from somewhere
# For now, we'll extract from CWM or use prebuilt ones
MLO_SOURCE=""
UBOOT_SOURCE=""

if [ -f "platform/nook-touch/boot/MLO" ]; then
    MLO_SOURCE="platform/nook-touch/boot/MLO"
    UBOOT_SOURCE="platform/nook-touch/boot/u-boot.bin"
elif [ -f "bootloader/MLO" ]; then
    MLO_SOURCE="bootloader/MLO"
    UBOOT_SOURCE="bootloader/u-boot.bin"
elif [ -f "/tmp/MLO.backup" ]; then
    MLO_SOURCE="/tmp/MLO.backup"
    UBOOT_SOURCE="/tmp/u-boot.bin.backup"
else
    print_warn "No bootloader files found!"
    echo "You need MLO and u-boot.bin from a working Nook boot"
    echo "Options:"
    echo "1. Extract from CWM image"
    echo "2. Download from XDA forums"
    echo "3. Build from source (advanced)"
    exit 1
fi

# Confirm with user
echo "============================================"
echo "JesterOS From-Scratch SD Card Creator"
echo "============================================"
echo "Target device: $SD_DEVICE"
lsblk "$SD_DEVICE" 2>/dev/null || true
echo ""
echo "Boot method: Ground-up custom boot chain"
echo "No ClockworkMod dependencies!"
echo ""
echo "This will COMPLETELY ERASE the device!"
echo -n "Type 'GROUND-UP' to continue: "
read confirm
if [ "$confirm" != "GROUND-UP" ]; then
    echo "Aborted."
    exit 1
fi

print_info "Creating JesterOS boot SD from scratch..."

# Step 1: Wipe and partition the SD card
print_info "Wiping SD card..."
dd if=/dev/zero of="$SD_DEVICE" bs=1M count=100 status=progress
sync

print_info "Creating partition table with NOOK-SPECIFIC sector alignment..."
# Critical: Nook requires first partition to start at sector 63 (not 2048)!
# Using sfdisk for precise sector control since modern fdisk won't accept sector 63

sfdisk "$SD_DEVICE" << 'SFDISK_EOF'
label: dos
unit: sectors
start=63, size=1048576, type=c, bootable
start=1048639, size=4194304, type=83
start=5242943, type=83
SFDISK_EOF

# Re-read partition table
partprobe "$SD_DEVICE"
sleep 2

# Determine partition naming
if [[ "$SD_DEVICE" =~ ^/dev/mmcblk ]]; then
    PART1="${SD_DEVICE}p1"
    PART2="${SD_DEVICE}p2"
    PART3="${SD_DEVICE}p3"
else
    PART1="${SD_DEVICE}1"
    PART2="${SD_DEVICE}2"
    PART3="${SD_DEVICE}3"
fi

# Step 2: Format partitions
print_info "Formatting partitions..."
mkfs.vfat -F 16 -n "JESTER_BOOT" "$PART1"
mkfs.ext4 -L "JESTER_ROOT" "$PART2"
mkfs.ext4 -L "JESTER_DATA" "$PART3"

# Step 3: Mount partitions
print_info "Mounting partitions..."
mkdir -p /tmp/jester_boot /tmp/jester_root /tmp/jester_data
mount "$PART1" /tmp/jester_boot
mount "$PART2" /tmp/jester_root
mount "$PART3" /tmp/jester_data

# Step 4: Install bootloaders in EXACT ORDER for Nook compatibility
print_info "Installing bootloaders in correct order..."
if [ -f "$MLO_SOURCE" ]; then
    # CRITICAL: MLO must be the FIRST file copied to ensure contiguous storage
    print_info "Installing MLO (first stage bootloader)..."
    cp "$MLO_SOURCE" /tmp/jester_boot/MLO
    sync
    
    print_info "Installing u-boot.bin (second stage bootloader)..."  
    cp "$UBOOT_SOURCE" /tmp/jester_boot/u-boot.bin
    sync
    
    # Verify files are present and correct size
    ls -la /tmp/jester_boot/{MLO,u-boot.bin}
else
    print_error "Cannot proceed without MLO and u-boot.bin"
    exit 1
fi

# Step 5: Install kernel
print_info "Installing JoKernel..."
cp "$KERNEL_IMAGE" /tmp/jester_boot/uImage

# Step 6: Create our custom boot script
print_info "Creating JoKernel boot script..."
cat > /tmp/boot.cmd << 'EOF'
# JoKernel Debug Boot Script with Extensive Logging

echo ""
echo "======================================="
echo "     JOKERNEL BOOT SYSTEM DEBUG"
echo "======================================="
echo ""

# Create log file on boot partition
fatwrite mmc 0 0x80000000 boot_debug.log 0x1000

# Log everything to both console and file
echo "=== JOKERNEL BOOT DEBUG LOG ===" > boot_debug.log
echo "Boot started at: [timestamp]" >> boot_debug.log

# Show U-Boot version and environment
echo "U-Boot version info:"
version
echo "Environment variables:"
printenv

# Test MMC detection
echo "=== MMC DETECTION TEST ==="
echo "MMC 0 info:"
mmc info 0
echo "MMC 1 info:"
mmc info 1

echo "Initializing MMC interfaces..."
mmcinit 0
if test $? -ne 0; then
    echo "ERROR: MMC 0 init failed!"
else
    echo "MMC 0 init successful"
fi

mmcinit 1  
if test $? -ne 0; then
    echo "ERROR: MMC 1 init failed!"
else
    echo "MMC 1 init successful"
fi

# List files on boot partition
echo "=== BOOT PARTITION CONTENTS ==="
fatls mmc 0
echo ""

# Test if we can read key files
echo "=== FILE ACCESS TESTS ==="
echo "Testing MLO access..."
if fatload mmc 0 0x80000000 MLO 1; then
    echo "MLO readable - OK"
else
    echo "ERROR: Cannot read MLO!"
fi

echo "Testing u-boot.bin access..."  
if fatload mmc 0 0x80000000 u-boot.bin 1; then
    echo "u-boot.bin readable - OK"
else
    echo "ERROR: Cannot read u-boot.bin!"
fi

echo "Testing uImage access..."
if fatload mmc 0 0x80000000 uImage 1; then
    echo "uImage readable - OK"
else
    echo "ERROR: Cannot read uImage!"
fi

# Set boot arguments with debug
echo "=== SETTING BOOT ARGUMENTS ==="
setenv bootargs 'console=ttyS0,115200n8 root=/dev/mmcblk0p2 rootfstype=ext4 rootwait rw init=/sbin/init debug loglevel=8'
echo "Boot args set to: ${bootargs}"

# Load and display boot art
echo "=== LOADING BOOT ART ==="
if fatload mmc 0 0x81000000 booting.txt; then
    echo "Boot art loaded successfully"
    # Try to display it (might not work in all U-Boot versions)
else
    echo "Boot art not found or failed to load"
fi

# Load kernel with size verification
echo "=== LOADING KERNEL ==="
echo "Attempting to load uImage to 0x81c00000..."
if fatload mmc 0 0x81c00000 uImage; then
    echo "Kernel loaded successfully!"
    echo "Kernel size: ${filesize} bytes"
    
    # Verify kernel magic number
    echo "Verifying kernel image..."
    md5sum 0x81c00000 0x100
    
    echo "=== STARTING BOOT ==="
    echo "Boot arguments: ${bootargs}"
    echo "Kernel address: 0x81c00000"
    echo "Starting JoKernel in 3 seconds..."
    sleep 3
    
    bootm 0x81c00000
    
    echo "ERROR: bootm returned - boot failed!"
else
    echo "ERROR: Failed to load kernel!"
fi

# If we get here, something went wrong
echo ""
echo "================================"
echo "    BOOT FAILED - DEBUG MODE"  
echo "================================"
echo "Available commands:"
echo "  printenv  - show environment"
echo "  fatls mmc 0 - list boot files"
echo "  mmc info  - show MMC status"
echo "  reset     - restart device"
echo ""
echo "Entering U-Boot shell for debugging..."
EOF

# Compile boot script
print_info "Compiling boot script..."
mkimage -A arm -O linux -T script -C none -n "JesterOS Boot" -d /tmp/boot.cmd /tmp/jester_boot/boot.scr

# Also create alternative boot script names that Nook might look for
cp /tmp/jester_boot/boot.scr /tmp/jester_boot/u-boot.scr
cp /tmp/jester_boot/boot.scr /tmp/jester_boot/boot.scr.uimg

# Step 7: Add boot splash and scripts
print_info "Adding boot art..."
if [ -f "platform/nook-touch/boot/booting.txt" ]; then
    cp platform/nook-touch/boot/booting.txt /tmp/jester_boot/
fi

# Step 8: Setup root filesystem
print_info "Setting up root filesystem..."

if [ -f "$ROOTFS_TAR" ]; then
    print_info "Extracting rootfs..."
    tar -xzf "$ROOTFS_TAR" -C /tmp/jester_root/
else
    print_info "Creating minimal rootfs from scratch..."
    
    # Create directory structure
    mkdir -p /tmp/jester_root/{bin,sbin,etc,proc,sys,dev,tmp,var,usr,lib,root,boot}
    mkdir -p /tmp/jester_root/etc/init.d
    mkdir -p /tmp/jester_root/lib/modules/2.6.29
    
    # Create essential files
    cat > /tmp/jester_root/etc/fstab << 'FSTAB'
# JoKernel filesystem table
proc            /proc           proc    defaults        0 0
sysfs           /sys            sysfs   defaults        0 0
devtmpfs        /dev            devtmpfs defaults       0 0
/dev/mmcblk0p2  /              ext4    defaults        0 1
/dev/mmcblk0p3  /data          ext4    defaults        0 2
FSTAB

    # Create init script
    cat > /tmp/jester_root/sbin/init << 'INIT'
#!/bin/sh
# JoKernel Init System

# Mount essential filesystems
mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev

# Clear screen
clear

# Show boot success
cat << 'BANNER'

     ╔═══════════════════════════════╗
     ║      JOKERNEL v1.0.0-dev      ║
     ║   Boot Successful - No Loop!   ║
     ╠═══════════════════════════════╣
     ║         ( ◉   ◉ )            ║
     ║          \  >  /              ║
     ║           \___/               ║
     ║      The jester lives!        ║
     ╚═══════════════════════════════╝

BANNER

# Load kernel modules
echo "Loading JokerOS modules..."
for module in /lib/modules/2.6.29/*.ko; do
    if [ -f "$module" ]; then
        insmod "$module" 2>/dev/null && echo "  Loaded: $(basename $module)"
    fi
done

# Show jester if available
if [ -f /proc/jokeros/jester ]; then
    echo ""
    cat /proc/jokeros/jester
fi

# Start shell for testing
echo ""
echo "Starting emergency shell..."
/bin/sh

# If shell exits, prevent kernel panic
while true; do
    sleep 1
done
INIT
    chmod +x /tmp/jester_root/sbin/init
    
    # Add busybox if available
    if [ -f "rootfs/busybox" ]; then
        cp rootfs/busybox /tmp/jester_root/bin/
        chmod +x /tmp/jester_root/bin/busybox
        # Create symlinks for common commands
        for cmd in sh ls cat echo mount umount sleep clear; do
            ln -s busybox /tmp/jester_root/bin/$cmd
        done
    else
        print_warn "No busybox found - rootfs will be very minimal"
    fi
fi

# Step 9: Add kernel modules
if [ -d "source/kernel/src/drivers/jesteros" ]; then
    print_info "Copying kernel modules..."
    find source/kernel/src/drivers/jesteros -name "*.ko" -exec cp {} /tmp/jester_root/lib/modules/2.6.29/ \; 2>/dev/null || true
fi

# Step 10: Add our scripts and configuration
print_info "Adding JesterOS scripts..."
cp -r platform/nook-touch/boot/*.sh /tmp/jester_root/boot/ 2>/dev/null || true
cp -r platform/nook-touch/boot/*.txt /tmp/jester_root/boot/ 2>/dev/null || true

# Copy critical system validation modules
if [ -f "platform/nook-touch/boot/system_journal_validation.sh" ]; then
    cp platform/nook-touch/boot/system_journal_validation.sh /tmp/jester_root/boot/
    chmod +x /tmp/jester_root/boot/system_journal_validation.sh
fi

if [ -f "platform/nook-touch/boot/system_audit_validation.sh" ]; then
    cp platform/nook-touch/boot/system_audit_validation.sh /tmp/jester_root/boot/
    chmod +x /tmp/jester_root/boot/system_audit_validation.sh
fi

# Step 11: Setup data partition
print_info "Setting up data partition..."
mkdir -p /tmp/jester_data/manuscripts
mkdir -p /tmp/jester_data/backups
echo "Your words go here" > /tmp/jester_data/manuscripts/README.txt

# Final sync and unmount
print_info "Finalizing SD card..."
sync
sync
sync

umount /tmp/jester_boot
umount /tmp/jester_root
umount /tmp/jester_data

rmdir /tmp/jester_boot /tmp/jester_root /tmp/jester_data

print_info "SD card creation complete!"
echo ""
echo "============================================"
echo "     JOKERNEL GROUND-UP BOOT READY!"
echo "============================================"
echo ""
echo "What we built:"
echo "  • Custom partition layout (no CWM)"
echo "  • Pure JoKernel boot chain"
echo "  • Minimal working rootfs"
echo "  • No legacy dependencies"
echo ""
echo "To test:"
echo "1. Insert SD card into Nook"
echo "2. Power off Nook completely"
echo "3. Power on - should boot JoKernel"
echo ""
echo "Expected:"
echo "  • JoKernel banner appears"
echo "  • 'Boot Successful - No Loop!' message"
echo "  • Emergency shell prompt"
echo ""
echo "This fixes Issue #18 properly - no CWM needed!"