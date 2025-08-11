# Nook Simple Touch Typewriter

[![Architecture](https://img.shields.io/badge/Architecture-8.5%2F10-green)](ARCHITECTURE_ANALYSIS.md)
[![RAM Usage](https://img.shields.io/badge/RAM-2--8MB-blue)](docs/vim-optimization-results.md)
[![Tests](https://img.shields.io/badge/Tests-Available-brightgreen)](tests/)
[![Plugin System](https://img.shields.io/badge/Plugins-Supported-yellow)](config/plugins/)

Transform a $20 Barnes & Noble Nook Simple Touch e-reader into a distraction-free digital typewriter with custom Linux kernel, optimized writing software, and whimsical medieval theming.

## Features

### Core Functionality
- **Debian Linux Base** (Bullseye): Full Linux environment optimized for 256MB RAM
- **E-Ink Display Support**: FBInk driver for proper refresh and ghosting control (800x600, 16 grayscale)
- **USB Keyboard Support**: Requires custom kernel with USB host mode (OTG cable + keyboard)
- **Vim Editor**: Pre-configured with writing plugins (Goyo, Pencil)
- **Cloud Sync**: Built-in rclone for Dropbox/Google Drive synchronization
- **SD Card Boot**: Non-destructive - preserves original Nook firmware

### QuillKernel - Medieval-Themed Custom Kernel
- **Court Jester Companion**: ASCII art guide through boot and errors
- **Achievement System**: Track writing milestones (Apprentice to Grand Chronicler)
- **Writing Statistics**: `/proc/squireos/typewriter/stats` tracking
- **Medieval Boot Messages**: "By quill and candlelight, we begin..."
- **Comprehensive Testing**: 12+ test scripts with Docker support

## Installation

### Prerequisites

**Hardware:**
- Barnes & Noble Nook Simple Touch (Model BNRV300)
- MicroSD card (8-32GB, Class 10 recommended)
- USB OTG cable + USB keyboard
- SD card reader for your computer

**Software:**
- Docker Engine 20.10+
- Git
- 2GB disk space for building

### Quick Start

1. **Clone and Build System**
```bash
git clone https://github.com/yourusername/nook
cd nook

# Choose your build:
# Option A: Optimized Writer Mode (Recommended - 1.5MB RAM)
docker build -t nook-writer --build-arg BUILD_MODE=writer -f nookwriter-optimized.dockerfile .

# Option B: Standard Build (Legacy - 15MB RAM)
docker build -t nook-system -f nookwriter.dockerfile .
```

2. **Create Deployment Package**
```bash
# For optimized build:
docker create --name nook-export nook-writer
docker export nook-export | gzip > nook-writer.tar.gz
docker rm nook-export
```

3. **Build QuillKernel (Optional but Recommended)**
```bash
cd nst-kernel
./squire-kernel-patch.sh  # Apply medieval patches

# Docker build (no toolchain needed!)
docker build -f Dockerfile.build -t quillkernel .

# Or traditional build
cd src
make ARCH=arm quill_typewriter_defconfig
make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- uImage
```

4. **Prepare Your Nook**
- Root with [NookManager](https://github.com/doozan/NookManager/releases)
- Install USB host kernel (see Kernel Resources below)
- Format SD card with FAT32 boot + F2FS root partitions

5. **Deploy and Boot**
- Extract `nook-debian.tar.gz` to SD card root partition
- Copy kernel to boot partition
- Insert SD card and power on

## Usage

### Main Menu System
The device boots into a simple E-Ink optimized menu (`/usr/local/bin/nook-menu.sh`):

- **[Z]** Zettelkasten Mode - Create timestamped notes
- **[D]** Draft Mode - Work on continuous draft
- **[R]** Resume Session - Continue last document
- **[S]** Sync Notes - Upload to cloud storage
- **[Q]** Shutdown - Power off safely

### Vim Writing Commands
```vim
\g          " Goyo focus mode
\p          " Pencil better writing
:w          " Save (or Ctrl+S)
:q          " Quit (or Ctrl+Q)
Space+zn    " New Zettel note
Space+dd    " Open draft
```

## Project Structure

```
nook/
├── nookwriter.dockerfile         # Main Debian system build
├── docker-compose.yml           # Development environment
├── docker-compose.hw.yml        # Hardware testing setup
├── config/
│   ├── vimrc                   # Vim configuration
│   ├── scripts/
│   │   ├── nook-menu.sh        # Main UI menu
│   │   ├── sync-notes.sh       # Cloud sync script
│   │   ├── squire-menu.sh      # Medieval themed menu
│   │   └── squireos-boot.sh    # Boot initialization
│   ├── splash/                 # ASCII art and messages
│   ├── system/                 # OS configuration files
│   └── vim/                    # Vim plugins config
├── nst-kernel/                  # QuillKernel source
│   ├── squire-kernel-patch.sh  # Apply medieval patches
│   ├── Dockerfile.build        # Kernel build environment
│   ├── Dockerfile.test         # Testing environment
│   ├── src/                    # Linux 2.6.29 source
│   ├── drivers/squireos/       # Custom typewriter module
│   └── test/                   # Comprehensive test suite
├── docs/
│   ├── tutorials/              # Step-by-step guides
│   ├── how-to/                 # Specific tasks
│   ├── explanation/            # Architecture docs
│   └── reference/              # Quick references
├── images/                      # Boot and recovery images
└── scripts/                     # Build automation
```

## Testing

### Docker Development
```bash
# Run development environment
docker-compose up -d
docker-compose exec nookwriter bash

# Test Vim setup
docker-compose exec nookwriter vim

# Test menu (will show gracefully without E-Ink)
docker-compose exec nookwriter /usr/local/bin/nook-menu.sh
```

### Kernel Testing
```bash
cd nst-kernel/test
./verify-build-simple.sh   # Quick verification
./run-all-tests.sh         # Full test suite
./low-memory-test.sh       # Memory constraint testing
./test-typewriter.sh       # Writing module test
```

## System Requirements

### Device Specifications
- **CPU**: 800 MHz ARM Cortex-A8 (TI OMAP 3621)
- **RAM**: 256MB total (95MB OS, 160MB writing space)
- **Display**: 6" E-Ink Pearl (800x600, 167 DPI)
- **Storage**: Internal 2GB + MicroSD slot
- **Battery**: 1500mAh (weeks of writing time)

### Software Stack
- **Base OS**: Debian 11 (Bullseye) ARM
- **Kernel**: Linux 2.6.29 + QuillKernel patches
- **Display**: FBInk (compiled with MINIMAL=1)
- **Editor**: Vim 8.2 with writing plugins
- **Shell**: Bash with custom scripts

### Memory Budget
```yaml
Reserved OS:      95MB
Vim + Plugins:    1.5MB  (Writer mode with Goyo + Pencil)
Writing Space:   254MB (available)
Total Used:      ~97MB at idle
```

## Documentation

Complete documentation follows the [Diataxis framework](https://diataxis.fr/):

### Tutorials (Learning-Oriented)
- [First Nook Setup](docs/tutorials/01-first-nook-setup.md) - Complete beginner guide
- [Writing Your First Note](docs/tutorials/02-writing-your-first-note.md) - Vim basics
- [Syncing to Cloud](docs/tutorials/03-syncing-to-cloud.md) - Setup cloud backup

### How-To Guides (Task-Oriented)
- [Install Custom Kernel](docs/how-to/install-custom-kernel.md) - Enable USB keyboard
- [Build Custom Kernel](docs/how-to/build-custom-kernel.md) - Compile from source
- [Setup Wireless Keyboard](docs/how-to/setup-wireless-keyboard.md) - Bluetooth/RF options
- [Customize Vim Plugins](docs/how-to/customize-vim-plugins.md) - Add writing tools

### Reference (Information-Oriented)
- [Keyboard Shortcuts](docs/reference/keyboard-shortcuts.md) - Quick command reference
- [System Requirements](docs/reference/system-requirements.md) - Hardware/software needs

### Explanation (Understanding-Oriented)
- [Architecture Overview](docs/explanation/architecture-overview.md) - System design
- [Why Debian Over Alpine](docs/explanation/why-debian-over-alpine.md) - OS choice rationale
- [Roadmap](docs/explanation/roadmap.md) - Future development plans

## Kernel Resources

### Pre-Built Kernels
Search XDA Forums for "Nook Simple Touch USB host kernel":
- **mali100's kernel** - FastMode E-Ink support
- **latuk's kernel** - Version 174+ with USB OTG
- **Guevor's kernel** - Power optimizations

### Building QuillKernel
```bash
# Automated Docker build
cd nst-kernel
docker build -f Dockerfile.build -t quillkernel .

# Extract kernel
docker create --name kernel-export quillkernel
docker cp kernel-export:/build/arch/arm/boot/uImage ./uImage
docker rm kernel-export
```

## Configuration

### Environment Variables
Set in `docker-compose.yml`:
```yaml
TERM: xterm-256color
EDITOR: vim
PAGER: less
```

### System Configuration
- **Network**: Disabled by default (distraction-free)
- **USB**: Host mode required for keyboard
- **Display**: E-Ink refresh on menu changes
- **Power**: Auto-suspend after 30 minutes idle

## Troubleshooting

### Common Issues

**Keyboard not working:**
- Verify USB host kernel installed
- Check OTG cable orientation
- Try powered hub for wireless keyboards

**Screen ghosting:**
- Normal E-Ink behavior
- Press 5 for full refresh
- Run `fbink -c` for manual clear

**Won't boot from SD:**
- Check partition table (MBR not GPT)
- Verify FAT32 boot partition
- Ensure uEnv.txt present

**Build failures:**
```bash
# Clear Docker cache
docker system prune -a

# Check disk space
df -h

# Verify internet connection
docker run --rm alpine ping -c 1 google.com
```

## Dependencies

### Build Dependencies
From `nookwriter.dockerfile`:
- `vim` - Primary editor
- `git` - Version control
- `tmux` - Terminal multiplexer
- `rsync` - File synchronization
- `rclone` - Cloud storage client
- `fbink` - E-Ink display driver (compiled from source)
- `wireless-tools` - WiFi management
- `wpasupplicant` - WPA authentication

### Vim Plugins (Optimized)
From `config/vimrc-writer`:
- `goyo.vim` - Distraction-free mode (essential for E-Ink)
- `vim-pencil` - Better prose writing (soft wrap)
- `vim-litecorrect` - Auto-correct common typos (optional)

## Contributing

We welcome contributions that enhance the writing experience:

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Test in Docker first
4. Ensure memory budget maintained
5. Submit PR with clear description

### Contribution Guidelines
- ✅ Memory optimizations
- ✅ Writing workflow improvements  
- ✅ Medieval theme enhancements
- ✅ Battery life improvements
- ❌ Web browsers or internet features
- ❌ Development tools
- ❌ Features using >5MB RAM


## License

GPL v2 (kernel requirement)

Component licenses:
- Linux Kernel: GPL v2
- FBInk: GPL v3  
- Vim: Vim License
- Debian: Various open source

See [LICENSE](LICENSE) for details.

## Credits

Built on the shoulders of giants:
- XDA Developers Nook Touch community
- NiLuJe (FBInk author)
- doozan (NookManager)
- felixhaedicke (nst-kernel base)
- Kernel developers (Guevor, mali100, latuk)

## Support

- [XDA Forums Nook Touch](https://forum.xda-developers.com/c/barnes-noble-nook-touch.1129/)
- [GitHub Issues](https://github.com/yourusername/nook/issues)
- [FBInk Repository](https://github.com/NiLuJe/FBInk)

---

*"By quill and candlelight, we code for those who write"* 🕯️📜