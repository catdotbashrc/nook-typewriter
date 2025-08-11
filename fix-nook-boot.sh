#!/bin/bash
# Fix Nook Boot Issues - Troubleshooting Script
# Run this in WSL with SD card mounted

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "════════════════════════════════════════"
echo "    Nook Boot Troubleshooting Script"
echo "════════════════════════════════════════"
echo ""

# Configuration
ROOT_PARTITION="${1:-/mnt/d}"  # D: drive - QuillOS root
BOOT_PARTITION="${2:-/mnt/e}"  # E: drive - Boot partition

echo "Checking current setup..."
echo "  Root partition: $ROOT_PARTITION"
echo "  Boot partition: $BOOT_PARTITION"
echo ""

# 1. Fix boot configuration for ext4
echo "1. Fixing boot configuration..."
if [ -f "$BOOT_PARTITION/uEnv.txt" ]; then
    echo "Current bootargs:"
    grep "^bootargs" "$BOOT_PARTITION/uEnv.txt" || true
    echo ""
    
    # Create corrected boot config
    cat > /tmp/uEnv.txt << 'EOF'
# Boot configuration for Nook Simple Touch - FIXED
# Using ext4 filesystem (NST kernel doesn't support F2FS)

# Boot arguments for Linux kernel
bootargs=console=ttyS0,115200n8 root=/dev/mmcblk0p2 rootfstype=ext4 rw rootwait mem=256M init=/sbin/init

# Boot commands - load kernel from FAT partition and boot
bootcmd=mmc rescan; fatload mmc 0:1 0x80300000 uImage; bootm 0x80300000

# Alternative minimal boot (if above fails)
# bootargs=console=ttyS0,115200n8 root=/dev/mmcblk0p2 rootfstype=ext4 rw rootwait
EOF
    
    echo "Backing up old config..."
    cp "$BOOT_PARTITION/uEnv.txt" "$BOOT_PARTITION/uEnv.txt.bak" 2>/dev/null || true
    
    echo "Installing fixed config..."
    sudo cp /tmp/uEnv.txt "$BOOT_PARTITION/uEnv.txt"
    echo -e "${GREEN}✓${NC} Boot config fixed for ext4"
else
    echo -e "${RED}✗${NC} No uEnv.txt found - creating new one"
    sudo cp /tmp/uEnv.txt "$BOOT_PARTITION/uEnv.txt"
fi
echo ""

# 2. Check for kernel
echo "2. Checking for kernel..."
if [ -f "$BOOT_PARTITION/uImage" ]; then
    echo -e "${GREEN}✓${NC} Kernel found"
    ls -lh "$BOOT_PARTITION/uImage"
    
    # Verify it's an ARM kernel
    if file "$BOOT_PARTITION/uImage" | grep -q "ARM"; then
        echo -e "${GREEN}✓${NC} Kernel is for ARM architecture"
    else
        echo -e "${YELLOW}⚠${NC} Kernel may not be for ARM"
    fi
else
    echo -e "${RED}✗${NC} CRITICAL: No kernel found!"
    echo ""
    echo "You MUST add a USB host-enabled kernel:"
    echo ""
    echo "Option 1: Download pre-built kernel"
    echo "  - Search XDA Forums for 'Nook Simple Touch USB host kernel'"
    echo "  - Look for kernel version 174 or later"
    echo "  - Copy the uImage file to $BOOT_PARTITION/"
    echo ""
    echo "Option 2: Use NookManager kernel"
    echo "  - If you have NookManager.img, extract its uImage"
    echo "  - It has USB host support enabled"
    echo ""
    echo "Option 3: Build QuillKernel"
    echo "  cd nst-kernel"
    echo "  docker build -f Dockerfile.build -t quillkernel ."
    echo "  docker run --rm -v \$(pwd):/output quillkernel"
    echo "  cp arch/arm/boot/uImage $BOOT_PARTITION/"
fi
echo ""

# 3. Verify init system
echo "3. Checking init system..."
if [ -f "$ROOT_PARTITION/sbin/init" ]; then
    echo -e "${GREEN}✓${NC} Init found at /sbin/init"
    file "$ROOT_PARTITION/sbin/init" | head -1
elif [ -f "$ROOT_PARTITION/bin/init" ]; then
    echo -e "${YELLOW}⚠${NC} Init at /bin/init - updating boot config"
    sudo sed -i 's|init=/sbin/init|init=/bin/init|' "$BOOT_PARTITION/uEnv.txt"
    echo -e "${GREEN}✓${NC} Boot config updated"
elif [ -f "$ROOT_PARTITION/init" ]; then
    echo -e "${YELLOW}⚠${NC} Init at /init - updating boot config"
    sudo sed -i 's|init=/sbin/init|init=/init|' "$BOOT_PARTITION/uEnv.txt"
    echo -e "${GREEN}✓${NC} Boot config updated"
else
    echo -e "${RED}✗${NC} No init system found!"
    echo "The root filesystem may be corrupted"
fi
echo ""

# 4. Check filesystem format
echo "4. Checking filesystem format..."
echo "The root partition MUST be formatted as ext4 (not F2FS)"
echo ""
echo "If you haven't formatted it yet:"
echo "  In Windows Disk Management:"
echo "  - D: drive should be ext4 (may show as 'RAW' in Windows)"
echo "  - E: drive should be FAT32"
echo ""
echo "Or use Linux/WSL:"
echo "  sudo mkfs.ext4 /dev/sdX2  # Replace X with your SD card letter"
echo ""

# 5. Fix permissions
echo "5. Fixing permissions..."
if [ -d "$ROOT_PARTITION/usr/local/bin" ]; then
    sudo chmod +x "$ROOT_PARTITION"/usr/local/bin/*.sh 2>/dev/null || true
    echo -e "${GREEN}✓${NC} Scripts made executable"
fi

if [ -f "$ROOT_PARTITION/usr/bin/vim" ]; then
    sudo chmod +x "$ROOT_PARTITION/usr/bin/vim" 2>/dev/null || true
    echo -e "${GREEN}✓${NC} Vim made executable"
fi
echo ""

# 6. Create debug boot option
echo "6. Creating debug boot option..."
cat > /tmp/uEnv-debug.txt << 'EOF'
# DEBUG boot configuration - verbose output
bootargs=console=ttyS0,115200n8 root=/dev/mmcblk0p2 rootfstype=ext4 rw rootwait debug earlyprintk loglevel=7
bootcmd=mmc rescan; fatload mmc 0:1 0x80300000 uImage; bootm 0x80300000
EOF
sudo cp /tmp/uEnv-debug.txt "$BOOT_PARTITION/uEnv-debug.txt"
echo -e "${GREEN}✓${NC} Debug config created (rename to uEnv.txt to use)"
echo ""

# Summary
echo "════════════════════════════════════════"
echo "            Troubleshooting Summary"
echo "════════════════════════════════════════"
echo ""

# Check critical issues
critical_issues=0

if [ ! -f "$BOOT_PARTITION/uImage" ]; then
    echo -e "${RED}✗ CRITICAL: Missing kernel - must add before booting${NC}"
    ((critical_issues++))
fi

if [ ! -f "$ROOT_PARTITION/sbin/init" ] && [ ! -f "$ROOT_PARTITION/bin/init" ] && [ ! -f "$ROOT_PARTITION/init" ]; then
    echo -e "${RED}✗ CRITICAL: No init system - redeploy filesystem${NC}"
    ((critical_issues++))
fi

if [ $critical_issues -eq 0 ]; then
    echo -e "${GREEN}✓ No critical issues found${NC}"
    echo ""
    echo "Try booting with these steps:"
    echo "1. Safely eject SD card in Windows"
    echo "2. Insert into Nook"
    echo "3. Power on while holding the power button for 3+ seconds"
    echo ""
    echo "If it still doesn't boot:"
    echo "- Try the debug config: rename uEnv-debug.txt to uEnv.txt"
    echo "- Connect via serial console to see boot messages"
    echo "- Check that root partition is ext4, not F2FS"
else
    echo -e "${RED}Fix the critical issues above before attempting to boot${NC}"
fi

echo ""
echo "For serial debugging, connect to UART pins inside Nook:"
echo "  TX/RX pins near SD card slot"
echo "  115200 baud, 8N1"
echo "  You'll see kernel messages during boot"