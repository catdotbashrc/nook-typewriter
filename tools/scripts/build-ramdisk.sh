#!/bin/bash
# build-ramdisk.sh - Build uRamdisk for JesterOS Boot
# Creates hybrid Android/JesterOS ramdisk image
# Target size: <3MB compressed

set -euo pipefail

# Color output for clarity
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
PLATFORM_DIR="$PROJECT_ROOT/platform/nook-touch"
BUILD_DIR="$PROJECT_ROOT/build/ramdisk"
OUTPUT_DIR="$PROJECT_ROOT/build/boot"

# Tool requirements
MKIMAGE="${MKIMAGE:-mkimage}"

# Functions
log() {
    echo -e "${GREEN}[BUILD]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
    exit 1
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Check dependencies
check_tools() {
    log "Checking build tools..."
    
    if ! command -v "$MKIMAGE" >/dev/null 2>&1; then
        error "mkimage not found. Install u-boot-tools: sudo apt-get install u-boot-tools"
    fi
    
    if ! command -v cpio >/dev/null 2>&1; then
        error "cpio not found. Install: sudo apt-get install cpio"
    fi
}

# Create ramdisk directory structure
create_ramdisk_structure() {
    log "Creating ramdisk structure..."
    
    # Clean and create build directory
    rm -rf "$BUILD_DIR"
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"
    
    # Create Android standard directories
    mkdir -p {dev,proc,sys,system,data,cache,mnt,tmp}
    mkdir -p {sbin,vendor,oem,root}
    mkdir -p system/{bin,lib,etc,usr}
    mkdir -p dev/{pts,socket}
    mkdir -p mnt/{sdcard,usbdisk}
    
    # JesterOS specific directories
    mkdir -p jesteros/{bin,lib,etc}
    mkdir -p var/jesteros
    mkdir -p etc/dsp
    
    # Create essential device nodes (will be created at runtime)
    # Android init will populate these
    touch dev/.placeholder
}

# Copy essential files
copy_essential_files() {
    log "Copying essential boot files..."
    
    # Copy Android init binary
    if [ -f "$PLATFORM_DIR/android/init" ]; then
        cp "$PLATFORM_DIR/android/init" init
        chmod 750 init
    else
        error "Android init binary not found at $PLATFORM_DIR/android/init"
    fi
    
    # Copy init.rc
    if [ -f "$PLATFORM_DIR/init.rc" ]; then
        cp "$PLATFORM_DIR/init.rc" init.rc
        chmod 644 init.rc
    else
        error "init.rc not found at $PLATFORM_DIR/init.rc"
    fi
    
    # Copy default.prop
    if [ -f "$PLATFORM_DIR/default.prop" ]; then
        cp "$PLATFORM_DIR/default.prop" default.prop
        chmod 644 default.prop
    else
        error "default.prop not found at $PLATFORM_DIR/default.prop"
    fi
    
    # Copy E-ink daemon
    if [ -f "$PLATFORM_DIR/bin/omap-edpd.elf" ]; then
        cp "$PLATFORM_DIR/bin/omap-edpd.elf" sbin/omap-edpd.elf
        chmod 755 sbin/omap-edpd.elf
    else
        warn "E-ink daemon not found, skipping"
    fi
    
    # Copy essential Android binaries
    # Android dynamic linker (required for all executables)
    if [ -f "$PLATFORM_DIR/system/bin/linker" ]; then
        mkdir -p system/bin
        cp "$PLATFORM_DIR/system/bin/linker" system/bin/linker
        chmod 755 system/bin/linker
    else
        warn "Android linker not found, binaries may not execute"
    fi
    
    # Shell (required for init scripts)
    if [ -f "$PLATFORM_DIR/system/bin/sh" ]; then
        cp "$PLATFORM_DIR/system/bin/sh" system/bin/sh
        chmod 755 system/bin/sh
    else
        warn "Shell binary not found, scripts won't run"
    fi
    
    # Busybox for core utilities
    if [ -f "$PLATFORM_DIR/system/bin/busybox" ]; then
        cp "$PLATFORM_DIR/system/bin/busybox" system/bin/busybox
        chmod 755 system/bin/busybox
    else
        warn "Busybox not found, limited utilities available"
    fi
    
    # Copy DSP firmware
    if [ -f "$PLATFORM_DIR/dsp/baseimage.dof" ]; then
        cp "$PLATFORM_DIR/dsp/baseimage.dof" etc/dsp/baseimage.dof
        chmod 644 etc/dsp/baseimage.dof
    else
        warn "DSP firmware not found, skipping"
    fi
    
    # Copy JesterOS init script
    if [ -f "$PROJECT_ROOT/src/init/jesteros-init.sh" ]; then
        mkdir -p system/bin
        cp "$PROJECT_ROOT/src/init/jesteros-init.sh" system/bin/jesteros-init.sh
        chmod 755 system/bin/jesteros-init.sh
    else
        warn "JesterOS init script not found"
    fi
    
    # Create boot counter clear script
    cat > system/bin/clrbootcount.sh << 'EOF'
#!/system/bin/sh
# Clear boot counter to prevent factory reset
# Critical for boot loop prevention
echo 0 > /rom/devconf/BootCnt 2>/dev/null || true
exit 0
EOF
    chmod 755 system/bin/clrbootcount.sh
}

# Create symbolic links
create_symlinks() {
    log "Creating symbolic links..."
    
    # Android standard symlinks
    ln -s /system/bin system/xbin 2>/dev/null || true
    
    # Busybox symlinks (if available)
    if [ -f system/bin/busybox ]; then
        for cmd in $(system/bin/busybox --list); do
            ln -sf busybox "system/bin/$cmd" 2>/dev/null || true
        done
    fi
}

# Build cpio archive
build_cpio() {
    log "Building cpio archive..."
    
    # Create cpio archive
    find . | cpio -o -H newc > ../initramfs.cpio
    
    # Check size
    CPIO_SIZE=$(stat -c%s ../initramfs.cpio)
    log "Uncompressed ramdisk size: $(($CPIO_SIZE / 1024))KB"
}

# Compress ramdisk
compress_ramdisk() {
    log "Compressing ramdisk..."
    
    cd "$PROJECT_ROOT/build"
    
    # Compress with gzip (standard for U-Boot)
    gzip -9 < initramfs.cpio > initramfs.cpio.gz
    
    # Check compressed size
    COMPRESSED_SIZE=$(stat -c%s initramfs.cpio.gz)
    log "Compressed ramdisk size: $(($COMPRESSED_SIZE / 1024))KB"
    
    # Verify size is under 3MB target
    if [ $COMPRESSED_SIZE -gt 3145728 ]; then
        warn "Ramdisk exceeds 3MB target ($(($COMPRESSED_SIZE / 1024))KB)"
    fi
}

# Create U-Boot image
create_uboot_image() {
    log "Creating U-Boot ramdisk image..."
    
    mkdir -p "$OUTPUT_DIR"
    
    # Create uRamdisk with mkimage
    # Load address and entry point for OMAP3
    $MKIMAGE -A arm -O linux -T ramdisk -C gzip \
        -a 0x81600000 -e 0x81600000 \
        -n "JesterOS Ramdisk" \
        -d initramfs.cpio.gz "$OUTPUT_DIR/uRamdisk"
    
    # Check final size
    FINAL_SIZE=$(stat -c%s "$OUTPUT_DIR/uRamdisk")
    log "Final uRamdisk size: $(($FINAL_SIZE / 1024))KB"
    
    # Show mkimage info
    $MKIMAGE -l "$OUTPUT_DIR/uRamdisk"
}

# Cleanup
cleanup() {
    log "Cleaning up build directory..."
    rm -f "$PROJECT_ROOT/build/initramfs.cpio"
    rm -f "$PROJECT_ROOT/build/initramfs.cpio.gz"
    # Optionally keep ramdisk directory for inspection
    # rm -rf "$BUILD_DIR"
}

# Verify output
verify_output() {
    log "Verifying uRamdisk..."
    
    if [ ! -f "$OUTPUT_DIR/uRamdisk" ]; then
        error "uRamdisk not created!"
    fi
    
    # Verify it's a valid U-Boot image
    if ! $MKIMAGE -l "$OUTPUT_DIR/uRamdisk" >/dev/null 2>&1; then
        error "Invalid U-Boot image format!"
    fi
    
    log "✓ uRamdisk successfully built at $OUTPUT_DIR/uRamdisk"
}

# Main build process
main() {
    log "Starting JesterOS ramdisk build..."
    log "Project root: $PROJECT_ROOT"
    
    check_tools
    create_ramdisk_structure
    copy_essential_files
    create_symlinks
    build_cpio
    compress_ramdisk
    create_uboot_image
    cleanup
    verify_output
    
    log "Build complete! 🏰"
}

# Run main function
main "$@"