#!/bin/bash
# Master build script for Nook Typewriter firmware

set -euo pipefail

echo "Building Nook Typewriter firmware..."

# Build kernel
./scripts/build-kernel.sh

# Build rootfs
./scripts/build-rootfs.sh

# Create boot files
./scripts/create-boot.sh

echo "Build complete! Firmware ready in platform/nook-touch/"
