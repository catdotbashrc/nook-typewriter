# 🚀 JesterOS Quick Start Guide

*Transform your Nook into a distraction-free writing device in 5 minutes!*

## 🎯 Prerequisites

- Nook SimpleTouch e-reader
- 4GB+ SD card  
- Computer with Docker
- USB cable for ADB
- (Optional) USB OTG cable + powered hub + keyboard for external typing

## 📦 Step 1: Build JesterOS

### Using Modular Docker (NEW - Recommended)
```bash
# Clone the repository
git clone https://github.com/yourusername/nook-typewriter.git
cd nook-typewriter

# Build the modular base image with GK61 keyboard support
docker build -t jesteros-base -f build/docker/jesteros-base.dockerfile .

# Quick test to verify build
./tests/test-runner.sh jesteros-base simple-test.sh

# Package for deployment
docker create --name export jesteros-base
docker export export | gzip > jesteros.tar.gz
docker rm export
```

### Using Traditional Build Scripts
```bash
# Build kernel modules
./build/utilities/build_modules.sh

# Create deployment package
./build/utilities/create_deployment.sh
```

## 💾 Step 2: Prepare SD Card

```bash
# CRITICAL: Use sector 63 alignment for Nook compatibility!
sudo fdisk /dev/sdX << EOF
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
w
EOF

# Format and mount
sudo mkfs.vfat -F 32 /dev/sdX1
sudo mount /dev/sdX1 /mnt

# Copy boot files IN EXACT ORDER
sudo cp boot/MLO /mnt/           # FIRST - must be contiguous
sync                              # Ensure written before continuing
sudo cp boot/u-boot.bin /mnt/    # SECOND
sudo cp boot/uImage /mnt/        # THIRD - kernel with USB support
sudo cp jesteros.tar.gz /mnt/   # FOURTH - root filesystem

# Unmount safely
sudo umount /mnt
```

## 🔌 Step 3: Boot Your Nook

1. Power off Nook completely (hold power 10 seconds)
2. Insert prepared SD card
3. Power on - should boot to JesterOS
4. You'll see the jester ASCII art = success!

## ⌨️ Step 4: Optional USB Keyboard Setup

### Hardware Connection
```
Nook → OTG Cable → Powered Hub → GK61/USB Keyboard
        ↓
    [5V Power Supply]
```

### Enable Keyboard Support
```bash
# Connect via ADB first
adb connect 192.168.1.X:5555
adb shell

# Run keyboard setup
/usr/local/bin/usb-keyboard-setup.sh

# Keyboard should now work!
# Note: ADB disconnects when keyboard active
```

## ✍️ Step 5: Start Writing!

```bash
# Launch the main menu
nook-menu

# Or jump straight to writing
vim ~/scrolls/my-novel.txt

# Check your writing stats
cat /var/jesteros/typewriter/stats

# See the jester's mood
cat /var/jesteros/jester
```

## 🎮 Essential Commands

| Function | Command | Description |
|----------|---------|-------------|  
| Main Menu | `nook-menu` | Access all features |
| Write | `vim [file]` | Open Vim editor |
| Stats | `cat /var/jesteros/typewriter/stats` | Writing statistics |
| Jester | `cat /var/jesteros/jester` | ASCII jester mood |
| Power | `power-menu` | Sleep/shutdown options |
| USB Mode | `usb-keyboard-manager.sh` | Keyboard control |

## 🔧 Troubleshooting

### Nook won't boot from SD card
- ✅ Verify partition starts at sector 63 (NOT 2048)
- ✅ Ensure MLO was copied FIRST and synced
- ✅ Try a different SD card (some cards incompatible)
- ✅ Check boot files aren't corrupted

### USB keyboard not detected
- ✅ Powered hub MUST be plugged into power
- ✅ Check OTG cable orientation (try flipping)
- ✅ Run `usb-keyboard-manager.sh status`
- ✅ Verify keyboard works on regular computer

### Lost ADB connection
- 💡 USB host mode disables ADB (normal behavior)
- Run `usb-keyboard-manager.sh restore-adb` to switch back
- Or physically disconnect OTG cable

### Build errors
- ✅ Ensure Docker is installed and running
- ✅ Check you have 10GB free disk space
- ✅ Try `docker system prune` to free space

## 📡 Deployment Options

### Deploy to Physical Nook
```bash
# If using build scripts
./build/utilities/deploy_to_nook.sh

# Or manual via ADB
adb connect 192.168.1.X:5555
adb push jesteros.tar.gz /data/
adb shell tar -xzf /data/jesteros.tar.gz -C /
```

### Test in Docker First
```bash
# Run interactive session
docker run -it jesteros-base bash

# Test specific component
docker run --rm jesteros-base jesteros-status.sh
```

## 📚 Documentation

### Essential Guides
- [Comprehensive Index](docs/00-indexes/comprehensive-index.md) - All documentation
- [USB Keyboard Setup](docs/01-getting-started/usb-keyboard-setup.md) - Detailed keyboard guide
- [Build System](docs/02-build/build-system-documentation.md) - Build details
- [Deployment](docs/07-deployment/deployment-documentation.md) - Deployment options

### Quick References  
- Built modules: `firmware/modules/*.ko`
- Output packages: `build/output/`
- Docker images: `build/docker/`
- Test scripts: `tests/`

## Cleanup Notes
Some root-owned files remain in:
- `standalone_modules/` - Can be safely ignored or removed with sudo
- `source/kernel/src/` - Build artifacts from Docker operations

To fully clean (requires sudo):
```bash
sudo rm -rf standalone_modules
sudo find . -name "*.o" -delete
```
