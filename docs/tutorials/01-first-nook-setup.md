# Your First Nook Typewriter Setup

This tutorial will walk you through transforming your Barnes & Noble Nook Simple Touch into a Linux-powered typewriter. By the end, you'll have a fully functional writing device.

## What You'll Need

### Hardware
- Barnes & Noble Nook Simple Touch (Model BNRV300)
- MicroSD card (8GB minimum, 16GB recommended)
- SD card reader for your computer
- USB OTG cable
- USB keyboard (wired recommended)
- Computer with Docker installed

### Time Required
- Preparation: 30 minutes
- Building: 20 minutes  
- Deployment: 15 minutes
- **Total: About 1 hour**

## Step 1: Prepare Your Nook

### 1.1 Skip OOBE (Out of Box Experience)

Since B&N servers are offline, you must skip registration:

1. Turn on your Nook
2. When you see the welcome screen, hold the **top-right button**
3. While holding, **swipe up** from bottom-left to top-right
4. The Nook will skip registration and boot to the home screen

### 1.2 Root Your Nook

1. Download [NookManager](https://github.com/doozan/NookManager/releases/download/0.5.0/NookManager-0.5.0.zip)
2. Extract the `.img` file from the zip
3. Write to a small SD card (256MB-2GB):
   ```bash
   # Linux/Mac
   sudo dd if=NookManager.img of=/dev/sdX bs=4M status=progress
   
   # Windows: Use Win32DiskImager
   ```
4. Insert SD card into your Nook
5. Power on - NookManager will boot automatically
6. Select "Root my device" and wait for completion
7. Remove SD card when prompted

✅ **Checkpoint**: Your Nook is now rooted and ready for customization.

## Step 2: Build the Typewriter System

### 2.1 Get the Code

```bash
git clone https://github.com/yourusername/nook-typewriter
cd nook-typewriter
```

### 2.2 Build the Docker Image

```bash
docker build -t nook-system -f nookwriter.dockerfile .
```

This builds a complete Debian Linux system with:
- Vim editor with writing plugins
- FBInk for E-Ink display support
- Cloud sync capabilities
- Optimized for 256MB RAM

⏱️ **Build time**: 15-20 minutes depending on internet speed

### 2.3 Create Deployment Image

```bash
# Create container
docker create --name nook-export nook-system

# Export filesystem
docker export nook-export | gzip > nook-debian.tar.gz

# Clean up
docker rm nook-export
```

✅ **Checkpoint**: You now have `nook-debian.tar.gz` ready to deploy.

## Step 3: Prepare Your SD Card

### 3.1 Partition the Card

You need two partitions:
1. **Boot** (FAT32, 100MB) - for kernel and boot files
2. **Root** (F2FS, remaining space) - for Linux system

#### Linux Instructions:
```bash
# WARNING: Replace sdX with your actual device!
sudo fdisk /dev/sdX

# In fdisk:
# o (create new partition table)
# n, p, 1, enter, +100M (create 100MB partition)
# t, c (set type to FAT32)
# n, p, 2, enter, enter (use remaining space)
# w (write and exit)

# Format partitions
sudo mkfs.vfat -F32 /dev/sdX1
sudo mkfs.f2fs /dev/sdX2
```

#### Windows Instructions:
Use MiniTool Partition Wizard (free):
1. Delete all partitions on SD card
2. Create 100MB FAT32 partition
3. Create F2FS partition with remaining space

### 3.2 Extract System Files

```bash
# Mount root partition
sudo mkdir -p /mnt/nook-root
sudo mount /dev/sdX2 /mnt/nook-root

# Extract Debian system
sudo tar -xzf nook-debian.tar.gz -C /mnt/nook-root/

# Create boot mount point
sudo mkdir -p /mnt/nook-root/boot

# Unmount
sudo umount /mnt/nook-root
```

## Step 4: Install USB Host Kernel

Your Nook needs a special kernel to support USB keyboards.

### 4.1 Get a USB Host Kernel

**Option A: Download Pre-built** (Recommended)
- Search "Nook Simple Touch USB host kernel" on XDA Forums
- Look for version 174 or newer
- Download the `.zip` file

**Option B: Build Your Own**
- See [Building a Custom Kernel](../how-to/build-custom-kernel.md)

### 4.2 Install the Kernel

1. Copy kernel zip to another SD card
2. Boot your Nook with NookManager
3. Select "Install from SD card"
4. Choose the kernel zip
5. Reboot when complete

## Step 5: Configure Boot

### 5.1 Mount Boot Partition

```bash
sudo mkdir -p /mnt/nook-boot
sudo mount /dev/sdX1 /mnt/nook-boot
```

### 5.2 Create Boot Configuration

```bash
sudo nano /mnt/nook-boot/uEnv.txt
```

Add these lines:
```
bootargs=console=ttyS0,115200n8 root=/dev/mmcblk0p2 rootfstype=f2fs rw rootwait mem=256M
bootcmd=mmc rescan; fatload mmc 0:1 0x80300000 uImage; bootm 0x80300000
```

### 5.3 Copy Kernel

**For QuillKernel** (medieval-themed):
```bash
# Build QuillKernel first
cd nst-kernel
./squire-kernel-patch.sh
docker build -f Dockerfile.build -t quillkernel .
docker run --rm -v $(pwd)/output:/output quillkernel

# Copy to boot partition
sudo cp output/uImage /mnt/nook-boot/
```

**For pre-built kernel**:
```bash
# Extract uImage from downloaded kernel zip
unzip nook-kernel.zip
sudo cp uImage /mnt/nook-boot/
```

```bash
# Unmount when done
sudo umount /mnt/nook-boot
```

## Step 6: First Boot

### 6.1 Insert and Boot

1. Safely eject SD card from computer
2. Insert into your Nook
3. Connect USB keyboard via OTG cable
4. Power on your Nook

The first boot takes about 30 seconds. You'll see:
- Kernel boot messages
- Debian system starting
- Menu appearing on E-Ink display

### 6.2 Test Your System

1. Press **1** for Vim
2. Type some text
3. Press `Ctrl+S` to save
4. Press `Ctrl+Q` to quit
5. You're writing on your Nook!

## Troubleshooting First Boot

### Black Screen
- SD card not detected - try different card
- Wrong partition format - must be FAT32 + F2FS
- Missing uEnv.txt - check boot partition

### Keyboard Not Working
- Kernel doesn't have USB host support
- Try different USB OTG cable
- For wireless: use powered USB hub

### Boot Loop
- Corrupted extraction - re-extract system
- Wrong root partition in uEnv.txt
- SD card issues - try different brand

## Next Steps

Congratulations! Your Nook is now a Linux typewriter. Next:

1. **[Writing Your First Document](02-writing-your-first-note.md)** - Learn Vim basics
2. **[Setting Up Cloud Sync](03-syncing-to-cloud.md)** - Never lose your work
3. **[Customizing Your Setup](../how-to/customize-vim-plugins.md)** - Make it yours

## Quick Reference Card

Print this for easy reference:

```
NOOK TYPEWRITER COMMANDS
========================
Menu Navigation:
1 - Open Vim
2 - File Browser  
3 - Sync to Cloud
4 - System Info
5 - Power Off

Vim Basics:
i - Insert mode
Esc - Normal mode
:w - Save
:q - Quit
:wq - Save & quit

Writing Mode:
\g - Goyo (focus mode)
\p - Pencil (writing tools)
```

---

💡 **Tip**: The E-Ink display refreshes slowly. This is normal! Full refresh happens automatically when needed.