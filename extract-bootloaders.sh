#!/bin/bash
# Extract MLO and u-boot.bin from CWM image for ground-up boot
# These are the only files we need from CWM

set -euo pipefail

CWM_IMAGE="${1:-images/2gb_clockwork-rc2.img}"
OUTPUT_DIR="bootloader"

echo "JoKernel Bootloader Extractor"
echo "=============================="
echo ""
echo "This extracts ONLY the bootloader files we need"
echo "MLO and u-boot.bin - nothing else from CWM"
echo ""

# Check if CWM image exists
if [ ! -f "$CWM_IMAGE" ]; then
    echo "Error: CWM image not found: $CWM_IMAGE"
    echo ""
    echo "Download it from XDA forums:"
    echo "https://xdaforums.com/t/nst-cwr-rc2-clockworkmod-based-recovery-fixed-backup-issue.1360994/"
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Create temporary mount point
TEMP_MOUNT=$(mktemp -d)
TEMP_DEVICE=""

# Cleanup function
cleanup() {
    if [ -n "$TEMP_DEVICE" ]; then
        sudo umount "$TEMP_MOUNT" 2>/dev/null || true
        sudo losetup -d "$TEMP_DEVICE" 2>/dev/null || true
    fi
    rmdir "$TEMP_MOUNT" 2>/dev/null || true
}
trap cleanup EXIT

echo "Setting up loop device..."
# Setup loop device for the image
TEMP_DEVICE=$(sudo losetup --show -f -P "$CWM_IMAGE")

# Mount the first partition (boot)
echo "Mounting boot partition..."
sudo mount "${TEMP_DEVICE}p1" "$TEMP_MOUNT"

# Extract bootloader files
echo "Extracting bootloader files..."
if [ -f "$TEMP_MOUNT/MLO" ]; then
    sudo cp "$TEMP_MOUNT/MLO" "$OUTPUT_DIR/MLO"
    echo "  ✓ Extracted MLO"
else
    echo "  ✗ MLO not found!"
fi

if [ -f "$TEMP_MOUNT/u-boot.bin" ]; then
    sudo cp "$TEMP_MOUNT/u-boot.bin" "$OUTPUT_DIR/u-boot.bin"
    echo "  ✓ Extracted u-boot.bin"
else
    # Try alternate names
    if [ -f "$TEMP_MOUNT/u-boot.img" ]; then
        sudo cp "$TEMP_MOUNT/u-boot.img" "$OUTPUT_DIR/u-boot.bin"
        echo "  ✓ Extracted u-boot.img as u-boot.bin"
    else
        echo "  ✗ u-boot.bin not found!"
    fi
fi

# Optional: grab other potentially useful files
if [ -f "$TEMP_MOUNT/mlo" ]; then
    sudo cp "$TEMP_MOUNT/mlo" "$OUTPUT_DIR/mlo.backup"
    echo "  ✓ Found lowercase mlo (backup)"
fi

# Fix permissions
sudo chown -R $(whoami):$(whoami) "$OUTPUT_DIR"
chmod 644 "$OUTPUT_DIR"/*

# Show what we got
echo ""
echo "Extracted files:"
ls -la "$OUTPUT_DIR"

echo ""
echo "Bootloader extraction complete!"
echo ""
echo "These files are now ready for ground-up boot creation:"
echo "  $OUTPUT_DIR/MLO        - First stage bootloader"
echo "  $OUTPUT_DIR/u-boot.bin - Second stage bootloader"
echo ""
echo "Use with: sudo ./create-boot-from-scratch.sh /dev/sdX"