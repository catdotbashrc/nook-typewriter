#!/bin/bash
# SD Card Troubleshooting Script for WSL

set -e

echo "================================"
echo "SD Card Troubleshooting for WSL"
echo "================================"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check WSL version
echo "1. Checking WSL environment..."
if grep -qi microsoft /proc/version; then
    echo -e "${GREEN}✓${NC} Running in WSL"
    wsl.exe --version 2>/dev/null || echo "WSL version info not available"
else
    echo -e "${YELLOW}⚠${NC} Not running in WSL"
fi
echo ""

# Check Windows drives
echo "2. Checking Windows drive letters..."
echo "In Windows, verify your SD card has:"
echo "  - E: drive (FAT32 boot partition, ~100MB)"
echo "  - D: drive (F2FS/ext4 root partition, rest of card)"
echo ""

# Try Windows path access
echo "3. Testing Windows path access..."
if cmd.exe /c "dir E:\\" 2>/dev/null | head -5; then
    echo -e "${GREEN}✓${NC} E: drive accessible from Windows"
else
    echo -e "${RED}✗${NC} E: drive not accessible"
    echo "  Check if E: is assigned in Windows Disk Management"
fi
echo ""

if cmd.exe /c "dir D:\\" 2>/dev/null | head -5; then
    echo -e "${GREEN}✓${NC} D: drive accessible from Windows"
else
    echo -e "${RED}✗${NC} D: drive not accessible"
    echo "  Check if D: is assigned in Windows Disk Management"
fi
echo ""

# Alternative mount points
echo "4. Checking alternative mount points..."
for letter in c d e f g h; do
    if [ -d "/mnt/$letter" ]; then
        echo "Found: /mnt/$letter"
        # Try to access it
        if ls "/mnt/$letter/" >/dev/null 2>&1; then
            echo -e "  ${GREEN}✓${NC} Accessible"
            # Check if it might be SD card
            if [ -f "/mnt/$letter/uEnv.txt" ] || [ -f "/mnt/$letter/uImage" ]; then
                echo -e "  ${GREEN}✓${NC} Looks like boot partition!"
            elif [ -d "/mnt/$letter/root" ] || [ -d "/mnt/$letter/usr" ]; then
                echo -e "  ${GREEN}✓${NC} Looks like root partition!"
            fi
        else
            echo -e "  ${RED}✗${NC} Not accessible"
        fi
    fi
done
echo ""

# WSL mount fix suggestions
echo "5. Troubleshooting steps:"
echo ""
echo "Option A: Restart WSL"
echo "  In PowerShell (as admin):"
echo "  wsl --shutdown"
echo "  Then restart WSL"
echo ""
echo "Option B: Manual mount in WSL"
echo "  sudo mkdir -p /mnt/d /mnt/e"
echo "  sudo mount -t drvfs D: /mnt/d"
echo "  sudo mount -t drvfs E: /mnt/e"
echo ""
echo "Option C: Check Windows permissions"
echo "  1. Open Disk Management (diskmgmt.msc)"
echo "  2. Verify SD card partitions have drive letters"
echo "  3. Right-click each partition → Change Drive Letter"
echo ""
echo "Option D: Use different mount points"
echo "  If /mnt/d and /mnt/e don't work, try:"
echo "  /mnt/f, /mnt/g, etc. based on what's available"
echo ""

# Check if running as admin
echo "6. Permission check..."
if [ "$EUID" -eq 0 ]; then
    echo -e "${GREEN}✓${NC} Running with sudo"
else
    echo -e "${YELLOW}⚠${NC} Not running with sudo"
    echo "  Some operations may require: sudo $0"
fi
echo ""

# Direct deployment option
echo "7. Alternative deployment method:"
echo "  If WSL mount issues persist, try:"
echo "  1. Use Windows Explorer to access D: and E:"
echo "  2. Extract tarball with 7-Zip or WinRAR"
echo "  3. Copy files manually"
echo ""
echo "  Or use PowerShell:"
echo "  tar -xzf nook-deploy.tar.gz -C D:\\"
echo ""

echo "================================"
echo "Next Steps:"
echo "1. Verify drive letters in Windows Disk Management"
echo "2. Try manual mounting with sudo"
echo "3. Run deployment after fixing mounts"
echo "================================"