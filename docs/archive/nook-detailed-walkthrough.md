# Nook Writing System - Detailed Walkthrough

A comprehensive guide to transforming your Nook Simple Touch into a Linux-powered writing device.

## Table of Contents

1. [Understanding the Project](#understanding-the-project)
2. [Hardware Requirements](#hardware-requirements)
3. [Building the System](#building-the-system)
4. [Preparing the Nook](#preparing-the-nook)
5. [SD Card Setup](#sd-card-setup)
6. [First Boot and Configuration](#first-boot-and-configuration)
7. [Advanced Customization](#advanced-customization)
8. [Troubleshooting](#troubleshooting)

## Understanding the Project

### What We're Building

We're replacing the Nook's Android interface with a minimal Debian Linux system optimized for distraction-free writing. The system boots from an SD card, preserving your original Nook OS.

### Key Components

- **Debian Linux**: Stable base with vast software repository
- **FBInk**: Direct E-Ink display control
- **Vim**: Powerful text editor with writing plugins
- **Custom Menu**: Simple interface for common tasks

### Why Debian?

We chose Debian over Alpine Linux for:
- Universal software compatibility
- No cross-compilation issues
- Access to 60,000+ packages
- Standard GNU/Linux behavior
- Easier development and maintenance

The trade-off is ~65MB more RAM usage, leaving us with 160MB free instead of 225MB - still plenty for text editing.

## Hardware Requirements

### Essential

- **Nook Simple Touch** (Model BNRV300)
  - Firmware 1.2.2 or earlier
  - 256MB RAM, 2GB internal storage
  
- **MicroSD Card** (8-32GB)
  - Class 10 recommended for speed
  - Will be completely erased
  
- **USB OTG Cable**
  - Micro-USB to USB-A female
  - Quality matters - cheap cables may not work

- **USB Keyboard**
  - Wired recommended (lower power draw)
  - Wireless possible with powered hub

### Optional but Recommended

- **Powered USB Hub**
  - Required for wireless keyboards
  - Allows multiple devices
  
- **SD Card Reader**
  - USB 3.0 for faster writes

## Building the System

### Prerequisites

Install Docker on your development machine:

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install docker.io docker-compose

# macOS
brew install --cask docker

# Windows
# Install Docker Desktop from docker.com
```

### Clone and Build

```bash
# Get the code
git clone https://github.com/yourusername/nook-writing-system
cd nook-writing-system

# Build the Docker image
docker build -t nook-system -f nookwriter.dockerfile .
```

This builds a complete Debian system with:
- Vim 8.2 with writing plugins
- FBInk for E-Ink display
- Cloud sync tools (rclone, rsync)
- System utilities

### Create Deployment Image

```bash
# Create a container
docker create --name nook-export nook-system

# Export the filesystem
docker export nook-export | gzip > nook-debian.tar.gz

# Clean up
docker rm nook-export
```

The resulting `nook-debian.tar.gz` contains your complete Linux system.

### Understanding the Docker Build

Our Dockerfile:
1. Starts with `debian:bullseye-slim` (minimal Debian 11)
2. Installs packages from Debian repositories
3. Compiles FBInk from source (only component needing compilation)
4. Installs Vim plugins
5. Copies configuration files
6. Sets up the environment

## Preparing the Nook

### Skip OOBE (Out of Box Experience)

If your Nook shows the setup wizard:
1. Hold the top-right button
2. Swipe right-to-left on the "Nook" logo
3. Release when the screen flashes

This is necessary because B&N servers are offline.

### Root Your Device

#### Method 1: NookManager (Recommended)

1. Download [NookManager](https://github.com/doozan/NookManager/releases)
2. Write to SD card:
   ```bash
   wget https://github.com/doozan/NookManager/releases/download/v0.5.0/NookManager.img
   sudo dd if=NookManager.img of=/dev/sdX bs=4M status=progress conv=fsync
   ```
3. Insert card into powered-off Nook
4. Power on - NookManager menu appears
5. Select "Root my device"
6. Wait for completion
7. Select "Exit" and remove card

#### Method 2: Manual Rooting

For advanced users - see XDA Forums guides.

### Install USB Host Kernel

The stock kernel doesn't support USB devices. You need a custom kernel.

#### Finding a Kernel

**Option 1: Pre-built kernels**
- Search XDA Forums for "Nook Simple Touch USB kernel"
- Look for versions 174 or higher
- Developers to search for: Guevor, mali100, latuk

**Option 2: Build nst-kernel**
```bash
# Clone the kernel
git clone https://github.com/felixhaedicke/nst-kernel
cd nst-kernel

# Install Android NDK (if not present)
wget https://dl.google.com/android/repository/android-ndk-r23c-linux.zip
unzip android-ndk-r23c-linux.zip
export PATH=$PWD/android-ndk-r23c/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH

# Configure and build
make ARCH=arm nook_defconfig
make ARCH=arm CROSS_COMPILE=arm-linux-androideabi- -j$(nproc)

# Result: arch/arm/boot/uImage
```

#### Installing the Kernel

1. Download ClockworkMod Recovery:
   ```bash
   wget https://forum.xda-developers.com/attachments/cwm-recovery-nst.zip
   unzip cwm-recovery-nst.zip
   sudo dd if=cwm-recovery.img of=/dev/sdX bs=4M
   ```

2. Copy kernel to SD card:
   ```bash
   sudo mount /dev/sdX1 /mnt
   sudo cp your-kernel.zip /mnt/
   sudo umount /mnt
   ```

3. Boot Nook with SD card
4. Install zip from SD card
5. Reboot

## SD Card Setup

### Partition Layout

We need two partitions:
1. **Boot** (FAT32, 100MB) - Kernel and boot config
2. **Root** (F2FS, remainder) - Linux system

### Automated Partitioning

```bash
#!/bin/bash
# partition-sd.sh
DEVICE=$1
if [ -z "$DEVICE" ]; then
    echo "Usage: $0 /dev/sdX"
    exit 1
fi

# Safety check
echo "This will ERASE $DEVICE. Continue? (yes/no)"
read answer
[ "$answer" != "yes" ] && exit 1

# Unmount any mounted partitions
sudo umount ${DEVICE}* 2>/dev/null

# Create partitions
sudo parted $DEVICE --script mklabel msdos
sudo parted $DEVICE --script mkpart primary fat32 1MiB 101MiB
sudo parted $DEVICE --script mkpart primary f2fs 101MiB 100%
sudo parted $DEVICE --script set 1 boot on

# Format
sudo mkfs.vfat -F32 -n BOOT ${DEVICE}1
sudo mkfs.f2fs -f -l NOOK ${DEVICE}2

echo "SD card prepared successfully"
```

### Manual Partitioning

```bash
# Start fdisk
sudo fdisk /dev/sdX

# Commands:
o  # Create new DOS partition table
n  # New partition
p  # Primary
1  # Partition 1
   # Default start
+100M  # 100MB size
t  # Change type
c  # W95 FAT32 (LBA)
n  # New partition  
p  # Primary
2  # Partition 2
   # Default start
   # Default end (rest of card)
w  # Write and exit

# Format partitions
sudo mkfs.vfat -F32 -n BOOT /dev/sdX1
sudo mkfs.f2fs -f -l NOOK /dev/sdX2
```

### Installing the System

```bash
# Create mount points
sudo mkdir -p /mnt/{boot,root}

# Mount partitions
sudo mount /dev/sdX1 /mnt/boot
sudo mount /dev/sdX2 /mnt/root

# Extract Debian system
sudo tar -xzf nook-debian.tar.gz -C /mnt/root/

# Create boot configuration
sudo tee /mnt/boot/uEnv.txt << 'EOF'
# Boot configuration for Nook Simple Touch
bootargs=console=ttyS0,115200n8 root=/dev/mmcblk0p2 rootfstype=f2fs rw rootwait mem=256M init=/sbin/init
bootcmd=mmc rescan; fatload mmc 0:1 0x80300000 uImage; bootm 0x80300000
uenvcmd=run bootcmd
EOF

# Copy kernel (if you have it)
# sudo cp uImage /mnt/boot/

# Set permissions
sudo chmod 755 /mnt/root

# Unmount
sudo umount /mnt/boot /mnt/root
sync
```

## First Boot and Configuration

### Initial Boot

1. **Insert SD card** into powered-off Nook
2. **Connect USB keyboard** via OTG cable
3. **Power on** - Boot takes ~20 seconds
4. **Menu appears** on E-Ink display

If boot fails:
- Long-press power (8 seconds) to force shutdown
- Remove SD card and boot normally
- Check SD card preparation steps

### Using the Menu System

The menu shows:
```
NOOK WRITING SYSTEM
[Z] Zettelkasten Mode
[D] Draft Mode  
[R] Resume Session
[S] Sync Notes
[Q] Shutdown
```

Press the corresponding key to select.

### First-Time Setup

#### 1. Test Writing

Press `Z` to create a test note:
- Vim opens with a timestamped file
- Type some text
- Press `Space + w` to save
- Press `Space + q` to quit

#### 2. Configure Cloud Sync

Press `S` to run sync (will fail first time):
```bash
# Exit to shell (Ctrl+C in menu)
# Configure rclone
rclone config

# Example for Dropbox:
n  # New remote
name> dropbox
Storage> dropbox
# Follow OAuth flow

# Test
rclone ls dropbox:

# Return to menu
/usr/local/bin/nook-menu.sh
```

#### 3. WiFi Setup (Optional)

```bash
# Configure network
sudo nano /etc/network/interfaces

# Add:
auto wlan0
iface wlan0 inet dhcp
    wpa-ssid "YourNetworkName"
    wpa-psk "YourPassword"

# Enable
sudo ifup wlan0
```

## Advanced Customization

### Installing Additional Software

Thanks to Debian, installation is simple:

```bash
# Update package lists
sudo apt-get update

# Spell checking
sudo apt-get install aspell aspell-en

# Word count
sudo apt-get install wc

# Python for scripts
sudo apt-get install python3-minimal

# Pandoc for document conversion
sudo apt-get install pandoc
```

### Customizing Vim

Edit `~/.vimrc`:
```vim
" Your custom settings
set spell spelllang=en_us
set textwidth=72
set tabstop=4

" Custom mappings
nnoremap <leader>c :!wc -w %<CR>
```

### Adding Vim Plugins

```bash
cd ~/.vim/pack/plugins/start
git clone https://github.com/preservim/vim-markdown
git clone https://github.com/dhruvasagar/vim-table-mode
```

### Creating Custom Scripts

Add to `/usr/local/bin/`:
```bash
#!/bin/bash
# word-count.sh
echo "Word count: $(wc -w ~/notes/*.md | tail -1 | awk '{print $1}')"
fbink -y 20 "Total words: $(wc -w ~/notes/*.md | tail -1 | awk '{print $1}')" || echo "Total words: $(wc -w ~/notes/*.md | tail -1 | awk '{print $1}')"
```

### Startup Customization

Edit `/etc/rc.local`:
```bash
#!/bin/bash
# Custom startup commands

# Disable WiFi to save power
ifdown wlan0 2>/dev/null

# Start menu system
/usr/local/bin/nook-menu.sh &

exit 0
```

## Troubleshooting

### Boot Issues

**Nook won't boot from SD card:**
- Verify SD card is FAT32/F2FS formatted
- Check uEnv.txt exists in boot partition
- Try different SD card brand
- Ensure kernel supports SD boot

**Boot loop:**
- Kernel incompatible with your Nook
- Try different kernel version
- Check serial console output

### Display Problems

**Screen not updating:**
```bash
# Force refresh
fbink -c
fbink -s
```

**Ghosting/artifacts:**
- Normal for E-Ink
- Menu does full refresh between screens
- Add more `fbink -c` calls to scripts

### Keyboard Issues

**Keyboard not detected:**
- Try different USB cable
- Use powered hub
- Test with different keyboard
- Check kernel has USB host support

**Keys not working:**
```bash
# Debug keyboard
cat /dev/input/event0
# Press keys to see output
```

### Performance Issues

**System slow:**
```bash
# Check memory usage
free -h

# Check processes
ps aux | sort -nrk 3,3 | head

# Disable unnecessary services
systemctl disable <service>
```

### Recovery

**System won't start:**
1. Boot without SD card (original Nook)
2. Mount SD card on computer
3. Check logs: `/mnt/root/var/log/`
4. Fix issues and retry

**Complete reinstall:**
```bash
# Backup notes first!
sudo mount /dev/sdX2 /mnt
sudo cp -r /mnt/root/notes ~/nook-backup/
sudo umount /mnt

# Reformat and reinstall
# ... (repeat SD card setup)
```

## Tips and Best Practices

### Battery Life

- Disable WiFi when not syncing
- Use full refresh sparingly
- Reduce screen updates in scripts
- Power off when not in use

### Writing Workflow

1. **Morning pages**: Use Draft mode
2. **Research notes**: Zettelkasten mode
3. **Sync regularly**: Prevent data loss
4. **Backup SD card**: Monthly image backup

### Maintenance

```bash
# Monthly cleanup
sudo apt-get autoremove
sudo apt-get clean

# Check filesystem
sudo fsck.f2fs -f /dev/mmcblk0p2

# Backup system
sudo dd if=/dev/sdX of=nook-backup-$(date +%Y%m%d).img bs=4M
```

## Conclusion

You now have a powerful, distraction-free writing device that:
- Runs full Linux with access to thousands of packages
- Provides excellent battery life
- Syncs to the cloud
- Costs under $50 total

The Debian base means you can extend it however you like - add Python scripts, install additional tools, or create custom interfaces. The E-Ink display ensures long writing sessions without eye strain.

Happy writing!