#!/bin/bash
# Quick fix for Issue #18 - Boot loader loop
# Creates a working boot configuration without CWM initrd

set -euo pipefail

echo "JoKernel Boot Loop Fix"
echo "======================"
echo ""
echo "This script updates the boot configuration to fix the boot loop"
echo ""

# Check if SD card is mounted
if [ ! -d "/tmp/cwm_boot" ]; then
    echo "Error: /tmp/cwm_boot not found"
    echo "Please mount SD card first:"
    echo "  sudo mount /dev/sdX1 /tmp/cwm_boot"
    exit 1
fi

# Create new boot script
echo "Creating fixed boot script..."
cat > /tmp/boot_fixed.cmd << 'EOF'
# JoKernel Boot Script v2 - No initrd, direct boot
# Fixes Issue #18: Boot loop

# Set boot arguments for direct kernel boot
setenv bootargs 'console=ttyS0,115200n8 root=/dev/mmcblk0p2 rootfstype=ext4 rootwait rw init=/init noinitrd'

# Initialize MMC
mmcinit 0
mmcinit 1

# Load kernel only (no uRamdisk!)
echo "Loading JoKernel (no initrd)..."
fatload mmc 0 0x81c00000 uImage

# Boot kernel directly
echo "Booting JoKernel..."
bootm 0x81c00000

# If we get here, boot failed
echo "Boot failed! Check kernel image."
EOF

# Check for mkimage
if ! command -v mkimage &> /dev/null; then
    echo "Warning: mkimage not found. Installing u-boot-tools..."
    sudo apt-get install -y u-boot-tools
fi

# Compile boot script
echo "Compiling boot script..."
mkimage -A arm -O linux -T script -C none -n "JoKernel Fixed" -d /tmp/boot_fixed.cmd /tmp/boot.scr

# Backup old boot script
if [ -f "/tmp/cwm_boot/boot.scr" ]; then
    echo "Backing up old boot.scr..."
    cp /tmp/cwm_boot/boot.scr /tmp/cwm_boot/boot.scr.old
fi

# Install new boot script
echo "Installing fixed boot script..."
cp /tmp/boot.scr /tmp/cwm_boot/boot.scr

# Also update the text version
cp /tmp/boot_fixed.cmd /tmp/cwm_boot/boot.script

# Check if we have our kernel
if [ ! -f "/tmp/cwm_boot/uImage" ]; then
    echo "Warning: No uImage found in boot partition!"
    if [ -f "firmware/boot/uImage" ]; then
        echo "Copying JoKernel..."
        cp firmware/boot/uImage /tmp/cwm_boot/
    fi
fi

# Add a minimal init to partition 2 if accessible
if [ -d "/tmp/cwm_root" ]; then
    echo "Creating minimal init on rootfs..."
    cat > /tmp/cwm_root/init << 'INIT'
#!/bin/sh
# Minimal init - proves we booted successfully!

echo ""
echo "===================================="
echo "  JOKERNEL BOOTED SUCCESSFULLY!"
echo "===================================="
echo ""
echo "Boot loop is FIXED!"
echo "The jester dances with joy!"
echo ""

# Basic setup
/bin/mount -t proc proc /proc
/bin/mount -t sysfs sysfs /sys

# Show kernel version
echo "Kernel: $(uname -r)"
echo ""

# Try to show jester if module is loaded
cat /var/jesteros/jester 2>/dev/null || echo "(JesterOS services not started yet)"

# Keep running
while true; do
    sleep 10
    echo "System is running... (no boot loop!)"
done
INIT
    chmod +x /tmp/cwm_root/init
    echo "Minimal init created"
fi

echo ""
echo "================================"
echo "Boot Loop Fix Applied!"
echo "================================"
echo ""
echo "Changes made:"
echo "1. Boot script no longer loads uRamdisk"
echo "2. Kernel boots directly without initrd"
echo "3. Boot args point to partition 2 for rootfs"
echo ""
echo "To test:"
echo "1. Sync: sync"
echo "2. Unmount: sudo umount /tmp/cwm_boot"
echo "3. Insert SD card into Nook"
echo "4. Power on Nook"
echo ""
echo "Expected: Boot messages without reboot loop!"
echo ""
echo "If this works, update Issue #18 on GitHub!"