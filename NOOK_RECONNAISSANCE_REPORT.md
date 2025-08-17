# Nook Simple Touch Device Reconnaissance Report

**Target Device**: Nook Simple Touch (BNRV300) at 192.168.12.111:5555  
**Investigation Date**: August 17, 2025  
**Objective**: Extract authentic hardware/software configuration for JokerOS Docker development environment

## Executive Summary

Successfully conducted comprehensive non-invasive reconnaissance of Nook Simple Touch device revealing critical specifications for authentic JokerOS development environment creation. Device confirmed as ARM-based Android 2.1 system with unique E-Ink display configuration and severe memory constraints.

## Device Identification

### Hardware Platform
- **Manufacturer**: Barnes & Noble (BarnesAndNoble)
- **Model**: BNRV300 (Nook Simple Touch)
- **Board**: OMAP3621 GOSSAMER board
- **Platform**: OMAP3 (omap3621)
- **Architecture**: ARMv7 Processor rev 2 (v7l)
- **CPU**: ARM Cortex-A8 with NEON, VFP, VFPv3 support
- **BogoMIPS**: 298.32 (indicating ~800MHz operation)
- **Serial**: 3014910105803005

### Android System
- **Version**: Android 2.1 (API Level 7, SDK 7)
- **Build**: ERD79 (1.2.1.24.carbon1_2.gossamer.rrdp.s70455)
- **Kernel**: Linux 2.6.29-omap1 #1 PREEMPT (built Dec 7, 2012)
- **Build Date**: Fri Dec  7 14:35:36 PST 2012
- **Build Host**: dhabuildimage04
- **CPU ABI**: armeabi (ARM EABI)

## Memory Configuration - CRITICAL CONSTRAINTS

### Physical Memory Layout
```
Total RAM:           233,008 KB (227 MB)
Available Memory:     44,748 KB (44 MB)
Buffers:              9,208 KB
Cached:              76,960 KB
Active Memory:       86,416 KB
Swap:                      0 KB (NO SWAP)
```

### Memory Budget Analysis
```
OS + Android Framework: ~188 MB (81% of total RAM)
Available for Apps:     ~44 MB remaining
JokerOS Target Budget:  <10 MB maximum footprint
```

**WARNING**: Extreme memory constraints confirmed. JokerOS must operate within <10MB memory budget.

## Display System - E-Ink Configuration

### Framebuffer Configuration
- **Device**: /dev/fb0 (primary framebuffer)
- **Resolution**: 600x1600 pixels (portrait orientation)
- **Color Depth**: 16 bits per pixel
- **Display**: E-Ink with E-Paper Display (EPD) drivers

### Kernel Boot Parameters
```
console=ttyS0,115200n8 initrd rw init=/init 
vram=16M 
video=omap3epfb:mode=800x600x16x14x270x0,pmic=tps65180-1p2-i2c,vcom=-1770 
androidboot.console=ttyS0
```

**Key Findings**:
- VRAM limited to 16MB
- Custom OMAP3 E-Paper Framebuffer driver (omap3epfb)
- TPS65180 Power Management IC for E-Ink
- VCOM voltage: -1770mV (critical for E-Ink operation)

## Filesystem Structure

### Partition Layout
```
/dev/block/mmcblk0p2  → /rom       (16MB, VFAT, read-only boot)
/dev/block/mmcblk0p5  → /system    (295MB, EXT2, Android system)
/dev/block/mmcblk0p8  → /data      (808MB, EXT3, user data)
/dev/block/mmcblk0p7  → /cache     (245MB, EXT3, cache)
/dev/block/mmcblk1p1  → /sdcard    (256MB, VFAT, external storage)
/dev/block/mmcblk1p2  → /media     (1.8GB, VFAT, internal storage)
```

### Storage Utilization
```
/system: 210MB used / 285MB total (74% full)
/data:   120MB used / 808MB total (15% full)
/cache:    6MB used / 237MB total (3% full)
```

## Kernel Modules & Drivers

### Loaded Modules
```
tiwlan_drv   866KB  - Texas Instruments WLAN driver
pvrsrvkm     150KB  - PowerVR graphics driver
omaplfb       16KB  - OMAP Linux framebuffer
bc_example     6KB  - Buffer class example
```

### Critical Driver Files
```
/system/etc/wifi/tiwlan_drv.ko    - WiFi driver module
/system/bin/sgx/pvrsrvkm.ko       - Graphics driver
/system/bin/sgx/omaplfb.ko        - Framebuffer driver
/system/bin/sgx/bc_example.ko     - Graphics buffer management
```

### Hardware Interrupts (Key Components)
```
IRQ 21:  SGX ISR (graphics)
IRQ 73:  Touch screen controller (zforce-ts)
IRQ 94:  TIWLAN WiFi
IRQ 175: GPIO WiFi
IRQ 208: Home button
IRQ 273: Touch controller
```

## Running Processes & Services

### Critical Android Services
```
system_server     - Main Android system service (50MB RAM!)
zygote           - Android app runtime (29MB RAM)
mediaserver      - Media framework (7MB RAM)
servicemanager   - Binder service manager
omap-edpd.elf    - E-Paper display daemon (12MB RAM)
```

### Resource-Heavy Processes
```
com.amazon.venezia        - Amazon Kindle app (31MB)
com.harasoft.relaunch     - RelaunchX launcher (32MB)
com.android.settings      - Settings app (32MB)
```

**Finding**: Current Android apps consume 95+ MB RAM, leaving minimal space for additional services.

## Boot Configuration

### Init System
- **Init Binary**: /init (128KB)
- **Configuration**: /init.rc (custom Android init)
- **Console**: ttyS0 at 115200 baud
- **Shell**: /system/bin/sh (basic shell, not bash)

### Available Utilities
```
Essential: sh, cat, mount, umount, toolbox
Missing: bash, vim, nano, make, gcc
Available: logcat, screenshot utilities
```

## Network Configuration

### WiFi System
- **Driver**: TI WiLink (tiwlan_drv.ko)
- **Supplicant**: wpa_supplicant running
- **DHCP**: dhcpcd active
- **ADB**: TCP mode on port 5555

## JokerOS Docker Development Strategy

### Hardware Emulation Requirements

#### CPU & Architecture
```dockerfile
# Use ARM emulation with QEMU
FROM --platform=linux/arm/v7 debian:bullseye-slim

# Target ARM Cortex-A8 equivalent
ENV TARGET_ARCH=armv7l
ENV TARGET_CPU=cortex-a8
ENV TARGET_FLOAT=softfp
```

#### Memory Constraints
```dockerfile
# Enforce strict memory limits
ENV MEMORY_LIMIT=227m
ENV AVAILABLE_MEMORY=44m
ENV JOKEROS_BUDGET=10m

# Use memory-limited container
docker run --memory=227m --oom-kill-disable nook-jokeros
```

#### Framebuffer Simulation
```dockerfile
# Install framebuffer development tools
RUN apt-get update && apt-get install -y \
    fbset \
    fbterm \
    directfb-dev \
    libfb-dev

# Configure virtual framebuffer
ENV FRAMEBUFFER=/dev/fb0
ENV FB_WIDTH=600
ENV FB_HEIGHT=1600
ENV FB_BPP=16
```

### Development Environment Configuration

#### Kernel Compatibility
```dockerfile
# Match kernel version for module development
ENV KERNEL_VERSION=2.6.29
ENV KERNEL_CONFIG=omap3_defconfig
ENV CROSS_COMPILE=arm-linux-gnueabi-

# Install kernel headers matching target
COPY linux-headers-2.6.29-omap1 /usr/src/linux-headers-2.6.29-omap1
```

#### Android Runtime Emulation
```dockerfile
# Minimal Android property system
COPY init.rc /init.rc
COPY build.prop /system/build.prop

# Essential Android binaries
COPY toolbox /system/bin/toolbox
RUN ln -s /system/bin/toolbox /system/bin/cat
RUN ln -s /system/bin/toolbox /system/bin/mount
```

#### File System Layout
```dockerfile
# Recreate Nook filesystem structure
RUN mkdir -p /system /data /cache /sdcard /media /rom
RUN mkdir -p /system/bin /system/lib /system/etc

# Mount points simulation
VOLUME ["/data", "/cache", "/sdcard", "/media"]
```

### Security Considerations

#### Read-Only Operations Confirmed
- All reconnaissance used non-invasive ADB commands
- No system modifications performed
- Device state preserved throughout investigation
- No reboots or service interruptions

#### Development Safety
```dockerfile
# Prevent accidental device modification
ENV ADB_DEVICE_READONLY=1
ENV NOOK_SAFE_MODE=1

# Test environment isolation
RUN echo "DEVELOPMENT_ONLY" > /etc/nook-dev-marker
```

## Implementation Recommendations

### 1. Base Image Strategy
Use multi-stage Docker build with ARM emulation:
```dockerfile
FROM --platform=linux/arm/v7 debian:bullseye-slim AS nook-base
# Install cross-compilation tools
# Configure ARM emulation
# Set up framebuffer simulation

FROM nook-base AS nook-jokeros
# Install JokerOS components
# Configure memory limits
# Set up development environment
```

### 2. Memory Optimization Priority
1. **Critical**: Stay under 10MB total footprint
2. **Essential**: Use static linking to reduce library overhead
3. **Required**: Implement memory monitoring and limits
4. **Recommended**: Use busybox for utilities to save space

### 3. Display System Integration
1. **Framebuffer**: Emulate /dev/fb0 with 600x1600x16 configuration
2. **Refresh**: Implement E-Ink refresh simulation for development
3. **Testing**: Provide fallback text-mode for CI/CD environments

### 4. Kernel Module Development
1. **Headers**: Include Linux 2.6.29 headers in development image
2. **Toolchain**: Use arm-linux-gnueabi-gcc 4.3.x for compatibility
3. **Testing**: Validate modules load without errors in emulation

### 5. Deployment Strategy
1. **SD Card**: Target /sdcard for JokerOS installation
2. **Chroot**: Use chroot environment to avoid Android conflicts
3. **Init**: Hook into Android init system for service startup

## Conclusion

Reconnaissance successfully mapped complete Nook Simple Touch hardware and software configuration. Critical findings:

- **Memory**: Extreme constraints (44MB available) require <10MB JokerOS footprint
- **Display**: Custom E-Ink drivers need framebuffer emulation for development
- **Architecture**: ARMv7 with specific OMAP3 requirements
- **Kernel**: Linux 2.6.29 with custom Android patches
- **Storage**: SD card provides installation target with 256MB available

Docker development environment can authentically recreate target conditions using ARM emulation, memory limits, and framebuffer simulation. All findings support confident JokerOS development and deployment strategy.