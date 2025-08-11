#!/bin/bash
# QuillKernel Build Script
# Builds the medieval-themed kernel for Nook Simple Touch

set -e

echo "═══════════════════════════════════════════════════════════════"
echo "           QuillKernel Build System"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Check if we're in the right directory
if [ ! -f "Dockerfile" ] || [ ! -d "modules" ]; then
    echo "Error: Please run this script from the quillkernel directory"
    exit 1
fi

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is required but not installed"
    echo "Please install Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

# Build the Docker image
echo "→ Building Docker image..."
docker build -t quillkernel-builder .

# Check if kernel submodule is initialized
if [ ! -f "../nst-kernel-base/src/Makefile" ]; then
    echo "→ Initializing kernel submodule..."
    (cd .. && git submodule update --init nst-kernel-base)
fi

# Run the build
echo "→ Starting kernel build..."
docker run --rm \
    -v "$(dirname $(pwd))":/build \
    -v /tmp/quillkernel-ccache:/root/.ccache \
    quillkernel-builder

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "✓ Build complete!"
echo ""
echo "Kernel image: ../nst-kernel-base/src/arch/arm/boot/uImage"
echo "Modules: modules/*.ko"
echo ""
echo "To install on your Nook:"
echo "1. Copy uImage to the boot partition of your SD card"
echo "2. Copy *.ko modules to /lib/modules/ in your rootfs"
echo "3. Add 'insmod /lib/modules/squireos.ko' to startup scripts"
echo "═══════════════════════════════════════════════════════════════"