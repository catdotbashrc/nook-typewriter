#!/bin/bash
# Flash Nook Typewriter image to SD card

set -euo pipefail

if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <device> <image>"
    echo "Example: $0 /dev/sdb nook-typewriter-v1.0.0.img"
    exit 1
fi

DEVICE=$1
IMAGE=$2

if [[ ! -b "$DEVICE" ]]; then
    echo "Error: $DEVICE is not a block device"
    exit 1
fi

if [[ ! -f "$IMAGE" ]]; then
    echo "Error: Image file $IMAGE not found"
    exit 1
fi

echo "WARNING: This will erase all data on $DEVICE"
read -p "Continue? (y/N) " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled"
    exit 1
fi

echo "Flashing $IMAGE to $DEVICE..."
sudo dd if="$IMAGE" of="$DEVICE" bs=4M status=progress conv=fsync

echo "Flash complete! You can now insert the SD card into your Nook."
