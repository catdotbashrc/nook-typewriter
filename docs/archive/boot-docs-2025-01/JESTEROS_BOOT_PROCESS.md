# JesterOS Boot Process Documentation

## Overview

JesterOS implements a safe, two-stage boot process for the Nook Simple Touch e-reader that preserves device recoverability while providing a minimal, distraction-free writing environment.

## Boot Architecture

### Stage 1: SD Card Boot (Development/Testing)
The device boots entirely from SD card without modifying internal storage, allowing safe testing and development.

### Stage 2: Internal Installation (Production)
After validation, JesterOS can be installed to internal storage while preserving critical recovery partitions.

## Partition Structure

```
/dev/mmcblk0p1  /boot     [PRESERVE]  - Contains kernel and boot configuration
/dev/mmcblk0p2  /rom      [NEVER TOUCH] - Factory recovery system
/dev/mmcblk0p3  /media    [OPTIONAL]  - Media storage
/dev/mmcblk0p5  /system   [REPLACE]   - Operating system files
/dev/mmcblk0p6  /cache    [WIPE]      - System cache
/dev/mmcblk0p8  /data     [WIPE]      - User data and settings
```

**CRITICAL**: Never modify `/rom` partition - it contains factory recovery

## Boot Sequence

### 1. Hardware Initialization
```
Power Button → U-Boot → Check SD Card → Load Kernel
```

### 2. Boot Priority
```
1. SD Card (if present and bootable)
2. Internal /boot partition
3. Factory recovery (8 failed boots)
```

### 3. JesterOS Initialization
```bash
# Boot sequence from kernel init
/init                          # Android init process
├── /system/bin/clrbootcount.sh  # Clear boot counter
├── /system/init.rc              # Android services
└── /system/bin/jesteros-init    # JesterOS services
    ├── Mount filesystems
    ├── Start jester services
    ├── Initialize E-Ink display
    └── Launch writing environment
```

## Installation Methods

### Method 1: Safe SD Card Boot (Recommended First)

**Requirements:**
- SanDisk Class 10 SD card (proven compatible)
- 2GB minimum capacity
- Computer with SD card reader

**Process:**
```bash
# 1. Prepare SD card
dd if=jesteros-sdboot.img of=/dev/sdX bs=1M status=progress

# 2. Insert SD card into Nook
# 3. Power on device
# 4. JesterOS boots from SD without modifying device
```

### Method 2: Internal Installation (After Testing)

**Pre-Installation Checklist:**
- [ ] SD card boot tested successfully
- [ ] CWM recovery SD card created and tested
- [ ] Full device backup completed
- [ ] Backup copied to computer
- [ ] Recovery process documented

**Installation Script:**
```bash
#!/bin/bash
# jesteros-install.sh - Runs from bootable SD card

set -euo pipefail

echo "JesterOS Installation Starting..."
echo "================================"

# Safety checks
if [ ! -f /sdcard/jesteros-system.tar.gz ]; then
    echo "ERROR: System archive not found!"
    exit 1
fi

# Create backup
echo "[1/6] Creating safety backup..."
mkdir -p /sdcard/backup
dd if=/dev/mmcblk0p5 of=/sdcard/backup/system.img bs=4M
dd if=/dev/mmcblk0p1 of=/sdcard/backup/boot.img bs=4M
tar czf /sdcard/backup/critical-files.tar.gz \
    /system/build.prop \
    /system/bin/clrbootcount.sh

# Mount partitions
echo "[2/6] Mounting partitions..."
mount /dev/mmcblk0p5 /mnt/system
mount /dev/mmcblk0p8 /mnt/data
mount /dev/mmcblk0p6 /mnt/cache

# Clean installation
echo "[3/6] Cleaning partitions..."
rm -rf /mnt/cache/*
rm -rf /mnt/data/*
rm -rf /mnt/system/*

# Install JesterOS
echo "[4/6] Installing JesterOS..."
tar xzf /sdcard/jesteros-system.tar.gz -C /mnt/system/
tar xzf /sdcard/jesteros-data.tar.gz -C /mnt/data/

# Preserve device identity
echo "[5/6] Preserving device configuration..."
cp /sdcard/backup/critical-files/system/build.prop /mnt/system/
cp /sdcard/backup/critical-files/system/bin/clrbootcount.sh /mnt/system/bin/

# Configure boot
echo "[6/6] Configuring boot..."
echo "init=/init console=ttyS0,115200 root=/dev/mmcblk0p5" > /mnt/system/boot.conf

# Sync and unmount
sync
umount /mnt/system
umount /mnt/data
umount /mnt/cache

echo "================================"
echo "Installation Complete!"
echo "Remove SD card and reboot device"
```

## Recovery Procedures

### Recovery Option 1: CWM Recovery
```bash
# 1. Create CWM recovery SD card
wget https://xda/cwm/sd_128mb_clockwork-rc2.zip
unzip sd_128mb_clockwork-rc2.zip
dd if=cwm-recovery.img of=/dev/sdX bs=1M

# 2. Boot from CWM SD card
# 3. Select "Restore" from menu
# 4. Choose backup to restore
```

### Recovery Option 2: Factory Reset
```
1. Power off device completely
2. Power on and immediately power off (before boot completes)
3. Repeat 8 times
4. Device enters factory recovery mode
5. Restores original B&N firmware
```

### Recovery Option 3: Manual Restoration
```bash
# Boot from any Linux SD card
mount /dev/mmcblk0p5 /mnt/system
mount /dev/mmcblk0p8 /mnt/data

# Restore from backup
dd if=/sdcard/backup/system.img of=/dev/mmcblk0p5 bs=4M
sync
reboot
```

## Critical Safety Features

### 1. Boot Counter Protection
```bash
# clrbootcount.sh - Prevents factory reset trigger
#!/system/bin/sh
echo -n -e "\x00\x00\x00\x00" > /rom/devconf/BootCnt
```

### 2. Power Management
```bash
# Prevent 14% daily battery drain issue
# Target: 1.5% daily drain when idle
echo "mem" > /sys/power/state  # Proper sleep mode
echo "1" > /sys/devices/platform/gpio-keys/disabled  # Disable when sleeping
```

### 3. Touch Recovery
```bash
# Handle known hardware touch lock-up issue
# Two-finger swipe gesture handler
if [ "$TOUCH_FROZEN" = "1" ]; then
    echo "reset" > /sys/devices/platform/i2c_omap.2/i2c-2/2-0050/reset
fi
```

## Boot Configuration Files

### /system/init.rc
```bash
# JesterOS init.rc additions
service jesteros /system/bin/jesteros-init
    class late_start
    user root
    group root
    oneshot

on property:sys.boot_completed=1
    start jesteros
```

### /system/bin/jesteros-init
```bash
#!/system/bin/sh
# JesterOS initialization script

# Mount JesterOS filesystem
mount -t tmpfs -o size=10M tmpfs /var/jesteros

# Start jester services
/usr/local/bin/jester-mood &
/usr/local/bin/typewriter-stats &
/usr/local/bin/wisdom-quotes &

# Initialize E-Ink display
fbink -c  # Clear display
fbink -q "JesterOS Ready"

# Launch menu
/usr/local/bin/nook-menu.sh
```

## Performance Targets

| Metric | Target | Current |
|--------|--------|---------|
| Boot Time | < 30 seconds | Testing |
| Idle Battery Drain | 1.5% per day | Testing |
| Touch Response | Immediate | Testing |
| Memory Usage | < 35MB available | Testing |

## Troubleshooting

### Device Won't Boot
1. Remove SD card and try internal boot
2. Try different SD card (must be SanDisk Class 10)
3. Check SD card partition alignment (sector 63)
4. Attempt factory recovery (8 failed boots)

### Touch Screen Frozen
1. Try two-finger horizontal swipe
2. Clean screen edges with compressed air
3. Press power button to sleep/wake
4. Hold power 30 seconds for hard reset

### Battery Draining Quickly
1. Check if device is registered (unregistered = 14% daily drain)
2. Verify WiFi is truly off (not just hidden)
3. Remove weather widget if present
4. Check for EBookDroid in landscape mode

## Development Guidelines

### Testing Protocol
1. **Always test on SD card first**
2. Never modify /rom partition
3. Keep CWM recovery SD ready
4. Document all changes
5. Test battery drain over 24 hours
6. Verify touch recovery gesture works

### Building Bootable SD Card
```bash
# Create partition table
fdisk /dev/sdX << EOF
o     # Create DOS partition table
n     # New partition
p     # Primary
1     # Partition 1
63    # Start sector (CRITICAL: must be 63)
+100M # Size
t     # Change type
6     # FAT16
a     # Make bootable
w     # Write
EOF

# Format and copy files
mkfs.vfat -F 16 /dev/sdX1
mount /dev/sdX1 /mnt
cp -r boot/* /mnt/
umount /mnt
```

## Community Resources

- **Phoenix Project Thread**: https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/
- **CWM Recovery Images**: Available from Phoenix Project
- **NookManager**: https://xdaforums.com/t/nst-g-updating-nookmanager-for-fw-1-2-2.3873048/
- **Known Issues**: Touch lock-up affects all devices (hardware issue)

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 0.1.0 | 2024-01 | Initial boot process design |
| 0.2.0 | 2024-01 | Added Phoenix Project insights |
| 0.3.0 | 2024-01 | Implemented safety measures |

## Author Notes

This boot process prioritizes safety and recoverability. The two-stage approach (SD boot then internal install) ensures users can test without risk. The preservation of /rom partition guarantees factory recovery is always possible.

Remember: **A writer who loses their work loses trust. Make backups.**

---

*"By quill and candlelight, we boot safely into the night"* 🕯️📜