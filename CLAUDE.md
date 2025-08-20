# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

JesterOS/JoKernel - Transform a $20 Barnes & Noble Nook Simple Touch into a distraction-free writing device. This is an embedded Linux distribution targeting ARM hardware with extreme memory constraints (256MB RAM, 95MB OS limit).

## Essential Commands

### Build Commands
```bash
# Complete firmware build (kernel + rootfs + boot)
make firmware

# Build kernel only (uses Docker cross-compilation)
make kernel
# Or directly:
J_CORES=$(nproc) ./build/scripts/build_kernel.sh

# Build root filesystem with JesterOS services
make rootfs

# Build Debian Lenny-based rootfs
make lenny-rootfs

# Create bootable SD card image
make image

# Quick build (skips unchanged components)
make quick-build
```

### Testing Commands
```bash
# Run complete 3-stage test pipeline
make test

# Run critical safety checks only (must pass before deploy)
make test-quick
make test-safety

# Run specific test stages
make test-pre-build   # Test build tools before Docker
make test-post-build  # Test Docker output after build
make test-runtime     # Test execution in container

# Run individual tests
cd tests && ./01-safety-check.sh
cd tests && ./02-boot-test.sh
cd tests && ./05-consistency-check.sh
cd tests && ./06-memory-guard.sh

# Test coverage analysis
make test-coverage
```

### Deployment Commands
```bash
# Deploy to SD card (auto-detect device)
make sd-deploy

# Deploy to specific device
make sd-deploy SD_DEVICE=/dev/sde

# Quick deploy (kernel only to existing card)
make quick-deploy SD_DEVICE=/dev/sde

# Detect safe SD card devices
make detect-sd

# Check battery optimization settings
make battery-check
```

### Docker Management
```bash
# Build all Docker images
make docker-build

# Build specific images
make docker-lenny      # Debian Lenny base
make docker-production # JesterOS production
make docker-kernel     # Kernel build environment

# Clean Docker cache
make docker-cache-clean
```

## High-Level Architecture

### Boot Chain
```
Power On → ROM Loader → MLO (16KB) → U-Boot (159KB) → Linux Kernel (1.9MB)
         → Android Init (hardware only) → JesterOS Init → 4-Layer Services
```

### 4-Layer JesterOS Architecture
The system uses a hierarchical 4-layer architecture with 35 scripts:

1. **UI Layer** (`src/1-ui/`) - Display and menu systems
   - Key components: display.sh, menu.sh, jester-menu.sh
   - Handles E-Ink refresh and user interaction

2. **Application Layer** (`src/2-application/`) - JesterOS services
   - Key components: daemon.sh, jester-daemon.sh, tracker.sh
   - Medieval-themed writing assistant and statistics

3. **System Layer** (`src/3-system/`) - Core functions
   - Key components: common.sh, memory-guardian.sh, unified-monitor.sh
   - Enforces 95MB OS memory limit

4. **Hardware Layer** (`src/4-hardware/`) - Device management
   - Key components: button-handler.sh, usb-keyboard-manager.sh, battery-monitor.sh
   - Interfaces with Android init for hardware control

### Critical Memory Constraints
- **Total RAM**: 256MB
- **OS Limit**: 95MB (enforced by memory-guardian.sh)
- **Vim Max**: 10MB
- **Writing Reserved**: 160MB (SACRED - never violate)

### Kernel Architecture
- **Base**: Linux 2.6.29 (required for Nook hardware)
- **Source**: `source/kernel/src/` (catdotbashrc/nst-kernel mirror)
- **Patches**: JesterOS-specific modifications in kernel config
- **Cross-Compilation**: ARM toolchain via Android NDK r10e in Docker

### Build System Flow
```
Makefile → Docker containers → Cross-compilation → Firmware artifacts
         ↓                  ↓                   ↓
    BuildKit cache    ARM binaries      boot/, rootfs/, kernel/
```

## Critical Development Rules

1. **Memory is Sacred**: Never exceed 95MB OS limit. The 160MB writing space is inviolable.

2. **Test Before Deploy**: Always run `make test-quick` before SD card deployment. Hardware mistakes can brick the device.

3. **E-Ink Awareness**: Display refreshes are slow (200-980ms). Design UIs for minimal updates.

4. **Docker Isolation**: All cross-compilation happens in Docker. Never install ARM toolchains on host.

5. **Phoenix Project Standards**: Follow XDA-proven configurations:
   - Firmware 1.2.2 is most stable
   - Use SanDisk Class 10 SD cards only
   - CWM images must be 128MB for installation

6. **Bootloader Protection**: MLO and u-boot.bin are preserved during `make clean`. Only `make distclean` removes them.

7. **Android Init Required**: Cannot bypass Android init - hardware drivers depend on it. JesterOS runs in userspace on top.

## Key File Locations

### Configuration
- `.project-context-cache.json` - Project metadata and structure
- `.mcp.json` - MCP server configuration (Simone integration)
- `pyproject.toml` - Python dependencies (superclaude)

### Build Scripts
- `build/scripts/build_kernel.sh` - Main kernel build orchestrator
- `build/scripts/create-image.sh` - SD card image creator
- `build/scripts/extract-bootloaders-dd.sh` - Bootloader extraction

### Docker Definitions
- `build/docker/jesteros-production.dockerfile` - Production image
- `build/docker/kernel-xda-proven-optimized.dockerfile` - Kernel builder
- `build/docker/jesteros-lenny-base.dockerfile` - Unified base images

### Test Suite
- `tests/run-tests.sh` - 3-stage test orchestrator
- `tests/01-safety-check.sh` - Critical safety validations
- `tests/02-boot-test.sh` - Boot sequence verification

### Documentation
- `docs/BOOT-INFRASTRUCTURE-COMPLETE.md` - Complete boot system analysis
- `docs/JESTEROS_BOOT_PROCESS.md` - JesterOS-specific boot flow
- `.simone/constitution.md` - Project philosophy and rules
- `.simone/architecture.md` - Detailed system architecture

## Activity Logging

You have access to the `log_activity` tool. Use it to record your activities after every activity that is relevant for the project. This helps track development progress and understand what has been done.