# How to Prepare an SD Card for Nook Typewriter

## Overview

This guide explains how to format, partition, and prepare an SD card to run the Nook Typewriter system on your Barnes & Noble Nook Simple Touch. The process differs slightly depending on whether your Nook is already rooted.

## Prerequisites

- **Hardware**:
  - Barnes & Noble Nook Simple Touch e-reader
  - SD card (8GB minimum, 16GB recommended)
  - SD card reader for your computer
  - Computer running Debian 12 (or similar Linux distribution)

- **Software**:
  - Built Nook Typewriter Docker image (`nook-system`)
  - Compiled uImage kernel (`nst-kernel/build/uImage`)
  - `fdisk`, `mkfs.vfat`, and `mkfs.ext4` utilities

- **Knowledge**:
  - Basic Linux command line skills
  - Understanding of device names (`/dev/sdb` vs `/dev/mmcblk0`)
  - Ability to identify your SD card device safely

## Understanding Boot Methods

### For Stock (Unrooted) Nooks

The Nook's OMAP3621 processor follows this boot sequence:

```
Power On → ROM checks SD slot → SD with MLO → Boot from SD
                              ↓
                              No MLO → Boot internal memory
```

**Required files**: MLO, u-boot.bin, uImage

### For Rooted Nooks

Already rooted Nooks have bootloaders in internal memory, offering two options:

1. **Simple method**: Use internal bootloader, only need uImage on SD
2. **Portable method**: Full bootloader set for any Nook

## Step 1: Identify Your SD Card

**Critical**: Identifying the wrong device could destroy your system!

```bash
# Insert SD card and identify the device
lsblk -p | grep -E "disk|part"

# Verify size matches your SD card
sudo fdisk -l | grep -E "Disk /dev/sd|Disk /dev/mmcblk"

# Double-check with dmesg
sudo dmesg | tail -20

# Set your device (adjust to YOUR device!)
DEVICE=/dev/sdb  # USB card reader
# OR
DEVICE=/dev/mmcblk0  # Built-in card reader
```

Common device names:
- `/dev/sdb`, `/dev/sdc`: USB card readers
- `/dev/mmcblk0`: Built-in SD card readers

## Step 2: Partition the SD Card

### Unmount Existing Partitions

```bash
# Unmount any auto-mounted partitions
sudo umount ${DEVICE}* 2>/dev/null

# Verify nothing is mounted
mount | grep ${DEVICE}
```

### Create Partition Layout

For a 14.8GB (16GB) SD card, create 2 partitions:

```bash
# Wipe existing partition table
sudo dd if=/dev/zero of=${DEVICE} bs=1M count=10
sync

# Create new partitions with fdisk
sudo fdisk ${DEVICE} << EOF
o
n
p
1
2048
+100M
t
c
a
n
p
2

+2G
p
w
EOF
```

Expected partition layout:
```
Device     Boot  Start     End Sectors  Size Id Type
/dev/sdb1  *      2048  206847  204800  100M  c W95 FAT32 (LBA)
/dev/sdb2       206848 4401151 4194304    2G 83 Linux
```

**Critical requirements**:
- First partition MUST start at sector 2048 (1MB offset)
- First partition MUST be type `c` (W95 FAT32 LBA)
- Boot flag MUST be set on first partition

## Step 3: Format the Partitions

```bash
# Determine partition names based on device type
if [[ ${DEVICE} == /dev/mmcblk* ]]; then
    BOOT_PART="${DEVICE}p1"
    ROOT_PART="${DEVICE}p2"
else
    BOOT_PART="${DEVICE}1"
    ROOT_PART="${DEVICE}2"
fi

# Format boot partition (MUST be FAT32)
sudo mkfs.vfat -F 32 -n NOOK_BOOT -s 4 ${BOOT_PART}

# Format root partition without journal (extends SD card life)
sudo mkfs.ext4 -L NOOK_ROOT -O ^has_journal,^huge_file ${ROOT_PART}

# Verify filesystems
sudo file -s ${BOOT_PART}  # Should show: DOS/MBR boot sector
sudo file -s ${ROOT_PART}  # Should show: Linux ext4 filesystem
```

## Step 4: Mount the Partitions

```bash
# Create mount points
sudo mkdir -p /mnt/nook_boot /mnt/nook_root

# Mount partitions
sudo mount ${BOOT_PART} /mnt/nook_boot
sudo mount ${ROOT_PART} /mnt/nook_root

# Verify mounts
df -h | grep nook
```

## Step 5: Install Boot Files

### For Rooted Nooks (Simple Method)

If your Nook is already rooted, you only need the kernel:

```bash
# Copy only the kernel
sudo cp nst-kernel/build/uImage /mnt/nook_boot/

# Create boot flag for rooted Nook detection
echo "boot_from_sd=1" | sudo tee /mnt/nook_boot/boot.flag
```

### For Stock Nooks (Full Bootloader Method)

For unrooted Nooks or portable SD cards, you need all boot files:

```bash
# CRITICAL: MLO must be copied FIRST!
sudo cp MLO /mnt/nook_boot/
sync  # Ensure it's written

# Then copy other boot files
sudo cp u-boot.bin /mnt/nook_boot/
sudo cp uImage /mnt/nook_boot/

# Create boot script
cat << 'EOF' > boot.script
setenv bootargs console=ttyS0,115200n8 root=/dev/mmcblk0p2 rootfstype=ext4 rootwait rw mem=256M fbcon=rotate:1 epd=pearl2
fatload mmc 0:1 0x80000000 uImage
bootm 0x80000000
EOF

# Compile boot script (requires mkimage)
mkimage -A arm -O linux -T script -C none -n "Nook Boot" -d boot.script boot.scr
sudo cp boot.scr /mnt/nook_boot/
```

### Obtaining Missing Bootloader Files

If you need MLO and u-boot.bin:

#### Option 1: Extract from Rooted Nook
```bash
# Via ADB from rooted Nook
adb shell su -c "dd if=/dev/block/mmcblk0p1 of=/sdcard/boot.img bs=1M"
adb pull /sdcard/boot.img

# Mount and extract
mkdir boot_extract
sudo mount -o loop boot.img boot_extract
cp boot_extract/MLO .
cp boot_extract/u-boot.bin .
```

#### Option 2: Download from Community
```bash
# Create directory for files
mkdir -p ~/nook-boot-files
cd ~/nook-boot-files

# Download MLO
curl -L -o MLO https://github.com/eurleif/Nook-Simple-Touch-Root/raw/master/MLO

# Download u-boot.bin
curl -L -o u-boot.bin https://github.com/eurleif/Nook-Simple-Touch-Root/raw/master/u-boot.bin

# Verify files
file MLO u-boot.bin
```

## Step 6: Install Root Filesystem

```bash
# Export filesystem from Docker
cd ~/projects/personal/nook
docker create --name nook-export nook-system
docker export nook-export | sudo tar -xf - -C /mnt/nook_root/
docker rm nook-export

# Fix critical permissions
sudo chmod 755 /mnt/nook_root/sbin/init
sudo chmod 755 /mnt/nook_root/etc/init.d/*

# Configure boot-time optimizations
sudo tee /mnt/nook_root/etc/fstab << EOF
/dev/mmcblk0p2  /        ext4  noatime,nodiratime,errors=remount-ro  0  1
proc            /proc    proc  defaults                               0  0
sysfs           /sys     sysfs defaults                               0  0
tmpfs           /tmp     tmpfs size=10M,noatime                       0  0
tmpfs           /var/log tmpfs size=5M,noatime                        0  0
EOF
```

## Step 7: Finalize and Unmount

```bash
# Ensure all data is written
sync
sync  # Yes, twice for safety

# Unmount cleanly
sudo umount /mnt/nook_boot
sudo umount /mnt/nook_root

# Remove mount points
sudo rmdir /mnt/nook_boot /mnt/nook_root

echo "SD card prepared successfully!"
```

## Step 8: Verify SD Card

```bash
# Check partition table
sudo fdisk -l ${DEVICE}

# Verify boot flag is set
sudo fdisk -l ${DEVICE} | grep Boot
# Should show * on first partition

# Check filesystem integrity
sudo fsck.vfat -n ${BOOT_PART}
sudo e2fsck -f -n ${ROOT_PART}
```

## Using the SD Card

1. **Power off** your Nook completely
2. **Insert** the prepared SD card
3. **Power on** the Nook
4. **Wait** ~30 seconds for first boot (E-Ink will refresh several times)
5. **See** the QuillOS boot message and medieval jester

## Troubleshooting

### Nook Won't Boot from SD

**Symptom**: Boots to normal Nook interface
- **Check**: Boot flag set on first partition
- **Check**: MLO is first file (for non-rooted Nooks)
- **Check**: FAT32 partition type is `0x0C`

### Kernel Panic

**Symptom**: "Kernel panic - not syncing"
- **Check**: `/sbin/init` exists and is executable
- **Check**: Root filesystem extracted correctly
- **Fix**: Re-extract filesystem with proper permissions

### Black Screen

**Symptom**: E-Ink doesn't refresh
- **Normal**: First boot takes 30-60 seconds
- **Check**: uImage is valid (2-3MB size)
- **Debug**: Connect serial console to see boot messages

### SD Card Not Detected

**Symptom**: Nook ignores SD card
- **Check**: Partition starts at sector 2048
- **Check**: Card is properly formatted FAT32
- **Try**: Different SD card brand (some are incompatible)

## Automated Script

Save this complete script as `prepare-nook-sd.sh`:

```bash
#!/bin/bash
set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Nook SD Card Preparation Script${NC}"
echo "=================================="

# Check for root
if [[ $EUID -eq 0 ]]; then
   echo -e "${RED}Don't run this script as root!${NC}"
   exit 1
fi

# List devices
echo -e "\n${YELLOW}Available devices:${NC}"
lsblk -d -o NAME,SIZE,MODEL | grep -E "sd|mmcblk"

# Get device
echo -e "\n${YELLOW}Enter device path (e.g., /dev/sdb):${NC}"
read -r DEVICE

# Confirm
echo -e "\n${RED}WARNING: This will ERASE all data on ${DEVICE}${NC}"
echo -n "Type 'YES' to continue: "
read -r CONFIRM

[[ "$CONFIRM" != "YES" ]] && exit 1

# Determine partition names
if [[ ${DEVICE} == /dev/mmcblk* ]]; then
    BOOT_PART="${DEVICE}p1"
    ROOT_PART="${DEVICE}p2"
else
    BOOT_PART="${DEVICE}1"
    ROOT_PART="${DEVICE}2"
fi

# Unmount
sudo umount ${DEVICE}* 2>/dev/null || true

# Partition
echo -e "\n${GREEN}Creating partitions...${NC}"
sudo fdisk ${DEVICE} << EOF
o
n
p
1
2048
+100M
t
c
a
n
p
2

+2G
p
w
EOF

# Format
echo -e "\n${GREEN}Formatting...${NC}"
sudo mkfs.vfat -F 32 -n NOOK_BOOT ${BOOT_PART}
sudo mkfs.ext4 -L NOOK_ROOT -O ^has_journal ${ROOT_PART}

# Mount
echo -e "\n${GREEN}Mounting...${NC}"
sudo mkdir -p /mnt/nook_boot /mnt/nook_root
sudo mount ${BOOT_PART} /mnt/nook_boot
sudo mount ${ROOT_PART} /mnt/nook_root

echo -e "\n${GREEN}Ready for files!${NC}"
echo "Boot: /mnt/nook_boot"
echo "Root: /mnt/nook_root"
```

## Next Steps

- [Install Custom Kernel](./install-custom-kernel.md) - Upgrade to QuillKernel
- [Choose Vim Configuration](./choose-vim-configuration.md) - Select writing mode
- [Customize Vim Plugins](./customize-vim-plugins.md) - Add writing tools

## See Also

- **Tutorial**: [First Nook Setup](../tutorials/01-first-nook-setup.md)
- **Reference**: [System Requirements](../reference/system-requirements.md)
- **Explanation**: [Architecture Overview](../explanation/architecture-overview.md)