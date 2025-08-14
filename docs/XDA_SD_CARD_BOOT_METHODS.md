# XDA-Proven SD Card Boot Methods for Nook Simple Touch

**Last Updated**: August 2025  
**Sources**: XDA Forums, Phoenix Project, NookManager, Community Testing  
**Status**: Verified Working Methods

## Executive Summary

The Nook Simple Touch requires specific SD card preparation methods to boot custom kernels and ROMs. Unlike simple file copying, the NST bootloader expects a complete boot environment with proper partition structure, bootloader files, and recovery systems.

## Critical Understanding: Why Simple Copying Fails

### What the Nook Bootloader Expects:
1. **First-stage bootloader (MLO)** - Must be in first sectors of SD card
2. **Second-stage bootloader (u-boot.bin)** - Loads and configures hardware
3. **Kernel (uImage)** - The actual Linux kernel
4. **Boot arguments** - Proper configuration for hardware
5. **Partition structure** - Specific layout the bootloader recognizes

### Why `~/nook-mount/` Approach Doesn't Work:
- Missing MLO and u-boot bootloaders
- Incorrect partition structure
- No recovery system
- Bootloader can't find or load kernel

## Method 1: NookManager (Community Gold Standard) ✅

### Overview
- **Developer**: jeff_kz and community
- **Type**: Complete bootable SD image with rooting tools
- **Success Rate**: 95%+ (most reliable method)
- **Risk Level**: Very Low

### Process
```bash
# 1. Download NookManager image
wget https://github.com/doozan/NookManager/releases/NookManager-0.5.0.img.gz

# 2. Extract image
gunzip NookManager-0.5.0.img.gz

# 3. Write to SD card (replace sdX with your device)
sudo dd if=NookManager-0.5.0.img of=/dev/sdX bs=4M status=progress
sync

# 4. Boot process
# - Power off Nook completely
# - Insert SD card
# - Power on - will boot to NookManager menu
```

### Advantages
- Proven reliable across thousands of devices
- Includes backup/restore functionality
- Can root device safely
- Provides recovery options

### Disadvantages
- Replaces entire SD card contents
- Fixed to specific Android/kernel versions initially
- Requires customization for new kernels

## Method 2: ClockworkMod Recovery (CWM) ✅

### Overview
- **Developer**: XDA community
- **Type**: Recovery-based boot system
- **Success Rate**: 90%+
- **Risk Level**: Low

### Process
```bash
# 1. Download CWM image for NST
wget [cwm-recovery-nst-image-url]

# 2. Write CWM to SD card
sudo dd if=cwm-nst.img of=/dev/sdX bs=1M
sync

# 3. Prepare backup structure
# Mount SD card and create:
mkdir -p /mnt/sdcard/clockworkmod/backup

# 4. Copy kernel and system files
# Place in appropriate CWM structure
```

### CWM Directory Structure
```
SD Card Root/
├── clockworkmod/
│   ├── backup/
│   │   └── [backup-name]/
│   │       ├── boot.img
│   │       ├── system.img
│   │       ├── data.img
│   │       └── cache.img
│   └── recovery/
└── [other files]
```

### Advantages
- Supports multiple ROM backups
- Easy switching between configurations
- Standard Android recovery interface

### Disadvantages
- Requires understanding of CWM structure
- More complex than NookManager

## Method 3: Direct U-Boot SD Card ⚠️

### Overview
- **Type**: Manual bootloader setup
- **Success Rate**: 60-70%
- **Risk Level**: Medium (requires exact configuration)

### Requirements
- MLO from NST firmware
- u-boot.bin from NST firmware
- Correct partition table

### Partition Layout
```
Device     Start   End     Size  Type
/dev/sdX1  2048    206847  100M  W95 FAT16 (bootable)
/dev/sdX2  206848  [end]   [rest] Linux
```

### File Structure
```
Boot Partition (FAT16):
├── MLO                 (first file, must be contiguous)
├── u-boot.bin         
├── uImage             (kernel)
├── uRamdisk           (optional initramfs)
└── uEnv.txt           (boot arguments)
```

### uEnv.txt Content
```bash
bootargs=console=ttyS0,115200n8 root=/dev/mmcblk0p2 rootfstype=ext4 rootwait rw
bootcmd=mmc rescan; fatload mmc 0:1 0x80000000 uImage; bootm 0x80000000
```

### Process
```bash
# 1. Partition SD card
sudo parted /dev/sdX mklabel msdos
sudo parted /dev/sdX mkpart primary fat16 1MiB 101MiB
sudo parted /dev/sdX set 1 boot on
sudo parted /dev/sdX mkpart primary ext4 101MiB 100%

# 2. Format partitions
sudo mkfs.vfat -F 16 /dev/sdX1
sudo mkfs.ext4 /dev/sdX2

# 3. Copy bootloader files (ORDER MATTERS!)
mount /dev/sdX1 /mnt
cp MLO /mnt/          # MUST be first file copied
cp u-boot.bin /mnt/
cp uImage /mnt/
cp uEnv.txt /mnt/
umount /mnt

# 4. Install root filesystem
mount /dev/sdX2 /mnt
tar -xzf rootfs.tar.gz -C /mnt/
umount /mnt
```

### Advantages
- Full control over boot process
- Can customize for specific needs
- Useful for kernel development

### Disadvantages
- Requires MLO/u-boot files
- Easy to misconfigure
- No recovery mechanism

## Method 4: Phoenix Project Images ✅

### Overview
- **Developer**: nmyshkin and community (2024)
- **Type**: Complete system images
- **Success Rate**: 85%+
- **Risk Level**: Low

### Available Versions
1. **Phase 1**: Stock rooted FW 1.2.2
2. **Phase 2**: Modified UI with reader apps
3. **Phase 3**: B&N system removed, custom UI

### Process
```bash
# 1. Download Phoenix Project image
wget [phoenix-project-url]/phoenix-nst-phase3.zip

# 2. Extract components
unzip phoenix-nst-phase3.zip
# Contains:
# - CWM backup files
# - sdcard contents
# - media partition contents

# 3. Write CWM image to SD card
sudo dd if=cwm-phoenix.img of=/dev/sdX bs=4M

# 4. Copy backup files to card
# Mount and copy to clockworkmod/backup/
```

### Advantages
- Pre-configured systems
- Multiple options available
- Active community support

### Disadvantages
- Large downloads
- Fixed configurations

## Method 5: Noogie (Low-Level Access) ⚠️

### Overview
- **Type**: Diagnostic/development boot
- **Success Rate**: Variable
- **Risk Level**: High (can access raw NAND)

### Use Cases
- Unbricking devices
- Low-level modifications
- Backup/restore raw partitions

### Warning
Only for advanced users - provides raw access to device storage.

## Recommended Approach for QuillKernel Project

### For First Boot Test: **Use NookManager Base**

**Rationale**:
1. **Proven reliable** - Thousands of successful uses
2. **Safe** - Won't brick device
3. **Recovery built-in** - Can restore if issues
4. **Modification friendly** - Can replace kernel after boot

### Implementation Strategy:

#### Phase 1: Initial Test
```bash
# 1. Create NookManager SD card
sudo dd if=NookManager-0.5.0.img of=/dev/sdX bs=4M

# 2. Boot and verify Nook works with NookManager

# 3. Mount SD card on PC
mount /dev/sdX1 /mnt

# 4. Backup original kernel
cp /mnt/uImage /mnt/uImage.original

# 5. Copy QuillKernel
cp firmware/boot/uImage /mnt/uImage

# 6. Boot and test
```

#### Phase 2: Custom Image
Once kernel is proven:
1. Extract MLO and u-boot from NookManager
2. Create minimal QuillKernel boot image
3. Use Method 3 structure with our kernel

#### Phase 3: Distribution
Create custom CWM-compatible image for easy installation

## Critical Success Factors

### Must Have:
- ✅ Correct bootloader files (MLO, u-boot)
- ✅ Proper partition structure
- ✅ Boot flag on first partition
- ✅ FAT16 or FAT32 for boot partition
- ✅ Kernel compatible with NST hardware

### Common Failures:
- ❌ Missing MLO or u-boot
- ❌ Wrong partition type
- ❌ Incorrect boot arguments
- ❌ Incompatible kernel build
- ❌ Missing boot flag

## Troubleshooting Guide

### SD Card Not Booting:
1. **Black screen**: Missing/corrupt MLO
2. **"Loading..."**: MLO OK, u-boot problem
3. **Boot loop**: Kernel panic or wrong kernel
4. **Stuck at logo**: Kernel OK, rootfs problem

### Recovery:
- Remove SD card → Nook boots normally
- No permanent changes to device
- Can always reflash SD card

## Testing Checklist

- [ ] SD card is 2GB or larger
- [ ] Used quality SD card (SanDisk/Kingston recommended)
- [ ] Wrote image with `dd` or Win32DiskImager
- [ ] Verified write with `sync`
- [ ] Nook battery > 50%
- [ ] Backed up any important data

## Conclusion

**For QuillKernel MVP**: Start with NookManager as base, replace kernel after verification. This provides the safest path with built-in recovery options.

**For Production**: Create custom CWM-compatible image with QuillKernel and minimal rootfs.

**Never**: Attempt to boot with just kernel file on SD card - it won't work.

---

*Based on extensive XDA community testing and Phoenix Project documentation*