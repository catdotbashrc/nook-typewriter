# Windows SD Card Setup Guide for Nook Typewriter

This guide helps Windows users deploy the Nook typewriter system to an SD card using WSL2.

## Prerequisites

- Windows 10/11 with WSL2 installed
- SD card (8GB+) with two partitions:
  - **E:** drive - FAT32 boot partition (100MB)
  - **D:** drive - F2FS root partition (remaining space)
- Rooted Nook Simple Touch
- USB OTG cable and keyboard

## Step 1: Prepare WSL Environment

Open WSL terminal and install required tools:

```bash
# Update package list
sudo apt update

# Install F2FS and extraction tools
sudo apt install -y f2fs-tools dosfstools tar gzip pv

# Verify F2FS support
mkfs.f2fs -V
```

## Step 2: Build Fresh Docker Image

In WSL, navigate to the project directory:

```bash
# Navigate to project (adjust path as needed)
cd /mnt/c/Users/[YourUsername]/projects/nook

# Build fresh Docker image
docker build -t nook-system -f nookwriter.dockerfile .
```

Build will take 5-10 minutes. Watch for any errors.

## Step 3: Test Docker Image

Before deployment, verify the image works:

```bash
# Start test container
docker run -it --name nook-test nook-system bash

# Inside container, test:
vim /tmp/test.txt          # Test editor
which fbink                 # Check E-Ink driver
ls /usr/local/bin/*.sh      # Check scripts
cat /etc/os-release         # Verify SquireOS branding
free -h                     # Check memory usage
exit                        # Exit container

# Clean up test
docker stop nook-test
docker rm nook-test
```

## Step 4: Create Fresh Tarball

```bash
# Create container for export
docker create --name nook-export nook-system

# Export to tarball (will be ~190MB)
docker export nook-export | gzip > nook-debian-fresh.tar.gz

# Verify tarball
ls -lh nook-debian-fresh.tar.gz
gzip -t nook-debian-fresh.tar.gz && echo "Tarball is valid!"

# Clean up
docker rm nook-export
```

## Step 5: Mount SD Card in WSL

Your SD card partitions should be accessible in WSL:

```bash
# Check if drives are mounted
ls -la /mnt/d/  # Root partition
ls -la /mnt/e/  # Boot partition

# Verify mounts
mount | grep "/mnt/[de]"
df -h /mnt/d /mnt/e
```

**Note**: If drives aren't visible, ensure they're properly formatted and assigned drive letters in Windows.

## Step 6: Deploy to Root Partition (D: drive)

**WARNING**: This will delete everything on D: drive!

```bash
# Clean root partition (optional - for fresh install)
sudo rm -rf /mnt/d/*

# Extract system to root partition
cd /mnt/d
sudo tar -xzf ~/nook-debian-fresh.tar.gz --checkpoint=.1000

# Verify extraction
ls -la /mnt/d/
du -sh /mnt/d/  # Should be around 200MB
```

## Step 7: Configure Boot Partition (E: drive)

Create boot configuration:

```bash
# Create uEnv.txt
cat << 'EOF' | sudo tee /mnt/e/uEnv.txt
bootargs=console=ttyS0,115200n8 root=/dev/mmcblk0p2 rootfstype=f2fs rw rootwait mem=256M
bootcmd=mmc rescan; fatload mmc 0:1 0x80300000 uImage; bootm 0x80300000
EOF

# Verify
cat /mnt/e/uEnv.txt
```

## Step 8: Add Kernel (Required!)

You need a USB host-enabled kernel. Options:

### Option A: Pre-built Kernel
1. Download USB host kernel from XDA Forums
2. Extract `uImage` file
3. Copy to boot partition:
```bash
sudo cp /path/to/uImage /mnt/e/
```

### Option B: Build QuillKernel
```bash
cd nst-kernel
./squire-kernel-patch.sh
docker build -f Dockerfile.build -t quillkernel .
docker create --name kernel-extract quillkernel
docker cp kernel-extract:/build/arch/arm/boot/uImage ~/uImage
docker rm kernel-extract
sudo cp ~/uImage /mnt/e/
```

Verify kernel is in place:
```bash
ls -lh /mnt/e/uImage
```

## Step 9: Final Verification

Run these checks before ejecting:

```bash
# Check root filesystem
echo "=== Root Partition Structure ==="
ls -la /mnt/d/root/
ls -la /mnt/d/usr/local/bin/ | head -5
file /mnt/d/usr/local/bin/nook-menu.sh

# Check boot partition
echo "=== Boot Partition Contents ==="
ls -la /mnt/e/

# Check space usage
echo "=== Space Usage ==="
df -h /mnt/d /mnt/e

# Verify critical files
echo "=== Critical Files ==="
[ -f /mnt/e/uEnv.txt ] && echo "✓ Boot config present" || echo "✗ Missing boot config!"
[ -f /mnt/e/uImage ] && echo "✓ Kernel present" || echo "✗ Missing kernel!"
[ -d /mnt/d/root ] && echo "✓ Root filesystem present" || echo "✗ Missing root filesystem!"
```

## Step 10: Safe Ejection

```bash
# Sync all writes
sync

# Show completion message
echo "SD card preparation complete!"
echo "Now safely eject in Windows using 'Safely Remove Hardware'"
```

Then in Windows:
1. Click system tray "Safely Remove Hardware" icon
2. Select your SD card
3. Wait for "Safe to Remove" message
4. Remove SD card

## Step 11: Boot Your Nook

1. Insert SD card into Nook
2. Connect USB keyboard via OTG cable
3. Power on Nook
4. Wait 30 seconds for boot
5. You should see the menu!

## Troubleshooting

### "Permission denied" errors in WSL
- Make sure to use `sudo` for all mount operations
- Check that your WSL user is in the docker group: `groups`

### SD card not visible in WSL
- Ensure drive letters are assigned in Windows Disk Management
- Try remounting: `wsl --shutdown` then restart WSL

### Boot fails on Nook
- Verify kernel has USB host support
- Check uEnv.txt has correct syntax (no Windows line endings)
- Try different SD card brand

### Keyboard not working
- Kernel must have USB host support (version 174+)
- Try powered USB hub for wireless keyboards
- Check OTG cable orientation

## Quick Command Reference

```bash
# Build image
docker build -t nook-system -f nookwriter.dockerfile .

# Create tarball
docker create --name nook-export nook-system
docker export nook-export | gzip > nook-debian-fresh.tar.gz
docker rm nook-export

# Deploy to SD
sudo tar -xzf ~/nook-debian-fresh.tar.gz -C /mnt/d/
sudo tee /mnt/e/uEnv.txt < uenv-content.txt
sudo cp uImage /mnt/e/

# Verify
ls -la /mnt/d/root/
ls -la /mnt/e/
df -h /mnt/d /mnt/e
```

## Support

If you encounter issues:
1. Check all commands completed without errors
2. Verify SD card partitions are correct format
3. Ensure kernel has USB host support
4. Post on XDA Forums Nook Touch section for help

Good luck with your digital typewriter!