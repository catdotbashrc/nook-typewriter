# JoKernel Configuration System Documentation

## Overview

The JoKernel project uses a centralized configuration system to prevent deployment failures from naming inconsistencies. After the Great JOKEROS/SQUIREOS Confusion of 2025, we've established clear separation between kernel configuration and build tooling.

## Configuration Architecture

### 1. Build Configuration (`.kernel.env`)
Shell environment variables for build scripts and tooling. **NOT** used by the kernel itself.

```bash
# Project identification
export PROJECT_NAME="JoKernel"
export PROJECT_VERSION="1.0.0"
export BUILD_NUMBER=0

# Kernel module naming (MUST match Kconfig)
export KERNEL_MODULE_PREFIX="JESTEROS"    # Used in Kconfig (CONFIG_JESTEROS)
export KERNEL_MODULE_NAME="jesteros"      # Module directory name
export PROC_FILESYSTEM_PATH="/proc/jesteros"  # Runtime proc path
```

### 2. Kernel Configuration (`jesteros_config.h`)
C header file with constants for kernel modules themselves.

```c
#define JESTEROS_VERSION "1.0.0-alpha.1"
#define JESTEROS_MODULE_NAME "jesteros"
#define JESTEROS_PROC_ROOT "jesteros"
```

### 3. Kconfig System (`Kconfig.jesteros`)
Linux kernel configuration system entries.

```
menuconfig JESTEROS
    tristate "JesterOS Jester Interface for Digital Typewriter"
    default m
```

## JesterOS Evolution: From Kernel to Userspace

### Historical Context
- **Original**: Kernel modules approach (JOKEROS, SQUIREOS naming)
- **Problem**: Complex kernel compilation, cross-compilation issues
- **Solution**: Moved to userspace implementation for simplicity
- **Philosophy**: "Simple solutions for joyful writing"

### Architecture Evolution
1. **Legacy Kernel Approach** (Deprecated):
   - Kernel modules in `source/kernel/src/drivers/jokeros/`
   - Required cross-compilation with Android NDK
   - Created `/proc/jokeros/` interface
   
2. **Current Userspace Approach**:
   - Shell scripts in `source/scripts/boot/`
   - No kernel compilation needed
   - Creates `/var/jesteros/` interface

4. **Filesystem Interface**:
   - Old kernel: `/proc/jokeros/` (deprecated)
   - New userspace: `/var/jesteros/`

## Critical Build Discovery: oldconfig vs olddefconfig

### The Problem
JesterOS modules weren't being included in kernel builds despite being in the config.

### The Investigation
After going in circles (and taking a metaphorical cigarette break), discovered that Linux 2.6.29's `make oldconfig` was silently dropping unknown config options.

### The Solution
Changed from:
```bash
make oldconfig  # Strips unknown options
```

To:
```bash
make olddefconfig  # Accepts new options with defaults
```

This single change fixed the entire build system!

## Version Control System

### Semantic Versioning
Uses semantic versioning with build tracking:
- **Format**: `MAJOR.MINOR.PATCH[-PRERELEASE][+BUILD]`
- **Example**: `1.0.0-alpha.1+42`

### Version Commands
```bash
# Bump version
./scripts/version-control.sh bump [major|minor|patch|pre]

# Set specific version
./scripts/version-control.sh set 2.0.0

# Tag release
./scripts/version-control.sh tag

# Show current version
./scripts/version-control.sh info

# Generate changelog
./scripts/version-control.sh changelog
```

## Pre-Commit Hooks

### Automatic Testing
Pre-commit hooks ensure code quality on the dev branch:

```bash
# Runs automatically on commit to dev branch:
- Kernel safety checks (if kernel files changed)
- Pre-flight validation (if critical files changed)
- Module compilation tests
```

### Manual Testing
```bash
# Run all pre-flight checks
./tests/pre-flight.sh

# Test kernel safety
./tests/kernel-safety.sh

# Smoke test
./tests/smoke-test.sh
```

## Module Loading Sequence

1. **Build Time**:
   - Kernel config enables `CONFIG_JESTEROS=m`
   - Modules compile to `.ko` files

2. **Boot Time**:
   ```bash
   insmod jesteros_core.ko    # Core module first
   insmod jester.ko            # ASCII art jester
   insmod typewriter.ko        # Writing statistics
   insmod wisdom.ko            # Writing quotes
   ```

3. **Runtime Access**:
   ```bash
   cat /proc/jesteros/jester          # Show ASCII jester
   cat /proc/jesteros/typewriter/stats # Writing stats
   cat /proc/jesteros/wisdom          # Random quote
   ```

## Configuration Best Practices

### DO:
- ✅ Keep kernel config in Kconfig files
- ✅ Use header files for kernel constants
- ✅ Use .kernel.env for build scripts only
- ✅ Match all naming across configs
- ✅ Test with pre-flight checks before deployment

### DON'T:
- ❌ Mix kernel and build configurations
- ❌ Use environment variables in kernel code
- ❌ Change module names without updating all references
- ❌ Skip pre-flight validation
- ❌ Use `make oldconfig` with new config options (use `olddefconfig`)

## Troubleshooting

### JesterOS modules not loading
```bash
# Check if modules built
ls source/kernel/src/drivers/jesteros/*.ko

# Check kernel config
grep JESTEROS source/kernel/src/.config

# Check module dependencies
modinfo jesteros_core.ko
```

### Pre-flight checks failing
```bash
# Run with verbose output
bash -x tests/pre-flight.sh

# Check specific module
grep -r "JESTEROS" source/kernel/src/
```

### Build failures
```bash
# Clean build
rm -rf source/kernel/src/.config
./build_kernel.sh

# Check Docker image
docker images | grep jokernel-unified
```

## File Reference

### Configuration Files
- `.kernel.env` - Build environment configuration
- `source/kernel/src/drivers/jesteros/jesteros_config.h` - Kernel constants
- `source/kernel/src/drivers/Kconfig.jesteros` - Kernel config menu
- `scripts/version-control.sh` - Version management

### Build Scripts
- `build_kernel.sh` - Main kernel build script
- `tests/pre-flight.sh` - Pre-deployment validation
- `tests/kernel-safety.sh` - Kernel module safety checks

### Module Source
- `source/kernel/src/drivers/jesteros/jesteros_core.c` - Core module
- `source/kernel/src/drivers/jesteros/jester.c` - ASCII art
- `source/kernel/src/drivers/jesteros/typewriter.c` - Writing tracker
- `source/kernel/src/drivers/jesteros/wisdom.c` - Quote system

## Historical Notes

### The QuillKernel Incident
Brief unauthorized attempt to rename JoKernel to QuillKernel was immediately reverted. JoKernel remains the canonical name. As decreed: "Your vandalism is unwelcome!"

### The Cigarette Break Revelation
After going in circles with kernel configuration, a break for clarity led to discovering the oldconfig/olddefconfig distinction - a crucial fix for Linux 2.6.29 builds.

---

*"By quill and candlelight, with JesterOS and JoKernel united!"* 🎭📜