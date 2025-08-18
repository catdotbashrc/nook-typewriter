# 📦 Nook Typewriter Deployment Documentation

*Last Updated: August 14, 2025*

## Overview

The deployment package provides everything needed to install JesterOS on a Barnes & Noble Nook Simple Touch, transforming it into a medieval-themed digital typewriter. JesterOS now runs as lightweight userspace services with our resilient **4-partition recovery architecture**, making deployment simpler, safer, and virtually indestructible.

### 🎯 New in v2.0
- **USB Keyboard Support**: Full external keyboard integration
- **GK61 Optimization**: Mechanical keyboard support via USB OTG
- **Modular Docker Build**: Simplified deployment with jesteros-base
- **Enhanced Input Handling**: Multiple input device management

---

## 📁 Deployment Package Structure

```
deployment_package/
├── README.md                    # Package documentation
├── install.sh                   # Automated installer script
├── create-sdcard.sh            # 4-partition SD card creator
├── boot/
│   ├── MLO                     # First stage bootloader
│   ├── u-boot.bin              # Second stage bootloader
│   ├── uImage                  # Linux kernel 2.6.29
│   └── boot.scr                # Boot script with recovery
├── images/
│   ├── jesteros-system.tar.gz  # Main system image
│   ├── jesteros-recovery.tar.gz # Recovery system
│   └── checksums.md5           # Integrity verification
├── usr/
│   └── local/
│       └── bin/
│           ├── jesteros-userspace.sh    # Main JesterOS service
│           ├── jesteros-tracker.sh      # Writing statistics tracker
│           ├── jester-splash.sh         # Terminal display
│           ├── jester-splash-eink.sh    # E-Ink optimized display
│           ├── usb-keyboard-manager.sh  # USB keyboard support
│           └── usb-keyboard-setup.sh    # Keyboard configuration
├── etc/
│   └── init.d/
│       └── jesteros             # Init script for JesterOS
└── var/
    └── jesteros/                # JesterOS data directory
        ├── jester               # ASCII art storage
        ├── typewriter/
        │   └── stats            # Writing statistics
        └── wisdom               # Quotes database
```

---

## 🚀 Installation Methods

### Method 1: Automated Installation (Recommended)

**Requirements**: 
- Root access on target device
- (Optional) USB OTG cable + powered hub for keyboard support

**Process**:
```bash
# Extract package
tar -xzf jesteros-nook-*.tar.gz
cd jesteros-nook-*/

# Run installer
sudo ./install.sh

# Verify installation
/etc/init.d/jesteros status
```

**What it does**:
- Copies JesterOS scripts to `/usr/local/bin/`
- Creates `/var/jesteros/` directory structure
- Installs init script
- Enables auto-start at boot
- Configures USB keyboard support (if hardware detected)
- Sets up input device monitoring

### Method 2: Manual Installation

**For custom configurations**:

```bash
# Copy scripts
sudo cp usr/local/bin/jesteros-*.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/jesteros-*.sh

# Create data directory
sudo mkdir -p /var/jesteros/typewriter

# Install init script
sudo cp etc/init.d/jesteros /etc/init.d/
sudo chmod +x /etc/init.d/jesteros

# Enable at boot
sudo update-rc.d jesteros defaults

# Start service
sudo /etc/init.d/jesteros start
```

### Method 3: 4-Partition SD Card Deployment (Recommended)

**For production deployment with recovery**:

1. **Create 4-partition SD card**:
```bash
# Run automated script
sudo ./create-sdcard.sh /dev/sdX

# This creates:
# - Partition 1: BOOT (512MB) - Bootloader & recovery flags
# - Partition 2: SYSTEM (1.5GB) - JesterOS (read-only)
# - Partition 3: RECOVERY (1.5GB) - Factory image & tools
# - Partition 4: WRITING (remaining) - User documents
```

2. **Deploy JesterOS**:
```bash
# Extract to system partition
sudo tar -xzf images/jesteros-system.tar.gz -C /mnt/system/

# Install recovery image
sudo tar -xzf images/jesteros-recovery.tar.gz -C /mnt/recovery/

# Copy boot files (ORDER MATTERS!)
sudo cp boot/MLO /mnt/boot/MLO && sync
sudo cp boot/u-boot.bin /mnt/boot/u-boot.bin && sync
sudo cp boot/uImage /mnt/boot/uImage && sync
sudo cp boot/boot.scr /mnt/boot/boot.scr && sync
```

3. **Boot Nook** from SD card

4. **Recovery Options**:
   - **Normal boot**: Powers on to JesterOS
   - **Recovery mode**: Hold Power+Home during boot
   - **Auto-recovery**: Triggers after 3 failed boots

### Method 4: NookManager Integration

**Using NookManager for rooted devices**:

1. **Add to NookManager** SD card:
```bash
# Mount NookManager SD
mount /dev/sdX1 /mnt/nookmanager

# Copy JesterOS files
cp -r usr/local/bin/* /mnt/nookmanager/files/usr/local/bin/
cp etc/init.d/jesteros /mnt/nookmanager/files/etc/init.d/
```

2. **Boot from NookManager** - files install automatically

---

## 🔧 Service Configuration

### Init Systems Support

#### SysV Init (Default for Nook)
```bash
# Start/stop/restart
/etc/init.d/jesteros start
/etc/init.d/jesteros stop
/etc/init.d/jesteros restart

# Enable at boot
update-rc.d jesteros defaults

# Disable at boot
update-rc.d jesteros remove
```

#### Manual Start
```bash
# Direct execution
/usr/local/bin/jesteros-userspace.sh &

# With logging
/usr/local/bin/jesteros-userspace.sh 2>&1 | tee /var/log/jesteros.log &
```

### Configuration Options

```bash
# Environment variables (set in /etc/default/jesteros)
JESTEROS_HOME=/var/jesteros          # Data directory
JESTEROS_UPDATE_INTERVAL=5           # Mood update interval (seconds)
JESTEROS_DISPLAY=eink                # Display mode: eink or terminal
```

---

## ✅ Verification

### Post-Installation Checks

```bash
#!/bin/bash
# verify-jesteros.sh

echo "=== JesterOS Installation Verification ==="

# Check files installed
echo -n "Scripts installed: "
if [ -f /usr/local/bin/jesteros-userspace.sh ]; then
    echo "✓"
else
    echo "✗"
    exit 1
fi

# Check service running
echo -n "Service running: "
if pgrep -f jesteros > /dev/null; then
    echo "✓"
else
    echo "✗"
    exit 1
fi

# Check interface available
echo -n "Interface ready: "
if [ -f /var/jesteros/jester ]; then
    echo "✓"
    cat /var/jesteros/jester
else
    echo "✗"
    exit 1
fi

echo "=== JesterOS is working! ==="
```

### Functional Tests

```bash
# Test jester display
cat /var/jesteros/jester

# Test statistics tracking
echo "test" > /tmp/test.txt
sleep 6
cat /var/jesteros/typewriter/stats

# Test wisdom quotes
cat /var/jesteros/wisdom
sleep 1
cat /var/jesteros/wisdom  # Should show different quote
```

---

## 🔄 Updates and Upgrades

### Safe A/B Update System

The 4-partition layout enables risk-free updates:

```bash
# Method 1: Update via Recovery Partition
# Download update to recovery partition
wget -O /recovery/images/jesteros-v1.1.tar.gz https://...

# Verify checksum
md5sum -c /recovery/images/checksums.md5

# Test update in recovery partition first
touch /boot/TEST_UPDATE
reboot  # Boots from recovery partition

# If successful, swap partitions
dd if=/dev/mmcblk0p3 of=/dev/mmcblk0p2 bs=4M status=progress
```

### Traditional Update (In-Place)

```bash
# Mount system partition read-write
mount -o remount,rw /

# Backup current version
cp -r /usr/local/bin/jesteros-*.sh /recovery/backup/

# Apply updates
tar -xzf jesteros-update.tar.gz -C /

# Remount read-only
mount -o remount,ro /

# Restart services
/etc/init.d/jesteros restart
```

### Version Management

```bash
# Check version
/usr/local/bin/jesteros-userspace.sh --version

# Version file location
cat /var/jesteros/version
```

---

## 🐛 Troubleshooting

### Common Issues

#### Service Won't Start
```bash
# Check for errors
bash -x /usr/local/bin/jesteros-userspace.sh

# Verify permissions
ls -la /usr/local/bin/jesteros-*.sh
chmod +x /usr/local/bin/jesteros-*.sh
```

#### Interface Not Available
```bash
# Create directory structure
mkdir -p /var/jesteros/typewriter

# Check permissions
chown -R root:root /var/jesteros
chmod -R 755 /var/jesteros
```

#### E-Ink Display Issues
```bash
# Test fbink
which fbink || echo "fbink not installed"

# Use terminal mode
export JESTEROS_DISPLAY=terminal
/usr/local/bin/jester-splash.sh
```

### Debug Mode

```bash
# Enable debug output
export JESTEROS_DEBUG=1
/usr/local/bin/jesteros-userspace.sh

# Check logs
tail -f /var/log/jesteros.log
```

---

## 📊 Performance Impact

### Resource Usage (4-Partition Setup)
- **Memory**: ~500KB RAM (userspace scripts)
- **CPU**: <1% average usage
- **Disk Usage**:
  - BOOT: 10MB used of 512MB
  - SYSTEM: 450MB used of 1.5GB
  - RECOVERY: 450MB used of 1.5GB
  - WRITING: User data (unlimited)
- **Boot time**: 
  - Normal boot: 15-18 seconds
  - Recovery boot: 12-15 seconds
  - JesterOS startup: +2 seconds

### Optimization Tips
- Adjust update interval for less CPU usage
- Use terminal mode if E-Ink is slow
- Disable unused features in config

---

## 🔐 Security Considerations

### Permissions
- Scripts run as root (for system integration)
- Data files are world-readable
- No network access required
- No external dependencies

### Hardening
```bash
# Restrict script permissions
chmod 750 /usr/local/bin/jesteros-*.sh

# Limit data directory access
chmod 755 /var/jesteros
```

---

## 📦 Creating Deployment Packages

### Package Builder Script (4-Partition)

```bash
#!/bin/bash
# build-deployment-package.sh

VERSION="1.0.0"
PACKAGE_NAME="jesteros-nook-${VERSION}"

echo "Building JesterOS deployment package v${VERSION} with recovery"

# Create structure
mkdir -p ${PACKAGE_NAME}/{usr/local/bin,etc/init.d,var/jesteros/typewriter}
mkdir -p ${PACKAGE_NAME}/{boot,images,recovery,tools}

# Copy system files
cp source/utilities/boot/jesteros-*.sh ${PACKAGE_NAME}/usr/local/bin/
cp source/configs/system/jesteros.init ${PACKAGE_NAME}/etc/init.d/jesteros

# Copy boot files (critical order!)
cp firmware/boot/MLO ${PACKAGE_NAME}/boot/
cp firmware/boot/u-boot.bin ${PACKAGE_NAME}/boot/
cp firmware/boot/uImage ${PACKAGE_NAME}/boot/
cp utilities/boot.scr ${PACKAGE_NAME}/boot/

# Create system and recovery images
tar -czf ${PACKAGE_NAME}/images/jesteros-system.tar.gz -C build/rootfs/ .
tar -czf ${PACKAGE_NAME}/images/jesteros-recovery.tar.gz -C build/recovery/ .

# Generate checksums
(cd ${PACKAGE_NAME}/images && md5sum *.tar.gz > checksums.md5)

# Create SD card preparation script
cat > ${PACKAGE_NAME}/create-sdcard.sh << 'EOF'
#!/bin/bash
set -euo pipefail

DEVICE="${1:-}"
[ -z "$DEVICE" ] && echo "Usage: $0 /dev/sdX" && exit 1

echo "Creating 4-partition JesterOS SD card on $DEVICE"
echo "WARNING: This will ERASE all data!"
read -p "Continue? (yes/no): " confirm
[ "$confirm" != "yes" ] && exit 1

# Create partitions with sector 63 alignment
sudo fdisk $DEVICE << FDISK_EOF
o
n
p
1
63
+512M
t
c
a
1
n
p
2

+1536M
n
p
3

+1536M
n
e


n


w
FDISK_EOF

# Format partitions
sudo mkfs.vfat -F 16 -n BOOT ${DEVICE}1
sudo mkfs.ext4 -L JESTEROS ${DEVICE}2
sudo mkfs.ext4 -L RECOVERY ${DEVICE}3
sudo mkfs.ext4 -L WRITING ${DEVICE}5

echo "SD card prepared! Now run deploy.sh to install JesterOS."
EOF

chmod +x ${PACKAGE_NAME}/create-sdcard.sh

chmod +x ${PACKAGE_NAME}/install.sh

# Create archive
tar czf ${PACKAGE_NAME}.tar.gz ${PACKAGE_NAME}/
echo "Package created: ${PACKAGE_NAME}.tar.gz"
```

---

## 🔗 Related Documentation

- [4-Partition Strategy](../storage/PARTITION_STRATEGY.md)
- [SD Card Boot Guide](../01-getting-started/sd-card-boot-guide.md)
- [Build Guide](../02-build/jesteros-build-guide.md)
- [Hardware Reference](../hardware/)
- [Recovery Procedures](../storage/PARTITION_STRATEGY.md#emergency-recovery-procedures)
- [Testing Procedures](../08-testing/testing-procedures.md)

---

*"Deploy with joy, no kernel to annoy!"* 🚀📚