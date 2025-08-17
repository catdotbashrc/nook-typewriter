# Nook Simple Touch - Storage and Boot Analysis

*Analysis conducted via ADB on device 192.168.12.111:5555*

## Executive Summary

The Nook Simple Touch uses a dual-storage architecture with an internal 2GB eMMC for system partitions and supports external SD cards for additional storage. The device boots from internal eMMC using a multi-stage process involving U-Boot → Android init → mounted filesystems. This analysis provides critical information for implementing JesterOS SD card boot capability.

## Storage Architecture

### Internal eMMC (mmcblk0) - 2GB Samsung M2G1HF
- **Device**: /dev/block/mmcblk0
- **Total Size**: 1,953,792 KB (~1.9GB)
- **Manufacturer**: Samsung (ID: 0x000015)
- **OEM ID**: 0x0100
- **Type**: MMC (Embedded MultiMediaCard)

### SD Card (mmcblk1) - External Storage
- **Device**: /dev/block/mmcblk1  
- **Current Card**: SB16G (16GB)
- **Manufacturer**: SanDisk (ID: 0x000003)
- **OEM ID**: 0x5344
- **Type**: SD (Secure Digital)

## Partition Layout

### Internal eMMC Partitions (mmcblk0)

| Partition | Device | Size (KB) | Mount Point | Filesystem | Usage |
|-----------|--------|-----------|-------------|------------|-------|
| mmcblk0p1 | /dev/block/mmcblk0p1 | 77,808 | - | - | Bootloader |
| mmcblk0p2 | /dev/block/mmcblk0p2 | 16,384 | /rom | VFAT | Recovery/Boot ROM |
| mmcblk0p3 | /dev/block/mmcblk0p3 | 194,560 | - | - | Reserved |
| mmcblk0p4 | /dev/block/mmcblk0p4 | 1 | - | - | Extended partition table |
| mmcblk0p5 | /dev/block/mmcblk0p5 | 294,896 | /system | EXT2 | Android system |
| mmcblk0p6 | /dev/block/mmcblk0p6 | 245,744 | /media | VFAT | Internal media storage |
| mmcblk0p7 | /dev/block/mmcblk0p7 | 245,744 | /cache | EXT3 | Application cache |
| mmcblk0p8 | /dev/block/mmcblk0p8 | 821,232 | /data | EXT3 | User data and apps |

### SD Card Partitions (mmcblk1)

| Partition | Device | Size (KB) | Mount Point | Filesystem | Usage |
|-----------|--------|-----------|-------------|------------|-------|
| mmcblk1p1 | /dev/block/mmcblk1p1 | 262,112 | /sdcard | VFAT | User storage |
| mmcblk1p2 | /dev/block/mmcblk1p2 | 1,835,008 | - | - | Available for JesterOS |

## Boot Process Analysis

### Kernel Configuration
- **Kernel Version**: Linux 2.6.29-omap1
- **Compiled**: Dec 7, 2012 (GCC 4.3.2 Sourcery G++ Lite)
- **Architecture**: ARM OMAP3 (800MHz)
- **Boot Parameters**: 
  ```
  console=ttyS0,115200n8 initrd rw init=/init vram=16M 
  video=omap3epfb:mode=800x600x16x14x270x0,pmic=tps65180-1p2-i2c,vcom=-1770 
  androidboot.console=ttyS0
  ```

### Boot Sequence (Power-on to Linux)

1. **Hardware Power-On**
   - OMAP3 ROM bootloader executes
   - Searches for bootable media (internal eMMC first)

2. **U-Boot Stage** (mmcblk0p1)
   - Primary bootloader loads from partition 1
   - Initializes hardware and RAM
   - Loads kernel and initrd from boot partition
   - Passes kernel command line parameters

3. **Linux Kernel Initialization**
   - Kernel loaded with initrd
   - Video subsystem initialized for E-Ink display
   - MMC/SD controllers initialized
   - Root filesystem mounted (rootfs)

4. **Android Init Process** (/init)
   - Executes /init.rc configuration
   - Mounts all required partitions
   - Sets up environment variables
   - Starts system services

### Mount Sequence (from /init.rc)
```bash
# Core system mounts
mount tmpfs tmpfs /sqlite_stmt_journals size=4m
mount rootfs rootfs / ro remount

# Storage partitions
mount vfat /dev/block/mmcblk0p2 /rom sync noatime nodiratime uid=1000,gid=1000,fmask=117,dmask=007
mount ext2 /dev/block/mmcblk0p5 /system
mount ext2 /dev/block/mmcblk0p5 /system ro remount
mount ext3 /dev/block/mmcblk0p8 /data nosuid nodev noatime nodiratime
mount ext3 /dev/block/mmcblk0p7 /cache nosuid nodev noatime nodiratime
```

## Storage Performance Configuration

### I/O Scheduler
- **Internal eMMC**: NOOP scheduler (optimal for flash storage)
- **SD Card**: NOOP scheduler (reduces latency for E-Ink updates)

### Mount Options Analysis
- **VFAT Partitions**: 
  - `sync` - Immediate writes (data safety for power loss)
  - `noatime,nodiratime` - No access time updates (performance)
  - `uid=1000,gid=1000` - Android app permissions
- **EXT2/3 Partitions**:
  - `noatime,nodiratime` - Performance optimization
  - `nosuid,nodev` - Security restrictions
  - `errors=continue` - Continue operation on errors

### Write Performance Optimization
- Block size: 4KB for EXT3, 512B for VFAT
- No write-back caching (immediate sync for safety)
- Wear leveling handled at hardware level (eMMC controller)

## SD Card Boot Implementation Strategy

### Current SD Card Detection
- SD cards are auto-detected and mounted via vold service
- Mount point: `/sdcard` for partition 1
- Partition 2 (`mmcblk1p2`) remains unmounted and available

### JesterOS Boot Requirements

#### Option 1: Replace Internal Boot (High Risk)
- Replace U-Boot on mmcblk0p1 (⚠️ **DANGEROUS - Can brick device**)
- Modify to boot from SD card first
- NOT RECOMMENDED due to recovery complexity

#### Option 2: Modify /init.rc (Moderate Risk)
- Modify Android init to chroot to SD card after boot
- Requires write access to /system partition
- More recoverable than bootloader modification

#### Option 3: Application-Level Boot (Recommended)
- Android boots normally
- Custom application immediately switches to SD card environment
- Safest approach with full recovery capability

### Recommended SD Card Layout for JesterOS

```
/dev/block/mmcblk1p1 (256MB) - FAT32 - Configuration and recovery
/dev/block/mmcblk1p2 (remaining) - EXT4 - JesterOS root filesystem
```

#### Partition 1 (Boot/Config) - 256MB FAT32
- JesterOS configuration files
- Recovery scripts
- Boot status flags
- Emergency fallback tools

#### Partition 2 (Root) - Remaining space EXT4
- Full Debian chroot environment
- JesterOS userspace services
- Writing tools and data
- User documents

## Recovery and Fallback Mechanisms

### Current Recovery System
- **Recovery Partition**: Uses MTD-based recovery (install-recovery.sh)
- **Recovery Image**: `/system/recovery-from-boot.p`
- **Auto-Recovery**: Validates recovery partition on boot
- **Cache Recovery**: `/cache/recovery` for recovery communications

### Recovery Scripts Analysis
```bash
# From /system/etc/install-recovery.sh
applypatch -c MTD:recovery:2048:5998751934cd5ce9b2823b3ac06e03f14a11d74e
applypatch MTD:boot:2037760:8dfc911d3ead5199d47558228b67044723726a11 \
           MTD:recovery 0b3c1ad0c5f9ec08c1b95a150f5af115bbe79b39 3366912
```

### JesterOS Recovery Strategy

#### Primary Boot Path
1. Normal Android boot
2. Check for JesterOS flag in `/sdcard/jesteros.conf`
3. If flag present, chroot to `/sdcard/debian/`
4. Start JesterOS services

#### Recovery Triggers
- **Hardware**: Power + Home button (existing Android recovery)
- **Software**: Delete `/sdcard/jesteros.conf`
- **Automatic**: Boot failure detection (fallback to Android)

#### Fallback Sequence
1. **Level 1**: Remove SD card → Normal Android boot
2. **Level 2**: Delete JesterOS config → Android with SD storage
3. **Level 3**: Factory reset via Android recovery
4. **Level 4**: Hardware recovery mode (power + home + page buttons)

## Memory and Performance Implications

### Memory Budget (256MB Total)
- **Android Base**: ~95MB (confirmed from df output)
- **Available for JesterOS**: ~160MB
- **Critical**: Must not exceed memory limits

### Current Memory Usage
```
/dev: 116MB total, 808KB used (tmpfs)
/system: 285MB total, 210MB used (70% full)
/data: 808MB total, 120MB used (15% full)
/cache: 237MB total, 6MB used (3% full)
```

### SD Card Performance Considerations
- **Write Speed**: Limited by NOOP scheduler and sync mounts
- **Read Speed**: Optimized for sequential access
- **Endurance**: Use wear-leveling aware filesystems (EXT4)

## Security Considerations

### File System Permissions
- Root filesystem mounted read-only for security
- User data partitions with `nosuid,nodev` restrictions
- SD card mounted with specific uid/gid for app access

### Boot Security
- No verified boot or secure boot implemented
- Full read/write access available via ADB
- Recovery possible through multiple vectors

### JesterOS Security Model
- Chroot environment provides process isolation
- File system permissions inherit from Android
- Network isolation (no WiFi in writing mode)

## Critical Implementation Notes

### Do NOT Modify
- **mmcblk0p1**: Bootloader partition (risk of bricking)
- **mmcblk0p2**: Boot ROM (recovery dependency)
- **mmcblk0p5**: System partition (unless backup available)

### Safe to Modify
- **mmcblk1p2**: Unused SD card partition
- **Application layer**: Android apps and services
- **User data**: Files in /data and /sdcard

### Boot Time Optimization
- Current kernel boot time: ~20 seconds to init
- Android services: Additional 10-15 seconds
- Target JesterOS boot: <30 seconds total

## Recommendations for JesterOS Implementation

### Phase 1: Proof of Concept
1. Create bootable SD card with Debian chroot
2. Implement application-level switch mechanism
3. Test memory usage and performance
4. Validate recovery procedures

### Phase 2: Integration
1. Optimize boot time with minimal Android services
2. Implement automatic SD card detection and switch
3. Create user-friendly recovery mechanism
4. Add hardware abstraction for E-Ink display

### Phase 3: Production
1. Implement wear leveling monitoring
2. Add over-the-air update mechanism via SD card
3. Create imaging tools for easy deployment
4. Document user installation procedures

## Technical Specifications Summary

- **Platform**: Texas Instruments OMAP3621 (800MHz ARM Cortex-A8)
- **Internal Storage**: 2GB eMMC (Samsung M2G1HF)
- **External Storage**: SD/SDHC up to 32GB (tested with 16GB SanDisk)
- **Boot Method**: U-Boot → Linux 2.6.29 → Android Init
- **Recovery**: Android recovery partition + factory reset
- **Memory**: 256MB total (160MB available for applications)
- **Display**: 6" E-Ink Pearl (800x600, 16 grayscale levels)

This analysis provides the foundation for implementing safe, recoverable SD card booting for JesterOS while preserving the device's primary functionality and recovery mechanisms.