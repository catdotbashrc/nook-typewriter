#!/bin/bash
# WSL2 USB/SD Card Mounting Helper for Nook Deployment
# Handles Windows 11 USB passthrough via USBIPD-WIN
#
# Prerequisites:
#   Windows: Install usbipd-win from https://github.com/dorssel/usbipd-win/releases
#   WSL: sudo apt install linux-tools-virtual hwdata usbutils
#
# Medieval theme maintained for consistency with Nook Typewriter project

set -euo pipefail
trap 'echo "❌ Error at line $LINENO"' ERR

echo "═══════════════════════════════════════════════════════════════"
echo "     🏰 WSL USB Mount Helper for Nook Typewriter 📜"
echo "     Preparing thy SD card for medieval writing device"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Colors for better visibility
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if running in WSL
check_wsl() {
    if ! grep -qi microsoft /proc/version; then
        echo -e "${RED}❌ This script is designed for WSL2 on Windows${NC}"
        echo "   Detected environment: $(uname -r)"
        exit 1
    fi
    echo -e "${GREEN}✓ WSL2 environment detected${NC}"
}

# Function to check prerequisites
check_prerequisites() {
    echo ""
    echo "→ Checking prerequisites..."
    
    local missing_tools=()
    
    # Check for required WSL tools
    for tool in lsusb fdisk mkfs.fat mkfs.ext3; do
        if ! command -v $tool &> /dev/null; then
            missing_tools+=($tool)
        fi
    done
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        echo -e "${YELLOW}⚠️  Missing tools: ${missing_tools[*]}${NC}"
        echo ""
        echo "Install with:"
        echo "  sudo apt update"
        echo "  sudo apt install usbutils fdisk dosfstools e2fsprogs"
        exit 1
    fi
    
    echo -e "${GREEN}✓ All required tools installed${NC}"
}

# Function to show Windows-side instructions
show_windows_instructions() {
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo "📋 WINDOWS SIDE SETUP (Run in Administrator PowerShell)"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    echo "1️⃣  Install USBIPD-WIN if not already installed:"
    echo "    winget install --interactive --exact dorssel.usbipd-win"
    echo ""
    echo "2️⃣  List USB devices to find your SD card reader:"
    echo "    usbipd list"
    echo ""
    echo "3️⃣  Note the BUSID (like 2-4) for your SD card reader"
    echo ""
    echo "4️⃣  Attach the device to WSL:"
    echo "    usbipd bind --busid <BUSID>"
    echo "    usbipd attach --wsl --busid <BUSID>"
    echo ""
    echo "Example for SD card reader on bus 2-4:"
    echo "    ${GREEN}usbipd bind --busid 2-4${NC}"
    echo "    ${GREEN}usbipd attach --wsl --busid 2-4${NC}"
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
}

# Function to detect USB storage devices
detect_usb_devices() {
    echo ""
    echo "→ Scanning for USB storage devices in WSL..."
    echo ""
    
    # Check if any USB devices are visible
    if ! lsusb | grep -q "Mass Storage\|Card Reader"; then
        echo -e "${YELLOW}⚠️  No USB storage devices detected in WSL${NC}"
        echo ""
        echo "Make sure you've attached the device from Windows using:"
        echo "  ${GREEN}usbipd attach --wsl --busid <BUSID>${NC}"
        echo ""
        echo "Current USB devices visible in WSL:"
        lsusb || echo "No USB devices found"
        return 1
    fi
    
    echo -e "${GREEN}✓ USB storage device detected${NC}"
    echo ""
    echo "USB Devices:"
    lsusb | grep -E "Mass Storage|Card Reader" || lsusb
}

# Function to find block devices
find_block_devices() {
    echo ""
    echo "→ Looking for block devices..."
    echo ""
    
    # List all block devices
    echo "Available block devices:"
    lsblk -d -o NAME,SIZE,TYPE,MODEL 2>/dev/null || {
        echo -e "${RED}❌ No block devices found${NC}"
        echo "The USB device may not be properly attached to WSL"
        return 1
    }
    
    echo ""
    echo "Removable devices (likely your SD card):"
    
    # Find removable devices
    local removable_devices=()
    for device in /sys/block/sd*; do
        if [ -e "$device/removable" ] && [ "$(cat $device/removable)" = "1" ]; then
            local dev_name=$(basename $device)
            removable_devices+=("/dev/$dev_name")
            echo -e "${GREEN}  → /dev/$dev_name${NC}"
            
            # Show device details
            if [ -e "/dev/$dev_name" ]; then
                sudo fdisk -l "/dev/$dev_name" 2>/dev/null | grep "Disk /dev/" | head -1
            fi
        fi
    done
    
    if [ ${#removable_devices[@]} -eq 0 ]; then
        echo -e "${YELLOW}No removable devices found${NC}"
        echo ""
        echo "Your SD card might appear as a regular disk. Check these devices:"
        ls -la /dev/sd* 2>/dev/null | grep -E "sd[b-z]$" || echo "No additional SCSI devices found"
    fi
    
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo "💡 TIP: Your SD card is typically /dev/sdb or /dev/sdc"
    echo "   Look for a device matching your SD card size (2GB, 4GB, etc)"
    echo "═══════════════════════════════════════════════════════════════"
}

# Function to prepare SD card (with safety checks)
prepare_sd_card() {
    local device=$1
    
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo "🎯 READY TO PREPARE: $device"
    echo "═══════════════════════════════════════════════════════════════"
    
    # Safety check - confirm device
    echo ""
    echo -e "${YELLOW}⚠️  WARNING: This will ERASE all data on $device${NC}"
    sudo fdisk -l "$device" 2>/dev/null | grep -E "Disk|Disk model"
    
    echo ""
    read -p "Is this your SD card? Type 'yes' to continue: " confirmation
    
    if [ "$confirmation" != "yes" ]; then
        echo "Cancelled by user"
        return 1
    fi
    
    echo ""
    echo "→ This script has prepared the mount detection."
    echo "→ To partition and flash your SD card, run:"
    echo ""
    echo -e "${GREEN}   sudo ./tools/deploy/flash-sd.sh $device <image>${NC}"
    echo ""
    echo "Or follow the deployment guide:"
    echo -e "${GREEN}   cat docs/DEPLOYMENT_INTEGRATION_GUIDE.md${NC}"
}

# Main execution
main() {
    check_wsl
    check_prerequisites
    
    echo ""
    read -p "Have you attached the USB device from Windows? (y/n): " attached
    
    if [[ ! "$attached" =~ ^[Yy]$ ]]; then
        show_windows_instructions
        exit 0
    fi
    
    detect_usb_devices
    find_block_devices
    
    echo ""
    echo "📝 Next Steps:"
    echo "1. Identify your SD card device from the list above"
    echo "2. Run the deployment script with your device:"
    echo "   ${GREEN}sudo ./source/scripts/create-cwm-sdcard.sh${NC}"
    echo ""
    echo "Or manually partition using the deployment guide."
    
    # Optional: Direct preparation
    echo ""
    read -p "Do you want to select a device for preparation? (y/n): " prepare
    
    if [[ "$prepare" =~ ^[Yy]$ ]]; then
        echo ""
        read -p "Enter device path (e.g., /dev/sdb): " device_path
        
        if [ -b "$device_path" ]; then
            prepare_sd_card "$device_path"
        else
            echo -e "${RED}❌ Invalid device: $device_path${NC}"
            exit 1
        fi
    fi
    
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo "✅ WSL USB mount helper completed successfully!"
    echo "   May your words flow freely upon digital parchment! 📜"
    echo "═══════════════════════════════════════════════════════════════"
}

# Run main function
main "$@"