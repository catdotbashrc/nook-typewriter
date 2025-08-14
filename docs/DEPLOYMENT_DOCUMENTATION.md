# 📦 Nook Typewriter Deployment Documentation

*Generated: December 13, 2024*

## Overview

The deployment package provides everything needed to install JesterOS (formerly SquireOS) on a Barnes & Noble Nook Simple Touch, transforming it into a medieval-themed digital typewriter. The package supports multiple installation methods and init systems.

---

## 📁 Deployment Package Structure

```
deployment_package/
├── README.md                    # Package documentation
├── install.sh                   # Automated installer script
├── boot/
│   └── uImage                   # JoKernel with JesterOS support
├── lib/
│   └── modules/
│       └── 2.6.29/
│           ├── jesteros_core.ko # Core module (currently squireos_core.ko)
│           ├── jester.ko        # ASCII art companion
│           ├── typewriter.ko    # Writing statistics
│           ├── wisdom.ko        # Quote system
│           └── load_modules.sh  # Module loader script
├── etc/
│   ├── init.d/
│   │   └── squireos-modules    # SysV init script
│   └── systemd/
│       └── system/
│           └── squireos-modules.service  # SystemD service
└── usr/
    └── local/
        └── bin/
            └── load-squireos-modules.sh  # Manual loader
```

---

## 🚀 Installation Methods

### Method 1: Automated Installation

**Requirements**: Root access on target device

**Process**:
```bash
# Extract package
tar -xzf squireos-nook-*.tar.gz
cd deployment_package

# Run installer
sudo ./install.sh
```

**What the installer does**:
1. Detects init system (Android/SystemD/SysV)
2. Installs kernel to `/boot/uImage.squireos`
3. Copies modules to `/lib/modules/2.6.29/`
4. Installs init scripts for auto-loading
5. Sets proper permissions

### Method 2: Manual Installation

**For custom setups or troubleshooting**:

#### Step 1: Install Kernel
```bash
# Backup existing kernel
cp /boot/uImage /boot/uImage.backup

# Install new kernel
cp boot/uImage /boot/uImage
```

#### Step 2: Install Modules
```bash
# Create module directory
mkdir -p /lib/modules/2.6.29

# Copy modules
cp lib/modules/2.6.29/*.ko /lib/modules/2.6.29/

# Set permissions
chmod 644 /lib/modules/2.6.29/*.ko
```

#### Step 3: Install Scripts
```bash
# Copy loader scripts
cp usr/local/bin/*.sh /usr/local/bin/
chmod +x /usr/local/bin/*.sh

# Install init script (choose one)
# For SysV:
cp etc/init.d/squireos-modules /etc/init.d/
chmod +x /etc/init.d/squireos-modules

# For SystemD:
cp etc/systemd/system/*.service /etc/systemd/system/
systemctl daemon-reload
```

### Method 3: SD Card Installation

**For booting from SD card**:

```bash
# Prepare SD card (2GB+ recommended)
sudo fdisk /dev/sdX  # Create partitions

# Format partitions
sudo mkfs.vfat -F 16 /dev/sdX1  # Boot partition
sudo mkfs.ext4 /dev/sdX2        # Root partition

# Mount partitions
sudo mount /dev/sdX1 /mnt/boot
sudo mount /dev/sdX2 /mnt/root

# Copy kernel
sudo cp boot/uImage /mnt/boot/

# Extract rootfs
sudo tar -xzf rootfs.tar.gz -C /mnt/root/

# Copy modules
sudo cp -r lib/modules /mnt/root/lib/

# Unmount
sudo umount /mnt/boot /mnt/root
```

---

## 🔧 Init System Configuration

### Android/Nook Stock ROM

**Integration with Android init**:

```bash
# Add to /init.rc or create /init.squireos.rc
service squireos /system/bin/sh /usr/local/bin/load-squireos-modules.sh
    class late_start
    oneshot
```

### SystemD Configuration

**Service file** (`squireos-modules.service`):
```ini
[Unit]
Description=JesterOS Medieval Kernel Modules
After=local-fs.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/load-squireos-modules.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

**Enable service**:
```bash
systemctl enable squireos-modules.service
systemctl start squireos-modules.service
```

### SysV Init Configuration

**Init script features**:
- LSB compliant headers
- Start/stop/restart/status support
- Module load order management
- Jester greeting on start

**Enable at boot**:
```bash
# Debian/Ubuntu:
update-rc.d squireos-modules defaults

# RedHat/CentOS:
chkconfig --add squireos-modules
chkconfig squireos-modules on

# Manual:
ln -s /etc/init.d/squireos-modules /etc/rc3.d/S99squireos
```

---

## 📜 Module Loading

### Automatic Loading at Boot

The init scripts handle module loading in the correct order:

1. **jesteros_core.ko** - Creates `/proc/jesteros/` filesystem
2. **jester.ko** - ASCII art companion
3. **typewriter.ko** - Writing statistics
4. **wisdom.ko** - Quote system

### Manual Module Loading

```bash
# Using provided script
/usr/local/bin/load-squireos-modules.sh

# Or manually
insmod /lib/modules/2.6.29/squireos_core.ko
insmod /lib/modules/2.6.29/jester.ko
insmod /lib/modules/2.6.29/typewriter.ko
insmod /lib/modules/2.6.29/wisdom.ko
```

### Verification

```bash
# Check modules loaded
lsmod | grep -E "jester|typewriter|wisdom"

# Check /proc interface
ls -la /proc/jesteros/

# View jester
cat /proc/jesteros/jester

# Check version
cat /proc/jesteros/version
```

---

## 🎯 Deployment Targets

### Nook Simple Touch (Primary)

**Specifications**:
- CPU: TI OMAP3621 @ 800MHz
- RAM: 256MB
- Storage: 2GB internal + SD slot
- Display: 6" E-Ink

**Installation Path**:
```
/boot/          # Kernel location
/lib/modules/   # Module location
/system/bin/    # Android binaries (if stock ROM)
```

### Nook with Custom ROM

**Supported ROMs**:
- NookManager
- CM7 for Nook
- Debian for Nook

**Adjustments**:
- Use appropriate init system
- May need different kernel path
- Check module compatibility

### Development/Testing

**Docker Container**:
```bash
# Test deployment in container
docker run -it --rm -v $(pwd):/deploy debian:bullseye
cd /deploy
./install.sh
```

---

## 📊 Deployment Verification

### Post-Installation Checks

```bash
#!/bin/bash
# Deployment verification script

echo "Checking JesterOS deployment..."

# 1. Check kernel
if [ -f /boot/uImage.squireos ]; then
    echo "✓ Kernel installed"
else
    echo "✗ Kernel not found"
fi

# 2. Check modules
for mod in squireos_core jester typewriter wisdom; do
    if [ -f /lib/modules/2.6.29/${mod}.ko ]; then
        echo "✓ Module ${mod}.ko present"
    else
        echo "✗ Module ${mod}.ko missing"
    fi
done

# 3. Check scripts
if [ -x /usr/local/bin/load-squireos-modules.sh ]; then
    echo "✓ Loader script executable"
else
    echo "✗ Loader script missing/not executable"
fi

# 4. Check init integration
if systemctl list-unit-files | grep -q squireos; then
    echo "✓ SystemD service registered"
elif [ -f /etc/init.d/squireos-modules ]; then
    echo "✓ SysV init script present"
else
    echo "⚠ No init integration found"
fi

# 5. Check /proc interface
if [ -d /proc/jesteros ]; then
    echo "✓ JesterOS interface active"
    ls /proc/jesteros/
else
    echo "✗ JesterOS interface not active"
fi
```

---

## 🚨 Troubleshooting

### Common Issues

#### Issue: Modules fail to load
**Causes & Solutions**:
```bash
# Check kernel version
uname -r  # Must be 2.6.29

# Check module files
ls -la /lib/modules/2.6.29/*.ko

# Check permissions
chmod 644 /lib/modules/2.6.29/*.ko

# Check kernel log
dmesg | grep -E "jester|squireos"
```

#### Issue: /proc/jesteros not created
**Solutions**:
```bash
# Ensure core module loaded first
rmmod jester typewriter wisdom 2>/dev/null
rmmod squireos_core 2>/dev/null
insmod /lib/modules/2.6.29/squireos_core.ko
```

#### Issue: Init script not running at boot
**Solutions**:
```bash
# For SystemD
systemctl status squireos-modules.service
journalctl -u squireos-modules.service

# For SysV
/etc/init.d/squireos-modules status
```

#### Issue: E-Ink display not showing jester
**Solutions**:
```bash
# Install FBInk
wget https://github.com/NiLuJe/FBInk/releases/download/v1.25.0/fbink
chmod +x fbink
./fbink -c  # Clear screen
```

---

## 🔐 Security Considerations

### File Permissions

```bash
# Recommended permissions
/boot/uImage                    - 644 root:root
/lib/modules/2.6.29/*.ko        - 644 root:root
/usr/local/bin/*.sh             - 755 root:root
/etc/init.d/squireos-modules    - 755 root:root
```

### Module Signing

For production deployments:
```bash
# Sign modules (if kernel supports it)
scripts/sign-file sha256 signing_key.pem signing_key.x509 module.ko
```

### Verification

```bash
# Verify package integrity
sha256sum -c squireos-nook.sha256

# Check module info
modinfo /lib/modules/2.6.29/squireos_core.ko
```

---

## 📈 Deployment Metrics

### Package Sizes

| Component | Size | Compressed |
|-----------|------|------------|
| Kernel (uImage) | 1.9MB | 1.8MB |
| Modules (all) | 200KB | 150KB |
| Scripts | 20KB | 10KB |
| Total Package | 2.2MB | 2.0MB |

### Installation Time

| Method | Time | Notes |
|--------|------|-------|
| Automated | <1 min | With script |
| Manual | 5 min | Step by step |
| SD Card | 10 min | Including formatting |

### Boot Impact

- Module load time: ~2 seconds
- Memory usage: <1MB for all modules
- CPU impact: Negligible after init

---

## 🔄 Updates and Maintenance

### Updating Modules Only

```bash
# Download update package
wget https://example.com/squireos-modules-update.tar.gz

# Backup existing
cp -r /lib/modules/2.6.29 /lib/modules/2.6.29.backup

# Install new modules
tar -xzf squireos-modules-update.tar.gz -C /

# Reload modules
/etc/init.d/squireos-modules restart
```

### Updating Kernel

```bash
# Backup current kernel
cp /boot/uImage /boot/uImage.backup

# Install new kernel
cp new-uImage /boot/uImage

# Reboot required
reboot
```

---

## 📚 Related Documentation

- [Installation Guide](INSTALLATION_GUIDE.md)
- [SD Card Setup](SD_CARD_SETUP.md)
- [Module Configuration](MODULE_CONFIG.md)
- [Troubleshooting Guide](TROUBLESHOOTING.md)

---

## 🎭 Post-Installation

Once installed, the medieval writing environment provides:

- **Jester Companion**: ASCII art mood indicator
- **Writing Statistics**: Track your progress
- **Wisdom Quotes**: Inspiration while writing
- **Distraction-Free**: No internet, pure focus

Access features:
```bash
# View the jester
cat /proc/jesteros/jester

# Check writing stats
cat /proc/jesteros/typewriter/stats

# Get wisdom
cat /proc/jesteros/wisdom

# See version
cat /proc/jesteros/version
```

---

*"Deploy with confidence, write with joy!"* 🎭

**Version**: 1.0.0  
**Last Updated**: December 13, 2024  
**Package Format**: tar.gz