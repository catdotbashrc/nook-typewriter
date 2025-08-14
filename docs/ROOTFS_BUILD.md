# Minimal Rootfs Build Documentation

## Overview

This document describes the minimal root filesystem (rootfs) build process for the Nook E-Ink Typewriter project. The rootfs provides just enough functionality to boot the Nook hardware and verify that our custom kernel works.

## Architecture Decision: Debian Lenny

### Why Debian 5.0 "Lenny" (2009)?

We chose Debian Lenny as our base for several important reasons:

1. **Period-Correct Compatibility**: 
   - Linux kernel 2.6.29 was released March 23, 2009
   - Debian Lenny was released February 14, 2009
   - They share the same era's libraries and toolchain

2. **Native ARM Support**:
   - Lenny has native ARMEL architecture support
   - Proven to work on embedded ARM devices of that era
   - Smaller footprint than modern distributions

3. **Kernel Compatibility**:
   - Lenny ships with kernel 2.6.26
   - Very close to our 2.6.29, ensuring glibc compatibility
   - No modern systemd or other incompatible components

4. **Size Optimization**:
   - Older packages are significantly smaller
   - No bloat from modern features we don't need
   - Achieves our <30MB compressed target easily

### Challenges and Solutions

Since Debian Lenny is archived, we use:
- `archive.debian.org` repositories
- `debootstrap` to build from scratch
- QEMU for ARM emulation during build

## Build Process

### Prerequisites

- Docker installed and running
- ~500MB free disk space
- Internet connection (for downloading packages)

### Building the Rootfs

```bash
cd /path/to/nook-typewriter
./build/scripts/build-rootfs.sh
```

This script:
1. Builds a Docker image with Debian Lenny ARMEL
2. Creates a minimal rootfs with busybox and essential tools
3. Exports it as `firmware/rootfs.tar.gz`
4. Adds kernel modules if available

### Build Output

- **Location**: `firmware/rootfs.tar.gz`
- **Size**: Should be <30MB compressed
- **Contents**: 
  - Minimal Debian Lenny base
  - Busybox for Unix utilities
  - Init script for boot
  - Menu system for testing
  - Support for JokerOS kernel modules

## Testing

### Local Testing with Docker

```bash
./tests/test-rootfs.sh
```

This validates:
- Directory structure is correct
- Essential files are present
- Busybox is properly installed
- Size is within target
- Basic functionality works

### What to Expect

The test script will:
1. Import the rootfs into Docker
2. Verify all essential directories exist
3. Check that init and menu scripts are present
4. Confirm busybox installation
5. Optionally allow interactive testing

**Note**: Kernel modules won't actually load in Docker since we're not running our custom kernel.

## Rootfs Structure

```
/
├── init                    # Boot script (PID 1)
├── bin/                    # Busybox and basic binaries
├── lib/
│   └── modules/
│       └── 2.6.29/        # Kernel modules go here
├── usr/
│   └── local/
│       └── bin/
│           └── mvp-menu.sh # Simple menu system
├── proc/                   # Process filesystem (mounted at boot)
├── sys/                    # Sysfs (mounted at boot)
├── dev/                    # Device files (mounted at boot)
└── etc/                    # Configuration files
```

## Boot Sequence

1. Kernel loads and starts `/init`
2. Init mounts essential filesystems (/proc, /sys, /dev)
3. Init attempts to load JokerOS kernel modules
4. If modules load, displays jester ASCII art
5. Launches minimal menu system
6. User can interact via menu or drop to shell

## Module Integration

The rootfs expects JokerOS kernel modules in `/lib/modules/2.6.29/`:
- `jokeros_core.ko` - Core module (must load first)
- `jester.ko` - ASCII art jester display
- `typewriter.ko` - Writing statistics tracker
- `wisdom.ko` - Inspirational quotes

These create entries in `/proc/jokeros/` when loaded.

## Troubleshooting

### Rootfs Too Large

If the rootfs exceeds 30MB:
1. Remove unnecessary packages
2. Delete documentation files
3. Strip binaries
4. Remove locale files

### Docker Build Fails

Common issues:
- Network problems accessing archive.debian.org
- Insufficient disk space
- Docker not running

### Modules Not Loading

Check that:
- Modules are compiled for kernel 2.6.29
- Module files are in `/lib/modules/2.6.29/`
- Dependencies are loaded in correct order

## Next Steps

Once the rootfs is built and tested:

1. **Build kernel** if not already done:
   ```bash
   ./build_kernel.sh
   ```

2. **Create SD card image** (when script is available):
   ```bash
   ./build/scripts/create-sd-image.sh
   ```

3. **Flash to SD card**:
   ```bash
   dd if=nook-mvp.img of=/dev/sdX bs=4M status=progress
   ```

4. **Boot on Nook**:
   - Insert SD card
   - Power on Nook
   - Watch the medieval magic happen!

## Memory Considerations

Target memory usage:
- Kernel: ~5MB
- Rootfs (uncompressed): <96MB
- Free RAM for writing: >160MB

The minimal rootfs helps achieve these goals by including only essential components.

## Future Enhancements

Once basic boot works, we can add:
- Vim for actual writing
- Full menu system with more features
- Writing directories (/root/drafts, /root/scrolls)
- More medieval theme elements
- Network support for syncing

But first, we need "Hello from Nook!"

---

*By quill and candlelight, we boot!* 🕯️📜