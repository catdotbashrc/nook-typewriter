# 🚀 Nook Typewriter Quick Start Guide

Get your Nook Simple Touch running as a distraction-free typewriter in 15 minutes!

## Prerequisites

- **Hardware**: Barnes & Noble Nook Simple Touch (firmware 1.2.2 recommended)
- **SD Card**: SanDisk Class 10, 4GB+ (CRITICAL - other brands may fail)
- **Computer**: Linux or WSL2 with Docker installed
- **USB Cable**: For serial debugging (optional)

## 🎯 Fast Track (5 Steps)

### 1. Clone & Setup
```bash
git clone https://github.com/catdotbashrc/nook-typewriter.git
cd nook-typewriter
```

### 2. Build Firmware
```bash
# Build everything (takes ~10 minutes first time)
make firmware

# Or quick build if you've built before
make quick-build
```

### 3. Run Safety Tests
```bash
# CRITICAL - Always test before deploying to hardware
make test-quick
```

### 4. Prepare SD Card
```bash
# Auto-detect SD card (excludes system drives)
make detect-sd

# Deploy to SD card (replace /dev/sdX with your device)
make sd-deploy SD_DEVICE=/dev/sdX
```

### 5. Boot Your Nook
1. Power off Nook completely
2. Insert SD card
3. Power on - it will boot JesterOS
4. See boot messages and medieval ASCII art
5. Start writing!

## 📋 Essential Commands

### Building
```bash
make firmware        # Complete build
make kernel         # Kernel only
make rootfs         # Root filesystem only
make lenny-rootfs   # Debian base
make image          # SD card image
```

### Testing
```bash
make test           # Full test suite
make test-quick     # Critical tests only
make test-safety    # Safety checks
```

### Deployment
```bash
make detect-sd      # Find SD cards
make sd-deploy      # Deploy to SD
make quick-deploy   # Update kernel only
```

### Maintenance
```bash
make clean          # Clean build files
make build-status   # Check build state
make battery-check  # Battery optimization info
```

## 🎮 Using JesterOS

### Navigation
- **Home Button**: Main menu
- **Page Turn**: Navigate options
- **Touch**: Select items (when working)

### Writing Mode
- Vim launches automatically
- USB keyboard recommended
- E-Ink optimized settings
- Auto-saves every 5 minutes

### Menu System
```
Main Menu
├── Write (Vim)
├── Browse Files
├── Statistics
├── Settings
└── Power Off
```

## ⚠️ Important Notes

### Memory Limits
- **OS**: 95MB maximum
- **Writing Space**: 160MB (SACRED - never violated)
- **Total RAM**: 256MB

### E-Ink Display
- Refresh is slow (200-980ms)
- Partial refresh for typing
- Full refresh every 10 pages
- Optimized for text, not graphics

### Battery Life
- Target: <1.5% drain per day
- WiFi disabled by default
- Screen timeout: 10 minutes
- Deep sleep supported

## 🔧 Troubleshooting

### Boot Issues
```bash
# Check bootloader files
make bootloader-status

# Verify SD card
make detect-sd

# Use recommended card
# MUST be SanDisk Class 10
```

### Touch Screen Freeze
Known hardware issue - Solutions:
1. Two-finger horizontal swipe
2. Clean screen edges
3. Press Home button
4. Last resort: Power cycle

### Memory Errors
```bash
# Check memory usage
make test-memory

# Verify limits
cat /proc/jesteros/memory
```

## 📚 Learn More

- [Full Documentation](./PROJECT_INDEX.md) - Complete project guide
- [CLAUDE.md](./CLAUDE.md) - AI development assistance
- [Architecture](./docs/.simone/architecture.md) - System design
- [Constitution](./docs/.simone/constitution.md) - Project philosophy

## 💬 Getting Help

### Logs & Debugging
```bash
# Build logs
tail -f build/logs/build.log

# Test results
cat tests/results/*.log

# Boot messages (on device)
dmesg | grep jester
```

### Community
- GitHub Issues: Report bugs
- XDA Forums: Phoenix Project thread
- Project philosophy: "Writers over features"

## 🎭 Welcome to JesterOS!

```
     _.-.
   ,'/ //\    By quill and candlelight,
  /// // /)     we code for those who write!
 /// // //|
(': // /// 
 ';`: ///
  '`://'
    `'
```

---

**Remember**: This device is for writing, not browsing. Embrace the limitations as features! 📜