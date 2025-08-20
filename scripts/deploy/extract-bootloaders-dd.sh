#!/bin/bash
# Alternative bootloader extraction using dd (no mount required)
# Extracts bootloader files directly from ClockworkMod image

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CWM_IMAGE="${PROJECT_ROOT}/images/2gb_clockwork-rc2.img"
FIRMWARE_DIR="${PROJECT_ROOT}/firmware/boot"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
RESET='\033[0m'

echo -e "${BOLD}═══════════════════════════════════════════════════════════════${RESET}"
echo -e "${BOLD}    Alternative Bootloader Extraction (No Mount Required)${RESET}"
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
echo ""

# Create firmware directory if needed
mkdir -p "$FIRMWARE_DIR"

# Check if already extracted
if [[ -f "$FIRMWARE_DIR/MLO" ]] && [[ -f "$FIRMWARE_DIR/u-boot.bin" ]]; then
    echo -e "${YELLOW}Bootloaders already present:${RESET}"
    ls -lh "$FIRMWARE_DIR/MLO" "$FIRMWARE_DIR/u-boot.bin"
    echo ""
    echo "Use the existing files or manually delete them to re-extract"
    exit 0
fi

echo "Method 1: Extracting boot partition to file..."
echo "This method doesn't require sudo"
echo ""

# Extract the boot partition (first partition starting at sector 63)
# Size: 512MB (1048576 sectors of 512 bytes)
BOOT_PARTITION="${FIRMWARE_DIR}/boot_partition.img"

echo "Extracting boot partition (this may take a moment)..."
dd if="$CWM_IMAGE" of="$BOOT_PARTITION" bs=512 skip=63 count=1048576 status=progress

echo ""
echo -e "${GREEN}✓ Boot partition extracted${RESET}"
echo "  Size: $(ls -lh "$BOOT_PARTITION" | awk '{print $5}')"
echo ""

# Now we need to extract files from the FAT partition
# This still requires mount, but we can provide instructions
echo -e "${YELLOW}Next steps to extract bootloaders:${RESET}"
echo ""
echo "The boot partition has been extracted to:"
echo "  $BOOT_PARTITION"
echo ""
echo "To extract the bootloader files, run these commands with sudo:"
echo ""
echo -e "${BOLD}# Create temporary mount point${RESET}"
echo "mkdir -p /tmp/boot_mount"
echo ""
echo -e "${BOLD}# Mount the extracted partition${RESET}"
echo "sudo mount -o loop \"$BOOT_PARTITION\" /tmp/boot_mount"
echo ""
echo -e "${BOLD}# Copy bootloader files${RESET}"
echo "sudo cp /tmp/boot_mount/MLO \"$FIRMWARE_DIR/MLO\""
echo "sudo cp /tmp/boot_mount/u-boot.bin \"$FIRMWARE_DIR/u-boot.bin\""
echo "sudo chown $USER:$USER \"$FIRMWARE_DIR/MLO\" \"$FIRMWARE_DIR/u-boot.bin\""
echo ""
echo -e "${BOLD}# Unmount${RESET}"
echo "sudo umount /tmp/boot_mount"
echo "rmdir /tmp/boot_mount"
echo ""
echo "Alternatively, you can use a file manager with root privileges"
echo "to extract MLO and u-boot.bin from the partition image."
echo ""

# Try to use mtools if available (doesn't require mount)
if command -v mcopy >/dev/null 2>&1; then
    echo -e "${GREEN}mtools detected - attempting direct extraction...${RESET}"
    
    # Try to copy files using mtools (works with FAT without mounting)
    if mcopy -i "$BOOT_PARTITION" ::MLO "$FIRMWARE_DIR/MLO" 2>/dev/null; then
        echo -e "${GREEN}✓ MLO extracted using mtools${RESET}"
    else
        echo -e "${YELLOW}Could not extract MLO with mtools${RESET}"
    fi
    
    if mcopy -i "$BOOT_PARTITION" ::u-boot.bin "$FIRMWARE_DIR/u-boot.bin" 2>/dev/null; then
        echo -e "${GREEN}✓ u-boot.bin extracted using mtools${RESET}"
    else
        # Try alternative name
        if mcopy -i "$BOOT_PARTITION" ::u-boot "$FIRMWARE_DIR/u-boot.bin" 2>/dev/null; then
            echo -e "${GREEN}✓ u-boot extracted using mtools${RESET}"
        else
            echo -e "${YELLOW}Could not extract u-boot.bin with mtools${RESET}"
        fi
    fi
    
    # List files in the partition
    echo ""
    echo "Files in boot partition:"
    mdir -i "$BOOT_PARTITION" ::/ 2>/dev/null | head -20 || true
else
    echo -e "${YELLOW}Tip: Install mtools for mount-free extraction:${RESET}"
    echo "  sudo apt-get install mtools"
    echo ""
    echo "With mtools, you can extract files without sudo:"
    echo "  mcopy -i $BOOT_PARTITION ::MLO $FIRMWARE_DIR/MLO"
    echo "  mcopy -i $BOOT_PARTITION ::u-boot.bin $FIRMWARE_DIR/u-boot.bin"
fi

# Check if extraction was successful
echo ""
if [[ -f "$FIRMWARE_DIR/MLO" ]] && [[ -f "$FIRMWARE_DIR/u-boot.bin" ]]; then
    echo -e "${GREEN}✅ SUCCESS! Bootloaders extracted:${RESET}"
    ls -lh "$FIRMWARE_DIR/MLO" "$FIRMWARE_DIR/u-boot.bin"
    echo ""
    echo "You can now run: make firmware"
else
    echo -e "${YELLOW}⚠ Manual extraction required${RESET}"
    echo "Please follow the instructions above to extract the bootloader files"
fi