# 📚 Nook Typewriter Project Structure

*Transform a $20 e-reader into a distraction-free writing device*

**Version**: 1.0.0  
**Updated**: December 2024  
**Kernel**: Linux 2.6.29 with JesterOS modules

---

## 🎯 Quick Navigation

| Directory | Purpose | Key Files |
|-----------|---------|-----------|
| [/](#root-directory) | Project root with essential configs | Makefile, README.md, CLAUDE.md |
| [build/](#build) | Build system and scripts | Docker configs, build scripts |
| [source/](#source) | Source code and kernel | kernel/, scripts/, configs/ |
| [tests/](#tests) | Test suite and validation | Unit tests, integration tests |
| [docs/](#docs) | Documentation | Guides, references, APIs |
| [tools/](#tools) | Utilities and maintenance | Deployment, maintenance scripts |

---

## 📁 Directory Structure

```
nook/
├── boot/                    # Boot configuration files
├── build/                   # Build system
├── cwm_package/            # ClockworkMod recovery package
├── data/                   # Runtime data directory
├── deployment_package/     # Deployment artifacts
├── design/                 # Architecture and design docs
├── docs/                   # Documentation
├── firmware/               # Firmware binaries and modules
├── images/                 # SD card and boot images
├── releases/               # Release packages
├── scripts/                # Utility scripts
├── source/                 # Source code
├── tests/                  # Test suite
└── tools/                  # Development tools
```

---

## 🏠 Root Directory

Essential project files and configurations.

```
/
├── README.md               # Project introduction and philosophy
├── CLAUDE.md              # AI assistant instructions
├── LICENSE                # GPL v2 license
├── VERSION                # Current version (1.0.0)
├── Makefile               # Main build system
├── QUICK_START.md         # Getting started guide
├── build.conf             # Build configuration
├── project.conf           # Project settings
├── lenny-rootfs.tar.gz   # Debian Lenny rootfs archive
└── nook-mvp-rootfs.tar.gz # Minimal viable rootfs
```

### Key Commands
- `make firmware` - Build complete system
- `make sd-deploy` - Deploy to SD card
- `make quick-build` - Fast incremental build
- `make detect-sd` - Find SD card devices

---

## 🔨 build/

Build system with Docker support and compilation scripts.

```
build/
├── docker/                 # Docker configurations
│   ├── kernel-xda-proven.dockerfile
│   ├── minimal-boot.dockerfile
│   └── nookwriter-optimized.dockerfile
└── scripts/               # Build automation
    ├── build_kernel.sh    # Main kernel builder
    ├── build-lenny-rootfs.sh # Rootfs creation
    ├── create-mvp-sd.sh   # SD card image creator
    ├── create_deployment.sh
    └── deploy_to_nook.sh
```

### Build Workflow
1. `build_kernel.sh` - Compiles kernel with JesterOS modules
2. `build-lenny-rootfs.sh` - Creates Debian Lenny base
3. `create-mvp-sd.sh` - Generates bootable SD image

---

## 💻 source/

Core source code including kernel, scripts, and configurations.

```
source/
├── kernel/                # Linux 2.6.29 + JesterOS
│   ├── src/              # Kernel source tree
│   ├── jokernel/         # JokerOS legacy modules
│   ├── quillkernel/      # QuillKernel writing features
│   └── test/             # Kernel tests
├── scripts/              # System scripts
│   ├── boot/             # Boot sequence
│   ├── menu/             # Menu system
│   ├── services/         # Background services
│   └── lib/              # Shared libraries
├── configs/              # Configuration files
│   ├── ascii/            # ASCII art collections
│   ├── vim/              # Vim configurations
│   ├── system/           # System configs
│   └── services/         # Service definitions
└── ui/                   # User interface
    ├── components/       # UI components
    ├── layouts/          # Screen layouts
    └── themes/           # Visual themes
```

### JesterOS Modules
- **jester** - ASCII art mood system
- **typewriter** - Keystroke tracking
- **wisdom** - Writing quotes

---

## 🧪 tests/

Comprehensive test suite for validation and quality assurance.

```
tests/
├── unit/                  # Unit tests by component
│   ├── boot/             # Boot script tests
│   ├── kernel/           # Kernel module tests
│   ├── menu/             # Menu system tests
│   └── modules/          # Module tests
├── integration/          # Integration tests
├── memory-profiles/      # Memory usage profiles
├── reports/              # Test reports
├── test-jesteros-*.sh    # JesterOS tests
├── smoke-test.sh         # Quick validation
├── pre-flight.sh         # Pre-deployment checks
└── run-all-tests.sh      # Complete test suite
```

### Test Categories
- **Kernel Safety** - Module loading, API compatibility
- **Memory Tests** - RAM usage validation
- **UI Tests** - Menu and display verification
- **Boot Tests** - Startup sequence validation

---

## 📖 docs/

Project documentation and references.

```
docs/
├── kernel/               # Kernel documentation
│   ├── KERNEL_BUILD_REFERENCE.md
│   ├── KERNEL_INTEGRATION_GUIDE.md
│   └── KERNEL_FEATURE_PLAN.md
├── guides/               # User guides
│   ├── QUICK_BOOT_GUIDE.md
│   └── BUILD_INFO
├── kernel-reference/     # Linux 2.6.29 references
│   ├── KERNEL_DOCUMENTATION.md
│   ├── module-building-2.6.29.md
│   └── proc-filesystem-2.6.29.md
├── deployment/           # Deployment guides
├── *.md                  # Various documentation files
└── archive/              # Archived docs
```

### Key Documentation
- Boot guides and troubleshooting
- Build system documentation
- API references
- Testing procedures

---

## 🛠️ tools/

Development and maintenance utilities.

```
tools/
├── maintenance/          # System maintenance
│   ├── cleanup_nook_project.sh
│   ├── fix-boot-loop.sh
│   └── install-jesteros-userspace.sh
├── deploy/               # Deployment tools
│   └── flash-sd.sh
├── debug/                # Debugging utilities
├── test/                 # Testing tools
├── windows-*.ps1         # Windows PowerShell scripts
└── wsl-mount-usb.sh      # WSL USB mounting
```

---

## 💾 firmware/

Compiled firmware and runtime files.

```
firmware/
├── boot/                 # Boot images
│   ├── uImage           # Kernel image
│   └── uEnv.txt         # Boot environment
├── bootloaders/          # Bootloader files
│   └── NookManager.img
├── kernel/               # Kernel modules
│   └── modules/         # Loadable modules
└── rootfs/              # Root filesystem
    ├── bin/             # Binaries
    ├── etc/             # Configuration
    └── usr/             # User programs
```

---

## 🚀 Deployment

### SD Card Structure
```
/dev/sde (or similar)
├── partition 1 (boot)    # FAT32, bootloader + kernel
│   ├── uImage
│   ├── uEnv.txt
│   └── MLO
└── partition 2 (root)    # ext3, Linux rootfs
    └── [extracted rootfs]
```

### Quick Deploy
```bash
# Auto-detect and deploy
make sd-deploy

# Specific device
make sd-deploy SD_DEVICE=/dev/sde
```

---

## 🎮 Key Scripts

### Boot Scripts (`source/scripts/boot/`)
- `jesteros-userspace.sh` - Main JesterOS launcher
- `squireos-init.sh` - System initialization
- `jester-splash.sh` - Boot splash screen

### Menu System (`source/scripts/menu/`)
- `nook-menu.sh` - Main menu interface
- `squire-menu.sh` - Writing environment menu

### Services (`source/scripts/services/`)
- `jester-daemon.sh` - Mood monitoring
- `jesteros-tracker.sh` - Statistics tracking

---

## 📊 Project Statistics

- **Kernel**: Linux 2.6.29 (March 2009 vintage)
- **Target Device**: Barnes & Noble Nook Simple Touch
- **Architecture**: ARM (OMAP3)
- **RAM Budget**: 256MB total (96MB OS, 160MB writing)
- **Display**: 6" E-Ink (800x600, 16 grayscale)
- **Storage**: SD card based

---

## 🏰 Philosophy

> "Every feature is a potential distraction"  
> "RAM saved is words written"  
> "E-Ink limitations are features"  
> "By quill and candlelight, we code for those who write"

---

*Generated with [Claude Code](https://claude.ai/code)*