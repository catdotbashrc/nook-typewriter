# Simplified QuillKernel Build Guide

Building QuillKernel is now streamlined to just two essential scripts!

## Quick Start

### 1. Apply Medieval Patches
```bash
cd nst-kernel
./squire-kernel-patch.sh
```

### 2. Build the Kernel

#### Option A: Traditional Build (with toolchain)
```bash
cd src
make ARCH=arm quill_typewriter_defconfig
make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- uImage
```

#### Option B: Docker Build (no toolchain needed!)
```bash
docker build -f Dockerfile.build -t quillkernel .
docker run --rm -v $(pwd)/output:/output quillkernel
```

## That's It!

The kernel will be at `src/arch/arm/boot/uImage`

## Testing (Optional)

To verify everything worked:
```bash
cd test
./verify-build-simple.sh
```

## What We Simplified

We eliminated these redundant scripts:
- ~~apply-branding.sh~~ → Use `squire-kernel-patch.sh` 
- ~~build-kernel.sh~~ → Just use make directly
- ~~customize-kernel.sh~~ → Use `make menuconfig` if needed
- ~~optimize-typewriter-kernel.sh~~ → Already in defconfig
- ~~setup-kernel-build.sh~~ → Use Docker instead

## Need Help?

See the [main README](README.md) for detailed documentation.