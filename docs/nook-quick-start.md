# Nook Writing System - Quick Start Guide

Transform your Barnes & Noble Nook Simple Touch into a distraction-free Linux typewriter in 30 minutes.

## Prerequisites

- Nook Simple Touch (BNRV300) 
- Docker installed on your computer
- MicroSD card (8-32GB) + reader
- USB OTG cable + keyboard
- Git

## Step 1: Build the System (5 minutes)

```bash
# Clone and build
git clone https://github.com/yourusername/nook-writing-system
cd nook-writing-system

# Build the Docker image
docker build -t nook-system -f nookwriter.dockerfile .

# Create system export
docker create --name nook-export nook-system
docker export nook-export | gzip > nook-debian.tar.gz
docker rm nook-export
```

You now have `nook-debian.tar.gz` - a complete Linux system ready for your Nook.

## Step 2: Prepare Your Nook (10 minutes)

### Root the Device

1. Download [NookManager](https://github.com/doozan/NookManager/releases)
2. Write to SD card:
   ```bash
   sudo dd if=NookManager.img of=/dev/sdX bs=4M status=progress
   sync
   ```
3. Insert SD card into Nook and power on
4. Follow prompts to root device
5. Remove SD card when complete

### Install USB Host Kernel

**Option A: Pre-built kernel (easiest)**
```bash
# Search XDA Forums for "Nook Simple Touch USB kernel"
# Download any kernel version 174+ with USB host support
# Example: mali100's kernel or latuk's kernel
```

**Option B: Build nst-kernel**
```bash
git clone https://github.com/felixhaedicke/nst-kernel
cd nst-kernel
# Requires Android NDK
make ARCH=arm CROSS_COMPILE=/path/to/ndk/toolchain/bin/arm-linux-androideabi-
# Output: arch/arm/boot/uImage
```

Install kernel via ClockworkMod Recovery.

## Step 3: Deploy to SD Card (10 minutes)

### Partition the Card

```bash
# Create partitions (replace sdX with your device)
sudo fdisk /dev/sdX << EOF
o
n
p
1

+100M
t
c
n
p
2


w
EOF

# Format
sudo mkfs.vfat -F32 -n BOOT /dev/sdX1
sudo mkfs.f2fs -l NOOK /dev/sdX2
```

### Install the System

```bash
# Mount partitions
sudo mkdir -p /mnt/{boot,root}
sudo mount /dev/sdX1 /mnt/boot
sudo mount /dev/sdX2 /mnt/root

# Extract system
sudo tar -xzf nook-debian.tar.gz -C /mnt/root/

# Create boot config
cat << 'EOF' | sudo tee /mnt/boot/uEnv.txt
bootargs=console=ttyS0,115200n8 root=/dev/mmcblk0p2 rootfstype=f2fs rw rootwait mem=256M
bootcmd=mmc rescan; fatload mmc 0:1 0x80300000 uImage; bootm 0x80300000
EOF

# Copy kernel (if you have uImage)
# sudo cp uImage /mnt/boot/

# Unmount
sudo umount /mnt/boot /mnt/root
```

## Step 4: First Boot (5 minutes)

1. Insert SD card into Nook
2. Connect USB keyboard via OTG cable
3. Power on (takes ~20 seconds)
4. Menu appears on E-Ink display

## Using Your Nook Writer

### Keyboard Shortcuts

- **Z** - Create new timestamped note
- **D** - Open draft mode
- **R** - Resume last session
- **S** - Sync notes to cloud
- **Q** - Shutdown

### Vim Commands

- `Space + w` - Save file
- `Space + q` - Quit
- `Space + z` - New Zettelkasten note
- `:Goyo` - Distraction-free mode
- `:Pencil` - Better word wrapping

### Cloud Sync Setup

```bash
# In the Nook terminal
rclone config

# Follow prompts for your cloud service
# Then sync with: sync-notes
```

## What's Included

- **Debian Linux** - Stable, compatible base
- **Vim** - With writing-focused plugins (Pencil, Goyo, Zettel)
- **FBInk** - E-Ink display driver
- **Cloud Sync** - Via rclone (Dropbox, Google Drive, etc.)
- **Optimized Scripts** - Menu system, auto-sync

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Keyboard not detected | Try powered USB hub |
| Screen ghosting | Full refresh happens automatically |
| Won't boot | Verify kernel is on SD card boot partition |
| Menu not appearing | Check USB keyboard connection |

## Next Steps

- Configure WiFi: Edit `/etc/network/interfaces`
- Customize Vim: Edit `~/.vimrc`
- Add spell checking: `apt-get update && apt-get install aspell`
- Read [detailed walkthrough](nook-detailed-walkthrough.md) for advanced setup

## System Specs

- Base: Debian 11 (Bullseye)
- RAM Usage: ~95MB (leaves 160MB for writing)
- Storage: 797MB base image
- Boot Time: ~20 seconds

Done! Your Nook is now a Linux writing machine.