# Nook Typewriter Project Index

**Last Updated**: August 11, 2024  
**Status**: Active Development - QuillKernel Integration Phase

## 📚 Table of Contents

1. [Project Overview](#project-overview)
2. [Directory Structure](#directory-structure)
3. [Core Components](#core-components)
4. [QuillKernel (NEW)](#quillkernel-new)
5. [Docker Images](#docker-images)
6. [Configuration Files](#configuration-files)
7. [Scripts & Tools](#scripts--tools)
8. [Documentation](#documentation)
9. [Testing Suite](#testing-suite)
10. [Development Branches](#development-branches)

---

## Project Overview

Transform a $20 Barnes & Noble Nook Simple Touch into a distraction-free digital typewriter with custom Linux kernel, medieval theming, and optimized writing software.

### Key Features
- **QuillKernel**: Custom Linux 2.6.29 kernel with medieval theming
- **SquireOS**: Debian Linux optimized for 256MB RAM
- **E-Ink Support**: FBInk driver for proper display control
- **USB Keyboard**: Full keyboard support via USB OTG
- **Medieval Theme**: Court jester companion and whimsical elements

### Hardware Target
- Device: Barnes & Noble Nook Simple Touch (BNRV300)
- CPU: 800 MHz ARM (OMAP3621)
- RAM: 256MB (160MB reserved for writing)
- Display: 6" E-Ink (800x600, 16 grayscale)
- Firmware: Compatible with 1.2.x

---

## Directory Structure

```
nook/
├── quillkernel/              # NEW: Clean kernel implementation
│   ├── modules/              # Medieval kernel modules (C code)
│   ├── Dockerfile            # Build environment
│   └── build.sh              # One-command builder
│
├── nst-kernel-base/          # Felixhaedicke kernel (git submodule)
│   ├── src/                  # Kernel source
│   └── build/                # Pre-built uImage
│
├── config/                   # System configuration
│   ├── scripts/              # Menu and boot scripts
│   ├── system/               # OS branding files
│   ├── vim/                  # Vim configurations
│   └── plugins/              # Plugin system
│
├── images/                   # Disk images
│   ├── NookManager.img       # Rooting tool
│   └── 2gb_clockwork-rc2.img # Recovery image
│
├── tests/                    # Test suite
├── scripts/                  # Build and deploy scripts
└── docs/                     # Documentation
```

---

## Core Components

### 1. Operating System Base
- **File**: `nookwriter-optimized.dockerfile`
- **Base**: Debian Bullseye (slim)
- **Size**: ~30MB compressed
- **Features**: Minimal Linux with vim, busybox, rsync

### 2. Boot System
- **Location**: `config/scripts/`
- **Main Menu**: `nook-menu.sh`
- **Boot Sequence**: `squireos-boot.sh`
- **Jester**: `jester-daemon.sh`, `jester-splash.sh`

### 3. Writing Environment
- **Editor**: Vim with Goyo and Pencil plugins
- **Config**: `config/vimrc-writer`
- **Modes**: Minimal (2MB RAM) or Writer (5MB RAM)

---

## QuillKernel (NEW)

### Overview
Clean kernel implementation replacing the previous patch-based approach.

### Components

#### Kernel Base
- **Source**: `nst-kernel-base/` (git submodule)
- **Origin**: github.com/felixhaedicke/nst-kernel
- **Features**: USB host mode, fast E-ink display
- **Version**: Linux 2.6.29 for Nook firmware 1.2.x

#### Medieval Modules (`quillkernel/modules/`)
1. **squireos_core.c**
   - Creates `/proc/squireos/` filesystem
   - Provides version and motto interfaces
   - Base for other modules

2. **jester.c**
   - ASCII art court jester at `/proc/squireos/jester`
   - Dynamic moods: happy, sleepy, excited, thoughtful, mischievous
   - Changes based on system state

3. **typewriter.c**
   - Keystroke tracking at `/proc/squireos/typewriter/stats`
   - Word counting algorithm
   - Achievement system (Apprentice → Grand Chronicler)
   - Session management

4. **wisdom.c**
   - Writing quotes at `/proc/squireos/wisdom`
   - 25+ quotes from famous authors
   - Rotates on each read

#### Build System
- **Docker**: Ubuntu 20.04 with Android NDK r10e
- **Toolchain**: ARM cross-compiler (GCC 4.8)
- **Script**: `quillkernel/build.sh` - one-command build

---

## Docker Images

### Current Images

1. **nookwriter-optimized**
   - File: `nookwriter-optimized.dockerfile`
   - Purpose: Minimal writing environment
   - Build modes: minimal (2MB) or writer (5MB)

2. **quillkernel-builder**
   - File: `quillkernel/Dockerfile`
   - Purpose: Kernel compilation environment
   - Includes: Android NDK, cross-compilation tools

### Build Commands
```bash
# Build writing environment
docker build -f nookwriter-optimized.dockerfile -t nook-writer .

# Build kernel
cd quillkernel && ./build.sh
```

---

## Configuration Files

### System Branding (`config/system/`)
- `os-release` - SquireOS identification
- `motd` - Medieval message of the day
- `issue` - Login banner with jester

### Vim Configurations (`config/`)
- `vimrc` - Base configuration
- `vimrc-minimal` - Ultra-light (no plugins)
- `vimrc-writer` - Writing optimized (Goyo+Pencil)
- `vimrc-zk` - Zettelkasten mode

### Scripts (`config/scripts/`)
- `nook-menu.sh` - Main interactive menu
- `boot-jester.sh` - Boot sequence with jester
- `sync-notes.sh` - Cloud synchronization
- `health-check.sh` - System health monitoring

---

## Scripts & Tools

### Deployment
- `deploy-to-nook.sh` - Deploy to SD card
- `fix-nook-boot.sh` - Fix boot issues
- `troubleshoot-sd.sh` - SD card diagnostics

### Testing
- `tests/run-tests.sh` - Complete test suite
- `test-jester.sh` - Jester functionality
- `test-vim-plugins.sh` - Plugin verification

### Build Tools
- `scripts/build-rootfs.sh` - Rootfs creation
- `scripts/verify-sd-card.sh` - SD validation

---

## Documentation

### Primary Docs
- `README.md` - Project overview and quick start
- `CLAUDE.md` - Development guidelines and philosophy
- `PROJECT_INDEX.md` - This file
- `ARCHITECTURE_ANALYSIS.md` - System architecture

### Specialized Docs
- `WINDOWS-SD-SETUP.md` - Windows SD card setup
- `CLEANUP_PLAN.md` - Code cleanup strategy
- `QUALITY_ANALYSIS_REPORT.md` - Code quality metrics

### QuillKernel Docs
- `quillkernel/README.md` - Kernel documentation
- `nst-kernel-base/README.md` - Base kernel info

---

## Testing Suite

### Test Categories
1. **Docker Build** - Container compilation
2. **Health Check** - System monitoring
3. **Plugin System** - Extension validation
4. **Vim Modes** - Editor configurations
5. **Maintainability** - Code quality

### QuillKernel Tests (Planned)
- Kernel module loading
- /proc interface validation
- Typewriter statistics tracking
- Jester mood transitions

---

## Development Branches

### Current Branch
- `mali1-kernel-integration` - QuillKernel development

### Git Submodules
- `nst-kernel-base` → github.com/felixhaedicke/nst-kernel

### Previous Work (Archived)
- Old patch-based kernel approach removed
- Medieval features reimplemented as proper kernel modules

---

## Project Status

### Completed ✅
- [x] QuillKernel structure created
- [x] Medieval kernel modules implemented
- [x] Docker build environment setup
- [x] Clean kernel base integrated
- [x] /proc/squireos interface designed

### In Progress 🔄
- [ ] Kernel compilation testing
- [ ] Module integration with kernel
- [ ] Android/Linux chroot setup

### Upcoming 📋
- [ ] Deploy to actual Nook hardware
- [ ] Performance optimization
- [ ] Battery life testing
- [ ] User documentation

---

## Quick Commands

```bash
# Build everything
cd quillkernel && ./build.sh

# Run tests
tests/run-tests.sh

# Deploy to Nook
./deploy-to-nook.sh

# Check project health
./tests/test-maintainability.sh
```

---

## Philosophy Reminder

> "Every feature serves writers. No distractions, just words and whimsy."

*By quill and candlelight, we code for those who write* 🕯️📜