# Deployment and Integration Guide

*Complete guide for deploying NST kernel and integrating SquireOS modules*

## Table of Contents
- [Overview](#overview)
- [Pre-deployment Preparation](#pre-deployment-preparation)
- [SD Card Deployment](#sd-card-deployment)
- [Boot Configuration](#boot-configuration)
- [Module Integration](#module-integration)
- [System Validation](#system-validation)
- [Troubleshooting](#troubleshooting)
- [Production Deployment](#production-deployment)

---

## Overview

This guide covers the complete deployment process for the NST kernel with SquireOS medieval interface on Barnes & Noble Nook Simple Touch devices.

### Deployment Architecture
```
Development Environment → Build Artifacts → SD Card → Nook Device
     ↓                        ↓              ↓           ↓
 Cross-compile            uImage +         Boot from    Run SquireOS
 Build modules           rootfs.tar.gz     SD card      modules
```

### Prerequisites
- Nook Simple Touch device
- 2GB+ SD card (Class 10 recommended)
- Linux development environment
- Built kernel and modules
- Root access for SD card operations

---

## Pre-deployment Preparation

### Verify Build Artifacts
```bash
# Check kernel image
ls -la nst-kernel-base/src/arch/arm/boot/uImage
file nst-kernel-base/src/arch/arm/boot/uImage

# Verify file size (should be ~2-3MB)
du -h nst-kernel-base/src/arch/arm/boot/uImage

# Check SquireOS modules
find nst-kernel-base/src -name "squireos*.ko"
find nst-kernel-base/src -name "jester.ko"
find nst-kernel-base/src -name "typewriter.ko"
find nst-kernel-base/src -name "wisdom.ko"
```

### Prepare Root Filesystem
```bash
# Build minimal rootfs
docker build -t nook-mvp-rootfs -f minimal-boot.dockerfile .

# Export rootfs
docker create --name nook-export nook-mvp-rootfs
docker export nook-export | gzip > nook-mvp-rootfs.tar.gz
docker rm nook-export

# Verify rootfs size (should be <30MB compressed)
ls -lh nook-mvp-rootfs.tar.gz
```

### Backup Original System
```bash
# Create backup of original Nook firmware (IMPORTANT!)
# Insert Nook's original SD card (if any)
sudo dd if=/dev/sdX of=nook_original_backup.img bs=1M
gzip nook_original_backup.img

# Store backup safely
mv nook_original_backup.img.gz ~/nook_backups/
```

---

## SD Card Deployment

### SD Card Partitioning
```bash
# WARNING: This will erase the SD card completely!
export SD_DEVICE="/dev/sdX"  # Replace X with your SD card

# Unmount any existing partitions
sudo umount ${SD_DEVICE}* 2>/dev/null || true

# Create partition table
sudo fdisk $SD_DEVICE << EOF
o
n
p
1

+100M
t
c
n
p
2


w
EOF

# Format partitions
sudo mkfs.vfat -F 16 -n "NOOK_BOOT" ${SD_DEVICE}1
sudo mkfs.ext4 -L "NOOK_ROOT" ${SD_DEVICE}2
```

### Mount Partitions
```bash
# Create mount points
sudo mkdir -p /mnt/nook_boot /mnt/nook_root

# Mount partitions
sudo mount ${SD_DEVICE}1 /mnt/nook_boot
sudo mount ${SD_DEVICE}2 /mnt/nook_root
```

### Install Boot Files
```bash
# Copy kernel image
sudo cp nst-kernel-base/src/arch/arm/boot/uImage /mnt/nook_boot/

# Create u-boot environment
sudo tee /mnt/nook_boot/uEnv.txt << 'EOF'
# QuillKernel Boot Configuration
bootargs=console=ttymxc0,115200 root=/dev/mmcblk0p2 rootwait rw
bootcmd=fatload mmc 0:1 0x70008000 uImage; bootm 0x70008000
uenvcmd=run bootcmd
EOF

# Set permissions
sudo chmod 644 /mnt/nook_boot/*
```

### Install Root Filesystem
```bash
# Extract rootfs to SD card
sudo tar -xzf nook-mvp-rootfs.tar.gz -C /mnt/nook_root

# Create module directory
sudo mkdir -p /mnt/nook_root/lib/modules/2.6.29

# Copy SquireOS modules
sudo cp nst-kernel-base/src/drivers/squireos_core.ko /mnt/nook_root/lib/modules/
sudo cp nst-kernel-base/src/drivers/jester.ko /mnt/nook_root/lib/modules/
sudo cp nst-kernel-base/src/drivers/typewriter.ko /mnt/nook_root/lib/modules/
sudo cp nst-kernel-base/src/drivers/wisdom.ko /mnt/nook_root/lib/modules/

# Set module permissions
sudo chmod 644 /mnt/nook_root/lib/modules/*.ko
```

---

## Boot Configuration

### Initialize SquireOS Services
```bash
# Create boot service for SquireOS
sudo tee /mnt/nook_root/etc/init.d/squireos << 'EOF'
#!/bin/sh
### BEGIN INIT INFO
# Provides:          squireos
# Required-Start:    $local_fs
# Required-Stop:     $local_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: SquireOS Medieval Interface
# Description:       Load SquireOS kernel modules and start services
### END INIT INFO

case "$1" in
    start)
        echo "Starting SquireOS Medieval Interface..."
        
        # Load modules in dependency order
        modprobe squireos_core 2>/dev/null || insmod /lib/modules/squireos_core.ko
        modprobe jester 2>/dev/null || insmod /lib/modules/jester.ko
        modprobe typewriter 2>/dev/null || insmod /lib/modules/typewriter.ko
        modprobe wisdom 2>/dev/null || insmod /lib/modules/wisdom.ko
        
        # Verify modules loaded
        if [ -f /proc/squireos/jester ]; then
            echo "SquireOS modules loaded successfully"
        else
            echo "Warning: SquireOS modules may not have loaded correctly"
        fi
        ;;
        
    stop)
        echo "Stopping SquireOS..."
        rmmod wisdom 2>/dev/null || true
        rmmod typewriter 2>/dev/null || true
        rmmod jester 2>/dev/null || true
        rmmod squireos_core 2>/dev/null || true
        ;;
        
    restart)
        $0 stop
        sleep 1
        $0 start
        ;;
        
    status)
        if [ -f /proc/squireos/jester ]; then
            echo "SquireOS is running"
            cat /proc/squireos/jester
        else
            echo "SquireOS is not running"
        fi
        ;;
        
    *)
        echo "Usage: $0 {start|stop|restart|status}"
        exit 1
        ;;
esac
EOF

# Make service executable
sudo chmod +x /mnt/nook_root/etc/init.d/squireos

# Enable service
sudo chroot /mnt/nook_root update-rc.d squireos defaults
```

### Configure Auto-start
```bash
# Create systemd service (alternative to init.d)
sudo tee /mnt/nook_root/etc/systemd/system/squireos.service << 'EOF'
[Unit]
Description=SquireOS Medieval Interface
After=local-fs.target

[Service]
Type=oneshot
ExecStart=/etc/init.d/squireos start
ExecStop=/etc/init.d/squireos stop
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# Enable systemd service
sudo chroot /mnt/nook_root systemctl enable squireos.service
```

---

## Module Integration

### Module Dependencies
```bash
# Create modules.dep file
sudo chroot /mnt/nook_root depmod -a

# Verify module dependencies
sudo chroot /mnt/nook_root modinfo squireos_core
sudo chroot /mnt/nook_root modinfo jester
```

### Configuration Files
```bash
# Create SquireOS configuration
sudo mkdir -p /mnt/nook_root/etc/squireos

sudo tee /mnt/nook_root/etc/squireos/config << 'EOF'
# SquireOS Configuration
JESTER_UPDATE_INTERVAL=30
WISDOM_UPDATE_INTERVAL=300
TYPEWRITER_AUTOSAVE=60
DEBUG_LEVEL=1

# Medieval Theme Settings
THEME_ENABLED=1
ASCII_ART_PATH=/usr/share/squireos/ascii
QUOTES_PATH=/usr/share/squireos/quotes
EOF

# Copy ASCII art and quotes
sudo mkdir -p /mnt/nook_root/usr/share/squireos/ascii
sudo mkdir -p /mnt/nook_root/usr/share/squireos/quotes

sudo cp source/configs/ascii/jester/* /mnt/nook_root/usr/share/squireos/ascii/
```

### Menu System Integration
```bash
# Install menu system
sudo cp source/scripts/menu/nook-menu.sh /mnt/nook_root/usr/local/bin/
sudo cp source/scripts/boot/boot-jester.sh /mnt/nook_root/usr/local/bin/

# Set executable permissions
sudo chmod +x /mnt/nook_root/usr/local/bin/*.sh

# Configure auto-login to menu
sudo tee -a /mnt/nook_root/root/.bashrc << 'EOF'
# Auto-start SquireOS menu
if [ -f /proc/squireos/jester ] && [ "$TERM" = "linux" ]; then
    exec /usr/local/bin/nook-menu.sh
fi
EOF
```

---

## System Validation

### Pre-deployment Validation
```bash
# Validate SD card structure
tree /mnt/nook_boot /mnt/nook_root | head -30

# Check file systems
sudo fsck.vfat /dev/sdX1
sudo fsck.ext4 /dev/sdX2

# Verify kernel image
file /mnt/nook_boot/uImage
hexdump -C /mnt/nook_boot/uImage | head -5

# Test module loading (in chroot)
sudo chroot /mnt/nook_root /bin/bash << 'EOF'
modprobe squireos_core
ls /proc/squireos/
modprobe jester
cat /proc/squireos/jester
EOF
```

### Unmount and Finalize
```bash
# Sync all changes
sync

# Unmount safely
sudo umount /mnt/nook_boot
sudo umount /mnt/nook_root

# Remove mount points
sudo rmdir /mnt/nook_boot /mnt/nook_root

# Verify SD card is ready
sudo fdisk -l $SD_DEVICE
```

---

## Boot Process Testing

### First Boot Sequence
1. **Insert SD Card**: Insert prepared SD card into Nook
2. **Power On**: Hold power button for 2 seconds
3. **Boot Selection**: Hold both page turn buttons while powering on
4. **U-Boot**: Device should boot from SD card
5. **Kernel Loading**: Watch for kernel messages
6. **Module Loading**: SquireOS modules should load
7. **Jester Appearance**: ASCII jester should appear
8. **Menu System**: Main menu should be accessible

### Boot Monitoring
```bash
# Connect serial console (if available)
# Monitor boot messages through serial interface
screen /dev/ttyUSB0 115200

# Expected boot sequence:
# 1. U-Boot messages
# 2. Kernel decompression
# 3. Linux kernel boot
# 4. SquireOS module loading
# 5. Init system startup
# 6. SquireOS service start
# 7. Jester display
# 8. Menu launch
```

---

## Troubleshooting

### Common Boot Issues

#### SD Card Not Detected
```bash
# Verify SD card format
sudo file -s /dev/sdX1
sudo file -s /dev/sdX2

# Check partition table
sudo fdisk -l /dev/sdX

# Reformat if needed
sudo mkfs.vfat -F 16 /dev/sdX1
sudo mkfs.ext4 /dev/sdX2
```

#### Kernel Won't Load
```bash
# Check uImage format
file /mnt/nook_boot/uImage

# Verify u-boot environment
cat /mnt/nook_boot/uEnv.txt

# Test kernel size (should be 2-4MB)
ls -lh /mnt/nook_boot/uImage
```

#### Modules Won't Load
```bash
# Check module format
file /mnt/nook_root/lib/modules/*.ko

# Verify dependencies
sudo chroot /mnt/nook_root depmod -a
sudo chroot /mnt/nook_root modinfo squireos_core

# Test manual loading
sudo chroot /mnt/nook_root insmod /lib/modules/squireos_core.ko
```

### Debug Boot Process
```bash
# Enable kernel debug messages
# Add to uEnv.txt:
bootargs=console=ttymxc0,115200 root=/dev/mmcblk0p2 rootwait rw debug loglevel=8

# Add SquireOS debug
# In module source, enable:
#define SQUIREOS_DEBUG 1

# Rebuild and redeploy modules
```

### Recovery Procedures
```bash
# If boot fails completely:
# 1. Remove SD card
# 2. Nook will boot to original firmware
# 3. Fix SD card issues
# 4. Reinsert and retry

# If modules fail:
# 1. Boot to shell (option 4 in menu)
# 2. Check dmesg for errors
# 3. Manually load modules with insmod
# 4. Debug module issues
```

---

## Production Deployment

### Batch Deployment
```bash
# Script for multiple SD cards
#!/bin/bash
for device in /dev/sd[b-z]; do
    if [ -b "$device" ]; then
        echo "Preparing SD card: $device"
        ./deploy_to_sd.sh "$device"
    fi
done
```

### Quality Assurance
```bash
# Automated testing script
#!/bin/bash
SD_DEVICE="$1"

echo "Testing SD card deployment..."

# Mount and verify
sudo mount ${SD_DEVICE}1 /mnt/test_boot
sudo mount ${SD_DEVICE}2 /mnt/test_root

# Check critical files
test -f /mnt/test_boot/uImage || exit 1
test -f /mnt/test_root/lib/modules/squireos_core.ko || exit 1
test -x /mnt/test_root/usr/local/bin/nook-menu.sh || exit 1

# Test chroot
sudo chroot /mnt/test_root /bin/sh -c "ls /lib/modules/*.ko"

echo "SD card validation passed"
sudo umount /mnt/test_boot /mnt/test_root
```

### Documentation Package
```bash
# Create deployment package
mkdir -p deployment_package
cp nook-mvp-rootfs.tar.gz deployment_package/
cp nst-kernel-base/src/arch/arm/boot/uImage deployment_package/
cp docs/DEPLOYMENT_INTEGRATION_GUIDE.md deployment_package/
cp deploy_to_sd.sh deployment_package/

# Create checksums
cd deployment_package
sha256sum * > checksums.txt

# Package for distribution
tar -czf nook_quillkernel_v1.0.tar.gz .
```

---

## Post-Deployment Validation

### System Health Check
```bash
# On the Nook device (after boot)
# Check SquireOS status
cat /proc/squireos/motto
cat /proc/squireos/jester

# Verify modules
lsmod | grep squireos

# Test writing statistics
echo "test session" > /proc/squireos/typewriter/session
cat /proc/squireos/typewriter/stats

# Check system resources
free -h
df -h
```

### Performance Validation
```bash
# Memory usage check
ps aux | grep -E "(kernel|squireos|jester)"

# Boot time measurement
systemd-analyze time

# Module load time
dmesg | grep -E "(squireos|jester|typewriter|wisdom)"
```

---

*Complete deployment and integration guide for NST Kernel with SquireOS*
*Version: 1.0.0*