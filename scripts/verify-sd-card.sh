#!/bin/bash
# SD Card Verification Script for Nook Typewriter
# Run this in WSL after deploying the system

set -e

echo "================================"
echo "SD Card Verification Script"
echo "================================"
echo

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running in WSL
if ! grep -qi microsoft /proc/version; then
    echo -e "${YELLOW}Warning: Not running in WSL. Some checks may fail.${NC}"
fi

# Function to check if path exists
check_path() {
    local path=$1
    local description=$2
    if [ -e "$path" ]; then
        echo -e "${GREEN}✓${NC} $description exists"
        return 0
    else
        echo -e "${RED}✗${NC} $description missing at $path"
        return 1
    fi
}

# Function to check file size
check_size() {
    local file=$1
    local min_size=$2
    local description=$3
    if [ -f "$file" ]; then
        size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null || echo 0)
        if [ "$size" -gt "$min_size" ]; then
            echo -e "${GREEN}✓${NC} $description ($(numfmt --to=iec-i --suffix=B $size))"
            return 0
        else
            echo -e "${RED}✗${NC} $description too small ($(numfmt --to=iec-i --suffix=B $size))"
            return 1
        fi
    else
        echo -e "${RED}✗${NC} $description not found"
        return 1
    fi
}

# Default paths (can be overridden)
BOOT_PARTITION="${1:-/mnt/e}"
ROOT_PARTITION="${2:-/mnt/d}"

echo "Checking partitions:"
echo "  Boot: $BOOT_PARTITION"
echo "  Root: $ROOT_PARTITION"
echo

# Check if partitions are mounted
echo "1. Checking partition mounts..."
if mount | grep -q "$BOOT_PARTITION"; then
    echo -e "${GREEN}✓${NC} Boot partition is mounted"
    df -h "$BOOT_PARTITION" | tail -1
else
    echo -e "${RED}✗${NC} Boot partition not mounted at $BOOT_PARTITION"
    echo "  Try: sudo mount /dev/sdX1 $BOOT_PARTITION"
fi

if mount | grep -q "$ROOT_PARTITION"; then
    echo -e "${GREEN}✓${NC} Root partition is mounted"
    df -h "$ROOT_PARTITION" | tail -1
else
    echo -e "${RED}✗${NC} Root partition not mounted at $ROOT_PARTITION"
    echo "  Try: sudo mount /dev/sdX2 $ROOT_PARTITION"
fi
echo

# Check boot partition contents
echo "2. Checking boot partition contents..."
check_path "$BOOT_PARTITION/uEnv.txt" "Boot configuration (uEnv.txt)"
check_size "$BOOT_PARTITION/uImage" 2000000 "Kernel image (uImage)"

if [ -f "$BOOT_PARTITION/uEnv.txt" ]; then
    echo "  Boot config contents:"
    grep "^bootargs\|^bootcmd" "$BOOT_PARTITION/uEnv.txt" | head -2 | sed 's/^/    /'
fi
echo

# Check root partition structure
echo "3. Checking root filesystem structure..."
CRITICAL_DIRS=(
    "bin"
    "etc"
    "lib"
    "root"
    "sbin"
    "usr"
    "var"
)

errors=0
for dir in "${CRITICAL_DIRS[@]}"; do
    if check_path "$ROOT_PARTITION/$dir" "/$dir directory"; then
        :
    else
        ((errors++))
    fi
done

if [ $errors -eq 0 ]; then
    echo -e "${GREEN}✓${NC} All critical directories present"
else
    echo -e "${RED}✗${NC} Missing $errors critical directories"
fi
echo

# Check for our custom files
echo "4. Checking Nook-specific files..."
check_path "$ROOT_PARTITION/usr/local/bin/nook-menu.sh" "Nook menu script"
check_path "$ROOT_PARTITION/usr/local/bin/fbink" "FBInk E-Ink driver"
check_path "$ROOT_PARTITION/usr/bin/vim" "Vim editor"
check_path "$ROOT_PARTITION/root/.vimrc" "Vim configuration"
check_path "$ROOT_PARTITION/etc/os-release" "SquireOS branding"

# Check for zk if using zk-enabled image
if [ -f "$ROOT_PARTITION/usr/local/bin/zk" ]; then
    echo -e "${GREEN}✓${NC} zk note-taking tool installed"
    file "$ROOT_PARTITION/usr/local/bin/zk" | grep -q "ARM" && \
        echo -e "${GREEN}✓${NC} zk compiled for ARM" || \
        echo -e "${YELLOW}⚠${NC} zk may not be ARM binary"
fi
echo

# Check Vim plugins
echo "5. Checking Vim plugins..."
PLUGINS=(
    "goyo.vim"
    "vim-pencil"
    "lightline.vim"
)

for plugin in "${PLUGINS[@]}"; do
    check_path "$ROOT_PARTITION/root/.vim/pack/plugins/start/$plugin" "$plugin"
done
echo

# Check permissions
echo "6. Checking file permissions..."
if [ -f "$ROOT_PARTITION/usr/local/bin/nook-menu.sh" ]; then
    perms=$(stat -c %a "$ROOT_PARTITION/usr/local/bin/nook-menu.sh" 2>/dev/null || echo "000")
    if [[ "$perms" == *"5"* ]] || [[ "$perms" == *"7"* ]]; then
        echo -e "${GREEN}✓${NC} Menu script is executable"
    else
        echo -e "${RED}✗${NC} Menu script not executable (permissions: $perms)"
        echo "  Fix with: sudo chmod +x $ROOT_PARTITION/usr/local/bin/*.sh"
    fi
fi
echo

# Calculate space usage
echo "7. Space usage analysis..."
if [ -d "$ROOT_PARTITION" ]; then
    total_size=$(du -sh "$ROOT_PARTITION" 2>/dev/null | cut -f1)
    echo "  Total root filesystem size: $total_size"
    
    # Check if size is reasonable (between 150MB and 500MB)
    size_bytes=$(du -sb "$ROOT_PARTITION" 2>/dev/null | cut -f1)
    if [ "$size_bytes" -gt 157286400 ] && [ "$size_bytes" -lt 524288000 ]; then
        echo -e "${GREEN}✓${NC} Size is reasonable for Nook"
    else
        echo -e "${YELLOW}⚠${NC} Size may be too large or too small"
    fi
fi
echo

# Summary
echo "================================"
echo "Verification Summary"
echo "================================"

all_good=true

# Check critical components
[ -f "$BOOT_PARTITION/uEnv.txt" ] || { all_good=false; echo -e "${RED}✗${NC} Missing boot config"; }
[ -f "$BOOT_PARTITION/uImage" ] || { all_good=false; echo -e "${YELLOW}⚠${NC} Missing kernel (need to add)"; }
[ -d "$ROOT_PARTITION/root" ] || { all_good=false; echo -e "${RED}✗${NC} Missing root filesystem"; }
[ -f "$ROOT_PARTITION/usr/local/bin/nook-menu.sh" ] || { all_good=false; echo -e "${RED}✗${NC} Missing menu system"; }

if $all_good; then
    echo -e "${GREEN}✓ SD card appears ready for Nook!${NC}"
    echo
    echo "Next steps:"
    echo "1. If kernel (uImage) is missing, copy it to $BOOT_PARTITION/"
    echo "2. Safely eject SD card in Windows"
    echo "3. Insert into Nook and boot"
else
    echo -e "${RED}✗ SD card has issues that need fixing${NC}"
    echo
    echo "Please address the issues above before booting."
fi

echo
echo "Run this script again after making changes to re-verify."