# Hardware Documentation

This directory contains comprehensive hardware documentation for JesterOS development on the Nook Simple Touch.

## Documents

### Core Hardware Documentation

#### [NOOK_HARDWARE_REFERENCE.md](NOOK_HARDWARE_REFERENCE.md)
Complete hardware specification and reference guide based on live device reconnaissance.

#### [EINK_DISPLAY_REFERENCE.md](EINK_DISPLAY_REFERENCE.md)  
E-Ink Pearl display system documentation with safe control methods.

#### [TOUCH_INPUT_REFERENCE.md](TOUCH_INPUT_REFERENCE.md)
zForce infrared touchscreen system and input handling.

### Storage & Boot Documentation

#### [../storage/PARTITION_STRATEGY.md](../storage/PARTITION_STRATEGY.md)
**4-Partition Recovery Architecture** - Our resilient storage design with automatic recovery.

#### [../../STORAGE_AND_BOOT_ANALYSIS.md](../../STORAGE_AND_BOOT_ANALYSIS.md)
Comprehensive analysis of Nook storage interfaces and boot process.

**Key Topics:**
- CPU Architecture (ARMv7 Cortex-A8)
- Memory System (233MB RAM, 138MB available)
- E-Ink Display Subsystem (800×600, safe sysfs control)
- 4-Partition SD Card Layout (Boot/System/Recovery/Writing)
- Touch Input (zForce IR, single-touch)
- Storage Layout (2GB eMMC + microSD boot)
- Boot Process (U-Boot with recovery support)
- Development Environment (Docker-based cross-compilation)
- JesterOS Hardware Abstraction Layer

## Quick Reference

| Component | Specification | JesterOS Impact |
|-----------|---------------|-----------------|
| **CPU** | 800MHz ARM Cortex-A8 | Modern toolchain support |
| **RAM** | 138MB available | Exceeds 96MB target |
| **Display** | 6" E-Ink Pearl 800×600 | 167 PPI, 16 grayscale |
| **Touch** | zForce IR single-touch | 600×800 resolution |
| **Storage** | 2GB eMMC + 32GB microSD | 4-partition architecture |
| **Recovery** | Multi-trigger recovery | Hardware + software + auto |

## Hardware Verification

To verify hardware specifications on your device:

```bash
# Connect via ADB
adb connect <NOOK_IP>:5555

# Check CPU info
adb shell cat /proc/cpuinfo

# Check memory
adb shell cat /proc/meminfo

# Check display
adb shell cat /proc/fb

# Check storage
adb shell cat /proc/partitions
```

## JesterOS 4-Partition Storage Architecture

Our resilient storage design provides enterprise-grade recovery:

```
┌──────────────────────────────────────────┐
│ Partition 1: BOOT (512MB, FAT16)        │
│ - Sector 63 aligned (critical!)          │
│ - MLO, u-boot, kernel, recovery flags    │
├──────────────────────────────────────────┤
│ Partition 2: SYSTEM (1.5GB, ext4)       │
│ - JesterOS root filesystem (read-only)   │
│ - ~450MB used, room for growth          │
├──────────────────────────────────────────┤
│ Partition 3: RECOVERY (1.5GB, ext4)     │
│ - Factory image & recovery tools         │
│ - Automatic recovery after 3 failures    │
├──────────────────────────────────────────┤
│ Partition 4: WRITING (remaining, ext4)  │
│ - User documents (80%+ of card)          │
│ - Survives all system operations         │
└──────────────────────────────────────────┘
```

### Recovery Capabilities
- **Hardware**: Hold Power+Home during boot
- **Software**: Touch `/boot/RECOVERY_MODE` file
- **Automatic**: 3 failed boots trigger recovery
- **Factory Reset**: Preserves user writings

## JesterOS Hardware Layers

The hardware documentation supports our 4-layer architecture:

```
Layer 1 (UI)         → E-Ink display, touch input
Layer 2 (Application) → JesterOS services
Layer 3 (System)     → Debian ARM environment  
Layer 4 (Hardware)   → ARM hardware + 4-partition storage
```

## Safety Notes

### E-Ink Display Control
**⚠️ CRITICAL**: Never write directly to `/dev/fb0`!
- Use sysfs controls only: `/sys/class/graphics/fb0/`
- Direct framebuffer writes can cause system crashes
- See [EINK_DISPLAY_REFERENCE.md](EINK_DISPLAY_REFERENCE.md) for safe methods

### Boot Requirements
**⚠️ CRITICAL**: First partition MUST start at sector 63!
- Modern tools default to sector 2048 (will not boot)
- MLO must be copied first for contiguous storage
- See [SD Card Boot Guide](../01-getting-started/sd-card-boot-guide.md)

---

*Hardware documentation based on embedded reverse engineering*  
*Safe, non-invasive ADB reconnaissance only*  
*JesterOS Development Team*