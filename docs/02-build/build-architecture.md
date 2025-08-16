# JoKernel Build Architecture

## Overview
We use different build environments for different components, each optimized for its purpose.

## Build Components

### 1. Kernel Builder (Docker)
- **Image**: `jokernel-unified` (4.1GB)
- **Base**: Ubuntu 20.04
- **Toolchain**: Android NDK r12b (XDA-proven)
- **Purpose**: Cross-compile Linux 2.6.29 kernel for ARM
- **Why large**: Needs full toolchain, headers, build tools
- **Keep as-is**: This works and is proven by XDA community

### 2. Rootfs Options

#### Option A: Debian Lenny (Period-Correct)
- **Method**: `build-lenny-rootfs.sh` using debootstrap
- **Base**: Debian 5.0 "Lenny" from 2009
- **Size**: ~30-40MB compressed
- **Advantages**:
  - Period-correct for 2.6.29 kernel (both from 2009)
  - Designed for 256MB RAM devices
  - No systemd (uses sysvinit)
  - Smaller than modern Debian
  - Native support for old kernel
- **Best for**: Authentic 2009 experience

#### Option B: Minimal Modern Debian
- **Method**: `minimal-boot.dockerfile`
- **Base**: Debian Buster (oldest Docker supports)
- **Size**: ~30MB compressed
- **Advantages**:
  - Easy to build with Docker
  - More recent security updates
  - Better package availability
- **Best for**: Quick testing

#### Option C: Busybox-only
- **Method**: Manual busybox static binary
- **Size**: <5MB
- **Advantages**:
  - Absolutely minimal
  - No package management overhead
- **Best for**: Emergency recovery, ultra-minimal

### 3. SD Card Creation
- **Script**: `create-boot-from-scratch.sh`
- **Method**: Ground-up partition and boot setup
- **No Docker needed**: Direct SD card manipulation

## Recommended Build Flow

```bash
# 1. Build kernel (one-time, unless kernel changes)
./build_kernel.sh

# 2. Build rootfs (choose one):

# Period-correct Lenny (recommended for authenticity)
sudo ./build-lenny-rootfs.sh

# OR modern minimal (easier)
docker build -t nook-minimal -f build/docker/minimal-boot.dockerfile .

# 3. Extract bootloaders (one-time)
./extract-bootloaders.sh

# 4. Create SD card
sudo ./create-boot-from-scratch.sh /dev/sdX
```

## Why This Architecture?

1. **Kernel needs modern tools**: Cross-compilation requires recent toolchain
2. **Rootfs should be minimal**: Old Debian matches old kernel better
3. **Docker for repeatability**: Kernel builds are complex, Docker ensures consistency
4. **Native for deployment**: SD card creation needs direct hardware access

## Space Usage

- Kernel builder image: 4.1GB (keep - it works)
- Kernel output: ~2MB (uImage)
- Lenny rootfs: ~40MB compressed
- Final SD image: ~100MB total

## Cleanup Commands

If you need space:
```bash
# Remove old test images (not kernel builder)
docker rmi nook-writer nook-font-test nook-rootfs-test

# Keep these:
# - jokernel-unified (kernel builder - needed)
# - nook-minimal (if using modern rootfs)

# Clean Docker system
docker system prune -a  # WARNING: Removes all unused images
```

## Summary

- **Keep kernel builder Docker image** - It's large but necessary and proven
- **Use Debian Lenny for rootfs** - Period-correct and smaller
- **Build SD card natively** - No Docker needed for deployment

The 4GB kernel builder is a one-time cost for a working toolchain. The actual deployed system is tiny (~100MB on SD card).