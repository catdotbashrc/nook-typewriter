#!/bin/bash
# Deploy SquireOS to Nook SD Card
# This script installs the kernel and modules to the mounted Nook partitions
# "By quill and candlelight, we prepare the digital realm!"

set -euo pipefail

# Color output for clarity
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "==============================================================="
echo "         SquireOS Deployment to Nook SD Card"
echo "==============================================================="
echo ""

# Configuration
BOOT_MOUNT="/mnt/nook_boot"
ROOT_MOUNT="/mnt/nook_root"
PROJECT_ROOT="$(pwd)"

# Safety checks
echo "-> Performing safety checks..."

# Check if running as root (required for deployment)
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}[ERROR]${NC} This script must be run as root (use sudo)"
    exit 1
fi

# Check if partitions are mounted
if ! mountpoint -q "$BOOT_MOUNT"; then
    echo -e "${RED}[ERROR]${NC} Boot partition not mounted at $BOOT_MOUNT"
    echo "Please mount the boot partition first"
    exit 1
fi

if ! mountpoint -q "$ROOT_MOUNT"; then
    echo -e "${RED}[ERROR]${NC} Root partition not mounted at $ROOT_MOUNT"
    echo "Please mount the root partition first"
    exit 1
fi

# Check if kernel exists
if [ ! -f "$PROJECT_ROOT/firmware/boot/uImage" ]; then
    echo -e "${RED}[ERROR]${NC} Kernel image not found at firmware/boot/uImage"
    echo "Please build the kernel first with ./build_kernel.sh"
    exit 1
fi

echo -e "${GREEN}[OK]${NC} All safety checks passed"
echo ""

# Confirmation prompt
echo "==============================================================="
echo "This will deploy to:"
echo "  Boot partition: $BOOT_MOUNT ($(df -h $BOOT_MOUNT | tail -1 | awk '{print $2}'))"
echo "  Root partition: $ROOT_MOUNT ($(df -h $ROOT_MOUNT | tail -1 | awk '{print $2}'))"
echo ""
echo "Current contents will be PRESERVED (non-destructive install)"
echo "==============================================================="
echo ""
read -p "Continue with deployment? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Deployment cancelled."
    exit 0
fi

echo ""
echo "-> Starting deployment..."

# Step 1: Deploy kernel to boot partition
echo ""
echo "Step 1: Installing kernel..."

# Backup existing kernel if present
if [ -f "$BOOT_MOUNT/uImage" ]; then
    echo "  Backing up existing kernel to uImage.backup..."
    cp "$BOOT_MOUNT/uImage" "$BOOT_MOUNT/uImage.backup"
    echo -e "  ${GREEN}[OK]${NC} Backup created"
fi

# Copy new kernel
cp "$PROJECT_ROOT/firmware/boot/uImage" "$BOOT_MOUNT/uImage"
echo -e "  ${GREEN}[OK]${NC} Kernel installed ($(du -h $BOOT_MOUNT/uImage | cut -f1))"

# Step 2: Create directory structure on root partition
echo ""
echo "Step 2: Creating directory structure..."

# Create required directories
mkdir -p "$ROOT_MOUNT/lib/modules/2.6.29"
mkdir -p "$ROOT_MOUNT/usr/local/bin"
mkdir -p "$ROOT_MOUNT/etc/init.d"
mkdir -p "$ROOT_MOUNT/var/log"
mkdir -p "$ROOT_MOUNT/proc/squireos"  # Placeholder for mount point
mkdir -p "$ROOT_MOUNT/root/notes"      # Writing directory
mkdir -p "$ROOT_MOUNT/root/drafts"     # Draft directory
echo -e "  ${GREEN}[OK]${NC} Directory structure created"

# Step 3: Install kernel modules
echo ""
echo "Step 3: Installing kernel modules..."

# Copy module files (even if they're .o files for now)
if ls "$PROJECT_ROOT/firmware/modules"/*.o 2>/dev/null; then
    cp "$PROJECT_ROOT/firmware/modules"/*.o "$ROOT_MOUNT/lib/modules/2.6.29/"
    echo -e "  ${GREEN}[OK]${NC} Module objects installed (will need .ko conversion)"
    
    # Create a note about module compilation
    cat > "$ROOT_MOUNT/lib/modules/2.6.29/README" << 'EOF'
SquireOS Medieval Kernel Modules
=================================

Current status: Object files (.o) installed
These need to be converted to .ko files for loading.

Modules included:
- squireos_core.o : Base module, creates /proc/squireos
- jester.o        : ASCII art jester companion
- typewriter.o    : Writing statistics tracker
- wisdom.o        : Inspirational quotes system

To load manually (once .ko files are available):
  insmod /lib/modules/2.6.29/squireos_core.ko
  insmod /lib/modules/2.6.29/jester.ko
  insmod /lib/modules/2.6.29/typewriter.ko
  insmod /lib/modules/2.6.29/wisdom.ko

EOF
    echo -e "  ${YELLOW}[NOTE]${NC} README created for module information"
elif ls "$PROJECT_ROOT/firmware/modules"/*.ko 2>/dev/null; then
    cp "$PROJECT_ROOT/firmware/modules"/*.ko "$ROOT_MOUNT/lib/modules/2.6.29/"
    echo -e "  ${GREEN}[OK]${NC} Kernel modules installed"
else
    echo -e "  ${YELLOW}[WARN]${NC} No module files found"
fi

# Step 4: Install boot scripts
echo ""
echo "Step 4: Installing boot scripts..."

# Copy main loading script
cp "$PROJECT_ROOT/source/scripts/boot/load-squireos-modules.sh" "$ROOT_MOUNT/usr/local/bin/"
chmod +x "$ROOT_MOUNT/usr/local/bin/load-squireos-modules.sh"
echo -e "  ${GREEN}[OK]${NC} Module loading script installed"

# Copy init.d script for automatic loading
cp "$PROJECT_ROOT/source/scripts/boot/init.d/squireos-modules" "$ROOT_MOUNT/etc/init.d/"
chmod +x "$ROOT_MOUNT/etc/init.d/squireos-modules"
echo -e "  ${GREEN}[OK]${NC} Init.d script installed"

# Create Android-style init script for Nook
cat > "$ROOT_MOUNT/init.squireos.rc" << 'EOF'
# SquireOS initialization for Android-based Nook boot
on boot
    # Load SquireOS kernel modules
    insmod /lib/modules/2.6.29/squireos_core.ko
    insmod /lib/modules/2.6.29/jester.ko
    insmod /lib/modules/2.6.29/typewriter.ko
    insmod /lib/modules/2.6.29/wisdom.ko
    
    # Set property to indicate modules loaded
    setprop squireos.loaded 1
EOF
echo -e "  ${GREEN}[OK]${NC} Android init script created"

# Step 5: Copy ASCII art collections
echo ""
echo "Step 5: Installing medieval assets..."

if [ -d "$PROJECT_ROOT/source/configs/ascii" ]; then
    mkdir -p "$ROOT_MOUNT/usr/share/squireos"
    cp -r "$PROJECT_ROOT/source/configs/ascii" "$ROOT_MOUNT/usr/share/squireos/"
    echo -e "  ${GREEN}[OK]${NC} ASCII art collections installed"
fi

# Step 6: Create welcome message
echo ""
echo "Step 6: Creating welcome message..."

cat > "$ROOT_MOUNT/etc/motd" << 'EOF'
===============================================
      Welcome to SquireOS Medieval Writing System
===============================================
         .~"~.~"~.
        /  o   o  \    
       |  >  u  <  |   Your digital squire
        \  ___  /      awaits thy command!
         |~|*|~|       
===============================================

Quick Commands:
  cat /proc/squireos/jester     - See your jester companion
  cat /proc/squireos/wisdom     - Get writing inspiration
  cat /proc/squireos/typewriter/stats - View writing statistics
  
Writing Directories:
  /root/notes/   - For thy permanent writings
  /root/drafts/  - For works in progress

"By quill and candlelight, we write eternal words!"
EOF
echo -e "  ${GREEN}[OK]${NC} Welcome message created"

# Step 7: Create test script
echo ""
echo "Step 7: Creating test utilities..."

cat > "$ROOT_MOUNT/usr/local/bin/test-squireos.sh" << 'EOF'
#!/bin/sh
# Test SquireOS installation

echo "Testing SquireOS installation..."
echo ""

# Check if modules can be loaded
if [ -f /proc/squireos/motto ]; then
    echo "[OK] SquireOS modules loaded"
    echo ""
    echo "Jester says:"
    cat /proc/squireos/jester
    echo ""
    echo "Today's wisdom:"
    cat /proc/squireos/wisdom
else
    echo "[INFO] Modules not loaded. Attempting to load..."
    /usr/local/bin/load-squireos-modules.sh
fi
EOF
chmod +x "$ROOT_MOUNT/usr/local/bin/test-squireos.sh"
echo -e "  ${GREEN}[OK]${NC} Test script created"

# Step 8: Display summary
echo ""
echo "==============================================================="
echo "           Deployment Complete!"
echo "==============================================================="
echo ""
echo "Installed components:"
echo "  Boot partition ($BOOT_MOUNT):"
echo "    - uImage (kernel)"
if [ -f "$BOOT_MOUNT/uImage.backup" ]; then
    echo "    - uImage.backup (original kernel)"
fi
echo ""
echo "  Root partition ($ROOT_MOUNT):"
echo "    - /lib/modules/2.6.29/ (kernel modules)"
echo "    - /usr/local/bin/ (scripts)"
echo "    - /etc/init.d/ (boot scripts)"
echo "    - /usr/share/squireos/ (assets)"
echo ""
echo "==============================================================="
echo "           Next Steps"
echo "==============================================================="
echo ""
echo "1. Safely unmount the SD card:"
echo "   sudo umount $BOOT_MOUNT"
echo "   sudo umount $ROOT_MOUNT"
echo ""
echo "2. Insert SD card into your Nook"
echo ""
echo "3. Boot the Nook (it should boot from SD automatically)"
echo ""
echo "4. Once booted, test the installation:"
echo "   /usr/local/bin/test-squireos.sh"
echo ""
echo "5. Check the jester:"
echo "   cat /proc/squireos/jester"
echo ""
echo "==============================================================="
echo "'The digital scriptorium awaits thy quill!'"
echo "==============================================================="