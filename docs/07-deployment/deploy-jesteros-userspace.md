# JesterOS Userspace Deployment Guide

*Last Updated: August 14, 2025*  
*Status: Current Implementation*

## Overview

JesterOS now runs entirely in userspace as shell scripts, eliminating the complexity of kernel module compilation and deployment. This guide covers the deployment of the JesterOS userspace services to your Nook Simple Touch.

## Architecture Change

### Old Method (Deprecated)
- Kernel modules (`.ko` files)
- Required cross-compilation
- Complex `insmod` loading sequence
- `/proc/jokeros/` interface

### New Method (Current)
- Shell scripts in userspace
- No compilation needed
- Simple service startup
- `/var/jesteros/` interface

## Deployment Package Contents

```
jesteros-userspace-package/
├── install.sh                        # Main installation script
├── usr/
│   └── local/
│       └── bin/
│           ├── jesteros-userspace.sh    # Main service
│           ├── jesteros-tracker.sh      # Statistics tracker
│           ├── jester-splash.sh         # Terminal display
│           └── jester-splash-eink.sh    # E-Ink display
├── etc/
│   └── init.d/
│       └── jesteros                  # Init script
└── var/
    └── jesteros/                     # Data directory
        ├── jester                    # ASCII art
        ├── typewriter/
        │   └── stats                 # Writing statistics
        └── wisdom                    # Quotes database
```

## Installation Methods

### Method 1: Automated Installation (Recommended)

```bash
# On your development machine
./install-jesteros-userspace.sh

# Or for system-wide installation on Nook
sudo ./install-jesteros-userspace.sh
```

### Method 2: Manual SD Card Deployment

1. **Prepare SD Card**:
```bash
# Create deployment package
tar czf jesteros-userspace.tar.gz \
    usr/local/bin/jesteros-*.sh \
    etc/init.d/jesteros \
    var/jesteros/

# Copy to SD card
cp jesteros-userspace.tar.gz /media/sdcard/
```

2. **Install on Nook**:
```bash
# Boot Nook and mount SD card
mount /dev/mmcblk1p1 /mnt/sdcard

# Extract package
cd /
tar xzf /mnt/sdcard/jesteros-userspace.tar.gz

# Make scripts executable
chmod +x /usr/local/bin/jesteros-*.sh
chmod +x /etc/init.d/jesteros

# Enable at boot
update-rc.d jesteros defaults
```

### Method 3: ADB Deployment (Rooted Devices)

```bash
# Push files via ADB
adb push jesteros-userspace.tar.gz /data/local/tmp/

# Install on device
adb shell
su
cd /
tar xzf /data/local/tmp/jesteros-userspace.tar.gz
chmod +x /usr/local/bin/jesteros-*.sh
chmod +x /etc/init.d/jesteros

# Start service
/etc/init.d/jesteros start
```

### Method 4: NookManager Integration

1. **Add to NookManager SD card**:
```bash
# Mount NookManager SD card
mount /dev/sdX1 /mnt/nookmanager

# Copy JesterOS files
cp -r usr/local/bin/jesteros-*.sh /mnt/nookmanager/files/usr/local/bin/
cp etc/init.d/jesteros /mnt/nookmanager/files/etc/init.d/

# Add to NookManager script
echo "/etc/init.d/jesteros start" >> /mnt/nookmanager/scripts/after_root.sh
```

2. **Boot from NookManager** and files will be installed automatically

## Service Management

### Starting JesterOS

```bash
# Using init script
/etc/init.d/jesteros start

# Or directly
/usr/local/bin/jesteros-userspace.sh &

# Check if running
ps aux | grep jesteros
```

### Stopping JesterOS

```bash
# Using init script
/etc/init.d/jesteros stop

# Or manually
pkill -f jesteros
```

### Enable Auto-Start at Boot

```bash
# Debian/Ubuntu style
update-rc.d jesteros defaults

# Or add to rc.local
echo "/etc/init.d/jesteros start" >> /etc/rc.local
```

## Verification

### Check Installation

```bash
# Verify files are installed
ls -la /usr/local/bin/jesteros-*
ls -la /var/jesteros/

# Check service status
/etc/init.d/jesteros status
```

### Test Functionality

```bash
# Display jester
cat /var/jesteros/jester

# Check writing statistics
cat /var/jesteros/typewriter/stats

# Get wisdom quote
cat /var/jesteros/wisdom
```

### Expected Output

```
# Jester display
    ___
   /o o\   Happy Jester!
  ( > < )  Ready to write!
   \___/

# Statistics
Words today: 0
Keystrokes: 0
Session time: 0m
Achievement: Novice

# Wisdom
"The pen is mightier than the sword" - Edward Bulwer-Lytton
```

## Troubleshooting

### Service Not Starting

```bash
# Check for errors
bash -x /usr/local/bin/jesteros-userspace.sh

# Verify permissions
ls -la /usr/local/bin/jesteros-*.sh
# Should be executable (755 or +x)

# Check log output
/usr/local/bin/jesteros-userspace.sh 2>&1 | tee /tmp/jesteros.log
```

### Interface Not Available

```bash
# Ensure directory exists
mkdir -p /var/jesteros/typewriter

# Check permissions
chown -R root:root /var/jesteros
chmod -R 755 /var/jesteros
```

### E-Ink Display Issues

```bash
# Test E-Ink support
which fbink

# If missing, install fbink
# Or use terminal mode
JESTEROS_DISPLAY=terminal /usr/local/bin/jester-splash.sh
```

## Migration from Kernel Modules

If you have the old kernel module version installed:

1. **Remove old modules**:
```bash
# Unload if running
rmmod wisdom typewriter jester jokeros_core 2>/dev/null || true

# Remove files
rm -f /lib/modules/2.6.29/*.ko
rm -rf /proc/jokeros
```

2. **Update scripts** that reference old paths:
```bash
# Find scripts using old path
grep -r "/proc/jokeros" /usr/local/bin/

# Update to new path
sed -i 's|/proc/jokeros|/var/jesteros|g' /usr/local/bin/*.sh
```

## Performance Considerations

### Memory Usage
- JesterOS userspace: ~500KB RAM
- Shell scripts: ~10KB disk space
- Runtime data: <1MB in /var/jesteros/

### CPU Impact
- Minimal: <1% CPU usage
- Update interval: 5 seconds for jester mood
- No kernel overhead

### Boot Time
- Service startup: <2 seconds
- No module loading delays
- Instant availability after start

## Security Notes

- Scripts run as root (for system integration)
- No network access required
- Read-only operations except for statistics
- No external dependencies

## Package Creation

To create a deployment package:

```bash
#!/bin/bash
# create-jesteros-package.sh

VERSION="1.0.0"
PACKAGE="jesteros-userspace-${VERSION}"

mkdir -p ${PACKAGE}/{usr/local/bin,etc/init.d,var/jesteros/typewriter}

# Copy scripts
cp source/scripts/boot/jesteros-*.sh ${PACKAGE}/usr/local/bin/
cp source/configs/system/jesteros.init ${PACKAGE}/etc/init.d/jesteros

# Create install script
cat > ${PACKAGE}/install.sh << 'EOF'
#!/bin/sh
cp -r usr/local/bin/* /usr/local/bin/
cp -r etc/init.d/* /etc/init.d/
mkdir -p /var/jesteros/typewriter
chmod +x /usr/local/bin/jesteros-*.sh
chmod +x /etc/init.d/jesteros
update-rc.d jesteros defaults
echo "JesterOS userspace installed successfully!"
EOF

chmod +x ${PACKAGE}/install.sh

# Create package
tar czf ${PACKAGE}.tar.gz ${PACKAGE}/
echo "Package created: ${PACKAGE}.tar.gz"
```

## Summary

The JesterOS userspace deployment is significantly simpler than the old kernel module approach:

- ✅ No compilation required
- ✅ No kernel dependencies
- ✅ Easy installation and updates
- ✅ Safe - can't crash the kernel
- ✅ Portable across Linux systems

---

*"From kernel depths to userspace heights, deployment now delights!"* 🚀