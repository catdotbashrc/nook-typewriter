# JesterOS Boot Infrastructure Documentation
*Comprehensive analysis of Nook SimpleTouch boot system from NookManager*

## Table of Contents
1. [Executive Summary](#executive-summary)
2. [Boot Architecture Overview](#boot-architecture-overview)
3. [Boot Chain Components](#boot-chain-components)
4. [Android Init System Analysis](#android-init-system-analysis)
5. [E-Ink Display System](#e-ink-display-system)
6. [Memory Map and Addresses](#memory-map-and-addresses)
7. [Partition Layout](#partition-layout)
8. [JesterOS Integration Strategy](#jesteros-integration-strategy)
9. [Implementation Roadmap](#implementation-roadmap)
10. [Critical Files Reference](#critical-files-reference)

---

## Executive Summary

This document consolidates all boot infrastructure discoveries from NookManager v0.5.0 analysis, providing the complete blueprint for JesterOS boot implementation on Nook SimpleTouch hardware.

### Key Discoveries
- **Android Layer Required**: Cannot bypass directly to Linux - hardware requires Android init
- **Hybrid Boot Solution**: Android init for hardware → JesterOS userspace
- **E-Ink Control Found**: `omap-edpd.elf` daemon with waveform support
- **Memory Optimization**: Can reduce from 10.7MB to <3MB ramdisk

### Critical Requirements
- OMAP3621 ARM Cortex-A8 processor support
- 256MB RAM (233MB available after hardware reserved)
- E-Ink Pearl display with DSP acceleration
- Android init for hardware initialization

---

## Boot Architecture Overview

### Complete Boot Chain
```
┌──────────────┐
│  Power On    │
└──────┬───────┘
       ↓
┌──────────────┐
│ ROM Loader   │ Internal OMAP3621 bootloader
└──────┬───────┘
       ↓
┌──────────────┐
│     MLO      │ 16KB - X-Loader (first-stage)
└──────┬───────┘ Loads from SD offset 0
       ↓
┌──────────────┐
│   U-Boot     │ 159KB - Second-stage bootloader
└──────┬───────┘ Configures memory, loads kernel
       ↓
┌──────────────┐
│  boot.scr    │ U-Boot script
└──────┬───────┘ Defines load addresses
       ↓
┌──────────────┐
│   uImage     │ 1.8MB - Linux kernel 2.6.29
└──────┬───────┘ Load @ 0x81c00000
       ↓
┌──────────────┐
│  uRamdisk    │ 10.7MB - Initial ramdisk
└──────┬───────┘ Load @ 0x81f00000
       ↓
┌──────────────┐
│ Android Init │ Hardware initialization
└──────┬───────┘ Sets up display, DSP, devices
       ↓
┌──────────────┐
│  JesterOS    │ Target: Writing environment
└──────────────┘
```

### Boot Memory Layout
```
0x80000000 ┌─────────────────┐
           │  U-Boot Space   │
0x80008000 ├─────────────────┤ ← U-Boot execution
           │                 │
0x81c00000 ├─────────────────┤ ← Kernel load address
           │   Linux Kernel  │   (uImage)
           │     (1.8MB)     │
0x81f00000 ├─────────────────┤ ← Ramdisk load address
           │    uRamdisk     │   (initrd)
           │    (10.7MB)     │
0x82000000 └─────────────────┘
```

---

## Boot Chain Components

### Primary Boot Files

| Component | Size | Purpose | Location | Required |
|-----------|------|---------|----------|----------|
| **MLO** | 16KB | OMAP3621 X-Loader | SD offset 0 | ✅ YES |
| **u-boot.bin** | 159KB | Main bootloader | /mnt/nook/ | ✅ YES |
| **boot.scr** | 201B | Boot script | /mnt/nook/ | ✅ YES |
| **uImage** | 1.8MB | Linux kernel | /mnt/nook/ | ✅ YES |
| **uRamdisk** | 10.7MB | Init ramdisk | /mnt/nook/ | Modify |
| **wvf.bin** | 92KB | E-Ink waveforms | /mnt/nook/ | ✅ YES |
| **cfg.bin** | 27B | Config params | /mnt/nook/ | Optional |
| **booting.pgm** | 480KB | Boot splash | /mnt/nook/ | Optional |

### Boot Script Decoded (`boot.scr`)
```bash
run setbootargs                    # Set kernel arguments
mmcinit 0                          # Init internal MMC
mmcinit 1                          # Init SD card
fatload mmc 0 0x81c00000 uImage   # Load kernel to RAM
fatload mmc 0 0x81f00000 uRamdisk # Load ramdisk to RAM
bootm 0x81c00000 0x81f00000       # Boot with both
```

---

## Android Init System Analysis

### uRamdisk Contents (Extracted)
```
Size: 10.7MB compressed → 25MB uncompressed
Blocks: 50,016 extracted via cpio
Method: dd if=uRamdisk bs=64 skip=1 | gunzip | cpio -i
```

### Critical Android Components

#### Init Binary (128KB)
- Android's PID 1 process
- Initializes hardware devices
- Parses init.rc configuration
- Manages system properties

#### Init.rc Configuration
```bash
on early-init
    sleep 2  # Wait for MMC enumeration

on init
    export FRAMEBUFFER /dev/graphics/fb0
    mkdir /system /data /sdcard /cache /rom /boot

on boot
    # E-Ink Display Setup (CRITICAL)
    write /sys/class/graphics/fb0/pgflip_refresh 1
    write /sys/class/graphics/fb0/epd_refresh 0
    
    # Load DSP firmware
    start baseimage    # DSP base firmware
    start bridged      # DSP bridge
    sleep 2
    start omap-edpd    # E-Ink daemon
```

#### System Properties (default.prop)
```properties
ro.product.device=zoom2
ro.product.board=zoom2
ro.product.manufacturer=BarnesAndNoble
ro.sf.widthpixels=600
ro.sf.heightpixels=800
ro.sf.lcd_density.xdpi=167
ro.sf.lcd_density.ydpi=167
```

---

## E-Ink Display System

### Discovery: Complete E-Ink Control Stack

#### omap-edpd.elf (634KB) - E-Ink Display Daemon
```bash
# Full command from init.rc:
/sbin/omap-edpd.elf \
    --timeout=2 \
    -pV220 \
    --fbdev=/dev/graphics/fb0 \
    -s /etc/dsp/subframeip_snode_dsp.dll64P \
    -w /rom/devconf/EpdWaveform,/etc/dsp/default_waveform.bin
```

#### Display Components
| Component | Size | Purpose |
|-----------|------|---------|
| **omap-edpd.elf** | 634KB | E-Ink display daemon |
| **default_waveform.bin** | 95KB | Display refresh patterns |
| **wvf.bin** | 92KB | Device-specific waveforms |
| **baseimage.dof** | 1.2MB | DSP base firmware |
| **bridged** | 87KB | DSP bridge daemon |
| **cexec.out** | 79KB | DSP firmware loader |
| **subframeip_snode_dsp.dll64P** | 191KB | DSP display library |

#### Display Control Interface
```bash
# Sysfs controls for E-Ink
/sys/class/graphics/fb0/pgflip_refresh  # Page flip refresh
/sys/class/graphics/fb0/epd_refresh     # E-Paper display refresh
/dev/graphics/fb0                       # Framebuffer device (800x600)
```

---

## Memory Map and Addresses

### Hardware Memory Layout
```
Physical RAM: 256MB
Available: 233MB (after hardware reserved)

Memory Regions:
0x80000000-0x8FFFFFFF: RAM (256MB)
0x81c00000: Kernel load address (FIXED)
0x81f00000: Ramdisk load address (FIXED)
```

### Current vs Target Memory Usage
| Component | Current | JesterOS Target | Savings |
|-----------|---------|-----------------|---------|
| uRamdisk compressed | 10.7MB | <3MB | 7.7MB |
| uRamdisk extracted | 25MB | <6MB | 19MB |
| Runtime init memory | ~15MB | <5MB | 10MB |
| **Total RAM freed** | - | - | **10MB+** |

---

## Partition Layout

### Internal Storage (mmcblk0) - 2GB Total
| Part | Mount | FS | Size | Purpose | JesterOS Use |
|------|-------|-----|------|---------|--------------|
| p1 | /boot | vfat | 16MB | Boot files | Keep |
| p2 | /rom | vfat | 16MB | Device config | Keep (waveforms) |
| p3 | /factory | ext2 | 190MB | Factory image | Backup space |
| p4 | - | extended | - | Container | - |
| p5 | /system | ext2 | 285MB | Android | Replace with JesterOS |
| p6 | /media | vfat | 285MB | User media | Writing storage |
| p7 | /cache | ext3 | 239MB | App cache | Vim swap/cache |
| p8 | /data | ext3 | 800MB | User data | Manuscripts |

### SD Card Layout (mmcblk1)
| Part | Size | Purpose |
|------|------|---------|
| p1 | 128MB | Boot partition (JesterOS) |
| p2 | Remaining | Backup/Writing storage |

---

## JesterOS Integration Strategy

### Phase 1: Minimal Hybrid Boot
**Goal**: Use Android init for hardware, pivot to JesterOS

#### Required Components (2.2MB total)
```
Boot Infrastructure:
├── MLO (16KB)              [Copy as-is]
├── u-boot.bin (159KB)      [Copy as-is]
├── wvf.bin (92KB)          [Copy as-is]
└── boot.scr (201B)         [Modify for JesterOS]

From uRamdisk:
├── init (128KB)            [Android init binary]
├── init.rc (minimal)       [Custom for JesterOS]
├── omap-edpd.elf (634KB)  [E-Ink daemon]
├── default_waveform.bin (95KB) [Display patterns]
├── baseimage.dof (1.2MB)  [DSP firmware]
├── bridged (87KB)          [DSP bridge]
└── cexec.out (79KB)        [DSP loader]
```

#### Minimal init.rc for JesterOS
```bash
on init
    export FRAMEBUFFER /dev/graphics/fb0
    export JESTEROS_ROOT /jesteros
    mkdir /jesteros
    mkdir /proc /sys /dev

on boot
    # Mount essential filesystems
    mount proc proc /proc
    mount sysfs sysfs /sys
    
    # E-Ink initialization
    write /sys/class/graphics/fb0/pgflip_refresh 1
    write /sys/class/graphics/fb0/epd_refresh 0
    
    # Load DSP (required for E-Ink)
    exec /sbin/cexec.out -T /etc/dsp/baseimage.dof
    exec /sbin/bridged
    sleep 1
    
    # Start E-Ink daemon
    exec /sbin/omap-edpd.elf --timeout=2 --fbdev=/dev/graphics/fb0 \
         -w /etc/dsp/default_waveform.bin &
    
    # Pivot to JesterOS
    exec /jesteros/init
```

### Phase 2: Build Custom uRamdisk
```bash
# Directory structure for new ramdisk
jesteros-ramdisk/
├── init                    # Android init (128KB)
├── init.rc                 # Minimal config
├── default.prop           # Minimal properties
├── sbin/
│   ├── omap-edpd.elf     # E-Ink daemon
│   ├── bridged           # DSP bridge
│   └── cexec.out         # DSP loader
├── etc/
│   └── dsp/
│       ├── baseimage.dof
│       ├── default_waveform.bin
│       └── subframeip_snode_dsp.dll64P
├── jesteros/
│   ├── init              # JesterOS init
│   └── bin/
│       └── vim          # Primary application
└── dev/                  # Device nodes

# Build commands
find . | cpio -o -H newc | gzip > ../ramdisk.gz
mkimage -A arm -T ramdisk -C gzip -d ramdisk.gz uRamdisk-jesteros
```

### Phase 3: Testing Strategy
1. **Test with NookManager kernel first**
   - Use existing uImage with modified ramdisk
   - Verify display initialization works
   
2. **Replace with JesterOS kernel**
   - Build minimal 2.6.29 kernel
   - Include only essential drivers
   
3. **Incremental replacement**
   - Start with working NookManager
   - Replace components one at a time
   - Maintain fallback to NookManager

---

## Implementation Roadmap

### Immediate Actions (Week 1)
1. **Extract and preserve boot files**
   ```bash
   mkdir -p firmware/boot-infrastructure
   cp /mnt/nook/{MLO,u-boot.bin,wvf.bin} firmware/boot-infrastructure/
   cp /tmp/nook-ramdisk/sbin/omap-edpd.elf firmware/boot-infrastructure/
   cp -r /tmp/nook-ramdisk/etc/dsp firmware/boot-infrastructure/
   ```

2. **Create minimal init.rc**
   - Strip all networking
   - Remove unnecessary services
   - Focus on display initialization

3. **Build test ramdisk**
   - Include only critical components
   - Target <3MB compressed size

### Short Term (Week 2-3)
1. **Hardware testing**
   - Boot with modified ramdisk
   - Verify E-Ink control
   - Test display refresh

2. **Kernel configuration**
   - Configure minimal 2.6.29 kernel
   - Include E-Ink drivers
   - Remove unnecessary modules

3. **JesterOS init development**
   - Create lightweight init
   - Implement service management
   - Add vim launcher

### Medium Term (Week 4-6)
1. **Optimization**
   - Reduce memory footprint
   - Optimize boot time
   - Tune E-Ink refresh

2. **Vim integration**
   - Configure for E-Ink
   - Optimize key mappings
   - Add writing modes

3. **Testing and refinement**
   - Battery life testing
   - Performance tuning
   - User experience polish

---

## Critical Files Reference

### From NookManager (/mnt/nook/)
```
Boot files:
├── MLO                     # Copy as-is
├── u-boot.bin             # Copy as-is
├── boot.scr               # Modify for JesterOS
├── wvf.bin                # Copy as-is (E-Ink waves)
└── uRamdisk               # Replace with custom

Scripts (for reference):
├── scripts/
│   ├── mount_nook         # Partition mounting
│   ├── do_root           # Rooting process
│   └── menu_*            # Menu system
└── menu/
    └── mainmenu          # Text UI example
```

### From uRamdisk Extraction (/tmp/nook-ramdisk/)
```
Critical binaries:
├── init                   # Android init (keep)
├── sbin/
│   ├── omap-edpd.elf     # E-Ink daemon (keep)
│   ├── bridged           # DSP bridge (keep)
│   ├── cexec.out         # DSP loader (keep)
│   └── toolbox           # Android tools (partial)
└── etc/
    └── dsp/
        ├── baseimage.dof          # DSP firmware (keep)
        ├── default_waveform.bin   # E-Ink patterns (keep)
        └── subframeip_snode_dsp.dll64P # DSP lib (keep)
```

### JesterOS Custom Files (to create)
```
jesteros/
├── init                   # JesterOS init system
├── jester                 # ASCII companion
├── typewriter            # Writing stats
├── wisdom                # Quote system
└── bin/
    └── vim               # Text editor
```

---

## Key Insights and Warnings

### Critical Discoveries
1. **Android Init Mandatory**: Hardware won't initialize without Android init
2. **DSP Required**: E-Ink display requires DSP firmware and acceleration
3. **Fixed Memory Addresses**: Kernel and ramdisk addresses are hardware-fixed
4. **Waveform Critical**: Device-specific waveform files required for display

### Implementation Warnings
⚠️ **Don't skip DSP loading** - Display won't work without it
⚠️ **Preserve boot order** - DSP must load before omap-edpd
⚠️ **Keep memory addresses** - 0x81c00000 and 0x81f00000 are fixed
⚠️ **Test incrementally** - Replace one component at a time
⚠️ **Maintain fallback** - Keep NookManager SD card for recovery

### Optimization Opportunities
- Remove WiFi stack: Save 500KB+
- Strip Android services: Save 2MB+
- Minimize busybox: Use only needed applets
- Custom kernel: Remove unnecessary drivers
- Compress resources: Use squashfs where possible

---

## Conclusion

This analysis provides the complete blueprint for implementing JesterOS boot on Nook SimpleTouch hardware. The key breakthrough is discovering the E-Ink display control system (omap-edpd.elf) and understanding that a hybrid Android/Linux approach is required.

With the boot infrastructure fully documented, JesterOS can now move forward with confidence, knowing exactly what components are needed and how to integrate them.

**Total implementation size**: ~5MB (vs 13MB original)
**RAM savings**: 10MB+ for actual writing
**Boot time target**: <20 seconds

---

*Documentation compiled from:*
- NookManager v0.5.0 image analysis
- uRamdisk extraction and analysis  
- Hardware testing and verification
- Date: 2025-01-19
- For: JesterOS Boot Infrastructure