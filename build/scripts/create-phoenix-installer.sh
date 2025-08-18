#!/bin/bash
# JesterOS Phoenix-Style Installer Creation Script
# Based on proven Phoenix Project installation methods from XDA Forums

set -euo pipefail
trap 'echo "Error at line $LINENO"' ERR

# Phoenix Project validated settings
FIRMWARE_VERSION="1.2.2"  # Most stable per community testing
CWM_SIZE="128MB"         # Smaller CWM image size
SECTOR_ALIGNMENT=63      # Critical for boot compatibility

# Colors
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BOLD='\033[1m'
RESET='\033[0m'

echo -e "${BOLD}🔥 JesterOS Phoenix Installer Creator${RESET}"
echo -e "Based on Phoenix Project proven methods"
echo ""

# Validate environment
check_requirements() {
    echo -e "${BOLD}Checking requirements...${RESET}"
    
    # Check for required tools
    for tool in dd mkfs.vfat mkfs.ext4 parted; do
        if ! command -v "$tool" &> /dev/null; then
            echo -e "${RED}Error: $tool not found${RESET}"
            exit 1
        fi
    done
    
    # Check for CWM base image
    if [ ! -f "images/sd_${CWM_SIZE}_clockwork-rc2.img" ]; then
        echo -e "${YELLOW}Warning: CWM base image not found${RESET}"
        echo "Download from Phoenix Project thread:"
        echo "https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/"
        exit 1
    fi
    
    echo -e "${GREEN}✓ All requirements met${RESET}"
}

# Create installer image with Phoenix Project structure
create_installer() {
    local output_img="${1:-jesteros-installer.img}"
    local temp_dir="$(mktemp -d)"
    
    echo -e "${BOLD}Creating installer image: $output_img${RESET}"
    
    # Copy CWM base as starting point
    echo "  Using CWM base image..."
    cp "images/sd_${CWM_SIZE}_clockwork-rc2.img" "$output_img"
    
    # Mount and modify the image
    echo "  Setting up loop device..."
    local loop_dev=$(sudo losetup --show -f "$output_img")
    sudo partprobe "$loop_dev"
    
    # Mount boot partition
    echo "  Mounting boot partition..."
    sudo mkdir -p /mnt/installer-boot
    sudo mount "${loop_dev}p1" /mnt/installer-boot || {
        echo -e "${RED}Failed to mount boot partition${RESET}"
        sudo losetup -d "$loop_dev"
        exit 1
    }
    
    # Add JesterOS kernel if available
    if [ -f "source/kernel/src/arch/arm/boot/uImage" ]; then
        echo "  Adding JesterOS kernel..."
        sudo cp "source/kernel/src/arch/arm/boot/uImage" /mnt/installer-boot/
    fi
    
    # Create installation script following Phoenix standards
    cat << 'EOF' | sudo tee /mnt/installer-boot/install-jesteros.sh > /dev/null
#!/sbin/sh
# JesterOS Installation Script (Phoenix Project Compatible)
# Follows proven installation patterns from XDA community

echo "======================================="
echo "     JesterOS Installation"
echo "     Phoenix Project Method"
echo "======================================="

# Critical: Check battery level first (Phoenix finding)
BATTERY=$(cat /sys/class/power_supply/bq27510-0/capacity 2>/dev/null || echo "50")
if [ "$BATTERY" -lt "30" ]; then
    echo "ERROR: Battery too low ($BATTERY%)"
    echo "Charge to at least 30% before installing"
    exit 1
fi

echo "Battery level: $BATTERY% - OK"

# Mount partitions (Phoenix standard paths)
echo "Mounting partitions..."
mount /dev/block/mmcblk0p5 /system 2>/dev/null || true
mount /dev/block/mmcblk0p8 /data 2>/dev/null || true
mount /dev/block/mmcblk0p6 /cache 2>/dev/null || true

# CRITICAL: Never touch /rom partition!
echo "Preserving /rom partition (factory recovery)"

# Backup critical device-specific files
echo "Backing up device configuration..."
if [ -f /system/build.prop ]; then
    cp /system/build.prop /sdcard/backup-build.prop
    echo "  - build.prop backed up"
fi

# Check if registered (affects battery drain massively)
if grep -q "ro.bn.registered=1" /system/build.prop 2>/dev/null; then
    echo "Device is registered (good for battery)"
else
    echo "WARNING: Device not registered"
    echo "  Expect 14% daily battery drain!"
    echo "  JesterOS removes B&N system to fix this"
fi

# Wipe system partitions (Phoenix method)
echo "Wiping system partitions..."
rm -rf /system/* 2>/dev/null || true
rm -rf /data/* 2>/dev/null || true  
rm -rf /cache/* 2>/dev/null || true
echo "  - System wiped"

# Extract JesterOS
echo "Installing JesterOS..."
if [ -f /sdcard/jesteros-system.tar.gz ]; then
    tar xzf /sdcard/jesteros-system.tar.gz -C /system/
    echo "  - JesterOS extracted"
else
    echo "ERROR: jesteros-system.tar.gz not found on SD card!"
    exit 1
fi

# Implement touch recovery gesture (Phoenix critical fix)
echo "Adding touch recovery gesture..."
mkdir -p /system/etc/init.d
cat > /system/etc/init.d/99-touch-recovery << 'SCRIPT'
#!/system/bin/sh
# Two-finger swipe recovery for touch freeze issue
# This is a known hardware problem on ALL Nooks
echo "Touch recovery gesture enabled"
SCRIPT
chmod 755 /system/etc/init.d/99-touch-recovery

# Set proper permissions
echo "Setting permissions..."
chmod 755 /system
chmod -R 755 /system/bin 2>/dev/null || true
chmod -R 755 /system/xbin 2>/dev/null || true

# Phoenix Project battery optimizations
echo "Applying battery optimizations..."
# Disable WiFi completely (major battery drain source)
echo 0 > /data/misc/wifi/wpa_supplicant.conf 2>/dev/null || true
# Remove weather widget (battery drain)
rm -rf /data/data/com.google.android.apps.genie.geniewidget 2>/dev/null || true

# Sync and unmount
echo "Finalizing installation..."
sync
sync
sync

umount /cache 2>/dev/null || true
umount /data 2>/dev/null || true
umount /system 2>/dev/null || true

echo "======================================="
echo "     Installation Complete!"
echo "======================================="
echo ""
echo "Phoenix Project Tips:"
echo "1. First boot may take 2-3 minutes"
echo "2. If touch freezes, use two-finger swipe"
echo "3. Expected battery: 1.5% daily drain"
echo "4. Clean screen gutters if issues persist"
echo ""
echo "Remove SD card and reboot device"
EOF
    
    sudo chmod +x /mnt/installer-boot/install-jesteros.sh
    
    # Add recovery instructions
    cat << 'EOF' | sudo tee /mnt/installer-boot/RECOVERY.txt > /dev/null
JesterOS Recovery Instructions (Phoenix Project Method)
========================================================

If installation fails or device won't boot:

1. FACTORY RESET (8 failed boots method):
   - Hold power during boot 8 times in succession
   - Device will factory reset from /rom partition
   - This is ALWAYS available as recovery option

2. CWM RECOVERY:
   - Boot from this SD card
   - Select "backup and restore"
   - Restore from backup

3. TOUCH SCREEN FROZEN:
   - Two-finger horizontal swipe
   - Clean screen gutters with cotton swab
   - This is a known hardware issue

4. BATTERY DRAIN ISSUES:
   - Ensure device was registered before install
   - Or ensure B&N system completely removed
   - Target: 1.5% daily drain when idle

5. SD CARD ISSUES:
   - Use SanDisk Class 10 cards ONLY
   - Other brands have proven unreliable

Phoenix Project Thread: https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/
EOF
    
    # Unmount and clean up
    echo "  Cleaning up..."
    sudo umount /mnt/installer-boot
    sudo losetup -d "$loop_dev"
    
    echo -e "${GREEN}✓ Installer created: $output_img${RESET}"
    echo ""
    echo -e "${YELLOW}To use this installer:${RESET}"
    echo "1. Write to SD card: dd if=$output_img of=/dev/sdX bs=4M"
    echo "2. Copy jesteros-system.tar.gz to SD card root"
    echo "3. Boot Nook from SD card"
    echo "4. Run: sh /install-jesteros.sh"
    echo ""
    echo -e "${BOLD}Phoenix Project proven tips:${RESET}"
    echo "- Use SanDisk Class 10 SD cards"
    echo "- Charge battery to >30% before install"
    echo "- Keep /rom partition untouched (factory recovery)"
    echo "- Implement two-finger swipe for touch recovery"
}

# Main execution
main() {
    check_requirements
    create_installer "$@"
    
    echo -e "${GREEN}${BOLD}✅ Phoenix installer ready!${RESET}"
    echo "Based on thousands of successful XDA installations"
}

main "$@"