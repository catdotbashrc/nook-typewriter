# Deployment Scripts

This directory contains scripts for deploying Nook Typewriter to hardware.

## Scripts

### create-sd-image.sh

Creates bootable SD card images for the Nook Simple Touch e-reader.

**Features:**
- Creates 512MB bootable images with proper partition layout
- FAT16 boot partition (100MB) + ext4 root partition
- Supports Docker images and tarball rootfs sources
- Includes SquireOS kernel module installation
- Provides compressed output for distribution

**Requirements:**
- Linux or WSL2 environment
- Tools: `parted`, `mkfs.vfat`, `mkfs.ext4`, `losetup`, `dd`, `gzip`
- Sudo access for loop device operations
- Either:
  - Docker image `nook-system` built
  - OR rootfs tarball (`nook-debian.tar.gz`)
- Kernel image (`uImage`) from nst-kernel build

**Usage:**
```bash
# Create SD card image
./create-sd-image.sh

# Output will be in releases/ directory:
# - nook-typewriter-YYYYMMDD.img (raw image)
# - nook-typewriter-YYYYMMDD.img.gz (compressed)
```

**Flashing to SD Card:**

Using dd (Linux/Mac):
```bash
# Find your SD card device
lsblk

# Flash the image (replace /dev/sdX with your device)
sudo dd if=releases/nook-typewriter-YYYYMMDD.img of=/dev/sdX bs=4M status=progress conv=fsync
```

Using Balena Etcher (Windows/Mac/Linux):
1. Download [Balena Etcher](https://www.balena.io/etcher/)
2. Select the .img or .img.gz file
3. Select your SD card
4. Click "Flash!"

**Partition Layout:**
```
Device     Boot  Start     End Sectors  Size Id Type
/dev/sdX1  *      2048  206847  204800  100M  c W95 FAT32 (LBA)
/dev/sdX2       206848 1024000  817153  399M 83 Linux
```

## Testing

Run the test suite to verify the script:
```bash
bash tests/test-sd-image-builder.sh
```

## Troubleshooting

**"Kernel uImage not found"**
- Build the kernel first: `cd nst-kernel && ./build-jester-kernel.sh`

**"Root filesystem not found"**
- Build the Docker image: `docker build -t nook-system -f nookwriter-optimized.dockerfile .`

**"Permission denied" on loop devices**
- The script requires sudo for loop device operations
- You'll be prompted for your password when needed

**SD card not booting on Nook**
- Ensure boot flag is set on first partition
- Try a different SD card brand (some are incompatible)
- Check that the image was written completely

## Medieval Magic 🏰

The script includes jester ASCII art and medieval-themed messages to maintain the whimsical spirit of the project:

```
    .~"~.~"~.
   /  o   o  \\
  |  >  ◡  <  |
   \  ___  /
    |~|♦|~|

By quill and candlelight, thy device awaits!
```