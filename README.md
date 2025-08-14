# 🎭 JoKernel - Nook Typewriter Project
### Transform Your E-Reader into a Distraction-Free Writing Machine

## 📚 Complete Documentation
**[→ View Master Index](MASTER_INDEX.md)** - Comprehensive documentation hub with 40+ guides, references, and procedures

## 📋 Table of Contents
- [Project Overview](#project-overview)
- [Key Features](#key-features)
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
- [Documentation](#documentation)

## 🎯 Project Overview

JoKernel transforms a $20 used Barnes & Noble Nook Simple Touch e-reader into a $400 distraction-free writing device. By combining a custom Linux kernel with jester-themed interface elements, this project creates the ultimate digital typewriter for focused writing.

### Project Philosophy
> "Every feature is a potential distraction. RAM saved is words written."

This project prioritizes **writers over features**, maintaining a sacred 160MB of RAM exclusively for the writing experience while running the entire OS in less than 96MB.

## ✨ Key Features

### Core Functionality
- **Distraction-Free Writing** - No internet, no notifications, just words
- **Jester-Themed Interface** - ASCII art jester companion with dynamic moods
- **Writing Statistics** - Track words, keystrokes, and writing achievements
- **Ultra-Minimal Footprint** - <30MB compressed rootfs, <96MB runtime
- **E-Ink Optimized** - Interface designed for E-Ink's unique characteristics

### Technical Achievements
- **JesterOS Userspace** - Lightweight userspace services via `/var/jesteros/` interface
- **Docker-Based Build** - Consistent cross-compilation environment
- **Comprehensive Testing** - 90%+ test coverage with safety validations
- **Script Safety** - Input validation, error handling, path protection
- **Memory Efficiency** - Aggressive optimization for 256MB constraint

### Target Hardware
- **Device**: Barnes & Noble Nook Simple Touch
- **CPU**: TI OMAP3621 @ 800MHz (ARM Cortex-A8)
- **RAM**: 256MB (160MB reserved for writing)
- **Display**: 6" E-Ink (800x600, 16-level grayscale)
- **Storage**: 2GB internal + SD card slot

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     JoKernel Stack                           │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  User Space                     Kernel Space                │
│  ┌──────────┐                  ┌──────────────┐            │
│  │   Vim    │                  │  JesterOS    │            │
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
2. **Kernel**: Custom Linux 2.6.29 with JesterOS modules
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

# Clean build attempt
./build_kernel.sh clean
./build_kernel.sh
```

#### SD Card Mount Errors
```bash
# Check filesystem
sudo fsck.vfat -r /dev/sdX1

# Reformat if corrupted
sudo mkfs.vfat -F 16 -n NOOK_BOOT /dev/sdX1
sudo mkfs.ext4 -L NOOK_ROOT /dev/sdX2
```

#### Module Load Failures
```bash
# Check kernel version match
uname -r
modinfo squireos_core.ko

# Check dmesg for errors
dmesg | grep squireos

# Manual module loading sequence
insmod /lib/modules/2.6.29/squireos_core.ko
insmod /lib/modules/2.6.29/jester.ko
insmod /lib/modules/2.6.29/typewriter.ko
insmod /lib/modules/2.6.29/wisdom.ko
```

#### Memory Issues
```bash
# Check current usage
free -h
cat /proc/meminfo

# Verify sacred writing space
df -h /root/notes
```

### Debug Tools

```bash
# Kernel messages
dmesg | grep squireos

# Module information
lsmod | grep squireos

# Process filesystem
ls -la /proc/squireos/
cat /proc/squireos/jester
cat /proc/squireos/typewriter/stats

# System health check
./source/scripts/services/health-check.sh
```

## 📚 Documentation

### 🎯 Quick Access
- **[MASTER_INDEX.md](MASTER_INDEX.md)** - Complete documentation hub (40+ files)
- **[QUICK_START.md](QUICK_START.md)** - Get started in 5 minutes
- **[PROJECT_INDEX_COMPLETE.md](PROJECT_INDEX_COMPLETE.md)** - Full project structure
- **[CLAUDE.md](CLAUDE.md)** - Development philosophy and guidelines

### 📖 Core Documentation

#### Kernel & Modules
- **[Kernel Documentation](docs/kernel-reference/KERNEL_DOCUMENTATION.md)** - Complete JoKernel/JesterOS reference
- **[Kernel API Reference](docs/KERNEL_API_REFERENCE.md)** - Module development guide
- **[Module Quick Reference](docs/MODULE_API_QUICK_REFERENCE.md)** - API quick reference
- **[Kernel Build Guide](docs/KERNEL_BUILD_EXPLAINED.md)** - Build process explained

#### Build & Development
- **[Build System Documentation](docs/BUILD_SYSTEM_DOCUMENTATION.md)** - Docker & compilation
- **[Scripts Catalog](docs/SCRIPTS_CATALOG.md)** - All shell scripts documented
- **[Source API Reference](docs/SOURCE_API_REFERENCE.md)** - Complete API documentation

#### Configuration & Deployment
- **[Configuration Reference](docs/CONFIGURATION_REFERENCE.md)** - All config files
- **[Deployment Documentation](docs/DEPLOYMENT_DOCUMENTATION.md)** - Installation methods
- **[SD Card Deployment](docs/deployment/XDA_DEPLOYMENT_METHOD.md)** - XDA method

#### Testing & Quality
- **[Test Suite Documentation](docs/TEST_SUITE_DOCUMENTATION.md)** - Complete test coverage
- **[Testing Procedures](docs/TESTING_PROCEDURES.md)** - Test procedures
- **[Developer Testing Guide](docs/DEVELOPER_TESTING_GUIDE.md)** - Testing guidelines

#### Design & UI
- **[ASCII Art Advanced](docs/ASCII_ART_ADVANCED.md)** - Jester art guide
- **[UI Components](docs/ui-components-design.md)** - Interface design
- **[Style Guide](docs/QUILLOS_STYLE_GUIDE.md)** - Medieval theme guide

### 📚 Technical References
- **[Linux 2.6.29 Quick Reference](docs/kernel-reference/QUICK_REFERENCE_2.6.29.md)**
- **[Proc Filesystem Guide](docs/kernel-reference/proc-filesystem-2.6.29.md)**
- **[ARM Memory Management](docs/kernel-reference/memory-management-arm-2.6.29.md)**
- **[Module Building Guide](docs/kernel-reference/module-building-2.6.29.md)**

### 🔗 External Resources
- [Original Nook Kernel](https://github.com/felixhaedicke/nst-kernel) - Base kernel source
- [Linux 2.6.29 Documentation](https://www.kernel.org/doc/html/v2.6.29/) - Kernel API reference
- [FBInk Library](https://github.com/NiLuJe/FBInk) - E-Ink display interface
- [XDA Forum Thread](docs/XDA-RESEARCH-FINDINGS.md) - Community research

## 📄 License

This project is licensed under GPL v2 - see [LICENSE](LICENSE) file for details.

## 🏆 Credits

- **Felix Hädicke** - Original NST kernel foundation
- **NiLuJe** - FBInk E-Ink library
- **XDA Community** - Research and guidance
- **Barnes & Noble** - Original Nook hardware
- **Medieval Scribes** - Eternal inspiration
- **The Court Jester** - Digital companionship

---

*"By quill and compiler, we craft digital magic!"* 🪶✨

## 🚦 Current Status

### Completed ✅
- [x] Kernel module architecture with `/proc/squireos/` interface
- [x] Docker-based cross-compilation environment
- [x] Minimal root filesystem (<30MB compressed)
- [x] Comprehensive test suite (90%+ coverage)
- [x] Script safety improvements (input validation, error handling)
- [x] SD card installation scripts
- [x] ASCII art jester with mood system
- [x] Writing statistics tracking

### In Progress 🔄
- [ ] Hardware testing on actual Nook device
- [ ] Vim writing environment integration
- [ ] Power management optimization

### Future Plans 📅
- [ ] Spell checker integration
- [ ] Thesaurus support
- [ ] Advanced writing analytics
- [ ] Battery life optimization to 2+ weeks
- [ ] Release packaging and distribution

---

**For Writers, By Developers** | **Vim + E-Ink = ❤️** | **Medieval Computing Since 2024**