# How to Build a Custom Kernel

Build QuillKernel - a medieval-themed, writer-optimized kernel for the Nook Simple Touch with whimsical features and USB keyboard support.

## Prerequisites

- Docker Engine 20.10+ (recommended) OR Linux build environment
- 4GB free disk space
- Basic command line knowledge
- 1-2 hours for first build

## Quick Start - Docker Build (Recommended)

The easiest way to build QuillKernel with medieval patches:

```bash
cd nook/nst-kernel
./squire-kernel-patch.sh  # Apply medieval patches
docker build -f Dockerfile.build -t quillkernel .

# Extract the built kernel
docker create --name kernel-extract quillkernel
docker cp kernel-extract:/build/uImage ./build/
docker rm kernel-extract
```

This builds a complete QuillKernel with:
- Court jester ASCII art companion
- Achievement system for writers
- `/proc/squireos/` interface
- Writing statistics tracking

## Manual Setup

### Step 1: Install Dependencies

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y \
    git wget tar gzip bzip2 \
    build-essential libncurses5-dev \
    bc python2 device-tree-compiler

# Create Python 2 symlink if needed
sudo ln -s /usr/bin/python2 /usr/bin/python
```

### Step 2: Get Android NDK

The Nook kernel requires Android's toolchain:

```bash
cd ~
wget https://dl.google.com/android/repository/android-ndk-r10e-linux-x86_64.zip
unzip android-ndk-r10e-linux-x86_64.zip
```

### Step 3: Clone Kernel Source

```bash
git clone https://github.com/felixhaedicke/nst-kernel.git
cd nst-kernel
```

## Configuration

### Using Default Config

```bash
# Set up cross-compilation
export CROSS_COMPILE=~/android-ndk-r10e/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin/arm-linux-androideabi-
export ARCH=arm

# Load Nook config
make omap3621_gossamer_defconfig
```

### Customizing Kernel

```bash
# Open configuration menu
make menuconfig
```

Key options for typewriter use:

#### Power Management
- `CONFIG_PM_RUNTIME=y` - Better battery life
- `CONFIG_CPU_IDLE=y` - CPU power saving
- `CONFIG_SUSPEND=y` - Proper sleep mode

#### USB Support
- `CONFIG_USB_SUPPORT=y` - Core USB
- `CONFIG_USB_EHCI_HCD=y` - USB 2.0
- `CONFIG_USB_HID=y` - Keyboard/mouse

#### Memory Optimization
- `CONFIG_SLUB=y` - Efficient allocator
- `CONFIG_ZRAM=y` - Compressed swap
- Disable unused drivers

#### E-Ink Specific
- `CONFIG_FB_OMAP3EP=y` - E-paper driver
- `CONFIG_FB_OMAP3EP_MANAGE_BORDER=y` - Border control

### QuillKernel Medieval Features

The QuillKernel adds whimsical medieval theming:

```bash
# Apply patches before building
./squire-kernel-patch.sh
```

This adds:
- **Court Jester**: ASCII art companion during boot
- **Achievement System**: Track writing milestones
- **Writing Stats**: `/proc/squireos/typewriter/stats`
- **Medieval Messages**: "By quill and candlelight..."
- **Wisdom Quotes**: Inspirational writing quotes

## Building

### Compile Kernel

```bash
# Use all CPU cores
make -j$(nproc) uImage
```

Build time: 10-30 minutes depending on CPU.

### Build Output

Find your kernel at:
```
arch/arm/boot/uImage
```

### Verify Build

```bash
# Check file
ls -lh arch/arm/boot/uImage

# Should show ~2-3MB file
-rw-r--r-- 1 user user 2.8M Nov 16 10:30 uImage
```

## Creating Installable Package

### Option 1: Simple Zip

```bash
cd ~/nook-kernel-dev
mkdir -p kernel-package/boot
cp nst-kernel/arch/arm/boot/uImage kernel-package/boot/
cd kernel-package
zip -r ../nook-kernel-typewriter.zip boot
```

### Option 2: CWM-Compatible Zip

Create proper update script:

```bash
mkdir -p META-INF/com/google/android/
```

Create `update-script`:
```
show_progress 0.1 0
ui_print "Installing Typewriter Kernel..."
mount /boot
package_extract_dir boot /boot
unmount /boot
show_progress 0.1 10
ui_print "Done!"
```

## Testing Your Kernel

### Docker Testing

Test QuillKernel features in Docker:

```bash
cd nst-kernel/test
./verify-build-simple.sh  # Quick verification
./test-in-docker.sh       # Comprehensive tests
```

### On Device

1. Copy uImage to SD card boot partition
2. Boot and check `dmesg` output
3. Verify USB keyboard works
4. Check medieval features:
   ```bash
   cat /proc/squireos/jester     # See the court jester
   cat /proc/squireos/wisdom     # Get writing wisdom
   cat /proc/squireos/typewriter/stats  # View stats
   ```

## Troubleshooting Builds

### Common Errors

#### "arm-linux-androideabi-gcc not found"

```bash
# Fix path
export PATH=$PATH:~/android-ndk-r10e/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin/
```

#### "ncurses.h not found"

```bash
sudo apt-get install libncurses5-dev
```

#### Build fails with Python errors

```bash
# Use Python 2
export PYTHON=python2
```

### Clean Build

If build fails:

```bash
make clean
make mrproper
# Then reconfigure and rebuild
```

## Advanced Options

### Debug Kernel

Enable debugging:

```bash
# In menuconfig
Kernel hacking → 
  [*] Kernel debugging
  [*] Debug filesystem
```

### Custom Drivers

Add E-Ink optimizations:

1. Edit `drivers/video/omap3ep/`
2. Adjust refresh timings
3. Compile and test

### Kernel Modules

Build as modules to save space:

```bash
# In menuconfig, press 'M' instead of '*'
# Then build modules
make modules
```

## Next Steps

After building:

1. [Install your kernel](install-custom-kernel.md)
2. [Optimize for battery life](optimize-battery.md)
3. Share your config with community!

## Build Script Reference

Complete build script:

```bash
#!/bin/bash
# Full kernel build

# Setup
export CROSS_COMPILE=~/android-ndk-r10e/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin/arm-linux-androideabi-
export ARCH=arm

# Configure
make omap3621_gossamer_defconfig

# Optional: customize
# make menuconfig

# Build
make -j$(nproc) uImage

# Package
echo "Kernel at: arch/arm/boot/uImage"
```

---

🔧 **Pro tip**: Save your `.config` file! It contains all your customizations and saves hours of reconfiguration.
