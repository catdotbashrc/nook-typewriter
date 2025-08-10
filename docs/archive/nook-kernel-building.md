# Building Your Own Nook Simple Touch Kernel

Welcome to the elite club of kernel builders! This guide will walk you through compiling your own custom kernel for the Nook Simple Touch.

## Why Build Your Own Kernel?

- **Bragging Rights**: Join the <1% of developers who've compiled a kernel
- **Custom Features**: Enable exactly what you need, disable the rest
- **Learning**: Understand how hardware really works
- **Optimization**: Squeeze every bit of performance from 256MB RAM

## Prerequisites

### Required Tools

1. **Linux Machine** (or WSL2 on Windows)
   - Ubuntu 20.04+ recommended
   - ~10GB free disk space

2. **Android NDK** (for cross-compilation)
   ```bash
   # Download Android NDK r23c (proven to work)
   wget https://dl.google.com/android/repository/android-ndk-r23c-linux.zip
   unzip android-ndk-r23c-linux.zip
   ```

3. **Build Dependencies**
   ```bash
   sudo apt-get update
   sudo apt-get install -y \
       git build-essential bc \
       libncurses5-dev libssl-dev \
       device-tree-compiler u-boot-tools
   ```

## Step 1: Get the Kernel Source

We'll use the nst-kernel which has USB host fixes already applied:

```bash
# Clone the kernel
git clone https://github.com/felixhaedicke/nst-kernel
cd nst-kernel

# Check out a stable point (optional)
git log --oneline | head -10  # See recent commits
```

## Step 2: Set Up Build Environment

```bash
# Set up NDK path (adjust to your location)
export ANDROID_NDK=/path/to/android-ndk-r23c
export PATH=$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH

# Set architecture and compiler
export ARCH=arm
export CROSS_COMPILE=arm-linux-androideabi-

# Test compiler works
${CROSS_COMPILE}gcc --version
```

## Step 3: Configure the Kernel

### Option A: Use Default Nook Config
```bash
# Use the pre-made Nook config
make nook_defconfig
```

### Option B: Typewriter-Optimized Configuration
```bash
# Start with default, then customize for minimal writing device
make nook_defconfig
make menuconfig  # Opens interactive menu
```

**Essential Features (Keep Enabled)**:
- Device Drivers → USB support → USB Host Controller Drivers → [*] OMAP EHCI support
- Device Drivers → USB support → [*] USB Mass Storage support
- Device Drivers → HID support → [*] USB Human Interface Device
- Device Drivers → Graphics support → [*] Support for frame buffer devices
- File systems → [*] F2FS filesystem support
- File systems → [*] FAT file system support

**Disable for Maximum Memory Savings**:
```
General setup →
  [ ] Support for paging of anonymous memory (swap)
  [ ] Enable process_vm_readv/writev syscalls
  [ ] Auditing support
  [ ] Kernel .config support
  [ ] Enable kernel headers through /sys/kernel/kheaders.tar.xz

Processor type and features →
  [ ] Symmetric multi-processing support (we have 1 core!)
  [ ] Suspend to RAM and standby
  
Kernel features →
  [ ] High Resolution Timer Support (save ~300KB)
  [ ] Debug Filesystem (debugfs)
  
Device Drivers →
  [ ] Network device support (no ethernet/wifi in kernel)
  [ ] Multimedia support (no camera/video)
  [ ] Sound card support (no audio)
  
File systems →
  [ ] Network File Systems (no NFS/CIFS needed)
  [ ] Native language support (keep only ASCII)
```

### Option C: Ultra-Minimal Script
```bash
# After make nook_defconfig, run this to disable everything unnecessary
cat >> .config << 'EOF'
# Typewriter optimizations
CONFIG_SWAP=n
CONFIG_MODULES=n
CONFIG_BLK_DEV_INITRD=n
CONFIG_SYSVIPC=n
CONFIG_AUDIT=n
CONFIG_IKCONFIG=n
CONFIG_CGROUPS=n
CONFIG_CHECKPOINT_RESTORE=n
CONFIG_NAMESPACES=n
CONFIG_SCHED_AUTOGROUP=n
CONFIG_RELAY=n
CONFIG_BLK_DEV_LOOP=n
CONFIG_INPUT_TOUCHSCREEN=n
CONFIG_SERIO=n
CONFIG_VT=n
CONFIG_LEGACY_PTYS=n
CONFIG_DEVMEM=n
# Power saving
CONFIG_CPU_IDLE=y
CONFIG_CPU_FREQ=n
CONFIG_SUSPEND=y
CONFIG_PM_RUNTIME=y
EOF

# Regenerate config with changes
make olddefconfig
```

## Step 4: Build the Kernel

```bash
# Clean any previous builds
make clean

# Build kernel image (this takes 15-30 minutes)
make -j$(nproc) uImage

# Watch the magic happen!
# You'll see thousands of files compile
```

**What's Happening**:
- Compiling ~15,000 source files
- Creating drivers for CPU, memory, display, USB
- Linking everything into one bootable image

## Step 5: Verify Your Build

```bash
# Check if kernel was created
ls -lh arch/arm/boot/uImage

# Should show something like:
# -rw-rw-r-- 1 user user 2.1M Dec 10 15:30 arch/arm/boot/uImage

# Get kernel info
mkimage -l arch/arm/boot/uImage
```

## Step 6: Prepare for Installation

### Create Kernel Package
```bash
# Create a flashable zip (ClockworkMod format)
mkdir -p kernel-package/META-INF/com/google/android
mkdir -p kernel-package/kernel

# Copy your kernel
cp arch/arm/boot/uImage kernel-package/kernel/

# Create updater script
cat > kernel-package/META-INF/com/google/android/updater-script << 'EOF'
ui_print("Installing Custom NST Kernel...");
package_extract_dir("kernel", "/boot");
ui_print("Kernel installed successfully!");
ui_print("Built by a true hacker!");
EOF

# Create update-binary (use a dummy one)
touch kernel-package/META-INF/com/google/android/update-binary

# Package it
cd kernel-package
zip -r ../nst-custom-kernel.zip .
cd ..
```

## Step 7: Install Your Kernel

1. **Copy to SD Card**:
   ```bash
   # Mount your SD card
   sudo cp nst-custom-kernel.zip /media/sdcard/
   ```

2. **Boot into ClockworkMod Recovery**
   - Power off Nook
   - Insert SD card with CWM
   - Power on

3. **Flash Your Kernel**
   - Choose "install zip from sdcard"
   - Select your `nst-custom-kernel.zip`
   - Confirm installation
   - Reboot

## Troubleshooting

### Build Errors

**"arm-linux-androideabi-gcc: not found"**
- Check NDK path is correct
- Ensure you're using NDK r23c (newer versions changed paths)

**"Can't find default configuration"**
```bash
# List available configs
ls arch/arm/configs/*nook*
```

### Boot Issues

If your kernel doesn't boot:
1. Don't panic! Original kernel is still there
2. Boot with CWM SD card
3. Flash a known working kernel

## USB Keyboard Optimization

Since USB keyboard support is critical for our typewriter, here's how to configure it properly:

### Essential USB Options
```bash
# In menuconfig, ensure these are enabled:
Device Drivers → USB support →
  [*] Support for Host-side USB
  [*] EHCI HCD (USB 2.0) support
  [*] OHCI HCD (USB 1.1) support
  [*] USB Mass Storage support (for USB drives)
  
Device Drivers → HID support →
  [*] USB HID transport layer
  [*] Generic HID driver
  [*] USB HID Boot Protocol drivers
    [*] USB HIDBP Keyboard support
```

### USB Power Saving
Add these to your `.config` for better battery life:
```bash
# USB autosuspend (keyboard stays responsive but saves power when idle)
CONFIG_USB_SUSPEND=y
CONFIG_USB_AUTOSUSPEND_DELAY=2

# Disable USB features we don't need
CONFIG_USB_PRINTER=n
CONFIG_USB_WDM=n
CONFIG_USB_AUDIO=n
CONFIG_USB_VIDEO_CLASS=n
CONFIG_USB_GSPCA=n
CONFIG_USB_SERIAL=n
CONFIG_USB_NET_DRIVERS=n
```

### Kernel Parameters for USB
Add to `uEnv.txt` on your boot partition:
```
usbcore.autosuspend=2      # Suspend USB devices after 2 seconds idle
usbhid.mousepoll=0         # Disable mouse polling (we only use keyboard)
```

### Testing USB in Your Kernel
After booting your custom kernel:
```bash
# Check if USB host is working
lsusb

# Monitor USB events when plugging keyboard
dmesg -w

# Check power consumption
cat /sys/bus/usb/devices/*/power/level
```

## Advanced Customizations

### Memory Optimization
Edit `.config` after `make nook_defconfig`:
```bash
# Disable unused features
CONFIG_SWAP=n           # No swap support needed
CONFIG_MODULES=n        # Build everything into kernel
CONFIG_PM_DEBUG=n       # Disable power management debugging
```

### Display Optimizations
```bash
# In menuconfig:
# Device Drivers → Graphics → Console display driver
# Enable "Framebuffer Console Rotation"
```

### USB Improvements
```bash
# Better USB device support
CONFIG_USB_STORAGE=y
CONFIG_USB_HID=y
CONFIG_USB_KBD=y
```

## Kernel Hacking Tips

1. **Start Small**: First build works? Great! Make one change at a time
2. **Keep Backups**: Always have a working kernel on hand
3. **Read Logs**: `dmesg` on device shows kernel messages
4. **Join Community**: XDA Forums Nook section has experts

## Verification Script

Create `verify-kernel.sh`:
```bash
#!/bin/bash
echo "=== Your Custom Kernel Info ==="
echo "Size: $(ls -lh arch/arm/boot/uImage | awk '{print $5}')"
echo "Build time: $(stat arch/arm/boot/uImage | grep Modify)"
echo "Config changes from default:"
diff arch/arm/configs/nook_defconfig .config | grep "^>" | wc -l
echo ""
echo "You are now officially a KERNEL DEVELOPER!"
```

## Kernel Hacking Safety (From Linus's Guide)

### The Golden Rules

1. **No Memory Protection** 
   - Your code runs in kernel space - one bad pointer crashes EVERYTHING
   - The Nook won't blue screen, it'll just freeze or reboot
   - Always double-check array bounds and pointer validity

2. **Limited Stack Space**
   - Kernel stacks are TINY (3-6KB on our ARM processor)
   - Never use large arrays on the stack
   - Avoid deep recursion
   ```c
   /* BAD - will overflow kernel stack */
   void bad_function() {
       char huge_buffer[8192];  // BOOM!
   }
   
   /* GOOD - use dynamic allocation */
   void good_function() {
       char *buffer = kmalloc(8192, GFP_KERNEL);
       if (!buffer) return -ENOMEM;
       /* use buffer */
       kfree(buffer);
   }
   ```

3. **Enable Debug Options**
   ```bash
   # In menuconfig, enable:
   CONFIG_DEBUG_ATOMIC_SLEEP=y    # Catch sleep-in-atomic bugs
   CONFIG_DEBUG_KERNEL=y          # General debugging
   CONFIG_KALLSYMS=y              # Symbolic crash dumps
   ```

4. **Test Gradually**
   - Make ONE change at a time
   - Boot test after each change
   - Keep serial console logs if possible

### Common Nook-Specific Pitfalls

1. **E-Ink Display Driver**
   - Never write to framebuffer from interrupt context
   - Display updates are SLOW - don't spam them

2. **Limited RAM (256MB)**
   - Every enabled feature costs memory
   - Disable what you don't need
   - Monitor with `free -m` after boot

3. **Power Management**
   - Bad suspend/resume code = dead battery
   - Test sleep modes thoroughly

## What You've Accomplished

By building this kernel, you've:
- Cross-compiled for ARM architecture
- Configured hardware drivers at the lowest level
- Created a bootable OS kernel from source
- Joined an elite group of developers

Most "full-stack" developers have never done this. You're now operating at the actual bottom of the stack where software meets hardware.

## Next Steps

1. **Test USB Devices**: Try different keyboards/drives
2. **Optimize Further**: Disable more unused features
3. **Add Features**: Enable new drivers
4. **Share**: Post your build on XDA Forums!

Remember: You didn't just install someone else's kernel - you BUILT your own. That's badass.

## Typewriter Kernel Checklist

Before building, ensure your config has:

### ✅ MUST HAVE (Writing Essentials)
- [ ] USB Host support (EHCI/OHCI)
- [ ] USB HID Keyboard support  
- [ ] Framebuffer console
- [ ] F2FS filesystem (for SD card)
- [ ] FAT filesystem (for boot partition)
- [ ] Power management (suspend/resume)

### ❌ MUST DISABLE (Save RAM)
- [ ] Network stack (no WiFi in kernel)
- [ ] Sound subsystem
- [ ] Video4Linux
- [ ] Bluetooth
- [ ] IrDA
- [ ] Amateur Radio
- [ ] Virtualization
- [ ] Security modules (SELinux, etc)
- [ ] Kernel debugging (for production)

### 🔋 Power Optimization
- [ ] CPU idle enabled
- [ ] USB autosuspend enabled
- [ ] Tickless kernel (CONFIG_NO_HZ)
- [ ] Power-efficient workqueues

### 📏 Size Target
Your kernel should be:
- **uImage size**: 2-3MB (stock is ~4MB)
- **RAM usage**: <50MB after boot
- **Boot time**: <20 seconds

## Resources

- [Linux Kernel Documentation](https://www.kernel.org/doc/html/latest/)
- [ARM Cross Compilation](https://www.kernel.org/doc/html/latest/arm/index.html)
- [Nook Touch XDA Forum](https://forum.xda-developers.com/c/barnes-noble-nook-touch.1129/)
- [Kernel Config Database](https://cateee.net/lkddb/web-lkddb/) - Search what each option does

## Final Words

You're not just installing software - you're crafting the foundational layer between hardware and your writing environment. Every option you disable frees RAM for your words. Every optimization extends battery life for longer writing sessions.

This kernel will be YOUR kernel, optimized for ONE purpose: writing without distraction.

Now go forth and tell people you compile kernels in your spare time!