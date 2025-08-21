#!/bin/bash
# Extract bootloader files from ClockworkMod recovery image
# These are required for SD card boot but not built from source

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CWM_IMAGE="${PROJECT_ROOT}/images/2gb_clockwork-rc2.img"
FIRMWARE_DIR="${PROJECT_ROOT}/firmware/boot"
TEMP_MOUNT=$(mktemp -d)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
RESET='\033[0m'

# Cleanup function
cleanup() {
    if mountpoint -q "$TEMP_MOUNT" 2>/dev/null; then
        echo "Cleaning up mount point..."
        sudo umount "$TEMP_MOUNT" 2>/dev/null || true
    fi
    rmdir "$TEMP_MOUNT" 2>/dev/null || true
}

# Set trap for cleanup
trap cleanup EXIT

echo -e "${BOLD}═══════════════════════════════════════════════════════════════${RESET}"
echo -e "${BOLD}       Bootloader Extraction from ClockworkMod Image${RESET}"
echo -e "${BOLD}═══════════════════════════════════════════════════════════════${RESET}"
echo ""

# Check for CWM image, download if missing
if [[ ! -f "$CWM_IMAGE" ]]; then
    echo -e "${YELLOW}ClockworkMod image not found locally${RESET}"
    echo "Expected at: $CWM_IMAGE"
    echo ""
    
    # Offer to download
    echo "The image can be downloaded from XDA Forums (158MB compressed, 2GB uncompressed)"
    read -p "Download now? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Downloading from XDA Forums..."
        mkdir -p "$(dirname "$CWM_IMAGE")"
        
        # Download the zip file
        ZIP_FILE="${PROJECT_ROOT}/images/sd_2gb_clockwork-rc2.zip"
        if command -v wget >/dev/null 2>&1; then
            wget -O "$ZIP_FILE" "https://xdaforums.com/attachments/sd_2gb_clockwork-rc2-zip.806434/" || {
                echo -e "${RED}Download failed!${RESET}"
                echo "Please download manually from:"
                echo "  https://xdaforums.com/attachments/sd_2gb_clockwork-rc2-zip.806434/"
                exit 1
            }
        elif command -v curl >/dev/null 2>&1; then
            curl -L -o "$ZIP_FILE" "https://xdaforums.com/attachments/sd_2gb_clockwork-rc2-zip.806434/" || {
                echo -e "${RED}Download failed!${RESET}"
                echo "Please download manually from:"
                echo "  https://xdaforums.com/attachments/sd_2gb_clockwork-rc2-zip.806434/"
                exit 1
            }
        else
            echo -e "${RED}Neither wget nor curl found!${RESET}"
            echo "Please install wget or curl, or download manually from:"
            echo "  https://xdaforums.com/attachments/sd_2gb_clockwork-rc2-zip.806434/"
            exit 1
        fi
        
        echo "Extracting image (this will expand to 2GB)..."
        if command -v unzip >/dev/null 2>&1; then
            unzip -j "$ZIP_FILE" -d "$(dirname "$CWM_IMAGE")" || {
                echo -e "${RED}Extraction failed!${RESET}"
                exit 1
            }
        else
            echo -e "${RED}unzip not found! Please install unzip${RESET}"
            exit 1
        fi
        
        # Clean up zip file to save space
        echo "Cleaning up compressed file..."
        rm -f "$ZIP_FILE"
        
        # Verify the image was extracted
        if [[ ! -f "$CWM_IMAGE" ]]; then
            echo -e "${RED}Image not found after extraction!${RESET}"
            echo "Expected: $CWM_IMAGE"
            exit 1
        fi
        
        echo -e "${GREEN}✓ ClockworkMod image downloaded and extracted${RESET}"
    else
        echo "Please download manually from:"
        echo "  https://xdaforums.com/attachments/sd_2gb_clockwork-rc2-zip.806434/"
        echo "Extract and place at: $CWM_IMAGE"
        exit 1
    fi
fi

echo -e "${GREEN}✓ Found ClockworkMod image${RESET}"
echo "  Size: $(ls -lh "$CWM_IMAGE" | awk '{print $5}')"
echo ""

# Create firmware directory if needed
mkdir -p "$FIRMWARE_DIR"

# Check if already extracted
if [[ -f "$FIRMWARE_DIR/MLO" ]] && [[ -f "$FIRMWARE_DIR/u-boot.bin" ]]; then
    echo -e "${YELLOW}Bootloaders already extracted:${RESET}"
    ls -lh "$FIRMWARE_DIR/MLO" "$FIRMWARE_DIR/u-boot.bin"
    echo ""
    read -p "Re-extract? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Keeping existing bootloaders"
        exit 0
    fi
fi

echo "Mounting ClockworkMod image..."
# Calculate offset: sector 63 * 512 bytes/sector = 32256
OFFSET=$((63 * 512))

# Try different mount options for compatibility
if sudo mount -o loop,offset=$OFFSET,ro "$CWM_IMAGE" "$TEMP_MOUNT" 2>/dev/null; then
    echo -e "${GREEN}✓ Image mounted successfully${RESET}"
elif sudo mount -o loop,offset=$OFFSET,ro,sizelimit=536870912 "$CWM_IMAGE" "$TEMP_MOUNT" 2>/dev/null; then
    echo -e "${GREEN}✓ Image mounted with size limit${RESET}"
else
    echo -e "${RED}Failed to mount image!${RESET}"
    echo "Trying alternative method..."
    
    # Alternative: Extract with dd
    echo "Extracting boot partition with dd..."
    dd if="$CWM_IMAGE" of="${TEMP_MOUNT}.img" bs=512 skip=63 count=1048576 status=progress
    
    # Try to mount extracted partition
    if sudo mount -o loop "${TEMP_MOUNT}.img" "$TEMP_MOUNT"; then
        echo -e "${GREEN}✓ Extracted partition mounted${RESET}"
    else
        echo -e "${RED}Failed to mount partition!${RESET}"
        rm -f "${TEMP_MOUNT}.img"
        exit 1
    fi
fi

echo ""
echo "Searching for bootloader files..."

# Look for MLO
if [[ -f "$TEMP_MOUNT/MLO" ]]; then
    echo -e "${GREEN}✓ Found MLO${RESET}"
    sudo cp "$TEMP_MOUNT/MLO" "$FIRMWARE_DIR/"
    sudo chown $USER:$USER "$FIRMWARE_DIR/MLO"
    chmod 644 "$FIRMWARE_DIR/MLO"
elif [[ -f "$TEMP_MOUNT/mlo" ]]; then
    echo -e "${GREEN}✓ Found mlo (renaming to MLO)${RESET}"
    sudo cp "$TEMP_MOUNT/mlo" "$FIRMWARE_DIR/MLO"
    sudo chown $USER:$USER "$FIRMWARE_DIR/MLO"
    chmod 644 "$FIRMWARE_DIR/MLO"
else
    echo -e "${RED}✗ MLO not found in image${RESET}"
fi

# Look for u-boot.bin
if [[ -f "$TEMP_MOUNT/u-boot.bin" ]]; then
    echo -e "${GREEN}✓ Found u-boot.bin${RESET}"
    sudo cp "$TEMP_MOUNT/u-boot.bin" "$FIRMWARE_DIR/"
    sudo chown $USER:$USER "$FIRMWARE_DIR/u-boot.bin"
    chmod 644 "$FIRMWARE_DIR/u-boot.bin"
elif [[ -f "$TEMP_MOUNT/u-boot" ]]; then
    echo -e "${GREEN}✓ Found u-boot (renaming to u-boot.bin)${RESET}"
    sudo cp "$TEMP_MOUNT/u-boot" "$FIRMWARE_DIR/u-boot.bin"
    sudo chown $USER:$USER "$FIRMWARE_DIR/u-boot.bin"
    chmod 644 "$FIRMWARE_DIR/u-boot.bin"
else
    echo -e "${RED}✗ u-boot.bin not found in image${RESET}"
fi

# Look for any boot scripts
for script in boot.scr u-boot.scr boot.scr.uimg; do
    if [[ -f "$TEMP_MOUNT/$script" ]]; then
        echo -e "${GREEN}✓ Found $script${RESET}"
        sudo cp "$TEMP_MOUNT/$script" "$FIRMWARE_DIR/"
        sudo chown $USER:$USER "$FIRMWARE_DIR/$script"
        chmod 644 "$FIRMWARE_DIR/$script"
    fi
done

# List what we found
echo ""
echo "Contents of boot partition:"
ls -la "$TEMP_MOUNT" 2>/dev/null | head -20 || true

# Unmount
echo ""
echo "Unmounting image..."
sudo umount "$TEMP_MOUNT"

# Clean up alternative extraction if used
[[ -f "${TEMP_MOUNT}.img" ]] && rm -f "${TEMP_MOUNT}.img"

# Verify extraction
echo ""
echo -e "${BOLD}Extraction Results:${RESET}"
if [[ -f "$FIRMWARE_DIR/MLO" ]] && [[ -f "$FIRMWARE_DIR/u-boot.bin" ]]; then
    echo -e "${GREEN}✓ All bootloaders extracted successfully!${RESET}"
    echo ""
    echo "Extracted files:"
    ls -lh "$FIRMWARE_DIR"/MLO "$FIRMWARE_DIR"/u-boot.bin
    echo ""
    echo -e "${GREEN}Ready for SD card creation!${RESET}"
    exit 0
else
    echo -e "${YELLOW}⚠ Some bootloaders missing:${RESET}"
    [[ ! -f "$FIRMWARE_DIR/MLO" ]] && echo "  - MLO not found"
    [[ ! -f "$FIRMWARE_DIR/u-boot.bin" ]] && echo "  - u-boot.bin not found"
    echo ""
    echo "You may need to obtain these files separately or build U-Boot from source"
    exit 1
fi