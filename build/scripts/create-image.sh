#!/bin/bash
# Nook SD Card Image Creator
# Creates a bootable SD card image file for the Nook Simple Touch
# Based on proven XDA methods and ClockworkMod recovery structure

set -euo pipefail

# Script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
RESET='\033[0m'

# Default configuration
DEFAULT_IMAGE_SIZE="2G"
IMAGE_NAME="${1:-nook-jesteros-$(date +%Y%m%d).img}"
IMAGE_PATH="${PROJECT_ROOT}/releases/${IMAGE_NAME}"

# Source files
KERNEL_IMAGE="${PROJECT_ROOT}/firmware/boot/uImage"
MLO_FILE="${PROJECT_ROOT}/firmware/boot/MLO"
UBOOT_FILE="${PROJECT_ROOT}/firmware/boot/u-boot.bin"
BOOT_SCRIPT="${PROJECT_ROOT}/firmware/boot/boot.scr"
ROOTFS_ARCHIVE="${PROJECT_ROOT}/nook-mvp-rootfs.tar.gz"

# Temporary mount points
TMP_DIR="/tmp/nook-image-$$"
BOOT_MOUNT="${TMP_DIR}/boot"
ROOT_MOUNT="${TMP_DIR}/root"

# Cleanup function
cleanup() {
    echo -e "${YELLOW}→ Cleaning up...${RESET}"
    
    # Unmount if mounted
    if mountpoint -q "$BOOT_MOUNT" 2>/dev/null; then
        sudo umount "$BOOT_MOUNT" || true
    fi
    if mountpoint -q "$ROOT_MOUNT" 2>/dev/null; then
        sudo umount "$ROOT_MOUNT" || true
    fi
    
    # Detach loop device if attached
    if [[ -n "${LOOP_DEVICE:-}" ]]; then
        sudo losetup -d "$LOOP_DEVICE" 2>/dev/null || true
    fi
    
    # Remove temporary directory
    rm -rf "$TMP_DIR"
}

# Set trap for cleanup
trap cleanup EXIT

echo -e "${BOLD}═══════════════════════════════════════════════════════════════${RESET}"
echo -e "${BOLD}       Nook JesterOS SD Card Image Creator${RESET}"
echo -e "${BOLD}═══════════════════════════════════════════════════════════════${RESET}"
echo ""

# Check if running as root (needed for mount operations)
if [[ $EUID -ne 0 ]]; then
   echo -e "${YELLOW}Note: This script needs sudo privileges for mount operations${RESET}"
   echo "Re-running with sudo..."
   exec sudo "$0" "$@"
fi

# Check for required files
echo "Checking required files..."

# Critical boot files check
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
    exit 1
fi

echo -e "${GREEN}✓ Kernel found: $(ls -lh "$KERNEL_IMAGE" | awk '{print $5}')${RESET}"
echo -e "${GREEN}✓ MLO found: $(ls -lh "$MLO_FILE" | awk '{print $5}')${RESET}"
echo -e "${GREEN}✓ U-Boot found: $(ls -lh "$UBOOT_FILE" | awk '{print $5}')${RESET}"

# Optional files
if [[ -f "$BOOT_SCRIPT" ]]; then
    echo -e "${GREEN}✓ Boot script found${RESET}"
    HAS_BOOT_SCRIPT=true
else
    echo -e "${YELLOW}⚠ Boot script not found, will create default${RESET}"
    HAS_BOOT_SCRIPT=false
fi

if [[ -f "$ROOTFS_ARCHIVE" ]]; then
    echo -e "${GREEN}✓ Root filesystem found: $(ls -lh "$ROOTFS_ARCHIVE" | awk '{print $5}')${RESET}"
    HAS_ROOTFS=true
else
    echo -e "${YELLOW}⚠ No rootfs archive, creating kernel-only image${RESET}"
    HAS_ROOTFS=false
fi

echo ""
echo -e "${BLUE}Creating image: ${IMAGE_PATH}${RESET}"
echo -e "${BLUE}Image size: ${DEFAULT_IMAGE_SIZE}${RESET}"
echo -e "${BLUE}Boot partition: 256MB FAT32${RESET}"
echo ""

# Create releases directory if it doesn't exist
mkdir -p "$(dirname "$IMAGE_PATH")"

# Create temporary directory
mkdir -p "$TMP_DIR" "$BOOT_MOUNT" "$ROOT_MOUNT"

# Step 1: Create the image file
echo -e "${BOLD}Step 1: Creating image file...${RESET}"
dd if=/dev/zero of="$IMAGE_PATH" bs=1M count=2048 status=progress 2>/dev/null || \
    dd if=/dev/zero of="$IMAGE_PATH" bs=1M count=2048

# Step 2: Set up loop device
echo -e "${BOLD}Step 2: Setting up loop device...${RESET}"
LOOP_DEVICE=$(losetup -f)
losetup "$LOOP_DEVICE" "$IMAGE_PATH"
echo "  Using loop device: $LOOP_DEVICE"

# Step 3: Create partition table
echo -e "${BOLD}Step 3: Creating partition table...${RESET}"
# Clear the first 10MB to ensure clean state
dd if=/dev/zero of="$LOOP_DEVICE" bs=1M count=10 2>/dev/null

# Create MBR partition table with proper Nook geometry
# Sector 63 alignment is CRITICAL for Nook boot
parted -s "$LOOP_DEVICE" mklabel msdos

# Create boot partition (256MB FAT32, starting at sector 63)
# FAT32 requires minimum 256MB for proper compatibility
echo "  Creating boot partition (256MB FAT32)..."
# Use sector units for precise alignment (sector 63 = 32256 bytes with 512-byte sectors)
parted -s "$LOOP_DEVICE" unit s mkpart primary fat32 63s 524287s
parted -s "$LOOP_DEVICE" set 1 boot on

# Create root partition (rest of space, ext4)
echo "  Creating root partition (ext4)..."
# Start at next sector after boot partition ends
parted -s "$LOOP_DEVICE" unit s mkpart primary ext4 524288s 100%

# Re-read partition table
partprobe "$LOOP_DEVICE" 2>/dev/null || true
sleep 1

# Step 4: Format partitions
echo -e "${BOLD}Step 4: Formatting partitions...${RESET}"

# Detach and reattach with partition scan
losetup -d "$LOOP_DEVICE"
LOOP_DEVICE=$(losetup -f --show -P "$IMAGE_PATH")
echo "  Re-attached as: $LOOP_DEVICE"

# Format boot partition
echo "  Formatting boot partition..."
mkfs.vfat -F 32 -n BOOT "${LOOP_DEVICE}p1"

# Format root partition
echo "  Formatting root partition..."
mkfs.ext4 -L rootfs "${LOOP_DEVICE}p2"

# Step 5: Mount partitions
echo -e "${BOLD}Step 5: Mounting partitions...${RESET}"
mount "${LOOP_DEVICE}p1" "$BOOT_MOUNT"
mount "${LOOP_DEVICE}p2" "$ROOT_MOUNT"

# Step 6: Copy bootloaders
echo -e "${BOLD}Step 6: Installing bootloaders...${RESET}"
# MLO MUST be copied first for contiguous allocation (OMAP requirement)
echo "  Copying MLO (must be first)..."
cp "$MLO_FILE" "$BOOT_MOUNT/MLO"
sync

echo "  Copying u-boot.bin..."
cp "$UBOOT_FILE" "$BOOT_MOUNT/u-boot.bin"
sync

# Step 7: Copy kernel
echo -e "${BOLD}Step 7: Installing kernel...${RESET}"
cp "$KERNEL_IMAGE" "$BOOT_MOUNT/uImage"
echo -e "${GREEN}  ✓ Kernel installed${RESET}"

# Step 8: Create or copy boot script
echo -e "${BOLD}Step 8: Setting up boot script...${RESET}"
if [[ "$HAS_BOOT_SCRIPT" == "true" ]]; then
    cp "$BOOT_SCRIPT" "$BOOT_MOUNT/boot.scr"
    echo -e "${GREEN}  ✓ Boot script copied${RESET}"
else
    # Create default boot script for Nook
    cat > "$BOOT_MOUNT/boot.scr.txt" << 'EOF'
# Nook Simple Touch Boot Script for JesterOS
# Boot from SD card with minimal kernel
setenv bootargs console=ttyS0,115200n8 root=/dev/mmcblk0p2 rootfstype=ext4 rootwait rw init=/init
fatload mmc 0:1 0x80000000 uImage
bootm 0x80000000
EOF
    echo -e "${GREEN}  ✓ Default boot script created${RESET}"
fi

# Step 9: Install root filesystem (if available)
if [[ "$HAS_ROOTFS" == "true" ]]; then
    echo -e "${BOLD}Step 9: Installing root filesystem...${RESET}"
    echo "  Extracting rootfs (this may take a moment)..."
    tar -xzf "$ROOTFS_ARCHIVE" -C "$ROOT_MOUNT/"
    
    # Ensure init is executable
    if [[ -f "$ROOT_MOUNT/init" ]]; then
        chmod +x "$ROOT_MOUNT/init"
    fi
    
    echo -e "${GREEN}  ✓ Root filesystem installed${RESET}"
else
    echo -e "${BOLD}Step 9: Creating minimal root filesystem...${RESET}"
    # Create minimal structure for kernel-only boot
    mkdir -p "$ROOT_MOUNT"/{proc,sys,dev,tmp,root}
    
    # Create a simple init script
    cat > "$ROOT_MOUNT/init" << 'EOF'
#!/bin/sh
# Minimal init for JesterOS kernel testing
/bin/mount -t proc proc /proc
/bin/mount -t sysfs sys /sys
echo "JesterOS kernel booted successfully!"
echo "The jester awakens..."
exec /bin/sh
EOF
    chmod +x "$ROOT_MOUNT/init"
    
    echo -e "${YELLOW}  ⚠ Minimal rootfs created (kernel testing only)${RESET}"
fi

# Step 10: Final sync and unmount
echo -e "${BOLD}Step 10: Finalizing image...${RESET}"
echo "  Syncing filesystem..."
sync

# Show final partition layout
echo ""
echo "Partition layout:"
fdisk -l "$LOOP_DEVICE" | grep "^${LOOP_DEVICE}"

# Calculate checksums
echo ""
echo "Calculating checksums..."
MD5_HASH=$(md5sum "$IMAGE_PATH" | cut -d' ' -f1)
SHA256_HASH=$(sha256sum "$IMAGE_PATH" | cut -d' ' -f1)

# Create checksum file
CHECKSUM_FILE="${IMAGE_PATH}.checksums"
cat > "$CHECKSUM_FILE" << EOF
MD5:    $MD5_HASH
SHA256: $SHA256_HASH
File:   $(basename "$IMAGE_PATH")
Date:   $(date -u +"%Y-%m-%d %H:%M:%S UTC")
EOF

echo -e "${GREEN}✓ Checksums saved to $(basename "$CHECKSUM_FILE")${RESET}"

# Show final size
FINAL_SIZE=$(du -h "$IMAGE_PATH" | cut -f1)

echo ""
echo -e "${BOLD}═══════════════════════════════════════════════════════════════${RESET}"
echo -e "${GREEN}✓ SD card image created successfully!${RESET}"
echo -e "${BOLD}═══════════════════════════════════════════════════════════════${RESET}"
echo ""
echo -e "${BLUE}Image file:${RESET} $IMAGE_PATH"
echo -e "${BLUE}Image size:${RESET} $FINAL_SIZE"
echo -e "${BLUE}MD5:${RESET} $MD5_HASH"
echo ""
echo "To write to SD card:"
echo "  sudo dd if=$IMAGE_PATH of=/dev/sdX bs=4M status=progress"
echo ""
echo "Or use a tool like Etcher or Win32DiskImager on Windows"
echo ""
echo -e "${YELLOW}The Jester proclaims: 'Thy digital scroll is ready!'${RESET}"