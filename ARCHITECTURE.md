# JesterOS Architecture Documentation

# JoKernel 4-Layer Architecture

## Architecture Evolution

The project has evolved from a 5-layer architecture to a cleaner **4-layer architecture** that reflects the actual implementation: **purely userspace services** without kernel modules.

### Why 4 Layers Instead of 5?

**Original Plan**: Custom kernel modules with `/proc/squireos/` interface
**Actual Implementation**: Userspace services with `/var/jesteros/` interface

This change reflects the project philosophy:
- **Writers over features** - No kernel compilation complexity
- **Simplicity over completeness** - Works perfectly in userspace
- **Reality over aspiration** - Document what actually exists

## The 4-Layer Architecture

```
┌─────────────────────────────────────────────────────────┐
│                 Layer 1: User Interface                  │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │   Vim UI    │  │  Menu System │  │ Jester ASCII │  │
│  │  (Writing)  │  │   (nook-     │  │  Animations  │  │
│  │             │  │   menu.sh)   │  │              │  │
│  └─────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────┐
│            Layer 2: Application Services                 │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │  JesterOS   │  │   Writing    │  │  Statistics  │  │
│  │  (Moods,    │  │   Modes      │  │  (Words,     │  │
│  │   Quotes)   │  │  (Draft/ZK)  │  │   Keystrokes)│  │
│  └─────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────┐
│              Layer 3: System Services                    │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │   Common    │  │  File System │  │   Process    │  │
│  │  Libraries  │  │   Manager    │  │   Manager    │  │
│  │             │  │              │  │              │  │
│  └─────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────┐
│            Layer 4: Hardware Abstraction                 │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │   E-Ink     │  │     USB      │  │    Power     │  │
│  │   Display   │  │   Keyboard   │  │  Management  │  │
│  └─────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
```

## Layer Descriptions

### Layer 1: User Interface (UI)
**Purpose**: Everything the user sees and interacts with
**Components**:
- Menu systems (`nook-menu.sh`)
- Vim interface and plugins
- ASCII art and themes
- User prompts and displays

**Dependencies**: Can call Layers 2, 3, 4

### Layer 2: Application Services
**Purpose**: Business logic and application features
**Components**:
- JesterOS services (mood, stats, quotes)
- Writing modes and workflows
- Statistics tracking
- Service daemons

**Dependencies**: Can call Layers 3, 4

### Layer 3: System Services
**Purpose**: Core system functionality and utilities
**Components**:
- Common libraries (`common.sh`, `service-functions.sh`)
- File system operations
- Process management
- Error handling

**Dependencies**: Can call Layer 4

### Layer 4: Hardware Abstraction
**Purpose**: Direct hardware interface and control
**Components**:
- E-Ink display control (FBInk wrapper)
- USB keyboard detection
- Power/battery management
- Hardware-specific optimizations

**Dependencies**: None (bottom layer)

## Directory Structure

```
runtime/
├── 1-ui/                  # User Interface Layer
│   ├── menu/              # Menu system scripts
│   ├── display/           # Display components
│   └── themes/            # ASCII art, themes
│
├── 2-application/         # Application Services Layer  
│   ├── jesteros/          # JesterOS services
│   │   ├── mood.sh        # Mood selector
│   │   ├── daemon.sh      # Main daemon
│   │   └── tracker.sh     # Stats tracking
│   ├── writing/           # Writing-specific services
│   └── stats/             # Statistics services
│
├── 3-system/              # System Services Layer
│   ├── display/           # Display management
│   ├── filesystem/        # File operations
│   ├── process/           # Process control
│   └── common/            # Shared libraries
│
├── 4-hardware/            # Hardware Abstraction Layer
│   ├── eink/              # E-Ink specific code
│   ├── usb/               # USB/keyboard handling
│   └── power/             # Power management
│
├── configs/               # Configuration files
│   ├── system/            # System configs
│   ├── services/          # Service configs
│   └── vim/               # Editor configs
│
└── init/                  # Boot/initialization
    ├── boot.sh            # Main boot script
    └── chroot.sh          # Chroot transition
```

## Dependency Rules

### Allowed Dependencies
- **Layer 1 → Layers 2, 3, 4** ✅
- **Layer 2 → Layers 3, 4** ✅
- **Layer 3 → Layer 4** ✅
- **Layer 4 → None** ✅

### Forbidden Dependencies
- **Layer 4 → Any layer** ❌ (bottom layer)
- **Layer 3 → Layers 1, 2** ❌
- **Layer 2 → Layer 1** ❌
- **Any circular dependencies** ❌

## Why This Architecture Works

### 1. **Reflects Reality**
- No phantom kernel layer for modules that don't exist
- Userspace implementation is accurately represented
- Clear separation between what exists and what doesn't

### 2. **Simpler to Understand**
- 4 layers are easier to grasp than 5
- Each layer has a clear, distinct purpose
- Dependencies flow in one direction only

### 3. **Easier to Maintain**
- No confusion about missing kernel modules
- Clear where new features belong
- Obvious impact analysis for changes

### 4. **Aligned with Philosophy**
- **Writers over features**: No unnecessary complexity
- **Userspace focus**: Avoids kernel compilation
- **Practical approach**: Works on actual hardware

## Migration from 5-Layer to 4-Layer

### Simple Migration Steps

```bash
# 1. Rename Layer 5 to Layer 4
mv runtime/5-hardware runtime/4-hardware

# 2. Remove empty kernel layer
rm -rf runtime/4-kernel

# 3. Update any remaining references
find runtime -name "*.sh" -exec grep -l "4-kernel\|5-hardware" {} \;
# Update these to reference 4-hardware instead
```

### What Changes
- `5-hardware/` becomes `4-hardware/`
- References to "5 layers" become "4 layers"
- Kernel interface documentation removed

### What Stays the Same
- All functionality remains identical
- No code changes required
- Services continue working as before

## Implementation Notes

### JesterOS in Userspace
Instead of kernel modules creating `/proc/squireos/`, JesterOS services create `/var/jesteros/`:

```bash
# Kernel approach (abandoned)
/proc/squireos/jester          # Would require kernel module
/proc/squireos/typewriter/stats # Would require kernel module

# Userspace approach (implemented)
/var/jesteros/jester           # Created by shell script
/var/jesteros/typewriter/stats # Created by shell script
```

### Benefits of Userspace
1. **No compilation required** - Just shell scripts
2. **Easy debugging** - Standard Unix tools work
3. **Safe updates** - No kernel panic risk
4. **Portable** - Works across kernel versions
5. **Simple** - Anyone can understand shell scripts

## Testing Strategy

### Layer-Specific Tests

```
tests/
├── 1-ui-tests/        # User interaction tests
├── 2-app-tests/       # Service logic tests
├── 3-system-tests/    # System integration tests
└── 4-hardware-tests/  # Hardware abstraction tests
```

### Test Coverage by Layer
- **Layer 1**: Menu navigation, display output
- **Layer 2**: Service functionality, state management
- **Layer 3**: Library functions, error handling
- **Layer 4**: Hardware detection, fallback behavior

## Summary

The 4-layer architecture is a **more honest and maintainable** representation of the JoKernel project. By removing the unnecessary kernel interface layer, we:

1. Reduce complexity without losing functionality
2. Better reflect the userspace implementation
3. Make the architecture easier to understand
4. Align with the "writers over features" philosophy

This is a perfect example of **pragmatic engineering** - choosing the simpler solution that actually works over the complex one that was originally planned.

---

*"Simplicity is the ultimate sophistication"* - The architecture that shipped is better than the architecture that was dreamed.# Architecture Improvements - 2025-01-18

## ✅ Completed Improvements

### 1. USB Keyboard Manager Relocation
**Before**: `runtime/3-system/services/usb-keyboard-manager.sh`
**After**: `runtime/4-hardware/input/usb-keyboard-manager.sh`

**Also moved**: 
- `runtime/1-ui/setup/usb-keyboard-setup.sh` → `runtime/4-hardware/input/usb-keyboard-ui-setup.sh`

**Rationale**: USB keyboard management is hardware-level functionality, not system service level.

### 2. Build Directory Unification
**Before**: 
```
build/scripts/        (newer versions)
development/build/    (older duplicates)
```

**After**:
```
build/
├── docker/          (Docker configurations)
├── kernel/          (Kernel build configs)
├── scripts/         (All build scripts)
└── output/          (Build outputs)
```

**Archived**: `development/build/` → `.archives/development/build/`

### 3. Test Directory Consolidation (Pending)
**Current State**: Multiple test directories exist:
- `tests/` (main)
- `tools/test/`
- `scripts/test/`
- `utilities/test/`

**Target**: Single `tests/` directory with subdirectories

### 4. Naming Consistency (Pending)
**Current**: Mixed usage of jesteros/jokeros/squireos
**Target**: Standardize on "jesteros" throughout

## 📁 New Archive Structure
```
.archives/
├── backups/         (SD card and unification backups)
├── development/     (Old development/build directory)
├── docker/          (Archived dockerfiles)
├── rootfs/          (Non-production rootfs archives)
└── tests/           (Archived test files)
```

## 🎯 Impact
- **Cleaner Structure**: No more duplicate build directories
- **Correct Layering**: Hardware functions in hardware layer
- **Better Organization**: Clear separation of concerns
- **Reduced Confusion**: Single source of truth for build scripts

## 📝 Next Steps
1. Complete test directory consolidation
2. Fix naming consistency (jesteros only)
3. Update documentation references
4. Run validation tests# ARCHITECTURE_RESTRUCTURE.md - SUPERSEDED  

**This restructuring plan has been COMPLETED and superseded by current architecture.**

Please refer to:
- `ARCHITECTURE_4LAYER.md` - Current 4-layer architecture documentation
- `runtime/README_ARCHITECTURE.md` - Runtime architecture details
- `runtime/MIGRATION_COMPLETED.md` - Migration completion status

The proposed restructuring has been successfully implemented in the `runtime/` directory.

This file scheduled for removal to save memory (~20KB).

### 🏗️ 5-Layer Architecture Mapping

```
Architecture Layer          Current Location            Proposed Location
─────────────────────────────────────────────────────────────────────────
1. UI Layer                 runtime/ui/                 runtime/1-ui/
   (User Interface)         runtime/scripts/menu/       ├── menu/
                           runtime/configs/ascii/       ├── display/
                                                       └── themes/

2. Application Services     runtime/scripts/services/   runtime/2-application/
   (Business Logic)         runtime/scripts/boot/       ├── jesteros/
                                                       ├── writing/
                                                       └── stats/

3. System Services          runtime/scripts/lib/        runtime/3-system/
   (OS Integration)         (FBInk in docker)           ├── display/
                                                       ├── filesystem/
                                                       └── process/

4. Kernel Interface         runtime/modules/            runtime/4-kernel/
   (Kernel Communication)   (currently empty)           ├── modules/
                                                       ├── proc/
                                                       └── sysfs/

5. Hardware Abstraction     (mixed in scripts)          runtime/5-hardware/
   (Hardware Control)                                   ├── eink/
                                                       ├── usb/
                                                       └── power/
```

## Proposed New Structure

```
nook/
├── runtime/                    # Device runtime code (matches architecture)
│   ├── 1-ui/                  # User Interface Layer
│   │   ├── menu/              # Menu system scripts
│   │   ├── display/           # Display components
│   │   └── themes/            # ASCII art, themes
│   │
│   ├── 2-application/         # Application Services Layer  
│   │   ├── jesteros/          # JesterOS services
│   │   │   ├── mood.sh        # Mood selector
│   │   │   ├── daemon.sh      # Main daemon
│   │   │   └── tracker.sh     # Stats tracking
│   │   ├── writing/           # Writing-specific services
│   │   └── stats/             # Statistics services
│   │
│   ├── 3-system/              # System Services Layer
│   │   ├── display/           # FBInk integration
│   │   ├── filesystem/        # File management
│   │   ├── process/           # Process management
│   │   └── common/            # Shared libraries
│   │
│   ├── 4-kernel/              # Kernel Interface Layer
│   │   ├── modules/           # Kernel modules (.ko files)
│   │   ├── proc/              # /proc interface scripts
│   │   └── sysfs/             # /sys interface scripts
│   │
│   ├── 5-hardware/            # Hardware Abstraction Layer
│   │   ├── eink/              # E-Ink specific code
│   │   ├── usb/               # USB/keyboard handling
│   │   └── power/             # Power management
│   │
│   ├── configs/               # All configuration files
│   │   ├── system/            # System configs
│   │   ├── services/          # Service configs
│   │   └── vim/               # Editor configs
│   │
│   └── init/                  # Boot/initialization
│       ├── boot.sh            # Main boot script
│       └── chroot.sh          # Chroot transition
│
├── development/               # Keep as-is (good separation)
├── tools/                     # Keep as-is
├── docs/                      # Keep as-is
└── tests/                     # Keep as-is
```

## Migration Plan

### Phase 1: Create New Structure
```bash
#!/bin/bash
# Create architecture-aligned directories

cd runtime/

# Create layer directories
mkdir -p 1-ui/{menu,display,themes}
mkdir -p 2-application/{jesteros,writing,stats}
mkdir -p 3-system/{display,filesystem,process,common}
mkdir -p 4-kernel/{modules,proc,sysfs}
mkdir -p 5-hardware/{eink,usb,power}
mkdir -p init
```

### Phase 2: Move Files (Examples)
```bash
# UI Layer
mv scripts/menu/* 1-ui/menu/
mv ui/components/* 1-ui/display/
mv ui/themes/* 1-ui/themes/
mv configs/ascii/* 1-ui/themes/

# Application Layer
mv scripts/services/jesteros-* 2-application/jesteros/
mv scripts/services/jester-daemon.sh 2-application/jesteros/daemon.sh

# System Layer
mv scripts/lib/common.sh 3-system/common/
mv scripts/lib/service-functions.sh 3-system/common/

# Kernel Layer
mv modules/* 4-kernel/modules/

# Init
mv scripts/boot/jesteros-init.sh init/
mv scripts/boot/boot-*.sh init/
```

## Benefits of This Structure

### 1. **Clear Layer Boundaries**
- Each directory number shows its layer in the stack
- Dependencies only flow downward (1→2→3→4→5)
- Easy to enforce architectural rules

### 2. **Better Maintainability**
- New developers immediately understand the architecture
- Clear where to add new features
- Obvious impact analysis for changes

### 3. **Testing Strategy**
```
tests/
├── 1-ui-tests/        # UI interaction tests
├── 2-app-tests/       # Service logic tests
├── 3-system-tests/    # System integration tests
├── 4-kernel-tests/    # Module tests
└── 5-hardware-tests/  # Hardware mock tests
```

### 4. **Documentation Alignment**
```
docs/
├── architecture/
│   ├── 1-ui-layer.md
│   ├── 2-application-layer.md
│   ├── 3-system-layer.md
│   ├── 4-kernel-layer.md
│   └── 5-hardware-layer.md
```

## Implementation Checklist

- [ ] Backup current structure
- [ ] Create new directory structure
- [ ] Move files to appropriate layers
- [ ] Update all script paths and imports
- [ ] Update documentation references
- [ ] Test boot sequence with new paths
- [ ] Update Docker build files
- [ ] Run full test suite

## Questions to Resolve

1. **Boot Scripts**: Should they be in `init/` or distributed across layers?
   - Recommendation: Keep in `init/` for clear boot sequence

2. **Configs**: Single `configs/` dir or distributed per layer?
   - Recommendation: Keep centralized for easier management

3. **Common Libraries**: In `3-system/common/` or separate `common/`?
   - Recommendation: In system layer as they're system services

4. **Cross-Layer Scripts**: Some scripts touch multiple layers
   - Recommendation: Place in highest layer they touch

## Script to Show Current Misalignment

```bash
#!/bin/bash
echo "Files that don't match their architectural layer:"
echo "================================================"

# UI files not in UI directory
echo "UI Layer files outside ui/:"
find runtime/scripts -name "*menu*" -o -name "*display*"

# System services in wrong place
echo -e "\nSystem service files not organized:"
find runtime/scripts -name "*common*" -o -name "*service*"

# Application services scattered
echo -e "\nApplication services not grouped:"
find runtime/scripts -name "*jester*"
```

## Next Steps

1. **Review & Approve**: Does this structure make sense?
2. **Gradual Migration**: Move one layer at a time
3. **Update Imports**: Fix all script dependencies
4. **Test Each Layer**: Ensure nothing breaks
5. **Document Changes**: Update all references

This restructuring will make the codebase much more intuitive and maintainable!# 📚 Nook Typewriter Project Structure

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