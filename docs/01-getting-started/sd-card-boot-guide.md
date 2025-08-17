# SD Card Boot Guide - Nook Simple Touch

**Created**: August 2025  
**Purpose**: Comprehensive guide for creating bootable SD cards for Nook Simple Touch  
**Based on**: XDA Forums research, Project Phoenix findings, and JoKernel implementation

## Overview

Creating a bootable SD card for the Nook Simple Touch requires precise technical requirements that differ significantly from modern Linux systems. This guide documents the **critical discoveries** that enable successful SD card booting, now enhanced with our **4-partition recovery architecture** for maximum resilience and user data protection.

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

## Partition Strategy

### 4-Partition Architecture (JesterOS v2.0)

Our enhanced partition layout provides enterprise-grade recovery capabilities:

```
┌──────────────────────────────────────────────┐
│ Partition 1: BOOT (512MB, FAT16)            │
│ - MLO, u-boot.bin, uImage                    │
│ - Boot scripts & recovery flags              │
├──────────────────────────────────────────────┤
│ Partition 2: SYSTEM (1.5GB, ext4)           │
│ - Active JesterOS root filesystem            │
│ - Read-only during normal operation          │
├──────────────────────────────────────────────┤
│ Partition 3: RECOVERY (1.5GB, ext4)         │
│ - Factory JesterOS image                     │
│ - Recovery tools & diagnostics               │
├──────────────────────────────────────────────┤
│ Partition 4: WRITING (remaining, ext4)      │
│ - User documents & personal data             │
│ - Survives all system operations             │
└──────────────────────────────────────────────┘
```

### Recovery Capabilities
- **Hardware Trigger**: Hold Power+Home during boot
- **Software Trigger**: Touch `/boot/RECOVERY_MODE` file
- **Auto-Recovery**: 3 failed boots = automatic recovery
- **Factory Reset**: Preserves user data while restoring system

## Complete SD Card Creation Process

### Step 1: Prepare the SD Card

```bash
# Unmount any existing partitions
sudo umount /dev/sdX* 2>/dev/null || true

# Zero out the beginning of the card
sudo dd if=/dev/zero of=/dev/sdX bs=1M count=100 status=progress
sync
```

### Step 2: Create 4-Partition Table (Sector 63 Alignment)

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
n          # New partition (system)
p          # Primary
2          # Partition number
           # Default start (next available)
+1536M     # System partition size (1.5GB)
n          # New partition (recovery)
p          # Primary  
3          # Partition number
           # Default start
+1536M     # Recovery partition size (1.5GB)
n          # New partition (writing)
e          # Extended partition
           # Default start
           # Default end (use remaining space)
n          # New logical partition
           # Default start
           # Default end (all remaining)
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
    PART4="/dev/sdXp5"  # Logical partition
else
    PART1="/dev/sdX1"
    PART2="/dev/sdX2"
    PART3="/dev/sdX3"
    PART4="/dev/sdX5"   # Logical partition
fi

# Format partitions
sudo mkfs.vfat -F 16 -n "BOOT" "$PART1"
sudo mkfs.ext4 -L "JESTEROS" "$PART2"
sudo mkfs.ext4 -L "RECOVERY" "$PART3"
sudo mkfs.ext4 -L "WRITING" "$PART4"

# Optimize ext4 partitions
sudo tune2fs -c 0 -i 0 "$PART2"  # Disable automatic fsck
sudo tune2fs -c 0 -i 0 "$PART3"
sudo tune2fs -c 0 -i 0 "$PART4"
```

### Step 4: Mount Partitions

```bash
# Create mount points
sudo mkdir -p /tmp/nook_boot /tmp/nook_system /tmp/nook_recovery /tmp/nook_writing

# Mount partitions
sudo mount "$PART1" /tmp/nook_boot
sudo mount "$PART2" /tmp/nook_system
sudo mount "$PART3" /tmp/nook_recovery
sudo mount "$PART4" /tmp/nook_writing
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

### Step 6: Install Recovery System

```bash
# Create recovery structure
sudo mkdir -p /tmp/nook_recovery/{images,tools,config,logs}

# Copy factory image to recovery partition
if [ -f "jesteros-factory.img" ]; then
    sudo cp jesteros-factory.img /tmp/nook_recovery/images/
    sudo md5sum /tmp/nook_recovery/images/jesteros-factory.img > /tmp/nook_recovery/images/checksums.md5
fi

# Install recovery tools
sudo tee /tmp/nook_recovery/tools/recovery-menu.sh > /dev/null << 'RECOVERY_EOF'
#!/bin/sh
# JesterOS Recovery Menu

show_menu() {
    clear
    echo "╔══════════════════════════════════════╗"
    echo "║     JesterOS Recovery Mode v1.0      ║"
    echo "╠══════════════════════════════════════╣"
    echo "║ 1. Factory Reset (keep writings)     ║"
    echo "║ 2. Full System Restore               ║"
    echo "║ 3. Repair Filesystem                 ║"
    echo "║ 4. Backup User Data                  ║"
    echo "║ 5. Hardware Diagnostics              ║"
    echo "║ 6. View Recovery Logs                ║"
    echo "║ 7. Advanced Options                  ║"
    echo "║ 8. Reboot to Normal Mode             ║"
    echo "╚══════════════════════════════════════╝"
    echo -n "Select option: "
}

factory_reset() {
    echo "Performing factory reset..."
    # Restore system partition from factory image
    dd if=/recovery/images/jesteros-factory.img of=/dev/mmcblk0p2 bs=4M status=progress
    sync
    echo "Factory reset complete. User data preserved."
    sleep 3
}

while true; do
    show_menu
    read choice
    case $choice in
        1) factory_reset ;;
        8) rm -f /boot/RECOVERY_MODE && reboot ;;
        *) echo "Option not yet implemented" ;;
    esac
done
RECOVERY_EOF

sudo chmod +x /tmp/nook_recovery/tools/recovery-menu.sh
```

### Step 7: Create Enhanced Boot Script with Recovery Support

Create a boot script that supports recovery mode detection:

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

# Check for recovery mode
if test -e mmc 0:1 RECOVERY_MODE; then
    echo "RECOVERY MODE DETECTED!"
    setenv bootargs 'console=ttyS0,115200n8 root=/dev/mmcblk0p3 rootfstype=ext4 rootwait rw init=/recovery/tools/recovery-menu.sh debug'
else
    echo "Normal boot mode"
    setenv bootargs 'console=ttyS0,115200n8 root=/dev/mmcblk0p2 rootfstype=ext4 rootwait ro init=/sbin/init'
fi

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

### Step 8: Install Root Filesystem to System Partition

```bash
# Extract JesterOS to system partition
if [ -f "jesteros-rootfs.tar.gz" ]; then
    echo "Extracting JesterOS root filesystem..."
    sudo tar -xzf jesteros-rootfs.tar.gz -C /tmp/nook_system/
    
    # Also copy to recovery partition as factory image
    echo "Creating factory recovery image..."
    sudo tar -xzf jesteros-rootfs.tar.gz -C /tmp/nook_recovery/images/factory/
else
    # Create minimal filesystem structure
    echo "Creating minimal JesterOS filesystem..."
    sudo mkdir -p /tmp/nook_system/{bin,sbin,etc,proc,sys,dev,tmp,var,usr,lib,root,boot}
    sudo mkdir -p /tmp/nook_system/etc/init.d
    
    # Create basic init script
    sudo tee /tmp/nook_system/sbin/init > /dev/null << 'INIT'
#!/bin/sh
# JesterOS Init Script with Recovery Support

mount -t proc proc /proc
mount -t sysfs sysfs /sys  
mount -t devtmpfs devtmpfs /dev

# Mount writing partition
mount -t ext4 /dev/mmcblk0p5 /home -o rw,noatime,commit=600

# Check boot counter for auto-recovery
BOOT_COUNT_FILE="/boot/.boot_count"
if [ -f "$BOOT_COUNT_FILE" ]; then
    COUNT=$(cat "$BOOT_COUNT_FILE")
    if [ "$COUNT" -ge 3 ]; then
        echo "Boot failures detected! Triggering recovery..."
        touch /boot/RECOVERY_MODE
        reboot
    fi
    echo $((COUNT + 1)) > "$BOOT_COUNT_FILE"
else
    echo 1 > "$BOOT_COUNT_FILE"
fi

echo ""
echo "================================="
echo "    JesterOS Boot Success"
echo "=================================" 
echo ""
echo "System partition: Read-only"
echo "Writing partition: Mounted at /home"
echo "Recovery available: Power+Home"
echo ""

# Clear boot counter on successful boot
echo 0 > "$BOOT_COUNT_FILE"

# Start JesterOS services
/usr/local/bin/jesteros-startup.sh

# Start shell
/bin/sh

# Keep system alive
while true; do sleep 1; done
INIT

    sudo chmod +x /tmp/nook_root/sbin/init
fi
```

### Step 9: Configure User Writing Space

```bash
# Create user directory structure
sudo mkdir -p /tmp/nook_writing/{documents,drafts,notes,archive}
sudo mkdir -p /tmp/nook_writing/.jesteros/{stats,config,backups}

# Create welcome document
sudo tee /tmp/nook_writing/documents/welcome.txt > /dev/null << 'WELCOME'
Welcome to JesterOS!

Your writing space is ready. This partition will preserve all your
work even if you need to restore the system partition.

Recovery Options:
- Hardware: Hold Power+Home during boot
- Software: Create /boot/RECOVERY_MODE file
- Auto: System recovers after 3 failed boots

Happy writing!
- The Jester
WELCOME
```

### Step 10: Finalize and Test

```bash
# Create recovery trigger instruction file
sudo tee /tmp/nook_boot/RECOVERY_INSTRUCTIONS.txt > /dev/null << 'EOF'
To enter recovery mode:
1. Create a file named RECOVERY_MODE in this directory
2. Reboot the device
3. System will boot into recovery menu

To exit recovery mode:
1. Select option 8 from recovery menu
2. Or delete the RECOVERY_MODE file and reboot
EOF

# Final sync
sync
sync
sync

# Unmount partitions
sudo umount /tmp/nook_boot
sudo umount /tmp/nook_system
sudo umount /tmp/nook_recovery
sudo umount /tmp/nook_writing

# Remove mount points
sudo rmdir /tmp/nook_boot /tmp/nook_system /tmp/nook_recovery /tmp/nook_writing

echo "4-Partition SD card creation complete!"
echo "Features:"
echo "  - System protection via read-only mounting"
echo "  - Automatic recovery after failures"
echo "  - User data preservation"
echo "  - Factory reset capability"
```

## Testing the SD Card

### Boot Sequence
1. **Power off** Nook completely (hold power button until shutdown)
2. **Insert SD card** into Nook
3. **Power on** (or hold Power+Home for recovery mode)
4. **Expected Normal Boot**: U-Boot → JesterOS → Writing environment
5. **Expected Recovery Boot**: U-Boot → Recovery Menu → Options

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
- System partition mounted read-only (no wear)
- Writing partition optimized: `noatime,nodiratime,commit=600`
- Recovery partition accessed only when needed
- Use ext4 for all Linux partitions
- Enable compression in kernel if space-constrained

### Recovery Mode Features

#### Entering Recovery
1. **Hardware Button**: Hold Power+Home during boot
2. **Software Flag**: `touch /boot/RECOVERY_MODE` then reboot
3. **Auto-Recovery**: Triggered after 3 consecutive boot failures
4. **Menu Option**: Select from JesterOS system menu

#### Recovery Capabilities
- **Factory Reset**: Restore system, preserve writings
- **Full Restore**: Complete system and data restoration
- **Filesystem Repair**: Fix corrupted partitions
- **Data Backup**: Save user documents externally
- **Diagnostics**: Hardware and software testing
- **Advanced Options**: Manual partition management

## Project-Specific: JesterOS Integration

### 4-Partition Benefits for JesterOS

1. **System Integrity**: Read-only system partition prevents corruption
2. **User Data Safety**: Writing partition isolated from system changes
3. **Easy Updates**: Swap SYSTEM ↔ RECOVERY for A/B updates
4. **Recovery Confidence**: Always have factory image available
5. **Space Efficiency**: 80%+ of card for actual writing

### Partition Usage in JesterOS

```yaml
BOOT (512MB):
  - Critical boot files (MLO, u-boot, kernel)
  - Recovery flags and boot configuration
  - Emergency boot scripts

SYSTEM (1.5GB):
  - JesterOS core (~450MB)
  - Vim and writing tools (~200MB)
  - Jester services (~50MB)
  - Free space for future features

RECOVERY (1.5GB):
  - Factory JesterOS image
  - Recovery tools and menu
  - Diagnostic utilities
  - Backup configurations

WRITING (remaining):
  - /home/writer/ - All user documents
  - Personal vim configurations
  - Writing statistics and history
  - Document backups and archives
```

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

*This guide documents hard-earned knowledge from the XDA community and JesterOS development. The sector 63 alignment requirement is critical and non-optional for Nook Simple Touch SD card boot success. The 4-partition recovery architecture adds enterprise-grade resilience while maintaining compatibility with all discovered boot requirements.*