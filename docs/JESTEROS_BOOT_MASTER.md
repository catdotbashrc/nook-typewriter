# JesterOS Boot System Master Documentation

> **Document Type**: Comprehensive Technical Reference  
> **Version**: 1.0.0  
> **Last Updated**: January 2025  
> **Supersedes**: JESTEROS_BOOT_PROCESS.md, BOOT-INFRASTRUCTURE-COMPLETE.md, URAM_IMAGE_ANALYSIS.md

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Boot Architecture Overview](#boot-architecture-overview)
3. [Hardware Boot Chain](#hardware-boot-chain)
4. [Android Init Layer](#android-init-layer)
5. [JesterOS Integration](#jesteros-integration)
6. [Deployment Strategy](#deployment-strategy)
7. [Installation Procedures](#installation-procedures)
8. [Recovery Methods](#recovery-methods)
9. [Technical Implementation](#technical-implementation)
10. [Memory Architecture](#memory-architecture)
11. [Critical Components](#critical-components)
12. [Troubleshooting](#troubleshooting)
13. [Development Guidelines](#development-guidelines)

---

## Executive Summary

### The Three-Layer Boot Reality

JesterOS implements a sophisticated **three-layer boot architecture** that safely transforms a Barnes & Noble Nook Simple Touch into a dedicated writing device while preserving recoverability:

1. **Hardware Layer**: OMAP3621 ROM → MLO → U-Boot → Linux Kernel
2. **Android Init Layer**: Mandatory proprietary hardware initialization
3. **JesterOS Layer**: Custom userspace environment for writing

### Key Architectural Decisions

- **Hybrid System Required**: Cannot bypass Android init - proprietary E-ink and DSP drivers require it
- **Two-Stage Deployment**: SD card testing → Internal installation for safety
- **Memory Constraints**: 92.8MB available after mandatory components (not 95MB as originally planned)
- **Recovery Guaranteed**: Factory `/rom` partition never modified

### Critical Discoveries

- **E-ink Control**: `omap-edpd.elf` (634KB) proprietary daemon required
- **DSP Firmware**: `baseimage.dof` (1.2MB) mandatory for display acceleration
- **Boot Counter**: Must clear to prevent factory reset after 8 failed boots
- **Sector 63 Alignment**: Critical for SD card boot compatibility

---

## Boot Architecture Overview

### Complete Boot Flow

```
┌─────────────────────────────────────────────────────┐
│                  HARDWARE BOOT                      │
├─────────────────────────────────────────────────────┤
│  Power Button → ROM Loader → MLO → U-Boot → Kernel │
└────────────────────────────┬────────────────────────┘
                             ↓
┌─────────────────────────────────────────────────────┐
│              ANDROID INIT (MANDATORY)               │
├─────────────────────────────────────────────────────┤
│  /init (128KB)                                      │
│  ├── Load DSP: baseimage.dof (1.2MB)               │
│  ├── Start DSP bridge: bridged (87KB)              │
│  ├── Initialize E-ink: omap-edpd.elf (634KB)       │
│  └── Load waveforms: default_waveform.bin (95KB)   │
└────────────────────────────┬────────────────────────┘
                             ↓
┌─────────────────────────────────────────────────────┐
│                  JESTEROS USERSPACE                 │
├─────────────────────────────────────────────────────┤
│  /system/bin/jesteros-init                         │
│  ├── Mount filesystems                             │
│  ├── Start services (mood, stats, quotes)          │
│  ├── Initialize menu system                        │
│  └── Launch writing environment                    │
└─────────────────────────────────────────────────────┘
```

### Boot Priority Decision Tree

```
U-Boot Initialization
        ↓
Check SD Card Present?
    ├─Yes→ SD Bootable? 
    │       ├─Yes→ Boot from SD
    │       └─No→ Continue
    └─No→ Boot from Internal
            ↓
    Boot Counter < 8?
        ├─Yes→ Normal Boot
        └─No→ Factory Recovery
```

---

## Hardware Boot Chain

### Stage 0: Power-On (ROM Loader)
- **Component**: OMAP3621 internal ROM
- **Size**: Built into CPU
- **Function**: Loads MLO from fixed locations
- **Search Order**: 
  1. SD card offset 0
  2. Internal NAND offset 0x20000

### Stage 1: MLO (X-Loader)
- **Component**: First-stage bootloader
- **Size**: 16KB (strict limit)
- **Load Address**: 0x40200000 (SRAM)
- **Function**: Initialize RAM, load U-Boot
- **Critical**: Never modify - device becomes unbootable

### Stage 2: U-Boot
- **Component**: Second-stage bootloader
- **Size**: 159KB
- **Load Address**: 0x80e80000
- **Functions**:
  - Hardware detection
  - Boot device selection
  - Kernel loading
  - Command line passing

### Stage 3: Linux Kernel
- **Version**: 2.6.29-omap1 (stock) or 2.6.29-jester (custom)
- **Size**: 1.9MB compressed (uImage)
- **Load Address**: 0x80008000
- **Entry Point**: 0x80008000
- **Critical Parameters**:
  ```
  console=ttyS0,115200
  root=/dev/mmcblk0p5 (internal) or /dev/mmcblk1p2 (SD)
  init=/init (Android init mandatory)
  ```

---

## Android Init Layer

### Why Android Init Cannot Be Replaced

The Android init system is **mandatory** because:

1. **Proprietary Binary Dependencies**
   - E-ink controller (`omap-edpd.elf`) expects Android hardware initialization
   - DSP firmware loader requires Android's specific loading sequence
   - No open-source alternatives exist for these components

2. **Hardware Path Creation**
   - Creates `/sys/class/graphics/fb0/` for display control
   - Initializes `/dev/graphics/fb0` framebuffer device
   - Sets up DSP communication channels

3. **Device-Specific Configuration**
   - Loads calibrated waveform data for E-ink refresh
   - Configures touch controller hardware addresses
   - Sets up power management systems

### Minimal Android Components Required

| Component | Size | Purpose | Location |
|-----------|------|---------|----------|
| init | 128KB | Hardware initialization | / |
| init.rc | 4KB | Boot configuration | / |
| default.prop | 1KB | System properties | / |
| omap-edpd.elf | 634KB | E-ink daemon | /sbin/ |
| baseimage.dof | 1.2MB | DSP firmware | /etc/dsp/ |
| bridged | 87KB | DSP bridge | /sbin/ |
| cexec.out | 79KB | DSP loader | /sbin/ |
| default_waveform.bin | 95KB | Display waveforms | /etc/dsp/ |
| **Total** | **~2.2MB** | **Mandatory overhead** | |

### Minimal init.rc for JesterOS

```bash
# JesterOS Minimal Android Init Configuration
on init
    export PATH /sbin:/bin:/usr/bin
    export FRAMEBUFFER /dev/graphics/fb0
    export ANDROID_ROOT /system
    
    # Create essential mount points
    mkdir /system /data /cache /jesteros
    
on boot
    # Initialize E-ink display
    write /sys/class/graphics/fb0/pgflip_refresh 1
    write /sys/class/graphics/fb0/epd_refresh 0
    
    # Load DSP firmware (required for display)
    exec /sbin/cexec.out -T /etc/dsp/baseimage.dof
    exec /sbin/bridged
    sleep 2
    
    # Start E-ink daemon
    exec /sbin/omap-edpd.elf --timeout=2 -pV220 \
         --fbdev=/dev/graphics/fb0 \
         -w /etc/dsp/default_waveform.bin
    
    # Clear boot counter (prevent factory reset)
    exec /system/bin/clrbootcount.sh
    
    # Pivot to JesterOS
    exec /system/bin/jesteros-init
```

---

## JesterOS Integration

### Service Architecture

```
/system/bin/jesteros-init
├── Mount tmpfs for runtime data
│   └── mount -t tmpfs -o size=10M tmpfs /var/jesteros
├── Start core services
│   ├── jester-mood (medieval personality)
│   ├── typewriter-stats (writing metrics)
│   └── wisdom-quotes (inspiration)
├── Initialize display
│   ├── fbink -c (clear screen)
│   └── fbink -q "JesterOS Ready"
└── Launch menu system
    └── /usr/local/bin/nook-menu.sh
```

### Memory Allocation

```
┌─────────────────────────────┐
│   Total RAM: 256MB          │
├─────────────────────────────┤
│   Hardware Reserved: 23MB   │ ← OMAP3621 framebuffer
│   Android Init: 2.2MB       │ ← Mandatory components
│   JesterOS OS: 90.6MB       │ ← Services + applications
│   Writing Space: 160MB      │ ← SACRED - Never touch!
└─────────────────────────────┘
```

---

## Deployment Strategy

### Two-Stage Deployment Philosophy

**Stage 1: SD Card Boot (Development/Testing)**
- Zero risk - internal storage untouched
- Rapid iteration for development
- Easy recovery - just remove SD card
- Performance testing before commitment

**Stage 2: Internal Installation (Production)**
- After thorough SD card validation
- Preserves recovery partition
- Maintains device identity
- Includes automatic backups

### SD Card Preparation

```bash
# CRITICAL: Sector 63 alignment required!
fdisk /dev/sdX << EOF
o     # Create DOS partition table
n     # New partition
p     # Primary
1     # Partition 1
63    # Start sector (MANDATORY - hardware requirement)
+50M  # Boot partition size
t     # Change type
6     # FAT16
a     # Set bootable
n     # New partition
p     # Primary
2     # Partition 2
      # Default start
+200M # System partition
w     # Write and exit
EOF

# Format partitions
mkfs.vfat -F 16 /dev/sdX1  # Boot partition
mkfs.ext4 /dev/sdX2        # System partition

# Install boot files
mount /dev/sdX1 /mnt/boot
cp MLO u-boot.bin uImage uRamdisk /mnt/boot/
umount /mnt/boot

# Install system files
mount /dev/sdX2 /mnt/system
tar xzf jesteros-system.tar.gz -C /mnt/system/
umount /mnt/system
```

---

## Installation Procedures

### Pre-Installation Checklist

- [ ] SD card boot tested successfully (minimum 24 hours)
- [ ] CWM recovery SD card created and tested
- [ ] Full device backup completed
- [ ] Backup copied to computer
- [ ] Recovery process documented and understood
- [ ] Battery > 50% charge

### Internal Installation Script

```bash
#!/bin/bash
# jesteros-install.sh - Safe internal installation with validation
set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}JesterOS Internal Installation${NC}"
echo "=================================="

# Phase 1: Validation
echo -e "${YELLOW}[Phase 1/4] Validation${NC}"

# Check for required files
for file in jesteros-system.tar.gz jesteros-data.tar.gz; do
    if [ ! -f "/sdcard/$file" ]; then
        echo -e "${RED}ERROR: Required file $file not found!${NC}"
        exit 1
    fi
done

# Verify battery level
BATTERY=$(cat /sys/class/power_supply/bq27510-0/capacity)
if [ "$BATTERY" -lt 50 ]; then
    echo -e "${RED}ERROR: Battery too low ($BATTERY%). Charge to >50%${NC}"
    exit 1
fi

# Phase 2: Backup
echo -e "${YELLOW}[Phase 2/4] Creating Safety Backup${NC}"

mkdir -p /sdcard/backup/$(date +%Y%m%d)
BACKUP_DIR="/sdcard/backup/$(date +%Y%m%d)"

# Backup critical partitions
dd if=/dev/mmcblk0p1 of=$BACKUP_DIR/boot.img bs=4M status=progress
dd if=/dev/mmcblk0p5 of=$BACKUP_DIR/system.img bs=4M status=progress

# Backup device-specific files
tar czf $BACKUP_DIR/device-identity.tar.gz \
    /system/build.prop \
    /system/bin/clrbootcount.sh \
    /rom/devconf/DeviceID \
    2>/dev/null || true

echo -e "${GREEN}Backup completed: $BACKUP_DIR${NC}"

# Phase 3: Installation
echo -e "${YELLOW}[Phase 3/4] Installing JesterOS${NC}"

# Mount partitions
mount -o rw,remount /system
mount -o rw,remount /data

# Clean old system (preserve critical files)
cp /system/build.prop /tmp/
cp /system/bin/clrbootcount.sh /tmp/
rm -rf /system/*
rm -rf /data/*

# Install JesterOS
tar xzf /sdcard/jesteros-system.tar.gz -C /system/
tar xzf /sdcard/jesteros-data.tar.gz -C /data/

# Restore device identity
cp /tmp/build.prop /system/
cp /tmp/clrbootcount.sh /system/bin/
chmod 755 /system/bin/clrbootcount.sh

# Phase 4: Verification
echo -e "${YELLOW}[Phase 4/4] Verification${NC}"

# Verify critical files exist
ERRORS=0
for file in /system/init /system/bin/jesteros-init /system/sbin/omap-edpd.elf; do
    if [ ! -f "$file" ]; then
        echo -e "${RED}ERROR: Critical file missing: $file${NC}"
        ((ERRORS++))
    fi
done

if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}Installation verification failed!${NC}"
    echo "Run recovery procedure before rebooting!"
    exit 1
fi

# Success
echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}Installation Complete!${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo "Next steps:"
echo "1. Remove SD card"
echo "2. Reboot device"
echo "3. JesterOS will start automatically"
echo ""
echo "If boot fails, use recovery SD card"

sync
```

---

## Recovery Methods

### Three-Layer Recovery Strategy

#### Layer 1: CWM Recovery (Recommended)
```bash
# Preparation
wget https://xda/cwm/sd_128mb_clockwork-rc2.zip
unzip sd_128mb_clockwork-rc2.zip
dd if=cwm-recovery.img of=/dev/sdX bs=1M status=progress

# Recovery Process
1. Insert CWM SD card
2. Power on Nook
3. Select "Restore" from menu
4. Choose backup date
5. Confirm restoration
```

#### Layer 2: Factory Reset (Hardware Level)
```
The 8-boot recovery trigger:
1. Power on device
2. Wait 2-3 seconds (see boot logo)
3. Power off (hold button 5 seconds)
4. Repeat exactly 8 times
5. Device enters factory recovery
6. Original B&N firmware restored
```

#### Layer 3: Manual Recovery (Expert)
```bash
# Boot from any Linux SD card
mkdir -p /mnt/{system,data}
mount /dev/mmcblk0p5 /mnt/system
mount /dev/mmcblk0p8 /mnt/data

# Restore from backup
dd if=/sdcard/backup/system.img of=/dev/mmcblk0p5 bs=4M
dd if=/sdcard/backup/boot.img of=/dev/mmcblk0p1 bs=4M

sync
reboot
```

---

## Technical Implementation

### Partition Layout

```
Device: /dev/mmcblk0 (Internal NAND)

Partition | Mount | Size | Purpose | JesterOS Action
----------|-------|------|---------|----------------
p1 | /boot | 50MB | Bootloader + Kernel | PRESERVE
p2 | /rom | 16MB | Factory Recovery | NEVER TOUCH
p3 | /media | 200MB | User Media | OPTIONAL USE
p5 | /system | 200MB | Operating System | REPLACE
p6 | /cache | 250MB | System Cache | WIPE
p7 | - | 100MB | Reserved | NEVER TOUCH
p8 | /data | 800MB | User Data | SELECTIVE WIPE
```

### Critical Safety Features

#### Boot Counter Protection
```bash
#!/system/bin/sh
# clrbootcount.sh - Prevent factory reset trigger
# Must run on every successful boot
echo -n -e "\x00\x00\x00\x00" > /rom/devconf/BootCnt
```

#### Power Management
```bash
# Prevent 14% daily battery drain bug
echo "mem" > /sys/power/state
echo "1" > /sys/devices/platform/gpio-keys/disabled

# Target: 1.5% daily drain when idle
```

#### Touch Recovery
```bash
# Hardware touch controller can lock up
# Two-finger swipe handler
if [ -f /sys/devices/platform/i2c_omap.2/i2c-2/2-0050/reset ]; then
    echo "reset" > /sys/devices/platform/i2c_omap.2/i2c-2/2-0050/reset
fi
```

### Build Process

#### Creating uRamdisk
```bash
# Structure
jesteros-ramdisk/
├── init                    # Android init (128KB)
├── init.rc                 # Minimal config (4KB)
├── default.prop            # Properties (1KB)
├── sbin/
│   ├── omap-edpd.elf      # E-ink daemon (634KB)
│   ├── bridged            # DSP bridge (87KB)
│   └── cexec.out          # DSP loader (79KB)
├── etc/dsp/
│   ├── baseimage.dof      # DSP firmware (1.2MB)
│   └── default_waveform.bin # Waveforms (95KB)
└── system/
    └── bin/
        └── jesteros-init  # JesterOS entry (10KB)

# Build commands
cd jesteros-ramdisk
find . | cpio -o -H newc | gzip > ../ramdisk.gz
mkimage -A arm -T ramdisk -C gzip -d ramdisk.gz uRamdisk-jesteros

# Result: ~3MB compressed (vs 10.7MB stock)
```

---

## Memory Architecture

### Detailed Memory Map

```
Physical Memory Layout (256MB Total)
=====================================
0x80000000 - 0x80007FFF  |  32KB | Exception Vectors
0x80008000 - 0x80207FFF  |   2MB | Kernel Text
0x80208000 - 0x80FFFFFF  |  14MB | Kernel Data + Stack
0x81000000 - 0x81FFFFFF  |  16MB | Framebuffer (E-ink)
0x82000000 - 0x86FFFFFF  |  80MB | User Space (JesterOS)
0x87000000 - 0x8FFFFFFF  | 144MB | Writing Applications
```

### Runtime Memory Budget

| Component | Size | Cumulative | Notes |
|-----------|------|------------|--------|
| Hardware Reserved | 23MB | 23MB | Framebuffer + DSP |
| Linux Kernel | 8MB | 31MB | Including drivers |
| Android Init | 2.2MB | 33.2MB | Mandatory binaries |
| JesterOS Core | 15MB | 48.2MB | Services + shell |
| Applications | 45MB | 93.2MB | Menu, vim, tools |
| **Free for Writing** | 162.8MB | 256MB | Protected space |

---

## Critical Components

### Binary Dependencies Checklist

These files MUST be present for boot to succeed:

```bash
# Bootloader files (never modify)
/boot/MLO                    # 16KB - First stage bootloader
/boot/u-boot.bin            # 159KB - Second stage bootloader
/boot/uImage                # 1.9MB - Linux kernel
/boot/uRamdisk              # 3MB - Initial ramdisk

# Android init files (mandatory)
/init                       # 128KB - Android init binary
/init.rc                    # 4KB - Boot configuration
/default.prop               # 1KB - System properties

# E-ink display system (critical)
/sbin/omap-edpd.elf         # 634KB - Display daemon
/etc/dsp/baseimage.dof      # 1.2MB - DSP firmware
/etc/dsp/default_waveform.bin # 95KB - Display waveforms
/sbin/bridged               # 87KB - DSP bridge
/sbin/cexec.out            # 79KB - DSP loader

# JesterOS entry point
/system/bin/jesteros-init   # 10KB - JesterOS launcher
/system/bin/clrbootcount.sh # 1KB - Boot counter reset
```

### Configuration Files

```bash
# /system/init.rc additions for JesterOS
service jesteros /system/bin/jesteros-init
    class late_start
    user root
    group root
    oneshot

on property:sys.boot_completed=1
    start jesteros
```

---

## Troubleshooting

### Boot Problems

| Symptom | Likely Cause | Solution |
|---------|-------------|----------|
| No display | Missing omap-edpd.elf | Verify E-ink daemon present |
| Stuck at logo | DSP firmware missing | Check baseimage.dof exists |
| Boot loop | Boot counter hit 8 | Use factory recovery |
| SD won't boot | Wrong sector alignment | Recreate with sector 63 |
| Black screen | Waveform missing | Restore default_waveform.bin |

### Hardware Issues

#### Touch Screen Frozen
1. Two-finger horizontal swipe (hardware gesture)
2. Clean screen edges with compressed air
3. Power cycle (hold 30 seconds)
4. Check `/sys/.../i2c-2/2-0050/reset`

#### Battery Drain (14% Daily)
- Device must be registered with B&N (even if disconnected)
- Unregistered devices have power management bug
- Solution: Register once, then use offline

#### E-ink Ghosting
- Normal for E-ink technology
- Full refresh: `fbink -c -f`
- Adjust waveform mode in omap-edpd.elf

### Software Issues

#### Memory Exceeded
```bash
# Check current usage
free -m
ps aux | sort -k4 -r | head

# JesterOS memory guardian should prevent this
cat /var/jesteros/memory_status
```

#### Services Not Starting
```bash
# Check Android init completed
getprop sys.boot_completed

# Verify JesterOS init ran
ps | grep jesteros-init

# Check service logs
logcat | grep jesteros
```

---

## Development Guidelines

### Testing Protocol

1. **Always test on SD card first** (minimum 24 hours)
2. **Never modify /rom partition** (factory recovery)
3. **Keep CWM recovery SD ready** (emergency restore)
4. **Document all changes** (changelog.md)
5. **Test battery drain** (24-hour measurement)
6. **Verify touch gestures** (two-finger swipe)
7. **Check memory usage** (must stay under 93MB)

### Build System Requirements

```makefile
# Makefile targets for boot system
firmware: bootloader kernel ramdisk
	@echo "Building complete firmware..."
	
bootloader:
	# DO NOT REBUILD MLO/u-boot unless absolutely necessary
	@echo "Using prebuilt bootloaders"
	
kernel:
	# Cross-compile with proper config
	make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- \
	     omap2plus_defconfig
	make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- \
	     uImage
	
ramdisk:
	# Build minimal Android + JesterOS ramdisk
	./scripts/build-ramdisk.sh
```

### Version Control

```bash
# Critical files to track
git add platform/nook-touch/android-init/  # Android components
git add src/                # JesterOS scripts
git add docs/JESTEROS_BOOT_MASTER.md  # This document

# Never commit
*.img                           # Binary images
/boot/MLO                       # Bootloader binaries
/tmp/                          # Temporary files
```

---

## Performance Metrics

| Metric | Target | Achieved | Notes |
|--------|--------|----------|-------|
| Boot Time | <30 sec | Testing | From power to menu |
| Memory Usage | <93MB | Testing | OS + services |
| Battery Idle | 1.5%/day | Testing | Registered device |
| Touch Response | <100ms | Testing | Hardware limited |
| E-ink Refresh | 200-980ms | Fixed | Hardware constraint |
| SD Boot Time | <45 sec | Testing | Slower than internal |

---

## Community Resources

- **Phoenix Project**: [XDA Thread](https://xdaforums.com/t/4673934/) - Proven configurations
- **NookManager**: [XDA Thread](https://xdaforums.com/t/3873048/) - Recovery tools
- **CWM Recovery**: Available from Phoenix Project
- **Touch Fix**: Known hardware issue, no software fix exists

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-01 | Consolidated boot documentation |
| - | - | Merged three documents into master reference |
| - | - | Added uRamdisk analysis findings |
| - | - | Clarified Android init requirements |

---

## Summary

JesterOS boot system is a carefully engineered **hybrid architecture** that:

1. **Leverages existing infrastructure** - Uses Android init for hardware access
2. **Maintains safety** - Two-stage deployment with multiple recovery options
3. **Optimizes resources** - Reduces ramdisk from 10.7MB to 3MB
4. **Preserves recoverability** - Never modifies factory recovery partition
5. **Provides clear implementation path** - From development to production

The key insight is that this isn't a "pure Linux" replacement but a **clever hybrid** that uses minimal Android components for hardware initialization while providing a Linux userspace for the actual writing environment. This pragmatic approach works within the constraints of proprietary embedded systems while achieving the goal of a distraction-free writing device.

---

*Documentation compiled from NookManager analysis, uRamdisk extraction, and boot testing*  
*For JesterOS Boot System Implementation*