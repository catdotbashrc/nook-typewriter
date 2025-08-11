#!/bin/bash
# Deploy script for Nook SD card
# Run this in WSL with your SD card mounted as D: and E: drives

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "════════════════════════════════════════"
echo "    Nook Typewriter Deployment Script"
echo "════════════════════════════════════════"
echo ""

# Check if running in WSL
if ! grep -qi microsoft /proc/version; then
    echo -e "${YELLOW}Warning: Not running in WSL${NC}"
    echo "This script is designed for WSL. Continue anyway? (y/n)"
    read -n 1 confirm
    [[ "$confirm" != "y" ]] && exit 1
fi

# Configuration
ROOT_PARTITION="${1:-/mnt/d}"  # D: drive - QuillOS
BOOT_PARTITION="${2:-/mnt/e}"  # E: drive - Kernel
TARBALL="${3:-nook-deploy.tar.gz}"

echo "Configuration:"
echo "  Root partition: $ROOT_PARTITION (D: QuillOS)"
echo "  Boot partition: $BOOT_PARTITION (E: Kernel)"
echo "  Tarball: $TARBALL"
echo ""

# Verify tarball exists
if [ ! -f "$TARBALL" ]; then
    echo -e "${RED}ERROR: Tarball $TARBALL not found!${NC}"
    echo "Run: docker export nook-export | gzip > nook-deploy.tar.gz"
    exit 1
fi

# Check partitions are accessible
echo "Checking partitions..."
if [ ! -d "$ROOT_PARTITION" ]; then
    echo -e "${RED}ERROR: Root partition not accessible at $ROOT_PARTITION${NC}"
    echo "Make sure D: drive is accessible in WSL"
    exit 1
fi

if [ ! -d "$BOOT_PARTITION" ]; then
    echo -e "${RED}ERROR: Boot partition not accessible at $BOOT_PARTITION${NC}"
    echo "Make sure E: drive is accessible in WSL"
    exit 1
fi

echo -e "${GREEN}✓${NC} Partitions accessible"

# Backup warning
echo ""
echo -e "${YELLOW}⚠ WARNING: This will DELETE everything on D: drive${NC}"
echo "Continue? (y/n)"
read -n 1 confirm
echo ""
[[ "$confirm" != "y" ]] && exit 1

# Clean root partition
echo "Cleaning root partition (D: drive)..."
sudo rm -rf "$ROOT_PARTITION"/* 2>/dev/null || true
sudo rm -rf "$ROOT_PARTITION"/.* 2>/dev/null || true
echo -e "${GREEN}✓${NC} Root partition cleaned"

# Extract system
echo "Extracting system to root partition..."
echo "This may take a few minutes..."
cd "$ROOT_PARTITION"
sudo tar -xzf "$OLDPWD/$TARBALL" --checkpoint=.1000
echo ""
echo -e "${GREEN}✓${NC} System extracted"

# Verify extraction
if [ -d "$ROOT_PARTITION/root" ] && [ -d "$ROOT_PARTITION/usr" ]; then
    echo -e "${GREEN}✓${NC} Filesystem structure verified"
else
    echo -e "${RED}ERROR: Extraction failed!${NC}"
    exit 1
fi

# Create boot configuration
echo "Creating boot configuration..."
sudo tee "$BOOT_PARTITION/uEnv.txt" > /dev/null << 'EOF'
# Boot configuration for Nook Simple Touch
# QuillOS with USB keyboard support

bootargs=console=ttyS0,115200n8 root=/dev/mmcblk0p2 rootfstype=f2fs rw rootwait mem=256M init=/sbin/init
bootcmd=mmc rescan; fatload mmc 0:1 0x80300000 uImage; bootm 0x80300000

# Alternative for ext4 (if F2FS doesn't work)
# bootargs=console=ttyS0,115200n8 root=/dev/mmcblk0p2 rootfstype=ext4 rw rootwait mem=256M init=/sbin/init
EOF
echo -e "${GREEN}✓${NC} Boot configuration created"

# Check for kernel
if [ -f "$BOOT_PARTITION/uImage" ]; then
    echo -e "${GREEN}✓${NC} Kernel already present"
else
    echo -e "${YELLOW}⚠${NC} No kernel found in E: drive"
    echo ""
    echo "You need to add a USB host-enabled kernel!"
    echo "Options:"
    echo "1. Download from XDA Forums (search 'Nook Simple Touch USB host kernel')"
    echo "2. Build QuillKernel from nst-kernel/ directory"
    echo "3. Copy from your rooted Nook's /boot/ directory"
    echo ""
    echo "Copy the uImage file to E: drive"
fi

# Fix permissions
echo "Setting permissions..."
sudo chmod +x "$ROOT_PARTITION"/usr/local/bin/*.sh 2>/dev/null || true
sudo chmod +x "$ROOT_PARTITION"/usr/bin/vim 2>/dev/null || true
echo -e "${GREEN}✓${NC} Permissions set"

# Summary
echo ""
echo "════════════════════════════════════════"
echo "         Deployment Complete!"
echo "════════════════════════════════════════"
echo ""
echo "System info:"
SIZE=$(du -sh "$ROOT_PARTITION" 2>/dev/null | cut -f1)
echo "  Root filesystem size: $SIZE"
echo "  Vim mode: Writer (5MB RAM)"
echo "  Plugins: Goyo + Pencil"
echo ""

if [ ! -f "$BOOT_PARTITION/uImage" ]; then
    echo -e "${YELLOW}⚠ IMPORTANT: Add kernel to E: drive before booting!${NC}"
    echo ""
fi

echo "Next steps:"
echo "1. Ensure kernel (uImage) is in E: drive"
echo "2. Safely eject SD card in Windows"
echo "3. Insert into Nook"
echo "4. Connect USB keyboard via OTG cable"
echo "5. Power on Nook"
echo ""
echo "Happy writing! 📝"