# Nook Simple Touch Linux Typewriter

A complete system for transforming a Barnes & Noble Nook Simple Touch e-reader into a minimalist Linux-powered typewriter. Features a Debian-based OS, optimized Vim editor, and E-Ink display support for distraction-free writing.

## Features

- **Debian Linux Base**: Full compatibility with standard Linux software
- **E-Ink Optimized**: FBInk library for proper display management  
- **Vim Editor**: Configured with writing-focused plugins (Pencil, Goyo, Zettel)
- **USB Keyboard Support**: Requires custom kernel with USB host mode
- **Cloud Sync**: Built-in rclone for Dropbox/Google Drive sync
- **Non-Destructive**: Boots from SD card, preserving original Nook OS
- **Resource Efficient**: ~95MB RAM usage, leaving 160MB for writing

## Prerequisites

### Hardware
- Barnes & Noble Nook Simple Touch (Model BNRV300)
- MicroSD card (8-32GB recommended)
- USB OTG cable + USB keyboard
- SD card reader

### Software
- Docker Engine 20.10+
- Docker Compose 2.0+
- Git
- 2GB available disk space for building

## Quick Start

1. **Build the system:**
   ```bash
   git clone https://github.com/yourusername/nook-writing-system
   cd nook-writing-system
   docker build -t nook-system -f nookwriter.dockerfile .
   ```

2. **Create deployment image:**
   ```bash
   docker create --name nook-export nook-system
   docker export nook-export | gzip > nook-debian.tar.gz
   docker rm nook-export
   ```

3. **Prepare your Nook:**
   - Root with [NookManager](https://github.com/doozan/NookManager/releases)
   - Install USB host kernel (see Kernel Resources below)

4. **Deploy to SD card and boot:**
   - See [Quick Start Guide](docs/nook-quick-start.md) for detailed steps

## Kernel Resources

The Nook Simple Touch requires a custom kernel with USB host support. Without this, USB keyboards won't work.

### Pre-Built Kernels

Search XDA Forums for "Nook Simple Touch USB host kernel". Recommended versions:
- **mali100's kernel** - Well-tested, includes FastMode E-Ink support
- **latuk's kernel** - Version 174+ with USB OTG
- **Guevor's kernel** - Stable with power optimizations

### Building Your Own Kernel

We provide complete kernel building infrastructure:

1. **Automated Setup Script:**
   ```bash
   ./scripts/setup-kernel-build.sh
   ```
   Creates build environment at `~/nook-kernel-dev` with Android NDK and nst-kernel source.

2. **Build Commands:**
   ```bash
   cd ~/nook-kernel-dev
   ./build-kernel.sh        # Build with default config
   ./customize-kernel.sh    # Open menuconfig for customization
   ```

3. **Typewriter Optimizations:**
   See [nst-kernel/optimize-typewriter-kernel.sh](nst-kernel/optimize-typewriter-kernel.sh) for:
   - Maximum battery life settings
   - USB keyboard power optimization
   - Memory-saving kernel options
   - E-Ink specific tweaks

### Kernel Documentation

- **[Complete Build Guide](docs/nook-kernel-building.md)** - Step-by-step kernel compilation
- **[Kernel Notes](nst-kernel/KERNEL_NOTES.md)** - Technical details and configuration
- **[XDA Forums NST Section](https://forum.xda-developers.com/c/barnes-noble-nook-touch.1129/)** - Community support

### Installing Kernels

1. Use ClockworkMod Recovery (bootable SD card)
2. Flash kernel zip file
3. Reboot and verify USB keyboard works

⚠️ **Important**: Always keep a working kernel backup! Bad kernels can prevent booting.

## Project Structure

```
nook-writing-system/
├── nookwriter.dockerfile    # Debian-based system build
├── docker-compose.yml       # Development environment
├── scripts/
│   ├── setup-kernel-build.sh    # Kernel build environment setup
│   ├── nook-menu.sh            # Main UI menu
│   └── sync-notes.sh           # Cloud sync script
├── config/
│   ├── vimrc                   # Vim configuration
│   └── scripts/                # System scripts
├── nst-kernel/                 # Kernel build scripts
│   ├── build-kernel.sh
│   ├── customize-kernel.sh
│   └── optimize-typewriter-kernel.sh
└── docs/
    ├── nook-quick-start.md
    ├── nook-detailed-walkthrough.md
    └── nook-kernel-building.md
```

## System Specifications

- **Base OS**: Debian 11 (Bullseye) slim
- **Display Driver**: FBInk (compiled from source)
- **Editor**: Vim 8.2 with writing plugins
- **RAM Usage**: ~95MB (leaves 160MB for writing)
- **Storage**: 797MB base image
- **Boot Time**: ~20 seconds from SD card

## Documentation

- **[Quick Start Guide](docs/nook-quick-start.md)** - Get running in 30 minutes
- **[Detailed Walkthrough](docs/nook-detailed-walkthrough.md)** - Comprehensive setup and customization
- **[Kernel Building Guide](docs/nook-kernel-building.md)** - Build your own optimized kernel
- **[CLAUDE.md](CLAUDE.md)** - Technical reference for development

## Troubleshooting

### Common Issues

**Keyboard not detected:**
- Verify kernel has USB host support (version 174+)
- Try powered USB hub for wireless keyboards
- Test with different USB OTG cable

**Won't boot from SD card:**
- Check SD card partitioning (FAT32 boot + F2FS root)
- Verify uEnv.txt exists in boot partition
- Try different SD card brand

**Display artifacts/ghosting:**
- Normal for E-Ink displays
- Menu performs full refresh automatically
- Manual refresh: `fbink -c`

**Build failures:**
- FBInk requires compilation from source
- Ensure Docker has internet access
- Check available disk space

## Development

### Testing in Docker

```bash
# Build and test locally
docker-compose up -d
docker-compose exec nookwriter bash

# Test FBInk (will fail gracefully without E-Ink)
docker-compose exec nookwriter fbink -c || echo "No E-Ink display"

# Test Vim setup
docker-compose exec nookwriter vim
```

### Adding Software

Thanks to Debian base, installation is simple:
```bash
# In Dockerfile
RUN apt-get update && apt-get install -y package-name
```

### Contributing

1. Fork the repository
2. Test changes in Docker first
3. Document any new dependencies
4. Submit pull request with clear description

## Community & Support

- **[XDA Forums Nook Touch](https://forum.xda-developers.com/c/barnes-noble-nook-touch.1129/)** - Active community
- **[FBInk Repository](https://github.com/NiLuJe/FBInk)** - E-Ink display driver
- **[NookManager](https://github.com/doozan/NookManager)** - Rooting tool

## Acknowledgments

This project builds on work from:
- The XDA Developers Nook Touch community
- NiLuJe (FBInk author)
- doozan (NookManager)
- felixhaedicke (nst-kernel)
- Various kernel developers (Guevor, mali100, latuk)

## License

This project is released under GPL v2. Component software retains original licenses:
- Linux Kernel: GPL v2
- FBInk: GPL v3
- Vim: Vim License
- Debian: Various open source licenses

See [LICENSE](LICENSE) for details.
