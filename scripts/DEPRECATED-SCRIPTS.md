# Deprecated Scripts Notice

The following scripts have been deprecated in favor of simpler solutions:

## Kernel Building Scripts

### ❌ setup-kernel-build.sh
**Deprecated** - Creates unnecessary complexity with Android NDK
**Use instead**: Docker build (see nst-kernel/Dockerfile.build)

### ❌ build-rootfs.sh  
**Status**: Keep if actively used for rootfs creation
**Note**: This appears to be for the main system, not kernel

## nst-kernel Scripts

### ❌ apply-branding.sh
**Deprecated** - Redundant with squire-kernel-patch.sh
**Use instead**: `./squire-kernel-patch.sh`

### ❌ build-kernel.sh
**Deprecated** - Wrapper adds no value
**Use instead**: Direct make commands or Docker

### ❌ customize-kernel.sh
**Deprecated** - Simple wrapper for menuconfig
**Use instead**: `make ARCH=arm menuconfig`

### ❌ optimize-typewriter-kernel.sh
**Deprecated** - Optimizations already in quill_typewriter_defconfig
**Use instead**: The defconfig already has these optimizations

### ✅ setup-hooks.sh
**Keep** - Still useful for git hooks

## Migration Guide

Old workflow:
```bash
./scripts/setup-kernel-build.sh
cd ~/nook-kernel-dev
./build-kernel.sh
```

New workflow:
```bash
cd nst-kernel
./squire-kernel-patch.sh
docker build -f Dockerfile.build -t quillkernel .
```

## Why We Simplified

1. **Docker eliminates toolchain setup** - No need for Android NDK
2. **Direct commands are clearer** - No hidden complexity
3. **Fewer scripts = less confusion** - Focus on what matters
4. **Modern approach** - Docker is standard for builds now