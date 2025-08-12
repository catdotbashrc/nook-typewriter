#!/bin/bash
# Install QuillKernel to prepared SD card

set -e

echo "═══════════════════════════════════════════════════════════════"
echo "         QuillKernel SD Card Installation"
echo "═══════════════════════════════════════════════════════════════"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Please run as root (use sudo)"
    exit 1
fi

# Check mount points
if ! mountpoint -q /mnt/nook_boot; then
    echo "❌ /mnt/nook_boot is not mounted"
    echo "   Run prepare_sdcard.sh first"
    exit 1
fi

if ! mountpoint -q /mnt/nook_root; then
    echo "❌ /mnt/nook_root is not mounted"
    echo "   Run prepare_sdcard.sh first"
    exit 1
fi

# Check for required files
echo "→ Checking for required files..."

if [ ! -f quillkernel/uImage ]; then
    echo "❌ Kernel not found: quillkernel/uImage"
    echo "   Run build_kernel.sh first"
    exit 1
fi

if [ ! -f quillkernel/nook-mvp-rootfs.tar.gz ]; then
    echo "❌ Root filesystem not found: quillkernel/nook-mvp-rootfs.tar.gz"
    exit 1
fi

echo "✓ All required files found"
echo ""

# Install kernel
echo "→ Installing kernel to boot partition..."
cp quillkernel/uImage /mnt/nook_boot/
echo "✓ Kernel installed"

# Create boot script for U-Boot
echo "→ Creating boot script..."
cat > /mnt/nook_boot/boot.scr.txt << 'EOF'
# QuillKernel Boot Script for Nook Simple Touch
echo "Loading QuillKernel..."
fatload mmc 0:1 0x80000000 uImage
echo "Booting medieval typewriter..."
bootm 0x80000000
EOF

# Note: In production, we'd compile this with mkimage
# For now, U-Boot can read the text version on some Nooks
echo "✓ Boot script created"

# Extract root filesystem
echo "→ Installing root filesystem (this may take a minute)..."
cd /mnt/nook_root
tar -xzf /home/jyeary/projects/personal/nook/quillkernel/nook-mvp-rootfs.tar.gz
cd - > /dev/null
echo "✓ Root filesystem installed"

# Copy kernel modules if they exist
if [ -d quillkernel/modules ]; then
    echo "→ Installing kernel modules..."
    mkdir -p /mnt/nook_root/lib/modules/2.6.29
    for mod in quillkernel/modules/*.ko; do
        if [ -f "$mod" ]; then
            cp "$mod" /mnt/nook_root/lib/modules/
            echo "  ✓ Installed $(basename $mod)"
        fi
    done
fi

# Create startup message
echo "→ Adding medieval boot message..."
cat > /mnt/nook_root/etc/motd << 'EOF'
═══════════════════════════════════════════════════════════════
           Welcome to QuillKernel Typewriter
              "By quill and compiler..."
═══════════════════════════════════════════════════════════════

     .~"~.~"~.
    /  o   o  \    Your digital scriptorium awaits!
   |  >  ◡  <  |   
    \  ___  /      Press any key to begin thy writing...
     |~|♦|~|       

═══════════════════════════════════════════════════════════════
EOF

echo "✓ Boot message added"

# Sync everything to SD card
echo ""
echo "→ Syncing to SD card (this ensures all data is written)..."
sync
echo "✓ Sync complete"

# Show usage statistics
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "✓ Installation Complete!"
echo ""
echo "SD Card Usage:"
df -h /mnt/nook_boot /mnt/nook_root | grep -v Filesystem
echo ""
echo "Next steps:"
echo "  1. Run: sudo umount /mnt/nook_boot /mnt/nook_root"
echo "  2. Remove SD card"
echo "  3. Insert into Nook"
echo "  4. Power on while holding page-turn buttons"
echo "═══════════════════════════════════════════════════════════════"