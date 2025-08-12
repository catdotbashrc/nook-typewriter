# NST Kernel Documentation Index

*Comprehensive documentation for the felixhaedicke/nst-kernel project*

## Table of Contents
- [Project Overview](#project-overview)
- [Key Features](#key-features)
- [Hardware Compatibility](#hardware-compatibility)
- [Build System](#build-system)
- [Development Guide](#development-guide)
- [Architecture Details](#architecture-details)
- [Integration with QuillKernel](#integration-with-quillkernel)
- [Troubleshooting](#troubleshooting)
- [References](#references)

---

## Project Overview

The **NST Kernel** is a custom Linux kernel specifically designed for the Barnes & Noble Nook Simple Touch (NST) e-reader. This kernel extends the original Barnes & Noble kernel sources with community improvements focused on enhanced USB host support and fast display mode capabilities.

### Project Origins
- **Base**: Barnes & Noble's original kernel sources
- **Maintainer**: Felix Hädicke (felixhaedicke)
- **Community Contributions**: Incorporates improvements from GitHub user "staylo"
- **License**: GPL-2.0
- **Repository**: https://github.com/felixhaedicke/nst-kernel

### Language Composition
- **95.6% C**: Core kernel implementation
- **2.6% Assembly**: Low-level hardware interface code
- **Remaining**: Build scripts, configuration files, documentation

---

## Key Features

### Enhanced USB Host Support
- **Fixed USB Host**: Resolves USB connectivity issues in original kernel
- **Improved Stability**: Better handling of USB device enumeration
- **Extended Compatibility**: Support for additional USB peripherals

### Fast Display Mode Support
- **E-Ink Optimization**: Enhanced refresh modes for E-Ink displays
- **Performance Improvements**: Faster screen updates for better user experience
- **Display Driver Enhancements**: Optimized framebuffer operations

### Hardware-Specific Optimizations
- **ARM Cortex-A8**: Optimized for TI OMAP3621 processor
- **Memory Management**: Efficient handling of 256MB RAM constraint
- **Power Management**: E-reader specific power optimization

---

## Hardware Compatibility

### Target Device: Barnes & Noble Nook Simple Touch
```yaml
Hardware Specifications:
  Processor: TI OMAP3621 @ 800MHz (ARM Cortex-A8)
  Memory: 256MB RAM
  Display: 6" E-Ink Pearl (800x600, 16 grayscale levels)
  Storage: 2GB internal + microSD slot
  Connectivity: WiFi 802.11b/g/n, USB 2.0
  Touch: Infrared touch sensor
```

### Kernel Version
- **Base Version**: Linux 2.6.29
- **Architecture**: ARM (OMAP3)
- **Configuration**: Custom defconfig for NST hardware

---

## Build System

### Prerequisites
```bash
# Required Tools
- Android NDK (version 4.7 or compatible)
- ARM cross-compilation toolchain
- Make build system
- Git for source management
```

### Build Environment Setup
```bash
# Download Android NDK
export NDK_PATH="/opt/android-ndk"
export CROSS_COMPILE="$NDK_PATH/toolchains/arm-linux-androideabi-4.7/prebuilt/linux-x86_64/bin/arm-linux-androideabi-"
export ARCH=arm
```

### Build Process
```bash
# 1. Clone repository
git clone https://github.com/felixhaedicke/nst-kernel.git
cd nst-kernel

# 2. Configure kernel
cp build/gossamer_evt1c_defconfig src/.config
cd src
make ARCH=arm oldconfig

# 3. Build kernel image
make -j$(nproc) ARCH=arm CROSS_COMPILE=$CROSS_COMPILE uImage

# 4. Output location
# Kernel image: arch/arm/boot/uImage
# Modules: Built with 'make modules'
```

### Build Optimization
```bash
# Parallel build for faster compilation
make -j6 ARCH=arm CROSS_COMPILE=$CROSS_COMPILE uImage

# Clean build
make ARCH=arm CROSS_COMPILE=$CROSS_COMPILE clean
make ARCH=arm CROSS_COMPILE=$CROSS_COMPILE mrproper
```

---

## Development Guide

### Repository Structure
```
nst-kernel/
├── build/                  # Build configurations
│   └── gossamer_evt1c_defconfig  # NST hardware config
├── src/                    # Linux kernel source tree
│   ├── arch/arm/          # ARM architecture code
│   ├── drivers/           # Device drivers
│   ├── include/           # Header files
│   └── ...                # Standard kernel directories
├── README.md              # Project documentation
└── LICENSE                # GPL-2.0 license
```

### Key Configuration Files
- **gossamer_evt1c_defconfig**: Hardware-specific kernel configuration
- **Device Tree**: OMAP3 device tree specifications for NST hardware
- **Driver Configs**: E-Ink display, USB host, power management

### Important Drivers
```c
// E-Ink Display Driver
drivers/video/omap2/
drivers/video/epd/

// USB Host Controller
drivers/usb/host/ehci-omap.c

// Touch Interface
drivers/input/touchscreen/

// Power Management
arch/arm/mach-omap2/pm34xx.c
```

### Kernel Configuration Options
```kconfig
# Essential NST configurations
CONFIG_ARCH_OMAP=y
CONFIG_ARCH_OMAP3=y
CONFIG_MACH_OMAP3621_GOSSAMER=y
CONFIG_USB_EHCI_HCD=y
CONFIG_FB_OMAP2=y
```

---

## Architecture Details

### OMAP3 Platform Integration
- **SoC Support**: TI OMAP3621-specific optimizations
- **Clock Management**: OMAP3 clock framework integration
- **Memory Mapping**: ARM MMU configuration for NST hardware
- **Interrupt Handling**: OMAP3 interrupt controller support

### Display Subsystem
```c
// E-Ink Display Architecture
struct omap_dss_device {
    // Display device structure
    // E-Ink specific refresh modes
    // Waveform management
};

// Fast Display Mode Implementation
void epd_fast_refresh(struct fb_info *info);
void epd_partial_refresh(int x, int y, int w, int h);
```

### USB Host Implementation
```c
// Enhanced USB Host Support
static int ehci_omap_init(struct usb_hcd *hcd);
static int ehci_omap_reinit(struct ehci_hcd *ehci);

// USB device enumeration improvements
static int omap_ehci_hub_control(struct usb_hcd *hcd, ...);
```

---

## Integration with QuillKernel

### How NST Kernel Serves as Foundation
The QuillKernel project builds upon the NST kernel as its base:

```yaml
Integration Architecture:
  Base Layer: felixhaedicke/nst-kernel (Linux 2.6.29)
  Extension Layer: SquireOS modules (medieval interface)
  Hardware Layer: Same NST hardware target
  
Build Integration:
  Source: NST kernel as git submodule
  Modules: SquireOS modules added to drivers/
  Configuration: Extended Kconfig for SquireOS features
```

### SquireOS Module Integration
```makefile
# Integration in NST kernel build system
# drivers/Makefile
obj-$(CONFIG_SQUIREOS) += ../../../../quillkernel/modules/

# drivers/Kconfig
source "drivers/Kconfig.squireos"
```

### Shared Hardware Support
- **Display Driver**: SquireOS uses NST's E-Ink drivers
- **USB Host**: Inherits fixed USB host support
- **Power Management**: Benefits from NST power optimizations
- **Touch Input**: Uses NST touch interface drivers

---

## Troubleshooting

### Common Build Issues

#### Toolchain Problems
```bash
# Error: arm-linux-androideabi-gcc not found
# Solution: Verify NDK path and toolchain
export PATH="$NDK_PATH/toolchains/arm-linux-androideabi-4.7/prebuilt/linux-x86_64/bin:$PATH"
which arm-linux-androideabi-gcc
```

#### Configuration Issues
```bash
# Error: Unknown symbol in kernel
# Solution: Check module dependencies
make ARCH=arm CROSS_COMPILE=$CROSS_COMPILE modules_prepare
make ARCH=arm CROSS_COMPILE=$CROSS_COMPILE modules
```

#### Memory Constraints
```bash
# Error: Kernel too large for device
# Solution: Optimize kernel configuration
make ARCH=arm menuconfig
# Disable unnecessary features
# Enable kernel compression
```

### Runtime Issues

#### USB Host Not Working
```bash
# Check USB host controller initialization
dmesg | grep ehci
dmesg | grep usb

# Verify USB power
cat /sys/class/power_supply/usb/online
```

#### Display Problems
```bash
# Check framebuffer device
ls -la /dev/fb*
cat /proc/fb

# Verify E-Ink driver
dmesg | grep epd
dmesg | grep omap_dss
```

---

## References

### Official Resources
- **Repository**: https://github.com/felixhaedicke/nst-kernel
- **License**: GPL-2.0
- **Base Sources**: Barnes & Noble NST kernel sources

### Community Resources
- **NookDevs Community**: Historic Nook development community
- **MobileRead Forums**: E-reader development discussions
- **Linux Kernel Documentation**: https://www.kernel.org/doc/html/v2.6.29/

### Technical Documentation
- **OMAP3 TRM**: TI OMAP3 Technical Reference Manual
- **ARM Architecture**: ARM Cortex-A8 documentation
- **E-Ink Integration**: E-Ink display controller specifications

### Development Tools
- **Android NDK**: https://developer.android.com/ndk/downloads/older_releases
- **Cross-compilation**: ARM GNU toolchain
- **Kernel Build**: Linux kernel build system documentation

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| Original | ~2012 | Initial NST kernel release |
| USB Fix | ~2013 | Fixed USB host support |
| Fast Display | ~2014 | Enhanced display mode support |
| Community | 2015+ | Ongoing community maintenance |

---

*Documentation generated for QuillKernel project integration*
*Last updated: 2024*