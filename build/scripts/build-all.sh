#!/bin/bash
# Master build script for Nook Typewriter firmware

set -euo pipefail

echo "Building Nook Typewriter firmware..."

# Build kernel
./build/scripts/build-kernel.sh

# Build rootfs
./build/scripts/build-rootfs.sh

# Create boot files
./build/scripts/create-boot.sh

echo "Build complete! Firmware ready in firmware/"
