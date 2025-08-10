# Nook Writing System - Quick Start Guide

For experienced Linux users. Estimated time: 30 minutes.

## Prerequisites

- Nook Simple Touch (BNRV300) with firmware ≤1.2.2
- Docker installed on your development machine
- 32GB SD card + reader
- USB OTG cable
- Git

## Get Started

```bash
# Clone repository with all configurations
git clone https://github.com/community/nook-writing-system
cd nook-writing-system
```

## Build System Image

Create `Dockerfile`:
```dockerfile
FROM alpine:3.17 AS builder

# Build environment
RUN apk add --no-cache \
    build-base git cmake \
    linux-headers ncurses-dev

# Build FBInk
RUN git clone --depth=1 https://github.com/NiLuJe/FBInk && \
    cd FBInk && \
    make MINIMAL=1 FONTS=1 && \
    make install

# Build Vim with full features
RUN git clone --depth=1 https://github.com/vim/vim.git && \
    cd vim && \
    ./configure --with-features=normal \
                --enable-multibyte \
                --disable-gui \
                --disable-netbeans && \
    make && make install

# Final image
FROM alpine:3.17

# Install packages
RUN apk add --no-cache \
    vim rsync rclone openssh-client \
    git tmux ncurses bash curl wget \
    e2fsprogs f2fs-tools dosfstools \
    wireless-tools wpa_supplicant

# Copy built binaries
COPY --from=builder /usr/local/bin/fbink /usr/local/bin/
COPY --from=builder /usr/local/bin/vim /usr/local/bin/

# Add configurations
COPY config/vimrc /root/.vimrc
COPY config/vim/ /root/.vim/
COPY config/scripts/ /usr/local/bin/
COPY config/system/fstab /etc/fstab
COPY config/system/sysctl.conf /etc/sysctl.conf

# Install Vim plugins
RUN mkdir -p /root/.vim/pack/plugins/start && \
    cd /root/.vim/pack/plugins/start && \
    git clone --depth=1 https://github.com/reedes/vim-pencil && \
    git clone --depth=1 https://github.com/junegunn/goyo.vim && \
    git clone --depth=1 https://github.com/michal-h21/vim-zettel && \
    git clone --depth=1 https://github.com/itchyny/lightline.vim

# Set permissions
RUN chmod +x /usr/local/bin/*.sh

# Configure boot
RUN rc-update add localmount boot && \
    rc-update del networking boot && \
    rc-update del chronyd default

WORKDIR /root
```

Build and export:
```bash
docker build -t nook-system .
docker create --name nook-export nook-system
docker export nook-export | gzip > nook-alpine.tar.gz
docker rm nook-export
```

## Prepare Nook

### 1. Root Device

```bash
# Download and flash NookManager
wget https://archive.org/download/nook-manager/NookManager.img
sudo dd if=NookManager.img of=/dev/sdX bs=4M status=progress
sync
```

Boot Nook with SD card → Backup → Root → Remove card → Reboot

### 2. Install USB Host Kernel

Option A: Use nst-kernel (compile yourself):
```bash
# Clone and build kernel
git clone https://github.com/felixhaedicke/nst-kernel
cd nst-kernel
# Requires Android NDK in /opt/android-ndk
make ARCH=arm CROSS_COMPILE=/opt/android-ndk/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin/arm-linux-androideabi-
# Output: arch/arm/boot/uImage
```

Option B: Find pre-compiled kernel:
```bash
# Search XDA Forums for USB host kernels
# Look for versions 174+ or any kernel mentioning "USB host"
# Download CWM recovery
wget https://xdaforums.com/attachments/sd_2gb_clockwork-rc2-zip.806434/
unzip sd_2gb_clockwork-rc2-zip.806434

sudo dd if=sd_2gb_clockwork-rc2.img of=/dev/sdX bs=4M
sudo mount /dev/sdX1 /mnt
sudo cp [your-kernel].zip /mnt/
sudo umount /mnt
```

Boot Nook with SD card → Install zip → Reboot

## Deploy Alpine System

### Prepare SD Card

```bash
# Partition SD card
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
sudo mkfs.vfat -F32 /dev/sdX1
sudo mkfs.f2fs /dev/sdX2

# Mount and extract
sudo mkdir -p /mnt/{boot,root}
sudo mount /dev/sdX1 /mnt/boot
sudo mount /dev/sdX2 /mnt/root

# Extract Alpine
sudo tar -xzf nook-alpine.tar.gz -C /mnt/root/

# Boot configuration
cat << 'EOF' | sudo tee /mnt/boot/uEnv.txt
bootargs=console=ttyS0,115200n8 root=/dev/mmcblk0p2 rootfstype=f2fs rw rootwait mem=256M quiet
bootcmd=mmc rescan; fatload mmc 0:1 0x80300000 uImage; bootm 0x80300000
EOF

# Copy kernel
sudo cp /mnt/root/boot/uImage /mnt/boot/

# Unmount
sudo umount /mnt/boot /mnt/root
```

## First Boot

1. Insert SD card into Nook
2. Power on (boot takes ~20 seconds)
3. Connect USB keyboard via OTG cable
4. System auto-starts menu

## Configure

### Vim Modes

- `Space + z` - Zettelkasten mode
- `Space + d` - Draft mode  
- `Space + w` - Save
- `Space + q` - Quit

### Cloud Sync

```bash
# Configure rclone (on Nook)
rclone config

# Sync script (already installed)
sync-notes  # Syncs ~/notes to cloud
```

### WiFi (Optional)

```bash
# Enable networking
vi /etc/network/interfaces
# Uncomment wlan0 section, add credentials

# Start WiFi
rc-service networking start
```

## Configurations Included

All configurations are in the Docker image:

- `.vimrc` - Full-featured, 1000 undo levels, plugins enabled
- `~/notes/` - Zettelkasten directory
- `~/drafts/` - Long-form writing
- `/usr/local/bin/nook-menu` - Startup menu
- `/usr/local/bin/sync-notes` - Cloud sync script

## Quick Customization

Modify locally and rebuild:
```bash
# Edit config files
vim config/vimrc
# Rebuild
docker build -t nook-system .
# Re-export and deploy
```

Or SSH into running Nook:
```bash
# On Nook
vi ~/.vimrc
```

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Keyboard not detected | Use powered USB hub |
| Screen ghosting | `fbink -s` for full refresh |
| Won't boot | Verify kernel in /mnt/boot/ |
| Out of memory | Restart vim (never happens with 200MB free) |

## Repository Structure

```
config/
├── vimrc           # Main vim config
├── vim/
│   ├── zettel.vim  # Note mode
│   └── draft.vim   # Writing mode
└── scripts/
    ├── nook-menu.sh
    └── sync-notes.sh
```

Done. Your Nook is now a Linux writing system.