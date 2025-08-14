#!/bin/bash
# Simple kernel build script for JoKernel

set -e

# Source build configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.kernel.env"

echo "═══════════════════════════════════════════════════════════════"
echo "           JoKernel Build Script v${PROJECT_VERSION}"
echo "═══════════════════════════════════════════════════════════════"

# Ensure we're in the right directory
cd "$SCRIPT_DIR"

# Check if XDA-proven Docker image exists, build if needed
if ! docker images | grep -q "jokernel-unified"; then
    echo "→ Building XDA-proven Docker environment..."
    docker build -t jokernel-unified -f build/docker/kernel-xda-proven.dockerfile build/docker/
fi

# Build the kernel using Docker
echo ""
echo "→ Starting kernel build with XDA-proven toolchain..."
docker run --rm \
    -v "$(pwd)/source/kernel:/kernel" \
    -v "$(pwd)/source/kernel/jokernel/modules:/modules" \
    -w /kernel/src \
    jokernel-unified \
    bash -c "
        echo '→ Configuring kernel for Nook...'
        make ARCH=arm omap3621_gossamer_evt1c_defconfig
        
        echo '→ Enabling JesterOS modules...'
        # Force JesterOS into config before oldconfig processes it
        cat >> .config << 'EOF'

#
# JesterOS Configuration
#
CONFIG_JESTEROS=m
CONFIG_JESTEROS_JESTER=y
CONFIG_JESTEROS_TYPEWRITER=y
CONFIG_JESTEROS_WISDOM=y
# CONFIG_JESTEROS_DEBUG is not set
EOF
        
        echo '→ Building kernel (this may take 5-10 minutes)...'
        make -j4 ARCH=arm CROSS_COMPILE=arm-linux-androideabi- olddefconfig
        make -j4 ARCH=arm CROSS_COMPILE=arm-linux-androideabi- uImage
        
        echo '→ Building modules...'
        make -j4 ARCH=arm CROSS_COMPILE=arm-linux-androideabi- modules
        
        echo ''
        echo '═══════════════════════════════════════════════════════════════'
        if [ -f arch/arm/boot/uImage ]; then
            echo '✓ Build successful!'
            echo '  Kernel: arch/arm/boot/uImage'
            ls -lh arch/arm/boot/uImage
        else
            echo '✗ Build failed - uImage not found'
            exit 1
        fi
    "

echo ""
echo "→ Copying build artifacts..."
mkdir -p firmware/boot
if [ -f source/kernel/src/arch/arm/boot/uImage ]; then
    cp source/kernel/src/arch/arm/boot/uImage firmware/boot/
    echo "✓ Kernel image copied to firmware/boot/uImage"
    ls -lh firmware/boot/uImage
else
    echo "✗ Could not find uImage"
    exit 1
fi

# Generate build info
echo ""
echo "→ Generating build information..."
if [ -f "$SCRIPT_DIR/scripts/version-control.sh" ]; then
    "$SCRIPT_DIR/scripts/version-control.sh" build
    echo "✓ Build info generated"
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "✓ JoKernel build complete! (v${PROJECT_VERSION})"
echo "═══════════════════════════════════════════════════════════════"