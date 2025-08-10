# Nook Simple Touch Linux Typewriter

## Overview

This project transforms a Barnes & Noble Nook Simple Touch e-reader into a minimalist Linux-based typewriter. Using modern containerization techniques and a Debian Linux base, we create a distraction-free writing environment that leverages the Nook's E-Ink display for comfortable, long-form writing sessions.

## Key Features

- **Debian Linux Base**: Full compatibility with standard Linux software
- **Docker-Based Development**: Build the entire system on your computer, deploy to SD card
- **E-Ink Optimized**: FBInk library provides proper display management
- **Cloud Sync**: Built-in support for Dropbox, Google Drive, OneDrive via rclone
- **Vim Editor**: Configured with writing-focused plugins (Goyo, Pencil, Zettel)
- **Non-Destructive**: Boots from SD card, preserving original Nook OS

## System Architecture

### Hardware Constraints

The Nook Simple Touch presents unique challenges:
- **CPU**: 800 MHz ARM Cortex-A8 (single core)
- **RAM**: 256MB total (160MB available after Debian boot)
- **Display**: 6-inch E-Ink Pearl (600x800, 167 PPI)
- **Storage**: 2GB internal + MicroSD slot (up to 32GB officially)

### Software Stack

1. **Base OS**: Debian 11 (Bullseye) - chosen for compatibility
2. **Display Driver**: FBInk - manages E-Ink refresh modes
3. **Editor**: Vim 8.2 with writing plugins
4. **Sync**: rclone for cloud storage
5. **Interface**: Custom bash menu system

### Why Debian Over Alpine?

We initially pursued Alpine Linux for its minimal footprint but switched to Debian for practical reasons:
- **Compatibility**: No cross-compilation issues (glibc vs musl)
- **Package Availability**: 60,000+ packages vs Alpine's limited selection
- **Development Speed**: Everything "just works" 
- **RAM Trade-off**: Uses 95MB vs Alpine's 30MB - acceptable with 256MB total

## Quick Start

### Prerequisites

- Nook Simple Touch (firmware ≤1.2.2)
- Docker on your development machine
- MicroSD card (8-32GB)
- USB OTG cable + keyboard
- Git

### Build Process

```bash
# Clone repository
git clone https://github.com/yourusername/nook-writing-system
cd nook-writing-system

# Build Docker image
docker build -t nook-system -f nookwriter.dockerfile .

# Create deployment archive
docker create --name nook-export nook-system
docker export nook-export | gzip > nook-debian.tar.gz
docker rm nook-export
```

### Nook Preparation

1. **Root Device**: Use NookManager to root your Nook
2. **Install USB Kernel**: Flash a kernel with USB host support (version 174+)
3. **Prepare SD Card**: Create FAT32 boot + F2FS root partitions
4. **Deploy System**: Extract nook-debian.tar.gz to root partition
5. **Boot**: Insert SD card and power on with USB keyboard connected

## Usage

### Menu System

The device boots to a simple menu:
- **Z** - Zettelkasten mode (timestamped notes)
- **D** - Draft mode (continuous writing)
- **R** - Resume last session
- **S** - Sync to cloud
- **Q** - Shutdown

### Vim Configuration

Leader key is Space:
- `Space + w` - Save
- `Space + q` - Quit
- `Space + z` - New Zettelkasten note
- `:Goyo` - Distraction-free mode
- `:Pencil` - Soft line wrapping

## Technical Details

### Docker Build Strategy

The Dockerfile uses Debian slim as a single-stage build:
1. Installs all packages from Debian repos
2. Compiles only FBInk from source
3. Clones Vim plugins
4. Copies configurations
5. Sets up environment

### E-Ink Display Management

FBInk handles the quirks of E-Ink:
- Partial updates for typing (fast, may ghost)
- Full refresh between screens (slower, clears artifacts)
- Automatic optimization based on content

### Power Management

- WiFi disabled by default
- USB keyboard draws ~50mA (within Nook's limits)
- E-Ink uses no power when static
- System idles at ~100mA total

## Customization

### Adding Software

Thanks to Debian, installing is simple:
```bash
apt-get update
apt-get install aspell pandoc python3
```

### Writing Plugins

Additional Vim plugins can enhance the writing experience:
- vim-markdown - Better Markdown support
- vim-table-mode - Easy table creation
- vim-litecorrect - Auto-correct common typos

### Cloud Services

Configure rclone for your preferred service:
```bash
rclone config
# Follow prompts for Dropbox/Google Drive/OneDrive
```

## Troubleshooting

### Common Issues

**Keyboard not detected**
- Try powered USB hub for wireless keyboards
- Test with different USB cable
- Verify kernel has USB host support

**Display artifacts**
- Normal for E-Ink technology
- Menu performs full refresh automatically
- Manual refresh: `fbink -c`

**Won't boot from SD**
- Check SD card partitioning (FAT32 + F2FS)
- Verify uEnv.txt in boot partition
- Try different SD card brand

## Future Enhancements

See [future-improvements.md](future-improvements.md) for planned features including:
- zk CLI tool for advanced note management
- Power optimization
- Additional writing tools
- Workflow improvements

## Community

This project builds on work from:
- XDA Developers Nook Touch community
- NiLuJe (FBInk author)
- doozan (NookManager)
- Various kernel developers (Guevor, mali100, latuk)

## License

This project documentation is provided as-is for educational purposes. Component software retains original licenses.

## Resources

- [Quick Start Guide](nook-quick-start.md) - Get running in 30 minutes
- [Detailed Walkthrough](nook-detailed-walkthrough.md) - Comprehensive setup guide
- [CLAUDE.md](../CLAUDE.md) - Technical reference for development