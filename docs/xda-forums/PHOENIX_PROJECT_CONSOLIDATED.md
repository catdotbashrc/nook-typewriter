# 🔥 The Phoenix Project - Complete Reference

> **Type**: Reference Documentation  
> **Source**: XDA Forums Community Research  
> **Compiled**: January 2025  
> **Purpose**: Consolidated findings for Nook SimpleTouch preservation

## 📚 Overview

The Phoenix Project was a community effort on XDA Forums to preserve and enhance the Barnes & Noble Nook SimpleTouch (NST) and GlowLight (NSTG) e-readers. This document consolidates all Phoenix Project findings relevant to JesterOS development.

## 🎯 Critical Discoveries

### Hardware Requirements
- **SD Card**: Must use **SanDisk Class 10** cards
  - Other brands proven unreliable  
  - Random boot failures with non-SanDisk cards
  - Class 4 technically works but not recommended

### Boot Requirements  
- **Sector 63 Alignment**: First partition MUST start at sector 63
  - Modern tools default to 2048 (will not boot)
  - Use fdisk, not parted for partitioning
  - MLO must be first file copied (contiguous requirement)

### Known Hardware Defects
- **Touch Freeze**: Universal hardware issue after wake
  - Solution: Two-finger horizontal swipe
  - Prevention: Clean screen gutters regularly
  - Affects ALL Nook SimpleTouch devices

### Battery Optimization
- **14% daily drain** on unregistered devices
- **Solution**: Remove B&N services entirely
- **Target**: 1.5% daily drain achievable

## 🛠️ Proven Solutions

### 1. ClockworkMod Recovery
- **Version**: 6.0.4.6 (final stable for NST)
- **Features**: Full backup/restore, root access
- **Installation**: Via SD card boot

### 2. Rooting Method
- **NookManager**: All-in-one rooting solution
- **Manual Root**: Via ADB with su binary
- **Persistence**: Survives factory reset

### 3. Kernel Compilation
- **Toolchain**: Android NDK r10e proven stable
- **Cross-compiler**: arm-linux-androideabi-
- **Config**: omap3621_gossamer_defconfig

### 4. Optimal Firmware
- **Recommended**: 1.2.2 (final B&N release)
- **Alternative**: 1.2.1 (more hackable)
- **Avoid**: 1.1.x (buggy touch driver)

## 📊 Performance Findings

### Memory Management
```
Total RAM:        256MB
System reserved:  ~95MB  
Available:        ~160MB
Optimal target:   <100MB for OS+apps
```

### Storage Layout
```
Partition  Size    Purpose
/rom       16MB    Factory image (never modify)
/system    285MB   Android system
/data      285MB   User apps and data
/media     800MB   Books and documents
```

### Power Consumption
```
Sleep:            <1mW
Page turn:        ~15mW
Full refresh:     ~500mW (450ms)
WiFi active:      ~300mW
Optimal average:  <50mW
```

## 🔧 Development Tips

### Cross-Compilation
```bash
export ARCH=arm
export CROSS_COMPILE=arm-linux-androideabi-
export PATH=$PATH:/path/to/ndk/toolchain/bin
```

### ADB Access
```bash
# Enable ADB
sqlite3 /data/data/com.android.providers.settings/databases/settings.db
UPDATE secure SET value=1 WHERE name='adb_enabled';

# Connect
adb connect <nook_ip>:5555
```

### E-Ink Optimization
- Minimize full refreshes (ghosting acceptable)
- Use partial refresh for small updates
- Never write directly to /dev/fb0
- Use sysfs controls only

## 🐛 Common Issues & Fixes

### Boot Loop
1. Hold power button for 20 seconds
2. Boot with known-good SD card
3. Factory reset (8 failed boots trigger)

### WiFi Issues
- Disable power management
- Use static IP when possible
- 2.4GHz only (no 5GHz support)

### Touch Calibration
```bash
# Recalibrate touch
rm /data/misc/zforce/zforce.cal
reboot
```

## 📁 Essential Files

### From Phoenix Project
- `uImage` - Kernel image (4MB)
- `u-boot.bin` - Bootloader (256KB)
- `MLO` - First stage bootloader (128KB)
- `clockwork-recovery.img` - Recovery image

### Configuration Files
- `/system/build.prop` - System properties
- `/init.rc` - Boot initialization
- `/default.prop` - Default properties

## 🔗 Community Resources

### Active Projects (as of 2019)
- NookManager - Rooting and management
- NoRefresh - E-Ink optimization
- Relaunch - Alternative launcher

### Archive Locations
- XDA Forums NST section
- GitHub: various preservation repos
- Internet Archive: firmware backups

## ⚠️ Warnings

### Never Modify
- `/rom` partition (factory recovery)
- Bootloader without backup
- Touch driver (hardware dependent)

### Always Backup
- Full device before modifications
- Calibration data
- WiFi MAC address

## 📈 Success Metrics

Based on community reports:
- **Rooting Success**: 95%+ with NookManager
- **Custom ROM Success**: 80%+ with proper SD card
- **Recovery Success**: 99%+ from soft brick
- **Hardware Longevity**: 10+ years with care

## 🎉 Phoenix Project Legacy

The Phoenix Project successfully:
- Preserved NST/NSTG devices from obsolescence
- Created comprehensive documentation
- Developed essential tools and recoveries
- Built lasting community knowledge base

This consolidated knowledge enables projects like JesterOS to build upon proven foundations.

---

*"From the ashes of abandoned devices, Phoenix rises eternal"* 🔥📚

## Document History

This document consolidates content from:
- 23 individual Phoenix Project forum posts
- Community findings from 2011-2019
- Proven solutions validated by 100+ users

Last community activity: 2019
Integration with JesterOS: 2024-2025