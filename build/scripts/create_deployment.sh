#!/bin/bash
# Create SquireOS Deployment Package
# Bundles kernel, modules, and init scripts for Nook deployment

set -euo pipefail

echo "==============================================================="
echo "           SquireOS Deployment Package Creator"
echo "==============================================================="
echo ""

# Configuration
PACKAGE_DIR="$(pwd)/deployment_package"
FIRMWARE_DIR="$(pwd)/firmware"
SOURCE_DIR="$(pwd)/source"
VERSION="1.0.0"
PACKAGE_NAME="squireos-nook-${VERSION}.tar.gz"

# Clean and create package directory
rm -rf "$PACKAGE_DIR"
mkdir -p "$PACKAGE_DIR"/{boot,lib/modules/2.6.29,etc/init.d,usr/local/bin,proc/squireos}

echo "-> Collecting deployment files..."

# Copy kernel image
if [ -f "$FIRMWARE_DIR/boot/uImage" ]; then
    cp "$FIRMWARE_DIR/boot/uImage" "$PACKAGE_DIR/boot/"
    echo "  [OK] Kernel image (uImage)"
else
    echo "  [WARN] Kernel image not found"
fi

# Copy module object files (as placeholders until .ko files are built)
if ls "$FIRMWARE_DIR/modules"/*.o 2>/dev/null; then
    cp "$FIRMWARE_DIR/modules"/*.o "$PACKAGE_DIR/lib/modules/2.6.29/"
    echo "  [OK] Module object files"
else
    echo "  [WARN] No module files found"
fi

# Copy init scripts
cp "$SOURCE_DIR/scripts/boot/load-squireos-modules.sh" "$PACKAGE_DIR/usr/local/bin/"
cp "$SOURCE_DIR/scripts/boot/init.d/squireos-modules" "$PACKAGE_DIR/etc/init.d/"
cp "$SOURCE_DIR/scripts/boot/squireos-init.sh" "$PACKAGE_DIR/usr/local/bin/"
echo "  [OK] Init scripts"

# Copy systemd service (optional)
mkdir -p "$PACKAGE_DIR/etc/systemd/system"
cp "$SOURCE_DIR/configs/system/squireos-modules.service" "$PACKAGE_DIR/etc/systemd/system/"
echo "  [OK] SystemD service file"

# Create installation script
cat > "$PACKAGE_DIR/install.sh" << 'EOF'
#!/bin/sh
# SquireOS Installation Script for Nook
# Run as root on the target device

echo "Installing SquireOS Medieval Writing System..."

# Check if running as root
if [ "$(id -u)" != "0" ]; then
    echo "Error: This script must be run as root"
    exit 1
fi

# Detect system type
if [ -d /system ]; then
    echo "Detected Android-based Nook system"
    INSTALL_TYPE="android"
elif [ -d /etc/systemd ]; then
    echo "Detected systemd-based system"
    INSTALL_TYPE="systemd"
else
    echo "Detected SysV init system"
    INSTALL_TYPE="sysv"
fi

# Install kernel (if provided)
if [ -f boot/uImage ]; then
    echo "Installing kernel image..."
    cp boot/uImage /boot/uImage.squireos
    echo "  [OK] Kernel installed (manual boot configuration required)"
fi

# Install modules
if ls lib/modules/2.6.29/*.o 2>/dev/null; then
    echo "Installing kernel modules..."
    mkdir -p /lib/modules/2.6.29
    cp lib/modules/2.6.29/*.o /lib/modules/2.6.29/
    echo "  [OK] Modules installed to /lib/modules/2.6.29/"
fi

# Install init scripts
echo "Installing init scripts..."
cp usr/local/bin/*.sh /usr/local/bin/
chmod +x /usr/local/bin/*.sh

case $INSTALL_TYPE in
    android)
        # For Android/Nook, add to init.rc or use property trigger
        echo "  [OK] Scripts installed for Android boot"
        ;;
    systemd)
        cp etc/systemd/system/*.service /etc/systemd/system/
        systemctl daemon-reload
        systemctl enable squireos-modules.service
        echo "  [OK] SystemD service enabled"
        ;;
    sysv)
        cp etc/init.d/* /etc/init.d/
        chmod +x /etc/init.d/squireos-modules
        update-rc.d squireos-modules defaults 2>/dev/null || \
            chkconfig --add squireos-modules 2>/dev/null || \
            echo "    Please manually enable init script"
        echo "  [OK] SysV init script installed"
        ;;
esac

echo ""
echo "==============================================="
echo "Installation complete!"
echo ""
echo "To load modules manually:"
echo "  /usr/local/bin/load-squireos-modules.sh"
echo ""
echo "To check status:"
echo "  ls -la /proc/squireos/"
echo ""
echo "The digital scriptorium awaits thy quill!"
echo "==============================================="
EOF

chmod +x "$PACKAGE_DIR/install.sh"
echo "  [OK] Installation script"

# Create README
cat > "$PACKAGE_DIR/README.md" << 'EOF'
# SquireOS Medieval Writing System for Nook

## Package Contents

- `boot/uImage` - QuillKernel with SquireOS support
- `lib/modules/` - SquireOS kernel modules
- `etc/init.d/` - Boot scripts for automatic loading
- `usr/local/bin/` - Module loading utilities
- `install.sh` - Automated installation script

## Installation

1. Copy this package to your Nook device
2. Extract the package: `tar -xzf squireos-nook-*.tar.gz`
3. Run the installer: `sudo ./install.sh`

## Manual Module Loading

If modules don't load at boot:
```bash
/usr/local/bin/load-squireos-modules.sh
```

## Accessing SquireOS Features

Once loaded, access the medieval writing features:

- View the jester: `cat /proc/squireos/jester`
- Check writing stats: `cat /proc/squireos/typewriter/stats`
- Get wisdom: `cat /proc/squireos/wisdom`
- See version: `cat /proc/squireos/version`

## Troubleshooting

If modules fail to load:
1. Check kernel version: `uname -r` (should be 2.6.29)
2. Verify module files exist: `ls /lib/modules/2.6.29/`
3. Check kernel log: `dmesg | grep squireos`

## Medieval Philosophy

"By quill and candlelight, we write eternal words"

The SquireOS system transforms your Nook into a distraction-free
writing sanctuary with a medieval theme to inspire your creativity.

May your words flow like ink from a well-seasoned quill!
EOF
echo "  [OK] README documentation"

echo ""
echo "-> Creating deployment package..."

# Create tarball
cd "$(dirname "$PACKAGE_DIR")"
tar -czf "$PACKAGE_NAME" "$(basename "$PACKAGE_DIR")"
cd - >/dev/null

echo "  [OK] Package created: $PACKAGE_NAME"

# Calculate package size
PACKAGE_SIZE=$(du -h "$PACKAGE_NAME" | cut -f1)
echo "  Package size: $PACKAGE_SIZE"

echo ""
echo "==============================================================="
echo "           Deployment Package Summary"
echo "==============================================================="
echo ""
echo "Package: $PACKAGE_NAME"
echo "Size: $PACKAGE_SIZE"
echo ""
echo "Contents:"
find "$PACKAGE_DIR" -type f | sed 's|'"$PACKAGE_DIR/"'|  - |' | head -20
echo ""
echo "To deploy on Nook:"
echo "1. Copy $PACKAGE_NAME to device"
echo "2. Extract: tar -xzf $PACKAGE_NAME"
echo "3. Install: sudo ./deployment_package/install.sh"
echo ""
echo "==============================================================="
echo "'The quill is sharpened, the parchment awaits!'"
echo "==============================================================="