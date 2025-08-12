#!/bin/bash
# Simple kernel build script for QuillKernel

set -e

echo "═══════════════════════════════════════════════════════════════"
echo "           QuillKernel Build Script"
echo "═══════════════════════════════════════════════════════════════"

# Ensure we're in the right directory
cd "$(dirname "$0")"

# Build the kernel using Docker
echo ""
echo "→ Starting kernel build in Docker..."
docker run --rm \
    -v "$(pwd)/nst-kernel-base:/kernel" \
    -v "$(pwd)/quillkernel/modules:/modules" \
    -w /kernel/src \
    quillkernel-builder \
    bash -c "
        echo '→ Configuring kernel for Nook...'
        make ARCH=arm omap3621_gossamer_evt1c_defconfig
        
        echo '→ Enabling SquireOS modules...'
        echo 'CONFIG_SQUIREOS=m' >> .config
        echo 'CONFIG_SQUIREOS_JESTER=y' >> .config
        echo 'CONFIG_SQUIREOS_TYPEWRITER=y' >> .config
        echo 'CONFIG_SQUIREOS_WISDOM=y' >> .config
        
        echo '→ Building kernel (this may take 5-10 minutes)...'
        make -j4 ARCH=arm CROSS_COMPILE=arm-linux-androideabi- oldconfig
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
if [ -f nst-kernel-base/src/arch/arm/boot/uImage ]; then
    cp nst-kernel-base/src/arch/arm/boot/uImage quillkernel/
    echo "✓ Kernel image copied to quillkernel/uImage"
    ls -lh quillkernel/uImage
else
    echo "✗ Could not find uImage"
    exit 1
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "✓ QuillKernel build complete!"
echo "═══════════════════════════════════════════════════════════════"