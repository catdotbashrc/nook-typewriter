#!/bin/bash
# generate-boot-script.sh - Generate boot.scr from boot.cmd
# Creates U-Boot script for JesterOS boot

set -euo pipefail

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BOOT_DIR="$PROJECT_ROOT/platform/nook-touch/boot"

# Tool
MKIMAGE="${MKIMAGE:-mkimage}"

# Check for mkimage
if ! command -v "$MKIMAGE" >/dev/null 2>&1; then
    echo "Error: mkimage not found. Install u-boot-tools:"
    echo "  sudo apt-get install u-boot-tools"
    exit 1
fi

# Check for boot.cmd
if [ ! -f "$BOOT_DIR/boot.cmd" ]; then
    echo "Error: boot.cmd not found at $BOOT_DIR/boot.cmd"
    exit 1
fi

echo "Generating boot.scr from boot.cmd..."

# Generate boot.scr
$MKIMAGE -A arm -O linux -T script -C none \
    -a 0 -e 0 \
    -n "JesterOS Boot Script" \
    -d "$BOOT_DIR/boot.cmd" "$BOOT_DIR/boot.scr"

# Check result
if [ -f "$BOOT_DIR/boot.scr" ]; then
    echo "✓ boot.scr generated successfully at $BOOT_DIR/boot.scr"
    ls -lh "$BOOT_DIR/boot.scr"
else
    echo "Error: Failed to generate boot.scr"
    exit 1
fi