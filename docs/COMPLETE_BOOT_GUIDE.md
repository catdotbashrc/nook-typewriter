# JoKernel Complete Boot Process Guide

## Table of Contents
1. [Boot Architecture Overview](#boot-architecture-overview)
2. [Hardware Requirements](#hardware-requirements)
3. [Boot Chain Components](#boot-chain-components)
4. [SD Card Boot Methods](#sd-card-boot-methods)
5. [ClockworkMod Integration](#clockworkmod-integration)
6. [JesterOS Module Loading](#jesteros-module-loading)
7. [Troubleshooting Guide](#troubleshooting-guide)
8. [Testing Procedures](#testing-procedures)

---

## Boot Architecture Overview

### The Nook Simple Touch Boot Sequence
```
Power Button → ROM Bootloader → MLO → U-Boot → Kernel → Init → JesterOS
```

#### Critical Understanding
The Nook Simple Touch follows ARM embedded Linux boot protocols, requiring a **complete bootloader chain**. Simply copying a kernel file to an SD card will **NOT work**.

### Why Simple File Copying Fails
- Missing first-stage bootloader (MLO)
- Missing second-stage bootloader (u-boot.bin)
- Incorrect partition structure
- No proper boot arguments
- Bootloader cannot locate or execute kernel

---

## Hardware Requirements

### Nook Simple Touch Specifications
```yaml
Device: Barnes & Noble Nook Simple Touch
CPU: 800 MHz ARM Cortex-A8 (OMAP3621)
RAM: 256MB total
Display: 6" E-Ink Pearl (800x600, 16 grayscale)
Storage: 2GB internal + SD card slot
Boot: U-Boot bootloader in internal NAND
```

### SD Card Requirements
- **Minimum Size**: 2GB
- **Recommended**: 4GB or larger
- **Type**: Class 4 or better
- **Brands**: SanDisk, Kingston (proven reliable)
- **Format**: Will be completely overwritten

---

## Boot Chain Components

### 1. ROM Bootloader (Hardware)
- **Location**: Burned into CPU silicon
- **Function**: Initial hardware setup, looks for MLO
- **Search Order**: SD card first, then internal NAND
- **Cannot be modified**

### 2. MLO (Minimal Loader)
- **Size**: ~20KB
- **Function**: Second-stage bootloader initialization
- **Requirements**: Must be first file on FAT partition
- **Critical**: Must be copied first to ensure contiguous storage

### 3. U-Boot (Das U-Boot)
- **Size**: ~200KB
- **Function**: Hardware configuration, kernel loading
- **Features**: Command line interface, script execution
- **Configuration**: Via uEnv.txt or compiled-in settings

### 4. Kernel (JoKernel)
- **Format**: uImage (U-Boot compatible)
- **Size**: ~1.9MB compressed
- **Base**: Linux 2.6.29 with JesterOS modules
- **Load Address**: 0x80008000 (OMAP3 standard)

### 5. Init System
- **Type**: Custom minimal init
- **Function**: Mount filesystems, load modules, start interface
- **Location**: /init in root filesystem

---

## SD Card Boot Methods

### Method 1: ClockworkMod Replacement (RECOMMENDED)
**Risk**: 🟢 Low | **Success Rate**: 95% | **Complexity**: Medium

#### Why This Works
ClockworkMod provides a complete, proven bootloader chain that we can modify:
- Contains working MLO + U-Boot for Nook Simple Touch
- Proven by thousands of XDA community users
- Allows kernel replacement without bootloader complexity
- Includes recovery mechanisms

#### Process Overview
1. Flash complete CWM image to SD card
2. Mount CWM boot partition
3. Replace CWM's recovery kernel with JoKernel
4. Boot Nook with modified CWM card

#### Detailed Steps
```bash
# 1. Flash CWM base image
sudo dd if=images/2gb_clockwork-rc2.img of=/dev/sdX bs=1M status=progress
sync

# 2. Re-read partition table
sudo partprobe /dev/sdX

# 3. Mount CWM boot partition
sudo mkdir -p /tmp/cwm_boot
sudo mount /dev/sdX1 /tmp/cwm_boot

# 4. Backup original CWM kernel
cp /tmp/cwm_boot/uImage /tmp/cwm_boot/uImage.cwm.backup

# 5. Install JoKernel
cp firmware/boot/uImage /tmp/cwm_boot/uImage

# 6. Sync and unmount
sync
sudo umount /tmp/cwm_boot
```

### Method 2: NookManager Base (ALTERNATIVE)
**Risk**: 🟢 Low | **Success Rate**: 90% | **Complexity**: Medium

```bash
# 1. Download NookManager
wget https://github.com/doozan/NookManager/releases/NookManager-0.5.0.img.gz
gunzip NookManager-0.5.0.img.gz

# 2. Flash to SD card
sudo dd if=NookManager-0.5.0.img of=/dev/sdX bs=4M status=progress

# 3. Replace kernel (similar to CWM method)
```

### Method 3: Manual U-Boot Chain (ADVANCED)
**Risk**: 🟡 Medium | **Success Rate**: 70% | **Complexity**: High

Only recommended for advanced users who need complete control.

---

## ClockworkMod Integration

### CWM Partition Structure
```
/dev/sdX1 (FAT32, ~50MB) - Boot Partition
├── MLO                  # First-stage bootloader
├── u-boot.bin           # Second-stage bootloader  
├── uImage               # Recovery kernel (WE REPLACE THIS)
├── uRamdisk             # Recovery filesystem
├── boot.scr             # U-Boot script
└── recovery/            # CWM recovery files

/dev/sdX2 (ext4, ~200MB) - Recovery System
└── [CWM recovery filesystem]

/dev/sdX3 (ext4, remaining) - Available for rootfs
```

### Boot Script Configuration
```bash
# Standard CWM boot.scr content:
setenv bootargs 'console=ttyS0,115200n8 root=/dev/mmcblk0p2 rootfstype=ext4 rootwait rw'
fatload mmc 0:1 0x80000000 uImage
bootm 0x80000000
```

### Kernel Replacement Strategy
1. **Keep CWM bootloaders** (MLO, u-boot.bin) - proven working
2. **Replace uImage** with JoKernel - our custom kernel
3. **Modify boot args** if needed for our rootfs
4. **Test incrementally** - kernel first, then modules

---

## JesterOS Module Loading

### Module Architecture
```
JesterOS Kernel Modules:
├── jesteros_core.ko     # Core module (creates /proc/jesteros)
├── jester.ko            # ASCII art display
├── typewriter.ko        # Writing statistics tracker  
└── wisdom.ko            # Writing quotes system
```

### Loading Sequence
```bash
# Correct dependency order:
insmod /lib/modules/2.6.29/jesteros_core.ko    # MUST load first
insmod /lib/modules/2.6.29/jester.ko           # Depends on core
insmod /lib/modules/2.6.29/typewriter.ko       # Depends on core
insmod /lib/modules/2.6.29/wisdom.ko           # Depends on core
```

### Runtime Interface
```bash
# After successful module loading:
cat /proc/jesteros/jester              # ASCII jester art
cat /proc/jesteros/typewriter/stats    # Writing statistics
cat /proc/jesteros/wisdom               # Random writing quote
```

---

## Troubleshooting Guide

### Boot Failure Symptoms

#### Black Screen
**Cause**: MLO not found or corrupted
**Solution**: Re-flash base image, verify SD card quality

#### "Loading..." Message
**Cause**: MLO OK, U-Boot problem
**Solution**: Check u-boot.bin file, verify boot partition

#### Boot Loop
**Cause**: Kernel panic, incompatible kernel
**Solution**: 
- Check kernel compatibility with OMAP3
- Verify boot arguments
- Test with known-good kernel first

#### Hangs at Boot Logo
**Cause**: Kernel loads but init fails
**Solution**:
- Check rootfs integrity
- Verify init script permissions
- Test init script manually

### Recovery Procedures

#### Safe Recovery
1. **Remove SD card** immediately
2. **Power cycle Nook** - it will boot normally from internal storage  
3. **No permanent damage** to device
4. **Re-flash SD card** with corrections

#### Debug Information
- Serial console output (requires UART adapter)
- U-Boot command line (interrupt boot process)
- Kernel boot messages (if kernel starts)

### Common Mistakes

❌ **Wrong device in dd command** - Can destroy computer's drive
❌ **Skipping sync command** - Incomplete writes
❌ **Bad SD card** - Random failures, corruption
❌ **Wrong partition type** - Boot partition must be FAT
❌ **Missing boot flag** - Partition not marked bootable
❌ **Module load order** - Core module must load first

---

## Testing Procedures

### Pre-Boot Checklist
```bash
# Verify kernel build
file firmware/boot/uImage
# Should show: "u-boot legacy uImage, Linux-2.6.29-omap1"

# Check kernel size  
ls -lah firmware/boot/uImage
# Should be ~1.9MB

# Verify SD card
lsblk
# Identify correct device (NOT partition)

# Check modules (if built)
ls -la source/kernel/src/drivers/jesteros/*.ko
```

### Boot Test Sequence

#### Phase 1: Kernel Only
1. Flash CWM base image
2. Replace with JoKernel
3. Boot test - expect kernel to load
4. Look for kernel boot messages

#### Phase 2: Basic System
1. Add minimal rootfs to third partition
2. Modify boot arguments to use rootfs
3. Test init system startup
4. Verify basic shell access

#### Phase 3: JesterOS Modules  
1. Copy modules to rootfs
2. Load modules manually first
3. Verify /proc/jesteros creation
4. Test module functionality

#### Phase 4: Integration
1. Add automatic module loading to init
2. Test complete boot sequence
3. Verify E-Ink display functionality
4. Test writing interface

### Success Criteria

✅ **Kernel Boot**: Boot messages appear, no kernel panic
✅ **Init Start**: Custom init script executes
✅ **Module Load**: All JesterOS modules load without errors
✅ **Interface**: Menu system appears on E-Ink display
✅ **Interaction**: Can navigate menus and execute commands

---

## Current Status (August 2025)

### Completed Components
- ✅ JoKernel v1.0.0 built with cross-compilation
- ✅ JesterOS modules compiled (config integration pending)
- ✅ Minimal rootfs created (30MB Debian-based)
- ✅ ClockworkMod base image available (1.8GB)
- ✅ SD card creation scripts ready

### Active Testing
- 🔄 **CWM kernel replacement method** - In progress
- 🔄 **First hardware boot test** - About to begin

### Next Steps
1. Complete CWM+JoKernel boot test
2. Fix JesterOS module configuration if needed  
3. Add proper writing environment (Vim)
4. Optimize for E-Ink display characteristics
5. Create production distribution image

---

## Historical Context

### The Great Configuration Battle
After extensive research and multiple failed attempts, we discovered:
- **The oldconfig Problem**: `make oldconfig` strips unknown config options
- **The olddefconfig Solution**: `make olddefconfig` accepts new options with defaults
- **The JesterOS Unification**: Renamed all modules from JokerOS to JesterOS for consistency

### XDA Community Research
This boot process is based on extensive XDA Developers forum research:
- felixhaedicke/nst-kernel project (GCC 4.9 requirement)
- ClockworkMod recovery development
- NookManager bootloader chain analysis  
- Phoenix Project system images

### The Moment of Truth
This represents the first attempt to boot a custom kernel on the Nook Simple Touch as part of the JoKernel project, aimed at transforming a $20 e-reader into a $400 distraction-free writing device.

---

*"By quill and candlelight, may the bootloader dance and the kernel sing!"* 🎭

## Result Log

### [Current Test - August 14, 2025]
**Method**: ClockworkMod kernel replacement  
**Status**: DD command in progress...  
**Outcome**: [TO BE RECORDED]

---

*This document consolidates boot process information from XDA_SD_CARD_BOOT_METHODS.md, MOMENT_OF_TRUTH.md, XDA_DEPLOYMENT_METHOD.md, and CONFIGURATION.md into a single comprehensive guide.*