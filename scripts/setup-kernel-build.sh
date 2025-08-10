#!/bin/bash
# Nook Simple Touch Kernel Build Environment Setup
# Run this to set up everything needed to build your kernel

set -e

echo "=== Nook Simple Touch Kernel Builder Setup ==="
echo "This script will prepare your environment for kernel compilation"
echo ""

# Check if running on Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo "Error: This script requires Linux (use WSL2 on Windows)"
    exit 1
fi

# Install dependencies
echo "Installing build dependencies..."
sudo apt-get update
sudo apt-get install -y \
    git build-essential bc \
    libncurses5-dev libssl-dev \
    device-tree-compiler u-boot-tools \
    wget unzip

# Create workspace
WORKSPACE="$HOME/nook-kernel-dev"
mkdir -p "$WORKSPACE"
cd "$WORKSPACE"

# Download Android NDK if not present
NDK_VERSION="android-ndk-r23c"
if [ ! -d "$NDK_VERSION" ]; then
    echo "Downloading Android NDK r23c..."
    wget https://dl.google.com/android/repository/${NDK_VERSION}-linux.zip
    echo "Extracting NDK (this takes a minute)..."
    unzip -q ${NDK_VERSION}-linux.zip
    rm ${NDK_VERSION}-linux.zip
else
    echo "Android NDK already present"
fi

# Clone kernel source
if [ ! -d "nst-kernel" ]; then
    echo "Cloning nst-kernel repository..."
    git clone https://github.com/felixhaedicke/nst-kernel
else
    echo "Kernel source already cloned"
fi

# Create build script
cat > "$WORKSPACE/build-kernel.sh" << 'EOF'
#!/bin/bash
# Quick kernel build script

# Set up environment
export ANDROID_NDK="$HOME/nook-kernel-dev/android-ndk-r23c"
export PATH="$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH"
export ARCH=arm
export CROSS_COMPILE=arm-linux-androideabi-

# Enter kernel directory
cd "$HOME/nook-kernel-dev/nst-kernel"

# Configure (skip if .config exists)
if [ ! -f .config ]; then
    echo "Configuring kernel..."
    make nook_defconfig
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
EOF

chmod +x "$WORKSPACE/build-kernel.sh"

# Create customization helper
cat > "$WORKSPACE/customize-kernel.sh" << 'EOF'
#!/bin/bash
# Opens kernel configuration menu

export ANDROID_NDK="$HOME/nook-kernel-dev/android-ndk-r23c"
export PATH="$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH"
export ARCH=arm
export CROSS_COMPILE=arm-linux-androideabi-

cd "$HOME/nook-kernel-dev/nst-kernel"

# Ensure we have a base config
if [ ! -f .config ]; then
    make nook_defconfig
fi

echo "Opening kernel configuration menu..."
echo "Tips:"
echo "  - Use arrow keys to navigate"
echo "  - Space to toggle options"
echo "  - ? for help on any option"
echo "  - Save and exit when done"
echo ""
sleep 2

make menuconfig
EOF

chmod +x "$WORKSPACE/customize-kernel.sh"

# Final instructions
echo ""
echo "=== Setup Complete! ==="
echo ""
echo "Workspace created at: $WORKSPACE"
echo ""
echo "Next steps:"
echo "1. cd $WORKSPACE"
echo "2. ./build-kernel.sh        # Build with default config"
echo "   OR"
echo "   ./customize-kernel.sh    # Customize first, then build"
echo ""
echo "Build output will be at:"
echo "$WORKSPACE/nst-kernel/arch/arm/boot/uImage"
echo ""
echo "Happy kernel hacking!"