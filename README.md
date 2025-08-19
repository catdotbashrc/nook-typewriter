# JesterOS - E-Ink Writing Environment for Nook SimpleTouch

> Transform your $20 Nook into a distraction-free writing device

## What is JesterOS?

JesterOS is a lightweight Linux environment that turns the Nook SimpleTouch e-reader into a dedicated writing device. Built on the philosophy that **writers deserve focus**, not features.

### Key Features
- **8MB Total Footprint** - Leaves 100MB+ for your writing
- **Vim-Based Editor** - Optimized for E-Ink display
- **ASCII Jester Companion** - Tracks your writing progress
- **USB Keyboard Support** - Full mechanical keyboard compatibility
- **Zero Distractions** - No internet, no notifications, just writing

## Quick Start

### Requirements
- Nook SimpleTouch (FW 1.2.2)
- SanDisk Class 10 SD card (4GB+)
- Docker for building
- USB keyboard (optional)

### Build & Deploy

```bash
# Clone repository
git clone --recursive https://github.com/yourusername/nook.git
cd nook

# Build system
make firmware

# Deploy to SD card
sudo ./deploy-to-sd.sh

# Insert SD card and boot Nook
# Hold page buttons while powering on
```

## System Architecture

```
User Space → Vim Editor → JesterOS Services
                ↓
        /var/jesteros/ Interface
                ↓
        Linux 2.6.29 Kernel
                ↓
        Android Bootloader
```

## Memory Budget

| Component | Usage | Purpose |
|-----------|-------|---------|
| Android Base | 188MB | System foundation |
| JesterOS | 10MB | Core services |
| Vim | 8MB | Text editor |
| **Free for Writing** | **27MB+** | Your manuscripts |

## Documentation

- **[INDEX.md](INDEX.md)** - Complete project map
- **[CLAUDE.md](CLAUDE.md)** - Development constraints
- **[docs/](docs/)** - Full documentation

## Project Status

### ✅ Working
- Userspace implementation complete
- SD card deployment verified
- ASCII jester with mood system
- Writing statistics tracking

### 🔄 Testing
- First hardware boot pending
- Power optimization in progress

## Contributing

This project prioritizes **simplicity over features**. PRs welcome for:
- Memory optimization
- E-Ink display improvements
- Writing-focused features
- Bug fixes

## License

GPL v2 - See [LICENSE](LICENSE)

## Philosophy

> **Writers > Features**  
> **RAM saved = Words written**  
> **Medieval computing for modern writers**

---

*By quill and compiler, we craft digital magic* 🪶