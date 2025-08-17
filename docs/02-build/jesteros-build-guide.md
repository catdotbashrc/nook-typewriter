# JesterOS Build Guide
*Complete build process for JesterOS with 4-partition recovery architecture*

## Overview

This guide covers building JesterOS from source, creating deployment images, and preparing SD cards with our resilient 4-partition layout.

---

## Prerequisites

### Development Environment
```yaml
Host OS: Linux (Ubuntu 20.04+ or Debian 10+)
Architecture: x86_64
RAM: 4GB minimum (8GB recommended)
Disk Space: 20GB free
Docker: Version 20.10+
```

### Required Tools
```bash
# Install build dependencies
sudo apt-get update
sudo apt-get install -y \
    build-essential \
    git \
    docker.io \
    debootstrap \
    qemu-user-static \
    binfmt-support \
    parted \
    dosfstools \
    e2fsprogs \
    u-boot-tools
```

### Source Code
```bash
# Clone JesterOS repository
git clone https://github.com/yourusername/jesteros-nook.git
cd jesteros-nook
```

---

## Build Process

### 1. Build JesterOS Docker Image

```bash
# Build the optimized writer environment
docker build \
    -t jesteros:latest \
    --build-arg BUILD_MODE=writer \
    -f nookwriter-optimized.dockerfile .

# Verify build
docker run --rm jesteros:latest cat /etc/jesteros-version
```

### 2. Extract Root Filesystem

```bash
# Create container and export filesystem
docker create --name jesteros-export jesteros:latest
docker export jesteros-export | gzip > jesteros-rootfs.tar.gz
docker rm jesteros-export

# Verify size (should be <500MB compressed)
ls -lh jesteros-rootfs.tar.gz
```

### 3. Build Recovery Image

```bash
# Build minimal recovery environment
docker build \
    -t jesteros:recovery \
    --build-arg BUILD_MODE=recovery \
    -f recovery.dockerfile .

# Export recovery image
docker create --name recovery-export jesteros:recovery
docker export recovery-export | gzip > jesteros-recovery.tar.gz
docker rm recovery-export
```

### 4. Compile Custom Kernel (Optional)

```bash
# Build kernel using Docker
./build_kernel.sh

# Output will be in:
# - build/kernel/arch/arm/boot/uImage
# - build/kernel/System.map
# - build/kernel/modules.tar.gz
```

---

## Creating Deployment Images

### Factory Image Structure

```
jesteros-v1.0-release/
├── images/
│   ├── jesteros-rootfs.tar.gz     # Main system (~450MB)
│   ├── jesteros-recovery.tar.gz   # Recovery system (~200MB)
│   └── checksums.md5               # Integrity verification
├── boot/
│   ├── MLO                         # First stage bootloader
│   ├── u-boot.bin                  # Second stage bootloader
│   ├── uImage                      # Kernel image
│   └── boot.scr                    # Boot script
├── tools/
│   ├── create-sdcard.sh            # Automated SD card creation
│   ├── backup-writings.sh          # User data backup
│   └── restore-system.sh           # System restoration
└── docs/
    ├── README.md                   # Installation guide
    ├── RECOVERY.md                 # Recovery procedures
    └── CHANGELOG.md                # Version history
```

### Creating Release Package

```bash
#!/bin/bash
# create-release.sh

VERSION="1.0"
RELEASE_DIR="jesteros-v${VERSION}-release"

# Create directory structure
mkdir -p ${RELEASE_DIR}/{images,boot,tools,docs}

# Copy images
cp jesteros-rootfs.tar.gz ${RELEASE_DIR}/images/
cp jesteros-recovery.tar.gz ${RELEASE_DIR}/images/

# Copy boot files (order matters!)
cp firmware/boot/MLO ${RELEASE_DIR}/boot/
cp firmware/boot/u-boot.bin ${RELEASE_DIR}/boot/
cp build/kernel/arch/arm/boot/uImage ${RELEASE_DIR}/boot/
cp scripts/boot.scr ${RELEASE_DIR}/boot/

# Generate checksums
cd ${RELEASE_DIR}/images
md5sum *.tar.gz > checksums.md5
cd ../..

# Create SD card preparation script
cat > ${RELEASE_DIR}/tools/create-sdcard.sh << 'SCRIPT_EOF'
#!/bin/bash
# JesterOS SD Card Creator
set -euo pipefail

DEVICE="${1:-}"
if [ -z "$DEVICE" ]; then
    echo "Usage: $0 /dev/sdX"
    echo "Available devices:"
    lsblk -d -o NAME,SIZE,MODEL | grep -E "^sd|^mmcblk"
    exit 1
fi

echo "This will ERASE all data on $DEVICE"
read -p "Continue? (yes/no): " confirm
[ "$confirm" != "yes" ] && exit 1

# [Include full partition creation script here]
# ...
SCRIPT_EOF

chmod +x ${RELEASE_DIR}/tools/create-sdcard.sh

# Create archive
tar -czf jesteros-v${VERSION}-release.tar.gz ${RELEASE_DIR}/
echo "Release package created: jesteros-v${VERSION}-release.tar.gz"
```

---

## SD Card Preparation

### Automated Method (Recommended)

```bash
# Download and run the automated script
wget https://raw.githubusercontent.com/yourusername/jesteros-nook/main/tools/create-4part-sdcard.sh
chmod +x create-4part-sdcard.sh
sudo ./create-4part-sdcard.sh /dev/sdX
```

### Manual 4-Partition Creation

```bash
#!/bin/bash
# Manual partition creation with critical sector 63 alignment

DEVICE="/dev/sdX"  # Replace with your device

# Step 1: Clear and create partition table
sudo dd if=/dev/zero of=$DEVICE bs=1M count=100
sudo fdisk $DEVICE << EOF
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

+100%
w
EOF

# Step 2: Format partitions
sudo mkfs.vfat -F 16 -n BOOT ${DEVICE}1
sudo mkfs.ext4 -L JESTEROS ${DEVICE}2
sudo mkfs.ext4 -L RECOVERY ${DEVICE}3
sudo mkfs.ext4 -L WRITING ${DEVICE}5

# Step 3: Mount partitions
mkdir -p /tmp/jesteros/{boot,system,recovery,writing}
sudo mount ${DEVICE}1 /tmp/jesteros/boot
sudo mount ${DEVICE}2 /tmp/jesteros/system
sudo mount ${DEVICE}3 /tmp/jesteros/recovery
sudo mount ${DEVICE}5 /tmp/jesteros/writing

# Step 4: Install boot files (EXACT ORDER!)
sudo cp MLO /tmp/jesteros/boot/MLO
sync
sudo cp u-boot.bin /tmp/jesteros/boot/u-boot.bin
sync
sudo cp uImage /tmp/jesteros/boot/uImage
sync
sudo cp boot.scr /tmp/jesteros/boot/boot.scr
sync

# Step 5: Extract system and recovery
sudo tar -xzf jesteros-rootfs.tar.gz -C /tmp/jesteros/system/
sudo tar -xzf jesteros-recovery.tar.gz -C /tmp/jesteros/recovery/

# Step 6: Setup writing partition
sudo mkdir -p /tmp/jesteros/writing/{documents,drafts,notes}
echo "Welcome to JesterOS!" | sudo tee /tmp/jesteros/writing/README.txt

# Step 7: Unmount and finish
sudo umount /tmp/jesteros/{boot,system,recovery,writing}
echo "SD card ready!"
```

---

## Build Configuration

### Memory Optimization Settings

```dockerfile
# In nookwriter-optimized.dockerfile

# Memory targets
ENV MEMORY_TARGET="96MB"
ENV WRITER_RESERVE="160MB"

# Optimization flags
ENV CFLAGS="-Os -fomit-frame-pointer -march=armv7-a"
ENV LDFLAGS="-Wl,--as-needed -Wl,--gc-sections"

# Disable unnecessary features
RUN echo "vm.swappiness=0" >> /etc/sysctl.conf && \
    echo "kernel.printk=3 3 3 3" >> /etc/sysctl.conf
```

### Feature Flags

```makefile
# config.mk - JesterOS build configuration

# Core features (always enabled)
CONFIG_JESTER_ASCII=y
CONFIG_TYPEWRITER_STATS=y
CONFIG_WISDOM_QUOTES=y

# Optional features
CONFIG_SPELL_CHECK=n      # +5MB RAM
CONFIG_THESAURUS=n        # +8MB RAM
CONFIG_MARKDOWN_PREVIEW=n # +12MB RAM
CONFIG_GIT_SUPPORT=n      # +15MB RAM

# E-Ink optimizations
CONFIG_EINK_REFRESH=partial
CONFIG_EINK_GHOSTING=accept
CONFIG_SCREEN_SAVER=n
```

---

## Testing Builds

### Local Testing (Docker)

```bash
# Test basic functionality
docker run -it --rm jesteros:latest /bin/sh -c "
    /usr/local/bin/jesteros-startup.sh
    cat /var/jesteros/jester
    cat /var/jesteros/wisdom
"

# Test memory usage
docker stats --no-stream jesteros:latest

# Test vim configuration
docker run -it --rm jesteros:latest vim /tmp/test.txt
```

### Hardware Testing Checklist

```yaml
Boot Tests:
  ✓ Normal boot from SD card
  ✓ Recovery mode via Power+Home
  ✓ Auto-recovery after 3 failures
  ✓ Boot time < 20 seconds

System Tests:
  ✓ System partition read-only
  ✓ Writing partition mounted
  ✓ JesterOS services running
  ✓ Memory usage < 96MB

Recovery Tests:
  ✓ Factory reset preserves data
  ✓ Recovery menu accessible
  ✓ Filesystem repair works
  ✓ Backup/restore functional

Performance Tests:
  ✓ Vim launches < 2 seconds
  ✓ File save < 1 second
  ✓ Menu response < 500ms
  ✓ E-Ink refresh smooth
```

---

## Troubleshooting

### Common Build Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| **Docker build fails** | Out of space | Clean: `docker system prune -a` |
| **Image too large** | Debug symbols | Strip binaries: `strip --strip-all` |
| **Boot fails** | Wrong sector alignment | Must start at sector 63 |
| **No boot files found** | Wrong copy order | MLO must be first |
| **Recovery not working** | Missing recovery image | Rebuild with recovery.dockerfile |

### Debug Commands

```bash
# Check partition alignment
sudo fdisk -l /dev/sdX | grep "Start"

# Verify boot partition
sudo fsck.vfat -v /dev/sdX1

# Test recovery trigger
sudo mount /dev/sdX1 /mnt
sudo touch /mnt/RECOVERY_MODE
sudo umount /mnt

# Check system size
du -sh /tmp/jesteros/system/

# Verify file order on boot partition
sudo debugfs -R "ls -l" /dev/sdX1
```

---

## Release Process

### Version Numbering
```
Major.Minor.Patch
1.0.0 - Initial release
1.1.0 - Feature additions
1.0.1 - Bug fixes only
```

### Pre-Release Checklist
- [ ] All tests passing
- [ ] Memory under 96MB
- [ ] Boot time < 20 seconds
- [ ] Recovery mode tested
- [ ] Documentation updated
- [ ] Checksums generated
- [ ] Release notes written

### Creating Official Release

```bash
# Tag release
git tag -a v1.0.0 -m "JesterOS v1.0.0 - Initial Release"
git push origin v1.0.0

# Build release images
./scripts/build-release.sh v1.0.0

# Upload to GitHub releases
gh release create v1.0.0 \
    jesteros-v1.0.0-release.tar.gz \
    --title "JesterOS v1.0.0" \
    --notes-file RELEASE_NOTES.md
```

---

## Advanced Topics

### A/B Update System

Using the recovery partition for staged updates:

```bash
# Download update to recovery partition
wget -O /recovery/images/jesteros-v1.1.img https://...

# Verify checksum
md5sum -c /recovery/images/checksums.md5

# Swap partitions on next boot
echo "UPDATE_PENDING=1" > /boot/UPDATE_FLAG

# On boot, init script swaps:
# SYSTEM ← → RECOVERY
```

### Custom Configurations

```bash
# User configuration overlay
/home/.jesteros/
├── config/
│   ├── vim/          # Personal vim settings
│   ├── themes/       # Custom ASCII art
│   └── quotes/       # Personal wisdom quotes
└── scripts/
    └── startup/      # User startup scripts
```

### Performance Profiling

```bash
# Memory profiling
./tools/profile-memory.sh

# Boot time analysis
systemd-analyze plot > boot-timing.svg

# I/O performance
iostat -x 1 10 > io-stats.txt
```

---

## Summary

Building JesterOS involves:

1. **Docker-based compilation** for consistent, reproducible builds
2. **4-partition SD card layout** for recovery and data protection
3. **Critical sector 63 alignment** for Nook boot compatibility
4. **Ordered file copying** to ensure bootloader finds MLO
5. **Comprehensive testing** before deployment

The build system prioritizes:
- **Reliability** over features
- **Writer experience** over technical complexity
- **Recovery capability** over space efficiency
- **Simplicity** over configurability

---

*JesterOS Build Guide v1.0*  
*"Built for writers, by writers"*  
*🏰 By quill and candlelight, we code! 🕯️*