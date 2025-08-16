# 🏰 Nook Typewriter Boot Guide - Complete Reference

*Last Updated: August 14, 2025*  
*Status: Consolidated from multiple sources*

## Table of Contents

1. [Overview](#overview)
2. [Boot Architecture](#boot-architecture)
3. [Boot Sequence](#boot-sequence)
4. [SD Card Boot Methods](#sd-card-boot-methods)
5. [JesterOS Integration](#jesteros-integration)
6. [Troubleshooting](#troubleshooting)
7. [Testing & Validation](#testing--validation)
8. [Quick Reference](#quick-reference)

---

## Overview

This guide consolidates all boot-related documentation for the Nook Typewriter project, providing a single source of truth for booting custom firmware on the Barnes & Noble Nook Simple Touch.

### Key Principles

- **SD Card First**: Always boot from SD card during development
- **Preserve Internal Storage**: Never modify internal NAND without backup
- **Test Before Deploy**: Validate boot process in safe environment
- **Recovery Ready**: Always have a known-good recovery SD card

---

## Boot Architecture

### Hardware Boot Chain

```
1. OMAP3621 ROM Code
   ↓
2. MLO (First-stage bootloader)
   ↓
3. U-Boot (Second-stage bootloader)
   ↓
4. Linux Kernel (uImage)
   ↓
5. Android Init / Linux Init
   ↓
6. JesterOS Userspace Services
```

### Critical Components

| Component | Location | Purpose |
|-----------|----------|---------|
| **MLO** | First sectors of SD | Hardware initialization |
| **u-boot.bin** | After MLO | Device configuration |
| **uImage** | Boot partition | Linux kernel 2.6.29 |
| **uRamdisk** | Boot partition | Initial root filesystem |
| **JesterOS** | /var/jesteros/ | Userspace services |

### Partition Structure

```
/dev/sdX1 - Boot (FAT32, 100MB)
├── MLO
├── u-boot.bin
├── uImage
├── uRamdisk
└── boot.scr (optional)

/dev/sdX2 - Root (ext4, remainder)
├── /bin
├── /etc
├── /usr
└── /var/jesteros/
```

---

## Boot Sequence

### Stage 1: Hardware Initialization

```bash
# OMAP3621 ROM Code executes
# Searches for MLO in:
1. SD card (preferred for development)
2. Internal NAND
3. USB boot (if enabled)
```

### Stage 2: Bootloader

```bash
# MLO loads and executes u-boot
# U-Boot performs:
- DDR initialization
- Display controller setup
- Load kernel from boot partition
- Pass bootargs to kernel
```

### Stage 3: Kernel Boot

```bash
# Linux 2.6.29 kernel boots
# Key bootargs:
console=ttyO0,115200n8
root=/dev/mmcblk0p2 rw rootwait
mem=256M
lcd=omap3_epson_vga
```

### Stage 4: Init Process

```bash
# Android init or Linux init starts
# For JesterOS:
1. Mount filesystems
2. Start essential services
3. Launch JesterOS userspace
```

### Stage 5: JesterOS Startup

```bash
# JesterOS userspace services initialize
/usr/local/bin/jesteros-userspace.sh &
/usr/local/bin/jesteros-tracker.sh &

# Creates interface at /var/jesteros/
├── jester       # ASCII art display
├── typewriter/  # Writing statistics
└── wisdom       # Inspirational quotes
```

---

## SD Card Boot Methods

### Method 1: NookManager (Recommended) ✅

**Success Rate**: 95%+  
**Risk Level**: Very Low  
**Use Case**: Rooting, recovery, initial setup

```bash
# Download NookManager
wget https://github.com/doozan/NookManager/releases/NookManager-0.5.0.img.gz

# Extract and write to SD card
gunzip NookManager-0.5.0.img.gz
sudo dd if=NookManager-0.5.0.img of=/dev/sdX bs=4M status=progress
sync

# Boot process
1. Power off Nook completely
2. Insert SD card
3. Power on - boots to NookManager menu
```

### Method 2: Custom Boot Image

**Success Rate**: 80%  
**Risk Level**: Medium  
**Use Case**: Development and testing

```bash
# Create boot partition
sudo fdisk /dev/sdX
# Create 100MB FAT32 partition (type 'b')
# Create ext4 partition for rootfs

# Format partitions
sudo mkfs.vfat -F 32 /dev/sdX1
sudo mkfs.ext4 /dev/sdX2

# Copy boot files
sudo mount /dev/sdX1 /mnt/boot
sudo cp MLO u-boot.bin uImage uRamdisk /mnt/boot/
sudo umount /mnt/boot

# Copy rootfs
sudo mount /dev/sdX2 /mnt/root
sudo tar -xf nook-rootfs.tar.gz -C /mnt/root/
sudo umount /mnt/root
```

### Method 3: ClockworkMod Recovery

**Success Rate**: 90%  
**Risk Level**: Low  
**Use Case**: ROM installation, backups

```bash
# Write CWM image to SD card
sudo dd if=cwm-recovery-nook.img of=/dev/sdX bs=1M
sync

# Boot to recovery
1. Insert SD card
2. Power on while holding 'n' button
3. CWM recovery menu appears
```

---

## JesterOS Integration

### Boot Configuration

```bash
# /etc/init.d/jesteros
#!/bin/sh
### BEGIN INIT INFO
# Provides:          jesteros
# Required-Start:    $local_fs $syslog
# Required-Stop:     $local_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Description:       JesterOS Userspace Services
### END INIT INFO

case "$1" in
    start)
        echo "Starting JesterOS..."
        /usr/local/bin/jesteros-userspace.sh &
        ;;
    stop)
        echo "Stopping JesterOS..."
        pkill -f jesteros
        ;;
esac
```

### First Boot Setup

```bash
# Install JesterOS userspace
./install-jesteros-userspace.sh

# Verify installation
ls -la /var/jesteros/
cat /var/jesteros/jester

# Enable at boot
update-rc.d jesteros defaults
```

### Boot Optimization

```bash
# Minimal services for fast boot
SERVICES="
    jesteros
    fbink
    vim-minimal
"

# Disable unnecessary services
for service in bluetooth wifi networking; do
    update-rc.d $service disable
done
```

---

## Troubleshooting

### Boot Failures

#### Black Screen
- **Cause**: Missing or corrupt bootloader
- **Solution**: Re-write MLO and u-boot.bin to SD card

#### Stuck at Boot Logo
- **Cause**: Kernel panic or missing rootfs
- **Solution**: Check kernel bootargs and rootfs integrity

#### Boot Loop
- **Cause**: Init script failure
- **Solution**: Boot to recovery, check /var/log/

### Debug Methods

```bash
# Enable verbose boot
# Add to bootargs:
debug earlyprintk loglevel=7

# Serial console debugging
screen /dev/ttyUSB0 115200

# Check boot logs
dmesg | grep -E "boot|init|error"
journalctl -b
```

### Recovery Options

1. **NookManager Recovery**
   - Boot from NookManager SD
   - Access root shell
   - Fix issues via ADB or terminal

2. **Factory Reset**
   - Hold power + home for 20 seconds
   - Restores original firmware

3. **Emergency SD Card**
   - Keep known-good boot SD
   - Contains minimal working system

---

## Testing & Validation

### Pre-Boot Checklist

```bash
#!/bin/bash
# boot-preflight.sh

echo "=== Boot Preflight Check ==="

# Check boot files
for file in MLO u-boot.bin uImage uRamdisk; do
    if [ -f "/mnt/boot/$file" ]; then
        echo "[✓] $file present"
    else
        echo "[✗] $file missing!"
        exit 1
    fi
done

# Verify partition structure
if fdisk -l /dev/sdX | grep -q "FAT32"; then
    echo "[✓] Boot partition correct"
else
    echo "[✗] Boot partition incorrect!"
    exit 1
fi

echo "=== Ready to boot ==="
```

### Boot Sequence Test

```bash
#!/bin/bash
# test-boot-sequence.sh

echo "Testing boot sequence..."

# Stage 1: Bootloader
if [ -f /proc/cmdline ]; then
    echo "[✓] Kernel booted"
    cat /proc/cmdline
else
    echo "[✗] Kernel boot failed"
fi

# Stage 2: Init
if pgrep init > /dev/null; then
    echo "[✓] Init running"
else
    echo "[✗] Init failed"
fi

# Stage 3: JesterOS
if [ -d /var/jesteros ]; then
    echo "[✓] JesterOS initialized"
    ls -la /var/jesteros/
else
    echo "[✗] JesterOS not found"
fi
```

### Performance Metrics

| Stage | Target Time | Actual |
|-------|------------|--------|
| Bootloader | < 2s | - |
| Kernel | < 5s | - |
| Init | < 3s | - |
| JesterOS | < 2s | - |
| **Total** | **< 12s** | - |

---

## Quick Reference

### Essential Commands

```bash
# Write SD card image
sudo dd if=boot.img of=/dev/sdX bs=4M status=progress

# Mount boot partition
sudo mount /dev/sdX1 /mnt/boot

# Check boot logs
dmesg | grep -i boot
journalctl -b -u jesteros

# Emergency recovery
# Hold Power + Home for factory reset
```

### File Locations

```
Boot Files:        /boot/ (SD card partition 1)
JesterOS Scripts:  /usr/local/bin/jesteros-*
JesterOS Data:     /var/jesteros/
Boot Logs:         /var/log/boot.log
Kernel Config:     /proc/config.gz
```

### Boot Parameters

```
Default: console=ttyO0,115200n8 root=/dev/mmcblk0p2 rw rootwait
Debug:   console=ttyO0,115200n8 root=/dev/mmcblk0p2 rw rootwait debug earlyprintk loglevel=7
Recovery: console=ttyO0,115200n8 root=/dev/mmcblk0p1 rw init=/bin/sh
```

---

## Migration Notes

### From Kernel Modules to Userspace

The boot process has been simplified with JesterOS moving to userspace:

**Old Boot Process** (Deprecated):
```
Kernel → Load JokerOS modules → /proc/jokeros/
```

**New Boot Process** (Current):
```
Kernel → Init → JesterOS userspace → /var/jesteros/
```

No kernel compilation or module loading required!

---

## References

- [XDA SD Card Boot Methods](XDA_SD_CARD_BOOT_METHODS.md)
- [JesterOS Migration Guide](MIGRATION_TO_USERSPACE.md)
- [Kernel Documentation](kernel-reference/KERNEL_DOCUMENTATION.md)
- [Deployment Guide](DEPLOYMENT_INTEGRATION_GUIDE.md)

---

*"From power on to jester's dawn, the boot sequence carries on!"* 🎭🚀