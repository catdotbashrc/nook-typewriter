#!/bin/bash
# Simple kernel build script for JoKernel

set -euo pipefail
trap 'echo "Error at line $LINENO"' ERR

# Source build configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$PROJECT_ROOT/.kernel.env"

echo "═══════════════════════════════════════════════════════════════"
echo "           JoKernel Build Script v${PROJECT_VERSION}"
echo "═══════════════════════════════════════════════════════════════"

# Ensure we're in the right directory
cd "$SCRIPT_DIR"

# Setup kernel source (uses local copy or downloads from catdotbashrc/nst-kernel)
if [ -f "$PROJECT_ROOT/scripts/setup-kernel-source.sh" ]; then
    echo "→ Setting up kernel source..."
    "$PROJECT_ROOT/scripts/setup-kernel-source.sh" || exit 1
    echo ""
fi

# Check if XDA-proven Docker image exists, build if needed
# Use optimized version with BuildKit caching if available
if ! docker images | grep -q "kernel-xda-proven-optimized"; then
    if [ -f "$PROJECT_ROOT/docker/kernel-xda-proven-optimized.dockerfile" ]; then
        echo "→ Building optimized XDA-proven Docker environment with BuildKit..."
        DOCKER_BUILDKIT=1 docker build -t kernel-xda-proven-optimized -f "$PROJECT_ROOT/docker/kernel-xda-proven-optimized.dockerfile" "$PROJECT_ROOT/docker"
        # Create alias for compatibility
        docker tag kernel-xda-proven-optimized jokernel-unified
    elif ! docker images | grep -q "jokernel-unified"; then
        echo "→ Building XDA-proven Docker environment..."
        docker build -t jokernel-unified -f "$PROJECT_ROOT/docker/kernel-xda-proven.dockerfile" "$PROJECT_ROOT/docker"
    fi
else
    # Use optimized image with compatibility alias
    docker tag kernel-xda-proven-optimized jokernel-unified 2>/dev/null || true
fi

# Build the kernel using Docker
echo ""
echo "→ Starting kernel build with XDA-proven toolchain..."

# Get absolute path to project root  
PROJECT_ROOT="${PROJECT_ROOT:-/home/jyeary/projects/personal/nook}"

# Resolve the kernel source path (follow symlink if it exists)
if [ -L "${PROJECT_ROOT}/source/kernel/src" ]; then
    KERNEL_SRC_PATH=$(readlink -f "${PROJECT_ROOT}/source/kernel/src")
else
    KERNEL_SRC_PATH="${PROJECT_ROOT}/source/kernel/src"
fi

docker run --rm \
    -v "${KERNEL_SRC_PATH}:/kernel/src" \
    -v "${PROJECT_ROOT}/firmware:/firmware" \
    -e J_CORES="${J_CORES:-4}" \
    jokernel-unified \
    bash -c "
        cd /kernel/src && 
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
        make -j${J_CORES:-4} ARCH=arm CROSS_COMPILE=arm-linux-androideabi- olddefconfig
        make -j${J_CORES:-4} ARCH=arm CROSS_COMPILE=arm-linux-androideabi- uImage
        
        echo '→ Building modules...'
        make -j${J_CORES:-4} ARCH=arm CROSS_COMPILE=arm-linux-androideabi- modules
        
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
mkdir -p "${PROJECT_ROOT}/platform/nook-touch/boot"
if [ -f "${PROJECT_ROOT}/source/kernel/src/arch/arm/boot/uImage" ]; then
    cp "${PROJECT_ROOT}/source/kernel/src/arch/arm/boot/uImage" "${PROJECT_ROOT}/platform/nook-touch/boot/"
    echo "✓ Kernel image copied to platform/nook-touch/boot/uImage"
    ls -lh "${PROJECT_ROOT}/platform/nook-touch/boot/uImage"
else
    echo "✗ Could not find uImage"
    exit 1
fi

# Generate build info
echo ""
echo "→ Generating build information..."
if [ -f "$SCRIPT_DIR/version-control.sh" ]; then
    "$SCRIPT_DIR/version-control.sh" build
    echo "✓ Build info generated"
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "✓ JoKernel build complete! (v${PROJECT_VERSION})"
echo "═══════════════════════════════════════════════════════════════"