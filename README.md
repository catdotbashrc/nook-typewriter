# 🏰 QuillKernel - Nook Typewriter Project
### Developer Documentation

## 📋 Table of Contents
- [Project Overview](#project-overview)
- [Architecture](#architecture)
- [Quick Start](#quick-start)
- [Development Setup](#development-setup)
- [Build System](#build-system)
- [Kernel Modules](#kernel-modules)
- [Testing](#testing)
- [Deployment](#deployment)
- [Project Structure](#project-structure)
- [Contributing](#contributing)
- [Troubleshooting](#troubleshooting)

## 🎯 Project Overview

QuillKernel transforms the Barnes & Noble Nook Simple Touch (NST) e-reader into a distraction-free typewriter with medieval-themed kernel modules. This project builds a custom Linux kernel (2.6.29) with whimsical features while maintaining extreme memory efficiency for the device's 256MB RAM constraint.

### Key Features
- **Medieval-themed kernel interface** via `/proc/squireos/`
- **ASCII art court jester** with dynamic moods
- **Writing statistics tracking** with achievement system
- **Ultra-minimal footprint** (<30MB compressed rootfs)
- **E-Ink optimized** interface

### Target Hardware
- **Device**: Barnes & Noble Nook Simple Touch
- **CPU**: TI OMAP3621 @ 800MHz (ARM Cortex-A8)
- **RAM**: 256MB (160MB reserved for writing)
- **Display**: 6" E-Ink (800x600, 16-level grayscale)
- **Storage**: 2GB internal + SD card slot

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     QuillKernel Stack                        │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  User Space                     Kernel Space                │
│  ┌──────────┐                  ┌──────────────┐            │
│  │   Vim    │                  │  SquireOS    │            │
│  │ Editor   │◄────────────────►│   Modules    │            │
│  └──────────┘                  └──────┬───────┘            │
│       ▲                               │                     │
│       │                               ▼                     │
│  ┌──────────┐                  ┌──────────────┐            │
│  │   Menu   │                  │    /proc     │            │
│  │  System  │◄────────────────►│  Interface   │            │
│  └──────────┘                  └──────┬───────┘            │
│                                       │                     │
│  Minimal Debian                       ▼                     │
│  Rootfs (31MB)                 ┌──────────────┐            │
│                                │ Linux Kernel │            │
│                                │    2.6.29    │            │
│                                └──────┬───────┘            │
│                                       │                     │
│                                       ▼                     │
│                                ┌──────────────┐            │
│                                │   Android    │            │
│                                │  Bootloader  │            │
│                                └──────────────┘            │
└─────────────────────────────────────────────────────────────┘
```

### Component Layers

1. **Bootloader**: Stock Android bootloader (U-Boot based)
2. **Kernel**: Custom Linux 2.6.29 with SquireOS modules
3. **Root Filesystem**: Minimal Debian Bullseye (31MB)
4. **User Interface**: Vim + custom menu system

## 🚀 Quick Start

### Prerequisites
```bash
# Required tools
docker --version  # Docker 20.10+
git --version     # Git 2.25+
sudo access       # For SD card operations

# For native builds (optional)
arm-linux-gnueabi-gcc --version  # ARM cross-compiler
```

### Clone and Build
```bash
# Clone repository with submodules
git clone --recursive https://github.com/yourusername/nook-typewriter.git
cd nook-typewriter

# Build kernel and modules
./build_kernel.sh

# Build root filesystem
docker build -t nook-mvp-rootfs -f minimal-boot.dockerfile .

# Package rootfs
docker create --name nook-export nook-mvp-rootfs
docker export nook-export | gzip > nook-mvp-rootfs.tar.gz
docker rm nook-export
```

## 🛠️ Development Setup

### Docker Build Environment

The project uses Docker for consistent cross-compilation:

```dockerfile
# quillkernel/Dockerfile
FROM ubuntu:20.04
# Installs Android NDK r10e for ARM cross-compilation
# Sets up build environment with kernel 2.6.29 support
```

Build the Docker environment:
```bash
cd quillkernel
docker build -t quillkernel-builder .
```

### Local Development

For local development without Docker:

```bash
# Install ARM toolchain
sudo apt-get install gcc-arm-linux-gnueabi

# Set environment variables
export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabi-

# Build kernel
cd nst-kernel-base/src
make omap3621_gossamer_evt1c_defconfig
make -j$(nproc) uImage
```

## 🔨 Build System

### Kernel Build Process

```bash
# Main build script
./build_kernel.sh

# What it does:
# 1. Configures kernel for Nook hardware
# 2. Enables SquireOS modules
# 3. Compiles kernel to uImage
# 4. Builds kernel modules (.ko files)
```

### Module Integration

SquireOS modules are integrated into the kernel build system:

```makefile
# nst-kernel-base/src/drivers/Makefile
obj-$(CONFIG_SQUIREOS) += ../../../../quillkernel/modules/

# nst-kernel-base/src/drivers/Kconfig
source "drivers/Kconfig.squireos"
```

### Configuration Options

```kconfig
# drivers/Kconfig.squireos
menuconfig SQUIREOS
    tristate "SquireOS Medieval Interface"
    
config SQUIREOS_JESTER
    bool "Enable Court Jester companion"
    
config SQUIREOS_TYPEWRITER
    bool "Enable typewriter statistics"
    
config SQUIREOS_WISDOM
    bool "Enable writing wisdom quotes"
```

## 🎭 Kernel Modules

### Module Overview

| Module | Purpose | /proc Interface |
|--------|---------|-----------------|
| `squireos_core.c` | Base module, creates /proc/squireos | `/proc/squireos/motto` |
| `jester.c` | ASCII art jester with moods | `/proc/squireos/jester` |
| `typewriter.c` | Keystroke and word tracking | `/proc/squireos/typewriter/stats` |
| `wisdom.c` | Rotating writing quotes | `/proc/squireos/wisdom` |

### Module Development

Example module structure:
```c
// squireos_core.c
#include <linux/module.h>
#include <linux/proc_fs.h>

static struct proc_dir_entry *squireos_root;

static int __init squireos_init(void) {
    squireos_root = proc_mkdir("squireos", NULL);
    // Create proc entries
    return 0;
}

static void __exit squireos_exit(void) {
    remove_proc_entry("squireos", NULL);
}

module_init(squireos_init);
module_exit(squireos_exit);
MODULE_LICENSE("GPL");
```

### Testing Modules

```bash
# User-space testing
./test/test_modules.sh

# Load modules on device
insmod /lib/modules/squireos_core.ko
insmod /lib/modules/jester.ko

# Verify
cat /proc/squireos/jester
```

## 🧪 Testing

### Test Suite

```bash
# Run all tests
./tests/run-tests.sh

# Individual test categories
./tests/test-docker-build.sh    # Docker build verification
./tests/test-vim-modes.sh       # Vim configuration
./tests/test-health-check.sh    # System health
./tests/test-plugin-system.sh   # Plugin architecture
```

### Module Testing

```bash
# Test kernel modules
./test/test_modules.sh

# Check module syntax
gcc -fsyntax-only -D__KERNEL__ -DMODULE quillkernel/modules/*.c
```

### Hardware Testing

```bash
# Verify SD card
./scripts/verify-sd-card.sh

# Mount test
./mount_sdcard_helper.sh detect
./mount_sdcard_helper.sh mount /dev/sdX
```

## 📦 Deployment

### SD Card Preparation

```bash
# 1. Prepare SD card (WARNING: Erases SD card!)
sudo ./prepare_sdcard.sh

# 2. Mount partitions
sudo ./mount_sde.sh

# 3. Install QuillKernel
sudo ./install_to_sdcard.sh

# 4. Unmount safely
sync
sudo umount /mnt/nook_boot /mnt/nook_root
```

### Boot Process

1. Insert SD card into Nook
2. Hold page-turn buttons while powering on
3. QuillKernel boots from SD card
4. Jester appears on E-Ink display
5. Menu system launches

## 📁 Project Structure

```
nook-typewriter/
├── quillkernel/              # QuillKernel specific code
│   ├── modules/              # Kernel modules (C)
│   │   ├── squireos_core.c   # Base module
│   │   ├── jester.c          # ASCII jester
│   │   ├── typewriter.c      # Stats tracking
│   │   └── wisdom.c          # Quote system
│   ├── Dockerfile            # Build environment
│   └── build.sh              # Build script
├── nst-kernel-base/          # Kernel source (submodule)
│   ├── src/                  # Linux 2.6.29 source
│   └── build/                # Build configs
├── config/                   # Configuration files
│   ├── scripts/              # System scripts
│   │   ├── nook-menu.sh      # Main menu
│   │   └── boot-jester.sh    # Boot animations
│   └── vim/                  # Vim configuration
├── tests/                    # Test suite
├── scripts/                  # Build & utility scripts
├── boot/                     # Boot configurations
└── docs/                     # Documentation
```

## 🤝 Contributing

### Development Workflow

1. **Fork** the repository
2. **Create** feature branch: `git checkout -b feature-name`
3. **Test** your changes thoroughly
4. **Document** any new features
5. **Submit** pull request

### Code Standards

- **C Kernel Code**: Follow Linux kernel coding style
- **Shell Scripts**: Use ShellCheck for validation
- **Memory**: Every byte matters - optimize aggressively
- **E-Ink**: Minimize screen refreshes

### Testing Requirements

- All modules must compile without warnings
- Memory usage must stay under limits
- E-Ink compatibility must be maintained
- Medieval theme must be preserved 🏰

## 🔧 Troubleshooting

### Common Issues

#### Kernel Build Fails
```bash
# Check Docker image
docker images | grep quillkernel-builder

# Rebuild if needed
cd quillkernel && docker build -t quillkernel-builder .
```

#### SD Card Mount Errors
```bash
# Check filesystem
sudo fsck.vfat -r /dev/sdeX

# Reformat if corrupted
sudo mkfs.vfat -F 16 -n NOOK_BOOT /dev/sde1
```

#### Module Load Failures
```bash
# Check kernel version match
uname -r
modinfo squireos_core.ko

# Check dmesg for errors
dmesg | tail -20
```

### Debug Tools

```bash
# Kernel messages
dmesg | grep squireos

# Module information
lsmod | grep squireos

# Process filesystem
ls -la /proc/squireos/
```

## 📚 Additional Resources

- [Original Nook Kernel](https://github.com/felixhaedicke/nst-kernel) - Base kernel source
- [Linux 2.6.29 Documentation](https://www.kernel.org/doc/html/v2.6.29/) - Kernel API reference
- [E-Ink Programming Guide](docs/eink-guide.md) - Display optimization
- [Medieval Theme Guide](docs/medieval-theme.md) - Maintaining the aesthetic

## 📄 License

This project is licensed under GPL v2 - see [LICENSE](LICENSE) file for details.

## 🏆 Credits

- **felixhaedicke** - Original NST kernel work
- **NiLuJe** - FBInk E-Ink library
- **Barnes & Noble** - Original Nook hardware
- **The Medieval Jester** - Inspiration and companionship

---

*"By quill and compiler, we craft digital magic!"* 🪶✨

## 🚦 Current Status

- [x] Kernel module development
- [x] Docker build environment
- [x] Minimal root filesystem
- [x] SD card installation scripts
- [ ] Hardware testing on actual Nook
- [ ] Writing application integration
- [ ] Power management optimization
- [ ] Release packaging

---

**For Writers, By Developers** | **Vim + E-Ink = ❤️** | **Medieval Computing Since 2024**