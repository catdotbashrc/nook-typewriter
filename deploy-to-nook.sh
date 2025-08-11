#!/bin/bash
#
# Nook Typewriter Deployment Script
# ==================================
# Deploy QuillOS system to SD card for Nook Simple Touch
#
# Usage: ./deploy-to-nook.sh [root_partition] [boot_partition] [tarball]
#   root_partition - Path to root partition (default: /mnt/d)
#   boot_partition - Path to boot partition (default: /mnt/e)
#   tarball       - System tarball to deploy (default: nook-deploy.tar.gz)
#
# Requirements:
#   - Running in WSL or Linux
#   - SD card with two partitions (FAT32 boot, ext4 root)
#   - Docker-exported system tarball
#
# Exit codes:
#   0 - Success
#   1 - User cancelled or general error
#   2 - Missing dependencies
#   3 - Partition access error
#

set -euo pipefail

# Script configuration
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Color definitions for output formatting
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[1;33m'
readonly COLOR_RED='\033[0;31m'
readonly COLOR_RESET='\033[0m'

# Logging functions for consistent output
log_info() {
    echo -e "${COLOR_GREEN}[INFO]${COLOR_RESET} $*"
}

log_warn() {
    echo -e "${COLOR_YELLOW}[WARN]${COLOR_RESET} $*" >&2
}

log_error() {
    echo -e "${COLOR_RED}[ERROR]${COLOR_RESET} $*" >&2
}

log_success() {
    echo -e "${COLOR_GREEN}✓${COLOR_RESET} $*"
}

# Display script header
show_header() {
    echo "════════════════════════════════════════"
    echo "    Nook Typewriter Deployment Script"
    echo "════════════════════════════════════════"
    echo ""
}

show_header

# Check runtime environment
check_environment() {
    if ! grep -qi microsoft /proc/version 2>/dev/null; then
        log_warn "Not running in WSL - script is optimized for WSL"
        echo -n "Continue anyway? (y/n): "
        read -r -n 1 confirm
        echo
        if [[ "${confirm,,}" != "y" ]]; then
            log_info "Deployment cancelled by user"
            exit 1
        fi
    fi
}

check_environment

# Parse command line arguments with defaults
readonly ROOT_PARTITION="${1:-/mnt/d}"     # Root filesystem partition (ext4)
readonly BOOT_PARTITION="${2:-/mnt/e}"     # Boot partition (FAT32)
readonly TARBALL="${3:-nook-deploy.tar.gz}" # System tarball to deploy

# Display deployment configuration
show_configuration() {
    echo "Deployment Configuration:"
    echo "  Root partition: $ROOT_PARTITION (ext4 filesystem)"
    echo "  Boot partition: $BOOT_PARTITION (FAT32 for kernel)"
    echo "  System tarball: $TARBALL"
    echo ""
}

show_configuration

# Verify required files exist
verify_tarball() {
    if [[ ! -f "$TARBALL" ]]; then
        log_error "System tarball not found: $TARBALL"
        echo "To create the tarball, run:"
        echo "  docker build -t nook-system -f nookwriter-optimized.dockerfile ."
        echo "  docker create --name nook-export nook-system"
        echo "  docker export nook-export | gzip > nook-deploy.tar.gz"
        echo "  docker rm nook-export"
        exit 2
    fi
    log_success "System tarball found: $TARBALL"
}

verify_tarball

# Verify partition accessibility
verify_partitions() {
    local errors=0
    
    log_info "Checking partition accessibility..."
    
    if [[ ! -d "$ROOT_PARTITION" ]]; then
        log_error "Root partition not accessible: $ROOT_PARTITION"
        echo "  Ensure the SD card is properly mounted in WSL"
        echo "  Try: sudo mount /dev/sdX2 $ROOT_PARTITION"
        ((errors++))
    fi
    
    if [[ ! -d "$BOOT_PARTITION" ]]; then
        log_error "Boot partition not accessible: $BOOT_PARTITION"
        echo "  Ensure the SD card is properly mounted in WSL"
        echo "  Try: sudo mount /dev/sdX1 $BOOT_PARTITION"
        ((errors++))
    fi
    
    if [[ $errors -gt 0 ]]; then
        exit 3
    fi
    
    log_success "Both partitions accessible"
}

verify_partitions

# Confirm destructive operation with user
confirm_deployment() {
    echo ""
    log_warn "⚠ WARNING: This will DELETE all data on $ROOT_PARTITION"
    echo -n "Are you sure you want to continue? (y/n): "
    read -r -n 1 confirm
    echo ""
    
    if [[ "${confirm,,}" != "y" ]]; then
        log_info "Deployment cancelled by user"
        exit 1
    fi
}

confirm_deployment

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