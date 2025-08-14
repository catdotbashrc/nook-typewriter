# 🔧 QuillKernel Build Reference
## *Quick Commands and Technical Specifications*

**Purpose**: Fast reference for kernel build operations and troubleshooting  
**Audience**: Developers working with QuillKernel  
**Updated**: August 12, 2025

---

## ⚡ Quick Commands

### Essential Build Operations
```bash
# Complete kernel build (8-10 minutes)
./build_kernel.sh

# Build only uImage (faster rebuild)
docker run --rm -v "$(pwd)/source/kernel:/kernel" -w /kernel/src \
  quillkernel-unified make ARCH=arm CROSS_COMPILE=arm-linux-androideabi- uImage

# Clean build (remove artifacts)
docker run --rm -v "$(pwd)/source/kernel:/kernel" -w /kernel/src \
  quillkernel-unified make ARCH=arm CROSS_COMPILE=arm-linux-androideabi- clean

# Configure kernel only
docker run --rm -v "$(pwd)/source/kernel:/kernel" -w /kernel/src \
  quillkernel-unified make ARCH=arm omap3621_gossamer_evt1c_defconfig
```

### Configuration Commands
```bash
# Interactive kernel configuration
docker run -it --rm -v "$(pwd)/source/kernel:/kernel" -w /kernel/src \
  quillkernel-unified make ARCH=arm CROSS_COMPILE=arm-linux-androideabi- menuconfig

# Apply NST default configuration  
cd source/kernel/src && make ARCH=arm omap3621_gossamer_evt1c_defconfig

# Add SquireOS configuration
echo -e '\nCONFIG_SQUIREOS=m\nCONFIG_SQUIREOS_JESTER=y\nCONFIG_SQUIREOS_TYPEWRITER=y\nCONFIG_SQUIREOS_WISDOM=y' >> .config
```

### Validation Commands
```bash
# Check uImage properties
file firmware/boot/uImage
ls -lh firmware/boot/uImage

# Verify kernel configuration
grep -i squireos source/kernel/src/.config

# Test build environment
docker run --rm quillkernel-unified arm-linux-androideabi-gcc --version
```

---

## 🏗️ Build System Architecture

### Docker Environment
```yaml
Image: quillkernel-unified
Base: Ubuntu 20.04
Toolchain: Android NDK r12b
Compiler: arm-linux-androideabi-gcc 4.9.x
Size: ~3GB (includes full NDK)
```

### Cross-Compilation Details
```yaml
Architecture: ARM (CONFIG_ARM=y)
Target CPU: ARMv7 (CONFIG_CPU_V7=y)  
SoC: OMAP3621 (CONFIG_ARCH_OMAP3=y)
Board: Gossamer EVT1C (CONFIG_MACH_OMAP3621_GOSSAMER_EVT1C=y)
Load Address: 0x80008000
Entry Point: 0x80008000
```

### Build Artifacts
```
source/kernel/src/
├── arch/arm/boot/
│   ├── uImage          # Final bootable image
│   ├── zImage          # Compressed kernel image  
│   └── Image           # Uncompressed kernel image
├── System.map          # Kernel symbol map
└── vmlinux             # Kernel ELF executable

firmware/boot/
└── uImage              # Deployment-ready image
```

---

## 🔧 Configuration Reference

### NST Hardware Configuration
```bash
# Essential NST-specific configs (auto-applied)
CONFIG_ARCH_OMAP3=y
CONFIG_MACH_OMAP3621_GOSSAMER_EVT1C=y
CONFIG_FB_OMAP3EP=y                    # E-Ink display
CONFIG_TOUCHSCREEN_ZFORCE=y            # Touch input
CONFIG_KEYBOARD_TWL4030=y              # Hardware buttons
CONFIG_MMC_OMAP_HS=y                   # SD card support
CONFIG_USB_MUSB_HDRC=y                 # USB OTG
```

### SquireOS Module Configuration
```bash
# Medieval-themed modules (manually added)
CONFIG_SQUIREOS=m                      # Core SquireOS module
CONFIG_SQUIREOS_JESTER=y               # ASCII art mood system
CONFIG_SQUIREOS_TYPEWRITER=y           # Writing statistics
CONFIG_SQUIREOS_WISDOM=y               # Inspirational quotes
```

### Memory Configuration
```bash
# Memory management (critical for 256MB limit)
CONFIG_FLATMEM=y                       # Flat memory model
CONFIG_VMSPLIT_3G=y                    # 3GB user/1GB kernel split
CONFIG_PREEMPT=y                       # Preemptible kernel
CONFIG_HZ=128                          # Timer frequency
CONFIG_LOG_BUF_SHIFT=14                # 16KB kernel log buffer
```

### Performance Optimization
```bash
# E-Ink display optimization
CONFIG_FB_DEFERRED_IO=y                # Batched display updates
CONFIG_FB_SYS_FOPS=y                   # System framebuffer ops

# Power management
CONFIG_CPU_FREQ=y                      # Dynamic frequency scaling
CONFIG_CPU_IDLE=y                      # CPU idle states
CONFIG_PM=y                            # Power management
CONFIG_SUSPEND=y                       # Suspend support
```

---

## 🐛 Troubleshooting Guide

### Common Build Issues

**Issue**: `arm-linux-androideabi-gcc: not found`
```bash
# Solution: Use Docker environment
docker run --rm quillkernel-unified which arm-linux-androideabi-gcc
# Should return: /opt/android-ndk/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin/arm-linux-androideabi-gcc
```

**Issue**: `Can't use 'defined(@array)' at kernel/timeconst.pl line 373`
```bash
# Solution: Already fixed in current source
grep -n "if (!@val)" source/kernel/src/kernel/timeconst.pl
# Should show line 373 with correct syntax
```

**Issue**: `No rule to make target 'omap3621_gossamer_evt1c_defconfig'`
```bash
# Solution: Verify kernel source integration
ls source/kernel/src/arch/arm/configs/omap3621_gossamer_evt1c_defconfig
# File should exist from felixhaedicke/nst-kernel integration
```

**Issue**: `uImage not created`
```bash
# Check if zImage was created first
ls -la source/kernel/src/arch/arm/boot/zImage

# Verify u-boot-tools is available in Docker
docker run --rm quillkernel-unified which mkimage
```

### Build Performance Issues

**Slow Build Times**:
```bash
# Increase parallel jobs (default: 4)
docker run --rm -v "$(pwd)/source/kernel:/kernel" -w /kernel/src \
  quillkernel-unified make -j8 ARCH=arm CROSS_COMPILE=arm-linux-androideabi- uImage

# Use ccache for faster rebuilds (if available)
docker run --rm -v "$(pwd)/source/kernel:/kernel" -w /kernel/src \
  quillkernel-unified bash -c "export USE_CCACHE=1 && make -j4 ARCH=arm CROSS_COMPILE=arm-linux-androideabi- uImage"
```

**Memory Issues**:
```bash
# Check available Docker memory
docker run --rm quillkernel-unified free -h

# Reduce parallel jobs if needed
make -j2 ARCH=arm CROSS_COMPILE=arm-linux-androideabi- uImage
```

### Configuration Issues

**Missing Modules**:
```bash
# Verify SquireOS configuration
grep -E "CONFIG_SQUIREOS" source/kernel/src/.config

# Re-apply if missing
echo -e '\nCONFIG_SQUIREOS=m\nCONFIG_SQUIREOS_JESTER=y\nCONFIG_SQUIREOS_TYPEWRITER=y\nCONFIG_SQUIREOS_WISDOM=y' >> source/kernel/src/.config
```

**Wrong Configuration**:
```bash
# Reset to NST defaults
cd source/kernel/src
make ARCH=arm omap3621_gossamer_evt1c_defconfig

# Then re-add SquireOS configs
echo -e '\nCONFIG_SQUIREOS=m\nCONFIG_SQUIREOS_JESTER=y\nCONFIG_SQUIREOS_TYPEWRITER=y\nCONFIG_SQUIREOS_WISDOM=y' >> .config
```

---

## 📊 Build Validation

### Expected Build Output
```bash
# Successful build indicators
✓ "Image arch/arm/boot/uImage is ready"
✓ uImage size: ~1.9MB (1904584 bytes)
✓ Load Address: 80008000
✓ Entry Point: 80008000
✓ Image Type: ARM Linux Kernel Image (uncompressed)
```

### File Verification
```bash
# Verify uImage format
file firmware/boot/uImage
# Expected: u-boot legacy uImage, Linux-2.6.29-omap1, Linux/ARM, OS Kernel Image

# Check size constraints
du -h firmware/boot/uImage
# Should be ~1.9M (reasonable for NST memory constraints)

# Verify load address
hexdump -C firmware/boot/uImage | head -2
# Should show 80008000 at bytes 16-19 (load address) and 20-23 (entry point)
```

### Configuration Validation
```bash
# Essential configs present
grep -c "CONFIG_ARCH_OMAP3=y" source/kernel/src/.config
grep -c "CONFIG_MACH_OMAP3621_GOSSAMER_EVT1C=y" source/kernel/src/.config
grep -c "CONFIG_FB_OMAP3EP=y" source/kernel/src/.config

# SquireOS configs present  
grep -c "CONFIG_SQUIREOS=m" source/kernel/src/.config
grep -c "CONFIG_SQUIREOS_JESTER=y" source/kernel/src/.config
```

---

## 🔬 Technical Specifications

### Kernel Version Details
```yaml
Version: Linux 2.6.29-omap1
Architecture: ARM
Target Hardware: OMAP3621 Gossamer EVT1C (Nook SimpleTouch)
Compiler: GCC 4.9.x (Android NDK r12b)
Build System: Kbuild
Module Support: Loadable modules enabled
```

### Memory Layout
```yaml
Physical RAM: 256MB total
Kernel Load: 0x80008000 (128MB mark)
Virtual Split: 3GB user / 1GB kernel
Page Size: 4KB
Memory Model: FLATMEM (no NUMA)
```

### Hardware Support Matrix
```yaml
Display:
  - E-Ink Panel: OMAP3EP framebuffer driver
  - Resolution: 800x600 @ 16 grayscale levels
  - Refresh: Deferred I/O for E-Ink optimization

Input:
  - Touchscreen: Zforce touch controller
  - Buttons: TWL4030 keypad driver
  - GPIO: General purpose I/O support

Storage:
  - Internal: MMC/eMMC via OMAP HS controller
  - External: SD card support
  - USB: MUSB OTG controller

Power:
  - PMIC: TWL4030 power management
  - CPU Freq: Dynamic frequency scaling
  - Suspend: Android-style power management
```

---

## 🚀 Advanced Operations

### Custom Configuration
```bash
# Create custom defconfig
cd source/kernel/src
make ARCH=arm savedefconfig
cp defconfig arch/arm/configs/quillkernel_defconfig

# Use custom config in build script
sed -i 's/omap3621_gossamer_evt1c_defconfig/quillkernel_defconfig/' build_kernel.sh
```

### Module Development
```bash
# Prepare for SquireOS module development
mkdir -p source/kernel/src/drivers/squireos
cat > source/kernel/src/drivers/squireos/Makefile << 'EOF'
obj-$(CONFIG_SQUIREOS) += squireos_core.o
obj-$(CONFIG_SQUIREOS) += jester.o  
obj-$(CONFIG_SQUIREOS) += typewriter.o
obj-$(CONFIG_SQUIREOS) += wisdom.o
EOF
```

### Performance Profiling
```bash
# Time the build process
time ./build_kernel.sh

# Monitor Docker resource usage during build
docker stats --no-stream quillkernel-unified

# Profile disk usage
du -sh source/kernel/src/
```

---

## 📋 Quick Reference Tables

### Build Commands Summary
| Command | Purpose | Time | Output |
|---------|---------|------|--------|
| `./build_kernel.sh` | Complete build | 8-10 min | uImage + modules |
| `make uImage` | Kernel only | 6-8 min | uImage |
| `make zImage` | Compressed kernel | 5-7 min | zImage |
| `make modules` | Modules only | 1-2 min | .ko files |

### Configuration Files
| File | Purpose | Location |
|------|---------|----------|
| `.config` | Active kernel config | `source/kernel/src/.config` |
| `defconfig` | Default NST config | `arch/arm/configs/omap3621_gossamer_evt1c_defconfig` |
| `uImage.config` | Proven config | `source/kernel/nst-proven.config` |

### Build Artifacts
| Artifact | Size | Purpose |
|----------|------|---------|
| `uImage` | ~1.9MB | Bootable kernel image |
| `zImage` | ~1.9MB | Compressed kernel |
| `vmlinux` | ~15MB | Debug kernel (with symbols) |
| `System.map` | ~1MB | Kernel symbol table |

---

*"By quill and candlelight, may your kernels compile true and your builds be swift!"* 🕯️⚡

**Last Updated**: August 12, 2025  
**Build System Version**: QuillKernel v1.0.0  
**Kernel Source**: felixhaedicke/nst-kernel (XDA-proven)