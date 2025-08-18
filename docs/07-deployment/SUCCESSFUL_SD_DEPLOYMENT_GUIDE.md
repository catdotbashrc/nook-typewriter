# JesterOS Successful SD Card Deployment Guide

**Date**: August 17, 2025  
**Status**: ✅ VERIFIED WORKING  
**Tested On**: Nook SimpleTouch with 16GB SD Card

## Overview

This guide documents the **proven working method** for deploying JesterOS with GK61 keyboard support to an SD card for Nook SimpleTouch. This process has been tested and confirmed to successfully create a bootable JesterOS environment.

## Critical Success Factors

1. **Sector 63 Alignment**: The Nook bootloader requires the first partition to start at sector 63
2. **MLO First**: The MLO bootloader MUST be copied first for contiguous storage
3. **Proper Rootfs**: Use the Docker-exported JesterOS image with all runtime components

## Prerequisites

### Required Files
```bash
firmware/boot/MLO                           # 16KB - First stage bootloader
firmware/boot/u-boot.bin                    # 157KB - Second stage bootloader  
firmware/boot/uImage                        # 2.1MB - Linux 2.6.29 kernel
firmware/boot/boot.scr                      # 199B - Boot script
jesteros-rootfs-with-gk61-20250817.tar.gz  # 48MB - Complete JesterOS with GK61
```

### Required Tools
- Linux system with sudo access (WSL2 on Windows 11 works)
- `sfdisk` for partitioning
- `mkfs.vfat` and `mkfs.ext4` for formatting
- SD card reader
- 2GB+ SD card (16GB recommended)

## Step-by-Step Deployment Process

### Step 1: Identify SD Card Device

```bash
# Insert SD card and identify device
lsblk
# Look for your SD card (usually /dev/sdX where X is e, f, g, etc.)
# In this guide, we use /dev/sdg as example
```

**⚠️ WARNING**: Verify this is your SD card! Wrong device = data loss!

### Step 2: Create Docker Export with GK61 Support

```bash
# Build the JesterOS base image with GK61 support
docker build -t jesteros-base -f build/docker/jesteros-base.dockerfile .

# Export as rootfs
docker create --name jesteros-export jesteros-base
docker export jesteros-export | gzip > jesteros-rootfs-with-gk61-$(date +%Y%m%d).tar.gz
docker rm jesteros-export
```

### Step 3: Partition SD Card (Critical!)

**This is the step that makes it work - proper sector 63 alignment:**

```bash
# Create partition layout file
cat > nook-partitions.txt << 'EOF'
label: dos
unit: sectors

start=63, size=524288, type=c, bootable
start=524351, type=83
EOF

# Apply partitions (replace /dev/sdg with your device)
sudo sfdisk /dev/sdg < nook-partitions.txt
```

Expected output:
```
Checking that no-one is using this disk right now ... OK
Disk /dev/sdg: 14.84 GiB, 15931539456 bytes, 31116288 sectors
...
Created a new partition 1 of type 'W95 FAT32 (LBA)' and of size 256 MiB.
Created a new partition 2 of type 'Linux' and of size 14.59 GiB.
The partition table has been altered.
```

### Step 4: Format Partitions

```bash
# Format boot partition as FAT32
sudo mkfs.vfat -F 32 -n "boot" /dev/sdg1

# Format root partition as ext4
sudo mkfs.ext4 -L "rootfs" /dev/sdg2
```

### Step 5: Mount Partitions

```bash
# Create mount points
sudo mkdir -p /mnt/nook-boot /mnt/nook-root

# Mount partitions
sudo mount /dev/sdg1 /mnt/nook-boot
sudo mount /dev/sdg2 /mnt/nook-root
```

### Step 6: Deploy Boot Files (ORDER MATTERS!)

```bash
cd /home/jyeary/projects/personal/nook

# CRITICAL: MLO must be first for contiguous storage!
sudo cp firmware/boot/MLO /mnt/nook-boot/

# Then other boot files
sudo cp firmware/boot/u-boot.bin /mnt/nook-boot/
sudo cp firmware/boot/uImage /mnt/nook-boot/
sudo cp firmware/boot/boot.scr /mnt/nook-boot/

# Verify
ls -la /mnt/nook-boot/
```

Expected output:
```
-rwxr-xr-x 1 root root   16004 Aug 17 20:45 MLO
-rwxr-xr-x 1 root root  159884 Aug 17 20:45 u-boot.bin
-rwxr-xr-x 1 root root 2149444 Aug 17 20:45 uImage
-rwxr-xr-x 1 root root     199 Aug 17 20:45 boot.scr
```

### Step 7: Deploy JesterOS Root Filesystem

```bash
# Extract JesterOS with GK61 support
sudo tar -xzf jesteros-rootfs-with-gk61-20250817.tar.gz -C /mnt/nook-root/

# Verify key components
ls -la /mnt/nook-root/runtime/3-system/services/ | grep usb
# Should show: usb-keyboard-manager.sh

ls -la /mnt/nook-root/runtime/4-hardware/input/
# Should show: button-handler.sh with GK61 support
```

### Step 8: Sync and Unmount

```bash
# Ensure all data is written
sudo sync

# Unmount safely
sudo umount /mnt/nook-boot
sudo umount /mnt/nook-root

# Verify clean unmount
lsblk /dev/sdg
```

### Step 9: Boot on Nook

1. **Remove SD card** from computer
2. **Insert into Nook** SimpleTouch
3. **Power on** while holding the 'n' button
4. **Watch for** JesterOS boot sequence:
   - U-Boot messages
   - Linux kernel boot
   - JesterOS ASCII art

## Troubleshooting

### Issue: fdisk won't accept sector 63
**Solution**: Use `sfdisk` with the partition layout file as shown above

### Issue: Boot fails - no MLO found
**Solution**: MLO must be copied FIRST to ensure contiguous storage

### Issue: Kernel panic - no rootfs
**Solution**: Ensure the rootfs tar.gz was properly extracted to partition 2

### Issue: USB keyboard not detected
**Solution**: 
- Check OTG cable is connected before boot
- Verify usb-keyboard-manager.sh exists in /runtime/3-system/services/
- Check dmesg for USB detection messages

## Verification Checklist

After deployment, before first boot:

- [ ] SD card has 2 partitions (256MB FAT32 + remaining ext4)
- [ ] Partition 1 starts at sector 63 (check with `fdisk -l /dev/sdg`)
- [ ] Boot partition contains: MLO, u-boot.bin, uImage, boot.scr
- [ ] Root partition contains /runtime/ directory structure
- [ ] USB keyboard manager present in /runtime/3-system/services/
- [ ] Total deployment size ~100MB (48MB rootfs + boot files)

## Success Indicators

When booting successfully:
1. **Nook screen shows** U-Boot messages
2. **Linux kernel boots** with penguin logo
3. **JesterOS ASCII art** appears
4. **Menu system** is accessible
5. **GK61 keyboard** detected when connected via OTG

## Recovery

If deployment fails, restore from backup:
```bash
# If you created a backup
tar -xzf backups/sd-card-20250817/sdcard-backup-*.tar.gz
```

Or start fresh with a new SD card.

## Key Improvements in This Deployment

1. **GK61 USB Keyboard Support**: Full integration with Skyloong GK61
2. **4-Layer Runtime Architecture**: Organized system structure
3. **Modular Docker Build**: Clean, reproducible builds
4. **Safety Features**: Input validation and error handling
5. **USB OTG Mode**: Automatic host/device switching

## Notes

- **Sector 63 is critical**: Modern tools default to 2048, but Nook needs 63
- **MLO ordering matters**: Must be first file copied for contiguous blocks
- **Docker export works**: Provides clean, complete rootfs with all components
- **WSL2 compatible**: Can deploy from Windows 11 with WSL2

---

*"By quill and candlelight, we deploy with confidence!"* 🕯️📜⌨️

**Document Version**: 1.0  
**Last Updated**: August 17, 2025  
**Status**: Production Ready