#!/bin/bash
# Quick kernel build script

# Set up environment
export ANDROID_NDK="$HOME/nook-kernel-dev/android-ndk-r23c"
export PATH="$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH"
export ARCH=arm
export CROSS_COMPILE=arm-linux-androideabi-

# Enter kernel directory
cd "$(dirname "$0")"

# Configure (skip if .config exists)
if [ ! -f .config ]; then
    echo "Configuring kernel..."
    # Check if QuillKernel config exists
    if [ -f arch/arm/configs/quill_typewriter_defconfig ]; then
        echo "Using QuillKernel typewriter configuration!"
        make quill_typewriter_defconfig
    else
        echo "Using standard Nook configuration"
        make omap3621_gossamer_defconfig
    fi
fi

# Build
echo "Building kernel (this will take 15-30 minutes)..."
make -j$(nproc) uImage

if [ -f arch/arm/boot/uImage ]; then
    echo ""
    echo "=== BUILD SUCCESSFUL! ==="
    echo "Kernel image: $(pwd)/arch/arm/boot/uImage"
    echo "Size: $(ls -lh arch/arm/boot/uImage | awk '{print $5}')"
    echo ""
    echo "You've just compiled a kernel! Welcome to the club!"
else
    echo "Build failed. Check the errors above."
    exit 1
fi
