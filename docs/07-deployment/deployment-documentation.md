# 📦 Nook Typewriter Deployment Documentation

*Last Updated: August 14, 2025*

## Overview

The deployment package provides everything needed to install JesterOS on a Barnes & Noble Nook Simple Touch, transforming it into a medieval-themed digital typewriter. JesterOS now runs as lightweight userspace services, making deployment simpler and safer.

---

## 📁 Deployment Package Structure

```
deployment_package/
├── README.md                    # Package documentation
├── install.sh                   # Automated installer script
├── boot/
│   └── uImage                   # Linux kernel 2.6.29
├── usr/
│   └── local/
│       └── bin/
│           ├── jesteros-userspace.sh    # Main JesterOS service
│           ├── jesteros-tracker.sh      # Writing statistics tracker
│           ├── jester-splash.sh         # Terminal display
│           └── jester-splash-eink.sh    # E-Ink optimized display
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

**Requirements**: Root access on target device

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

### Method 3: SD Card Deployment

**For development and testing**:

1. **Prepare SD card** with deployment package:
```bash
# Copy to SD card
cp -r deployment_package/* /media/sdcard/nook-deploy/
```

2. **Boot Nook** from SD card

3. **Install from SD**:
```bash
cd /mnt/sdcard/nook-deploy
./install.sh
```

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

### Updating JesterOS

```bash
# Stop service
sudo /etc/init.d/jesteros stop

# Backup current version
sudo cp -r /usr/local/bin/jesteros-*.sh /usr/local/bin/backup/

# Copy new scripts
sudo cp new-version/jesteros-*.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/jesteros-*.sh

# Restart service
sudo /etc/init.d/jesteros start
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

### Resource Usage
- **Memory**: ~500KB RAM (userspace scripts)
- **CPU**: <1% average usage
- **Disk**: ~50KB for scripts, <1MB for data
- **Boot time**: +2 seconds for JesterOS startup

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

### Package Builder Script

```bash
#!/bin/bash
# build-deployment-package.sh

VERSION="1.0.0"
PACKAGE_NAME="jesteros-nook-${VERSION}"

echo "Building JesterOS deployment package v${VERSION}"

# Create structure
mkdir -p ${PACKAGE_NAME}/{usr/local/bin,etc/init.d,var/jesteros/typewriter,boot}

# Copy files
cp source/scripts/boot/jesteros-*.sh ${PACKAGE_NAME}/usr/local/bin/
cp source/configs/system/jesteros.init ${PACKAGE_NAME}/etc/init.d/jesteros
cp firmware/boot/uImage ${PACKAGE_NAME}/boot/ 2>/dev/null || true

# Create installer
cat > ${PACKAGE_NAME}/install.sh << 'EOF'
#!/bin/bash
set -e
echo "Installing JesterOS userspace..."
cp -r usr/local/bin/* /usr/local/bin/
cp -r etc/init.d/* /etc/init.d/
mkdir -p /var/jesteros/typewriter
chmod +x /usr/local/bin/jesteros-*.sh
chmod +x /etc/init.d/jesteros
update-rc.d jesteros defaults 2>/dev/null || true
echo "JesterOS installed successfully!"
echo "Start with: /etc/init.d/jesteros start"
EOF

chmod +x ${PACKAGE_NAME}/install.sh

# Create archive
tar czf ${PACKAGE_NAME}.tar.gz ${PACKAGE_NAME}/
echo "Package created: ${PACKAGE_NAME}.tar.gz"
```

---

## 🔗 Related Documentation

- [JesterOS Userspace Deployment](deployment/DEPLOY_JESTEROS_USERSPACE.md)
- [Boot Guide](BOOT_GUIDE_CONSOLIDATED.md)
- [Migration from Kernel Modules](MIGRATION_TO_USERSPACE.md)
- [Testing Procedures](TESTING_PROCEDURES.md)

---

*"Deploy with joy, no kernel to annoy!"* 🚀📚