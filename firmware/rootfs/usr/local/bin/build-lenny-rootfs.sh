#!/bin/bash
# Build period-correct Debian Lenny (5.0) rootfs for JesterOS
# Lenny was released Feb 2009, perfect for our March 2009 kernel (2.6.29)

set -euo pipefail

# Check if running as root (needed for debootstrap)
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (needed for debootstrap)"
    exit 1
fi

OUTPUT_DIR="${1:-lenny-rootfs}"
ARCH="armel"  # ARM EABI for Nook

echo "========================================"
echo " JesterOS Debian Lenny Rootfs Builder"
echo "========================================"
echo ""
echo "Building period-correct Debian 5.0 (2009)"
echo "Perfect match for Linux 2.6.29 kernel!"
echo ""

# Install debootstrap if not available
if ! command -v debootstrap &> /dev/null; then
    echo "Installing debootstrap..."
    apt-get update && apt-get install -y debootstrap
fi

# Clean any existing rootfs
if [ -d "$OUTPUT_DIR" ]; then
    echo "WARNING: This will remove existing $OUTPUT_DIR directory!"
    echo -n "Continue? (yes/no): "
    read confirm
    if [ "$confirm" != "yes" ]; then
        echo "Aborted."
        exit 1
    fi
    echo "Removing existing $OUTPUT_DIR..."
    rm -rf "$OUTPUT_DIR"
fi

echo "Creating Debian Lenny rootfs..."
echo "This will take a few minutes..."

# Create Lenny rootfs using archived repository
debootstrap \
    --arch="$ARCH" \
    --variant=minbase \
    --include=busybox,kmod \
    --exclude=apt,aptitude,gcc,g++,perl,python \
    lenny \
    "$OUTPUT_DIR" \
    http://archive.debian.org/debian/ || {
        echo "Debootstrap failed!"
        echo "Trying fallback mirror..."
        debootstrap \
            --arch="$ARCH" \
            --variant=minbase \
            --include=busybox \
            lenny \
            "$OUTPUT_DIR" \
            http://archive.debian.org/debian-archive/debian/
    }

echo "Customizing rootfs for JesterOS..."

# Create essential directories
mkdir -p "$OUTPUT_DIR"/lib/modules/2.6.29
mkdir -p "$OUTPUT_DIR"/proc
mkdir -p "$OUTPUT_DIR"/sys
mkdir -p "$OUTPUT_DIR"/dev
mkdir -p "$OUTPUT_DIR"/root/manuscripts
mkdir -p "$OUTPUT_DIR"/boot

# Create minimal init script
cat > "$OUTPUT_DIR"/init << 'EOF'
#!/bin/sh
# JesterOS Init - Debian Lenny Edition

# Mount essential filesystems
mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev 2>/dev/null || mount -t tmpfs tmpfs /dev

clear
echo ""
echo "================================"
echo "  JesterOS with Debian Lenny"
echo "  Period-Correct 2009 Stack!"
echo "================================"
echo ""

# Show versions
echo "Kernel: $(uname -r)"
echo "Debian: 5.0 Lenny (2009)"
echo ""

# Load JesterOS modules if present
if [ -d /lib/modules/2.6.29 ]; then
    echo "Loading JokerOS modules..."
    for mod in /lib/modules/2.6.29/*.ko; do
        if [ -f "$mod" ]; then
            modname=$(basename "$mod" .ko)
            insmod "$mod" 2>/dev/null && echo "  + $modname"
        fi
    done
fi

# Show jester if available
if [ -f /var/jesteros/jester ]; then
    echo ""
    cat /var/jesteros/jester
fi

# Start a shell
echo ""
echo "Starting shell..."
exec /bin/sh
EOF
chmod +x "$OUTPUT_DIR"/init

# Fix sources.list to use archive
cat > "$OUTPUT_DIR"/etc/apt/sources.list << 'EOF'
# Debian Lenny - Archived (2009)
deb http://archive.debian.org/debian/ lenny main
deb http://archive.debian.org/debian-security/ lenny/updates main
EOF

# Clean up unnecessary files to save space
echo "Cleaning up to minimize size..."
rm -rf "$OUTPUT_DIR"/usr/share/doc/*
rm -rf "$OUTPUT_DIR"/usr/share/man/*
rm -rf "$OUTPUT_DIR"/usr/share/locale/*
rm -rf "$OUTPUT_DIR"/var/cache/apt/*
rm -rf "$OUTPUT_DIR"/var/lib/apt/lists/*
rm -rf "$OUTPUT_DIR"/usr/share/info/*
find "$OUTPUT_DIR" -name "*.a" -delete 2>/dev/null || true
find "$OUTPUT_DIR" -name "*.pyc" -delete 2>/dev/null || true

# Add our boot scripts if they exist
if [ -f platform/nook-touch/boot/system_init_menu.sh ]; then
    cp platform/nook-touch/boot/system_init_menu.sh "$OUTPUT_DIR"/boot/
fi

if [ -f platform/nook-touch/boot/booting.txt ]; then
    cp platform/nook-touch/boot/booting.txt "$OUTPUT_DIR"/boot/
fi

# Calculate size
SIZE=$(du -sh "$OUTPUT_DIR" | cut -f1)
echo ""
echo "Rootfs creation complete!"
echo "Size: $SIZE"
echo ""

# Create tarball
echo "Creating tarball..."
tar -czf "${OUTPUT_DIR}.tar.gz" -C "$OUTPUT_DIR" .
TARSIZE=$(du -sh "${OUTPUT_DIR}.tar.gz" | cut -f1)

echo "========================================"
echo "          Build Complete!"
echo "========================================"
echo ""
echo "Rootfs directory: $OUTPUT_DIR/ ($SIZE)"
echo "Compressed: ${OUTPUT_DIR}.tar.gz ($TARSIZE)"
echo ""
echo "Why Lenny is perfect for JesterOS:"
echo "  • Released Feb 2009 (kernel is March 2009)"
echo "  • Native 2.6.26 kernel (ours is 2.6.29)"
echo "  • Designed for 256MB RAM devices"
echo "  • No systemd bloat (uses sysvinit)"
echo "  • Period-appropriate libraries"
echo "  • Smaller than modern Debian"
echo ""
echo "To use:"
echo "  1. Extract to SD card partition 2"
echo "  2. Boot JesterOS"
echo "  3. Enjoy 2009 computing!"