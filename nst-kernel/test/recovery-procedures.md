# QuillKernel Recovery & Rollback Procedures

*"Even the finest quill sometimes needs re-sharpening"* - A wise scribe

## Emergency Recovery Guide

If QuillKernel causes boot issues, don't panic! Your faithful squire has prepared multiple recovery paths.

```
     .~!!!~.
    / O   O \    Fear not! Recovery is possible!
   |  >   <  |   Follow these procedures carefully.
    \  ~~~  /    
     |~|♦|~|     
```

## Recovery Methods

### Method 1: SD Card Recovery (Recommended)

**Preparation** (Do this BEFORE installing QuillKernel):
```bash
# 1. Create recovery SD card
sudo fdisk /dev/sdX
# Create two partitions:
# - 100MB FAT32 (boot)
# - Remainder ext4 (recovery)

# 2. Format partitions
sudo mkfs.vfat -F32 /dev/sdX1
sudo mkfs.ext4 /dev/sdX2

# 3. Mount boot partition
sudo mount /dev/sdX1 /mnt/boot

# 4. Copy WORKING kernel
sudo cp /current/working/uImage /mnt/boot/uImage.recovery
sudo cp /current/working/uRamdisk /mnt/boot/uRamdisk.recovery

# 5. Create recovery uEnv.txt
cat > /mnt/boot/uEnv.txt << 'EOF'
bootargs=console=ttyS0,115200n8 root=/dev/mmcblk0p2 rootfstype=f2fs rw rootwait mem=256M
bootcmd=mmc rescan; fatload mmc 0:1 0x80300000 uImage.recovery; bootm 0x80300000
recovery=1
EOF

# 6. Unmount
sudo umount /mnt/boot
```

**Recovery Process**:
1. Power off Nook completely
2. Insert recovery SD card
3. Power on - boots with working kernel
4. Fix QuillKernel issues
5. Remove SD card and reboot

### Method 2: Serial Console Recovery

**Requirements**: 
- USB-to-serial adapter (3.3V)
- Soldering skills or pogo pins

**Connection**:
```
Nook Serial Points (J4 header):
Pin 1: GND
Pin 2: RX (connect to TX on adapter)
Pin 3: TX (connect to RX on adapter)

Settings: 115200,8,N,1
```

**Recovery Steps**:
```bash
# 1. Connect serial console
screen /dev/ttyUSB0 115200

# 2. Interrupt U-Boot (press any key during boot)
U-Boot> 

# 3. Boot with different kernel
U-Boot> setenv bootcmd 'mmc rescan; fatload mmc 0:1 0x80300000 uImage.backup; bootm 0x80300000'
U-Boot> boot

# 4. Once booted, restore working kernel
mount /dev/mmcblk0p1 /mnt
cp /mnt/uImage.backup /mnt/uImage
```

### Method 3: Clockwork Recovery

**If CWM is installed**:
1. Boot into ClockworkMod Recovery (hold buttons during boot)
2. Select "backup and restore"
3. Choose "restore"
4. Select your pre-QuillKernel backup
5. Reboot

**Installing CWM** (if not present):
```bash
# Download CWM for NST
wget https://example.com/cwm-nst.zip

# Write to SD card
dd if=cwm-recovery.img of=/dev/sdX bs=4M
```

## Kernel Backup Strategies

### Before Installing QuillKernel

**Option 1: Full Backup**
```bash
# Mount boot partition
mount /dev/mmcblk0p1 /mnt/boot

# Backup current kernel
cp /mnt/boot/uImage /mnt/boot/uImage.stock
cp /mnt/boot/uRamdisk /mnt/boot/uRamdisk.stock

# Create restoration script
cat > /mnt/boot/restore-stock.sh << 'EOF'
#!/bin/sh
mount /dev/mmcblk0p1 /mnt
cp /mnt/uImage.stock /mnt/uImage
cp /mnt/uRamdisk.stock /mnt/uRamdisk
sync
reboot
EOF
chmod +x /mnt/boot/restore-stock.sh
```

**Option 2: Multi-Kernel Setup**
```bash
# Keep multiple kernels
/boot/
├── uImage           # Current kernel (QuillKernel)
├── uImage.stock     # Original B&N kernel
├── uImage.quill     # QuillKernel
└── uImage.recovery  # Known working kernel

# Modify U-Boot to select
# Hold button during boot for menu
```

### Safe Testing Procedure

```bash
# 1. Test boot from SD first
cp arch/arm/boot/uImage /mnt/sdcard/boot/uImage.test

# 2. Create test uEnv.txt
echo 'bootcmd=mmc rescan; fatload mmc 0:1 0x80300000 uImage.test; bootm 0x80300000' > /mnt/sdcard/boot/uEnv.txt

# 3. Boot with SD card
# If successful, install to internal storage
```

## Troubleshooting Boot Issues

### Boot Loop
**Symptoms**: Nook continuously reboots
**Solution**:
1. Use recovery SD card
2. Check kernel size (must be <4MB)
3. Verify kernel format:
   ```bash
   file uImage
   # Should show: u-boot legacy uImage, Linux-2.6.29...
   ```

### Black Screen
**Symptoms**: No display after boot
**Possible Causes**:
- E-Ink driver issue
- Wrong framebuffer config
- Kernel panic (check serial)

**Solutions**:
```bash
# Boot recovery kernel
# Check dmesg for errors
dmesg | grep -i "error\|fail\|panic"

# Verify E-Ink driver
grep FB_OMAP3EP /boot/config-*
```

### Stuck at Boot Logo
**Symptoms**: B&N logo stays on screen
**Solution**:
1. Kernel is loading but not completing
2. Connect serial console
3. Check for medieval message delays:
   ```bash
   # Remove delays from kernel
   # Edit board-omap3621_gossamer-squire.c
   # Remove all mdelay() calls
   ```

## Recovery Utilities

### Create Recovery Kit
```bash
#!/bin/bash
# create-recovery-kit.sh

RECOVERY_DIR="quillkernel-recovery"
mkdir -p "$RECOVERY_DIR"

# 1. Save current working kernel
cp /boot/uImage "$RECOVERY_DIR/uImage.working"

# 2. Create recovery instructions
cat > "$RECOVERY_DIR/RECOVERY.txt" << 'EOF'
QuillKernel Recovery Instructions
=================================

If QuillKernel fails to boot:

1. Copy uImage.working to SD card boot partition
2. Create uEnv.txt with:
   bootcmd=mmc rescan; fatload mmc 0:1 0x80300000 uImage.working; bootm 0x80300000
3. Boot with SD card inserted
4. Once booted, restore working kernel:
   mount /dev/mmcblk0p1 /mnt
   cp /mnt/uImage.working /mnt/uImage

Your squire apologizes for any inconvenience!
EOF

# 3. Create automated recovery script
cat > "$RECOVERY_DIR/auto-recover.sh" << 'EOF'
#!/bin/sh
echo "QuillKernel Auto-Recovery"
echo "========================"

# Check if running from SD
if grep -q "root=/dev/mmcblk1" /proc/cmdline; then
    echo "Booted from SD - proceeding with recovery"
    
    mount /dev/mmcblk0p1 /mnt
    if [ -f /mnt/uImage.stock ]; then
        echo "Restoring stock kernel..."
        cp /mnt/uImage.stock /mnt/uImage
        echo "Recovery complete! Remove SD and reboot."
    else
        echo "Stock kernel backup not found!"
    fi
else
    echo "Not booted from SD - aborting for safety"
fi
EOF

chmod +x "$RECOVERY_DIR/auto-recover.sh"

# 4. Package it
tar czf quillkernel-recovery.tar.gz "$RECOVERY_DIR"
echo "Recovery kit created: quillkernel-recovery.tar.gz"
```

### Kernel Switcher Script
```bash
#!/bin/sh
# /usr/local/bin/kernel-switch.sh

BOOT_DIR="/boot"
CURRENT=$(readlink "$BOOT_DIR/uImage")

echo "QuillKernel Switcher"
echo "==================="
echo "Current: $CURRENT"
echo ""
echo "Available kernels:"
ls -1 "$BOOT_DIR"/uImage.* | nl

echo ""
echo -n "Select kernel number (0 to exit): "
read choice

if [ "$choice" -eq 0 ]; then
    exit 0
fi

KERNEL=$(ls -1 "$BOOT_DIR"/uImage.* | sed -n "${choice}p")
if [ -f "$KERNEL" ]; then
    ln -sf "$KERNEL" "$BOOT_DIR/uImage"
    echo "Switched to: $KERNEL"
    echo "Reboot to use new kernel"
else
    echo "Invalid selection!"
fi
```

## Prevention Best Practices

1. **Always Test on SD First**
   - Never install untested kernel to internal storage
   - Boot from SD card for initial tests

2. **Keep Multiple Backups**
   - Stock B&N kernel
   - Last known working kernel
   - QuillKernel versions

3. **Document Changes**
   ```bash
   # Before each kernel update
   echo "$(date): Installing $(uname -r)" >> /boot/kernel-history.log
   ```

4. **Serial Console Ready**
   - Have adapter connected
   - Terminal software configured
   - Know U-Boot commands

5. **Recovery SD Prepared**
   - Keep updated with working kernel
   - Test it periodically
   - Store safely

## Emergency Contacts

- **XDA Forums**: Nook Simple Touch section
- **GitHub Issues**: Report QuillKernel problems
- **The Jester**: Deeply apologetic for any crashes

---

```
     .~"~.~"~.
    /  o   o  \    Remember: Even the best squire
   |  >  ◡  <  |   occasionally drops the quill!
    \  ___  /      But recovery is always possible!
     |~|♦|~|       
    d|     |b      
```

*"A kernel backed up is a kernel that can be recovered"* - Ancient IT wisdom