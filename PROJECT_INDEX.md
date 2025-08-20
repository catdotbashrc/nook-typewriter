# 📚 Nook Typewriter Project Index

> *Transform a $20 e-reader into a distraction-free writing device*

## 🏰 Project Overview

**JesterOS/JoKernel** - A medieval-themed embedded Linux distribution for the Barnes & Noble Nook Simple Touch, optimized for writers with extreme hardware constraints (256MB RAM, E-Ink display).

### Quick Stats
- **Version**: 1.0.0-alpha.1
- **Target**: B&N Nook Simple Touch (OMAP3621 ARM)
- **Kernel**: Linux 2.6.29-jester
- **Base OS**: Debian Lenny 5.0
- **Memory Budget**: 95MB OS / 160MB Writing (Sacred)
- **Architecture**: 4-Layer System (35 scripts)

## 📖 Documentation Index

### Core Documentation
- [CLAUDE.md](./CLAUDE.md) - AI assistant guidance for development
- [PROJECT_INDEX.md](./PROJECT_INDEX.md) - This file - comprehensive navigation
- [.context-cache-deep.json](./.context-cache-deep.json) - Project metadata cache

### System Architecture
- [📋 Boot Infrastructure Complete](./docs/BOOT-INFRASTRUCTURE-COMPLETE.md) - Complete boot system analysis
- [🏗️ JesterOS Boot Process](./docs/JESTEROS_BOOT_PROCESS.md) - JesterOS-specific boot flow
- [⚙️ Kernel API Reference](./docs/kernel-api-reference.md) - Kernel module interfaces

### Hardware Documentation
- [🖥️ Nook Hardware Reference](./docs/hardware/NOOK_HARDWARE_REFERENCE.md) - Hardware specifications
- [📺 E-Ink Display Reference](./docs/hardware/EINK_DISPLAY_REFERENCE.md) - Display management
- [⌨️ USB Keyboard Guide](./docs/hardware/USB_KEYBOARD.md) - External keyboard support
- [🔋 Power Management](./docs/hardware/POWER_MANAGEMENT_GUIDE.md) - Battery optimization
- [🎮 Button Navigation](./docs/hardware/BUTTON_NAVIGATION_GUIDE.md) - Physical controls
- [📊 System Information](./docs/hardware/SYSTEM_INFORMATION.md) - Hardware details

### Kernel Documentation
- [📚 Kernel Documentation](./docs/kernel-reference/kernel-documentation.md) - 2.6.29 kernel docs
- [🔧 Module Building Guide](./docs/kernel-reference/module-building-2.6.29.md) - Kernel module development
- [💾 Memory Management ARM](./docs/kernel-reference/memory-management-arm-2.6.29.md) - ARM-specific memory
- [📁 Proc Filesystem](./docs/kernel-reference/proc-filesystem-2.6.29.md) - /proc interface

### Project Philosophy
- [📜 Constitution](./simone/constitution.md) - Project rules and principles
- [🏛️ Architecture Document](./simone/architecture.md) - Detailed system design
- [⚙️ Project Configuration](./simone/project.yaml) - Simone project settings

## 🗂️ Directory Structure

### `/build/` - Build System
```
├── docker/          # Docker container definitions
├── images/          # Build output images
├── kernel/          # Kernel build artifacts
├── logs/            # Build logs
├── rootfs/          # Root filesystem staging
└── scripts/         # Build automation scripts
```

### `/runtime/` - 4-Layer JesterOS Architecture
```
├── 1-ui/            # User Interface Layer
│   ├── display/     # Display management
│   ├── menu/        # Menu systems
│   └── themes/      # ASCII art and themes
├── 2-application/   # Application Services Layer
│   ├── jesteros/    # JesterOS core services
│   └── writing/     # Writing tools
├── 3-system/        # System Services Layer
│   ├── common/      # Shared libraries
│   ├── memory/      # Memory management
│   └── services/    # System daemons
├── 4-hardware/      # Hardware Interface Layer
│   ├── battery/     # Power management
│   ├── buttons/     # Physical controls
│   └── input/       # Input devices
└── init/            # Initialization scripts
```

### `/source/` - Source Code
```
└── kernel/          # Linux kernel 2.6.29 source
    ├── build/       # Kernel build configuration
    └── src/         # Kernel source tree
```

### `/tests/` - Test Suite
```
├── 01-safety-check.sh       # Critical safety validations
├── 02-boot-test.sh          # Boot sequence verification
├── 05-consistency-check.sh  # File consistency
├── 06-memory-guard.sh       # Memory limit enforcement
├── run-tests.sh             # 3-stage test orchestrator
└── unit/                    # Unit tests
```

### `/firmware/` - Boot & System Components
```
├── android/         # Android init (hardware layer only)
├── boot/            # Bootloaders (MLO, u-boot)
├── dsp/             # DSP firmware for E-Ink
├── kernel/          # Kernel modules
└── modules/         # Loadable kernel modules
```

### `/docs/` - Documentation
```
├── hardware/        # Hardware specifications
├── kernel-reference/# Kernel 2.6.29 documentation
└── xda-forums/      # Phoenix Project research
```

## 🔨 Build & Development

### Essential Make Targets
| Command | Description |
|---------|-------------|
| `make firmware` | Complete build (kernel + rootfs + boot) |
| `make kernel` | Build Linux kernel only |
| `make rootfs` | Build root filesystem |
| `make lenny-rootfs` | Build Debian Lenny base |
| `make image` | Create SD card image |
| `make release` | Create release package |
| `make test` | Run complete test suite |
| `make test-quick` | Run critical tests only |
| `make sd-deploy` | Deploy to SD card |
| `make clean` | Clean build artifacts |

### Docker Images
- `jesteros:lenny-base` - Debian Lenny 5.0 base
- `jesteros:dev-base` - Development environment
- `jesteros:runtime-base` - Minimal runtime
- `jesteros-production` - Production image
- `kernel-xda-proven-optimized` - Kernel build environment

### Testing Pipeline
1. **Pre-Build Stage** - Test build tools and scripts
2. **Post-Build Stage** - Test Docker output
3. **Runtime Stage** - Test execution in container

## 🚀 Quick Start

### Build Everything
```bash
# Complete firmware build
make firmware

# Run safety tests
make test-quick

# Deploy to SD card
make sd-deploy
```

### Development Workflow
```bash
# 1. Make changes
vim runtime/2-application/jesteros/daemon.sh

# 2. Test changes
make test-quick

# 3. Build firmware
make quick-build

# 4. Deploy
make sd-deploy SD_DEVICE=/dev/sde
```

## 📊 Memory Map

```
┌─────────────────────────────┐
│   Sacred Writing Space      │ 160MB (NEVER TOUCH)
├─────────────────────────────┤
│   JesterOS + Services       │ 95MB max
├─────────────────────────────┤
│   Kernel + Drivers          │ ~30MB
├─────────────────────────────┤
│   Hardware Reserved         │ ~31MB
└─────────────────────────────┘
Total: 256MB
```

## 🎭 Medieval Theme

The project maintains a whimsical medieval theme throughout:
- **Jester Daemon** - ASCII art mood system
- **Squire Services** - Helper utilities
- **Knight Mode** - Power user features
- **Scroll Management** - Document handling
- **Quill Statistics** - Writing metrics

## ⚠️ Critical Constraints

1. **Memory is Sacred**: 160MB writing space is inviolable
2. **E-Ink Limitations**: 200-980ms refresh rates
3. **ARM Architecture**: Cross-compilation required
4. **Android Init**: Cannot bypass for hardware
5. **Battery Target**: <1.5% daily drain
6. **SD Card**: SanDisk Class 10 required

## 🔗 Related Projects

- [catdotbashrc/nst-kernel](https://github.com/catdotbashrc/nst-kernel) - Kernel source mirror
- [Phoenix Project (XDA)](./docs/xda-forums/) - Community research
- [NookManager](./docs/.scratch/NOOKMANAGER-COMPLETE-DOCUMENTATION.md) - Boot analysis source

## 📝 Contributing

See [Constitution](./simone/constitution.md) for project rules and philosophy.

---

*"By quill and candlelight, we code for those who write"* 🕯️📜