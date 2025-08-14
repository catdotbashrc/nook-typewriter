# SD Card Boot Guide - Nook Simple Touch

**Created**: August 2025  
**Purpose**: Comprehensive guide for creating bootable SD cards for Nook Simple Touch  
**Based on**: XDA Forums research, Project Phoenix findings, and JoKernel implementation

## Overview

Creating a bootable SD card for the Nook Simple Touch requires precise technical requirements that differ significantly from modern Linux systems. This guide documents the **critical discoveries** that enable successful SD card booting.

## ⚠️ Critical Requirements

### Partition Alignment (MANDATORY)

The **most critical requirement** for Nook SD card boot:

```bash
# ❌ WRONG (modern Linux default):
parted -s /dev/sdX mkpart primary fat16 1MiB 513MiB  # Starts at sector 2048

# ✅ CORRECT (Nook requirement):
fdisk /dev/sdX << EOF
o          # Create new DOS partition table
n          # New partition
p          # Primary
1          # Partition number 1
63         # CRITICAL: Start at sector 63
+512M      # Size
t          # Change type
c          # FAT32 LBA
a          # Make bootable
1          # Partition 1
w          # Write changes
EOF
```

**Why sector 63?**
- Nook ROM bootloader expects first partition at sector 63
- Modern tools use sector 2048 (1MiB alignment) which Nook ROM cannot find
- Using sector 2048 results in device booting to internal OS instead of SD card

### File Order (MANDATORY)

Boot files must be copied in **exact order** to ensure contiguous storage:

```bash
# ✅ CORRECT ORDER:
cp MLO /mount/point/MLO                    # FIRST - ROM bootloader needs contiguous MLO
sync                                       # Ensure MLO is written before continuing
cp u-boot.bin /mount/point/u-boot.bin     # SECOND - MLO loads this
sync
cp uImage /mount/point/uImage              # THIRD - U-Boot loads kernel
cp boot.scr /mount/point/boot.scr          # FOURTH - U-Boot script
sync
```

**Critical Notes**:
- **MLO MUST be the first file written** to the partition
- Each file should be sync'd immediately after copy
- Any other order may prevent ROM bootloader from finding MLO

### Boot Script Naming

Nook devices may look for different boot script names. Create all variants:

```bash
# Create multiple script names for compatibility
mkimage -A arm -O linux -T script -C none -n "Boot Script" -d boot.cmd boot.scr
cp boot.scr u-boot.scr              # Alternative name 1
cp boot.scr boot.scr.uimg          # Alternative name 2
```

## Complete SD Card Creation Process

### Step 1: Prepare the SD Card

```bash
# Unmount any existing partitions
sudo umount /dev/sdX* 2>/dev/null || true

# Zero out the beginning of the card
sudo dd if=/dev/zero of=/dev/sdX bs=1M count=100 status=progress
sync
```

### Step 2: Create Partition Table (Sector 63 Alignment)

```bash
sudo fdisk /dev/sdX << 'FDISK_EOF'
o          # Create new DOS partition table
n          # New partition
p          # Primary
1          # Partition number
63         # CRITICAL: Start at sector 63
+512M      # Boot partition size
t          # Change partition type
c          # FAT32 LBA
a          # Make bootable
1          # Partition 1
n          # New partition (root)
p          # Primary
2          # Partition number
           # Default start (next available)
+2G        # Root partition size
n          # New partition (data)
p          # Primary  
3          # Partition number
           # Default start
           # Default end (use remaining space)
w          # Write changes
FDISK_EOF

# Re-read partition table
sudo partprobe /dev/sdX
sleep 2
```

### Step 3: Format Partitions

```bash
# Determine partition naming (sdX1 vs mmcblk0p1)
if [[ "/dev/sdX" =~ ^/dev/mmcblk ]]; then
    PART1="/dev/sdXp1"
    PART2="/dev/sdXp2"
    PART3="/dev/sdXp3"
else
    PART1="/dev/sdX1"
    PART2="/dev/sdX2"
    PART3="/dev/sdX3"
fi

# Format partitions
sudo mkfs.vfat -F 16 -n "NOOK_BOOT" "$PART1"
sudo mkfs.ext4 -L "NOOK_ROOT" "$PART2"
sudo mkfs.ext4 -L "NOOK_DATA" "$PART3"
```

### Step 4: Mount Partitions

```bash
# Create mount points
sudo mkdir -p /tmp/nook_boot /tmp/nook_root /tmp/nook_data

# Mount partitions
sudo mount "$PART1" /tmp/nook_boot
sudo mount "$PART2" /tmp/nook_root
sudo mount "$PART3" /tmp/nook_data
```

### Step 5: Install Boot Files (EXACT ORDER)

```bash
# CRITICAL: MLO must be copied FIRST for contiguous storage
echo "Installing MLO (first stage bootloader)..."
sudo cp firmware/boot/MLO /tmp/nook_boot/MLO
sync

echo "Installing u-boot.bin (second stage bootloader)..."
sudo cp firmware/boot/u-boot.bin /tmp/nook_boot/u-boot.bin  
sync

echo "Installing kernel..."
sudo cp firmware/boot/uImage /tmp/nook_boot/uImage
sync

echo "Installing boot scripts..."
sudo cp boot.scr /tmp/nook_boot/boot.scr
sudo cp /tmp/nook_boot/boot.scr /tmp/nook_boot/u-boot.scr
sudo cp /tmp/nook_boot/boot.scr /tmp/nook_boot/boot.scr.uimg
sync
```

### Step 6: Create Debug Boot Script

Create a boot script with extensive logging to troubleshoot boot issues:

```bash
cat > boot.cmd << 'EOF'
# Debug Boot Script with Extensive Logging

echo "======================================="
echo "     NOOK CUSTOM BOOT DEBUG"
echo "======================================="

# Test MMC detection
echo "=== MMC DETECTION TEST ==="
mmc info 0
mmc info 1
mmcinit 0
mmcinit 1

# List boot partition contents
echo "=== BOOT PARTITION CONTENTS ==="
fatls mmc 0

# Test file access
echo "=== FILE ACCESS TESTS ==="
if fatload mmc 0 0x80000000 MLO 1; then
    echo "MLO readable - OK"
else
    echo "ERROR: Cannot read MLO!"
fi

if fatload mmc 0 0x80000000 u-boot.bin 1; then
    echo "u-boot.bin readable - OK"
else
    echo "ERROR: Cannot read u-boot.bin!"
fi

if fatload mmc 0 0x80000000 uImage 1; then
    echo "uImage readable - OK" 
else
    echo "ERROR: Cannot read uImage!"
fi

# Set boot arguments with debug
setenv bootargs 'console=ttyS0,115200n8 root=/dev/mmcblk0p2 rootfstype=ext4 rootwait rw init=/sbin/init debug loglevel=8'

# Load kernel
echo "=== LOADING KERNEL ==="
if fatload mmc 0 0x81c00000 uImage; then
    echo "Kernel loaded successfully!"
    echo "Kernel size: ${filesize} bytes"
    echo "Starting boot in 3 seconds..."
    sleep 3
    bootm 0x81c00000
else
    echo "ERROR: Failed to load kernel!"
fi

echo "Boot failed - entering U-Boot shell..."
EOF

# Compile boot script
mkimage -A arm -O linux -T script -C none -n "Debug Boot" -d boot.cmd boot.scr
```

### Step 7: Install Root Filesystem

```bash
# Extract rootfs (if you have a rootfs tarball)
if [ -f "rootfs.tar.gz" ]; then
    echo "Extracting root filesystem..."
    sudo tar -xzf rootfs.tar.gz -C /tmp/nook_root/
else
    # Create minimal filesystem structure
    echo "Creating minimal root filesystem..."
    sudo mkdir -p /tmp/nook_root/{bin,sbin,etc,proc,sys,dev,tmp,var,usr,lib,root,boot}
    sudo mkdir -p /tmp/nook_root/etc/init.d
    
    # Create basic init script
    sudo tee /tmp/nook_root/sbin/init > /dev/null << 'INIT'
#!/bin/sh
# Basic init script

mount -t proc proc /proc
mount -t sysfs sysfs /sys  
mount -t devtmpfs devtmpfs /dev

echo ""
echo "================================="
echo "    NOOK CUSTOM BOOT SUCCESS"
echo "=================================" 
echo ""
echo "Boot completed successfully!"
echo "Starting emergency shell..."
echo ""

# Start shell
/bin/sh

# Keep system alive
while true; do sleep 1; done
INIT

    sudo chmod +x /tmp/nook_root/sbin/init
fi
```

### Step 8: Finalize and Test

```bash
# Final sync
sync
sync
sync

# Unmount partitions
sudo umount /tmp/nook_boot
sudo umount /tmp/nook_root
sudo umount /tmp/nook_data

# Remove mount points
sudo rmdir /tmp/nook_boot /tmp/nook_root /tmp/nook_data

echo "SD card creation complete!"
```

## Testing the SD Card

### Boot Sequence
1. **Power off** Nook completely (hold power button until shutdown)
2. **Insert SD card** into Nook
3. **Power on** while watching for any screen output
4. **Expected**: U-Boot messages → Debug output → Custom boot

### Troubleshooting Boot Issues

#### No Boot at All (Boots to Nook OS)
**Likely Causes**:
- Partition doesn't start at sector 63
- MLO not contiguous (copied after other files)
- Boot partition not marked bootable
- Wrong partition type (should be FAT16/32 LBA)

**Solutions**:
1. Verify partition table: `sudo fdisk -l /dev/sdX`
2. Check first partition starts at sector 63
3. Recreate SD card with exact sector alignment
4. Ensure MLO is copied first

#### Boot Starts But Fails
**Likely Causes**:
- Kernel not compatible with bootloader
- Wrong boot arguments
- Root filesystem issues
- Missing boot script

**Solutions**:
1. Check debug output from boot script
2. Verify uImage is valid Nook kernel
3. Test with minimal init script
4. Check root partition filesystem

## Advanced Configuration

### Boot Script Customization

Custom boot scripts can include:
- Hardware initialization
- Custom kernel parameters  
- Multiple boot options
- Recovery modes
- Debug logging

### Multi-Boot Setup

Create multiple kernels on same SD card:
- `uImage.default` - Main kernel
- `uImage.recovery` - Recovery kernel
- `uImage.test` - Development kernel

Boot script can choose based on button presses or environment variables.

### Performance Optimization

- Use Class 10+ SD cards for better performance
- Minimize boot partition fragmentation  
- Use ext4 for root partition (better than ext3)
- Enable compression in kernel if space-constrained

## Project-Specific: JoKernel Integration

### Easter Eggs Integration

JoKernel includes hidden easter eggs activated by typing specific sequences:
- Files: `system_journal_validation.sh`, `system_audit_validation.sh`
- Deployment: Copy to `/boot/` directory in root filesystem
- Activation: Type "jammy" or "astra" at shell prompt

### Debian Lenny Rootfs

Period-correct rootfs matching 2.6.29 kernel:
- Built with `debootstrap --arch=armel lenny`
- Size: ~14MB compressed
- Includes: Basic Debian system, shell, essential tools

### Custom Kernel Features

JoKernel includes:
- JesterOS modules (humor and medieval themes)
- Writer-focused utilities
- E-Ink display optimizations
- Power management improvements

## References

### XDA Forum Sources
- **Project Phoenix**: NST preservation project with CWM images
- **Bootable SD Card Discussion**: Critical sector 63 alignment discovery
- **NookManager Development**: Community rooting and boot tools

### Technical Documents
- **TI OMAP Boot Process**: ARM bootloader chain documentation
- **U-Boot Documentation**: Boot script and environment reference
- **Nook Hardware Reference**: Community reverse-engineering findings

### Related Projects
- **felixhaedicke/nst-kernel**: Working NST kernel build environment
- **NookManager**: Community boot and rooting tool
- **ClockworkMod**: Recovery system for custom ROM installation

---

*This guide documents hard-earned knowledge from the XDA community and JoKernel development. The sector 63 alignment requirement is critical and non-optional for Nook Simple Touch SD card boot success.*