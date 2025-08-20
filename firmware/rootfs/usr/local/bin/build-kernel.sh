#!/bin/bash
# Unified Kernel Build Script with Integrated SquireOS
# Builds Linux 2.6.29 with medieval writing support

set -euo pipefail
trap 'echo "Error at line $LINENO"' ERR

echo "═══════════════════════════════════════════════════════════════"
echo "           Nook Typewriter Kernel Build System"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "     .~\"~.~\"~."
echo "    /  o   o  \\\\"
echo "   |  >  ◡  <  |   Building thy kernel with"
echo "    \\  ___  /      integrated SquireOS modules..."
echo "     |~|♦|~|"
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Configuration
KERNEL_DIR="${KERNEL_DIR:-source/kernel/nst-kernel-base}"
BUILD_MODE="${1:-full}"  # full, kernel-only, modules-only
CLEAN="${2:-no}"         # yes to clean first

# Get to project root
cd "$(dirname "$0")/../.."

# Check if kernel source exists
if [ ! -f "$KERNEL_DIR/src/Makefile" ]; then
    echo "Error: Kernel source not found at $KERNEL_DIR/src"
    echo "Please run: git submodule update --init"
    exit 1
fi

# Check if SquireOS modules are integrated
if [ ! -d "$KERNEL_DIR/src/drivers/squireos" ]; then
    echo "Error: SquireOS modules not found at $KERNEL_DIR/src/drivers/squireos"
    echo "Integration incomplete!"
    exit 1
fi

echo "→ Kernel source: $KERNEL_DIR"
echo "→ SquireOS modules: Integrated ✓"
echo ""

# Build options
ARCH=arm
CROSS_COMPILE=arm-linux-gnueabi-
DEFCONFIG=omap3621_gossamer_evt1c_defconfig

# Check for Docker
if command -v docker &> /dev/null; then
    echo "→ Using Docker build environment"
    BUILD_CMD="docker run --rm -v $(pwd)/$KERNEL_DIR:/kernel -w /kernel/src quillkernel-builder"
    
    # Build Docker image if needed
    if ! docker images | grep -q quillkernel-builder; then
        echo "→ Building Docker image..."
        if [ -f build/docker/kernel.dockerfile ]; then
            docker build -t quillkernel-builder -f build/docker/kernel.dockerfile build/docker/
        else
            echo "Warning: Docker build file not found, using native build"
            BUILD_CMD=""
        fi
    fi
else
    echo "→ Using native build environment"
    BUILD_CMD=""
fi

# Clean if requested
if [ "$CLEAN" == "yes" ]; then
    echo "→ Cleaning previous build..."
    cd "$KERNEL_DIR/src"
    if [ -n "$BUILD_CMD" ]; then
        $BUILD_CMD make ARCH=$ARCH clean
    else
        make ARCH=$ARCH clean
    fi
    cd - > /dev/null
fi

# Configure kernel
echo ""
echo "→ Configuring kernel..."
cd "$KERNEL_DIR/src"

# Use default config
if [ -n "$BUILD_CMD" ]; then
    $BUILD_CMD make ARCH=$ARCH $DEFCONFIG
else
    make ARCH=$ARCH $DEFCONFIG
fi

# Enable SquireOS modules in config
echo "→ Enabling SquireOS modules..."
cat >> .config << EOF
CONFIG_SQUIREOS=y
CONFIG_SQUIREOS_JESTER=y
CONFIG_SQUIREOS_TYPEWRITER=y
CONFIG_SQUIREOS_WISDOM=y
EOF

# Update config with our changes
if [ -n "$BUILD_CMD" ]; then
    $BUILD_CMD make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE oldconfig
else
    make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE oldconfig
fi

echo "✓ Configuration complete"

# Build kernel
if [ "$BUILD_MODE" == "full" ] || [ "$BUILD_MODE" == "kernel-only" ]; then
    echo ""
    echo "→ Building kernel image..."
    echo "  This will take 5-10 minutes..."
    
    if [ -n "$BUILD_CMD" ]; then
        $BUILD_CMD make -j$(nproc) ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE uImage
    else
        make -j$(nproc) ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE uImage
    fi
    
    if [ -f arch/arm/boot/uImage ]; then
        echo "✓ Kernel image built successfully!"
        ls -lh arch/arm/boot/uImage
    else
        echo "✗ Kernel build failed"
        exit 1
    fi
fi

# Build modules (if configured as modules)
if [ "$BUILD_MODE" == "full" ] || [ "$BUILD_MODE" == "modules-only" ]; then
    echo ""
    echo "→ Building kernel modules..."
    
    if [ -n "$BUILD_CMD" ]; then
        $BUILD_CMD make -j$(nproc) ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE modules
    else
        make -j$(nproc) ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE modules
    fi
    
    echo "✓ Modules built successfully!"
fi

cd - > /dev/null

# Copy artifacts to firmware directory
echo ""
echo "→ Installing build artifacts..."
mkdir -p platform/nook-touch/kernel/modules
mkdir -p platform/nook-touch/boot

if [ -f "$KERNEL_DIR/src/arch/arm/boot/uImage" ]; then
    cp "$KERNEL_DIR/src/arch/arm/boot/uImage" platform/nook-touch/kernel/
    cp "$KERNEL_DIR/src/arch/arm/boot/uImage" platform/nook-touch/boot/
    echo "  ✓ Kernel image: platform/nook-touch/kernel/uImage"
fi

# If SquireOS was built as a module, copy it
if [ -f "$KERNEL_DIR/src/drivers/squireos/squireos.ko" ]; then
    cp "$KERNEL_DIR/src/drivers/squireos/squireos.ko" platform/nook-touch/kernel/modules/
    echo "  ✓ SquireOS module: platform/nook-touch/kernel/modules/squireos.ko"
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "✅ Kernel build complete!"
echo ""
echo "Integrated components:"
echo "  • Linux kernel 2.6.29 for Nook Simple Touch"
echo "  • SquireOS medieval interface"
echo "  • Jester ASCII art system"
echo "  • Typewriter statistics tracking"
echo "  • Writing wisdom quotes"
echo ""
echo "Next steps:"
echo "  1. Build rootfs: make rootfs"
echo "  2. Create SD image: make image"
echo "  3. Flash to Nook: make install"
echo ""
echo "To test the jester on device:"
echo "  cat /proc/squireos/jester"
echo "═══════════════════════════════════════════════════════════════"