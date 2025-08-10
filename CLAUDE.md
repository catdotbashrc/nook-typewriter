# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This project transforms a Barnes & Noble Nook Simple Touch (NST) e-reader into a minimalist Linux-based typewriter. The device has severe hardware constraints: 800 MHz ARM CPU, 256MB RAM, and a 6-inch E-Ink display that requires special handling.

## Key Commands

### Building and Testing

```bash
# Build Docker image from scratch
docker build --no-cache -t nook-system -f nookwriter.dockerfile .

# Quick rebuild (with cache)
docker build -t nook-system -f nookwriter.dockerfile .

# Run container for testing
docker run -it --rm nook-system /bin/bash

# Test with docker-compose (development mode)
docker-compose up -d
docker-compose exec nookwriter bash

# Hardware testing (requires privileged access)
docker-compose -f docker-compose.yml -f docker-compose.hw.yml up -d
```

### Creating Nook Deployment Image

```bash
# Create filesystem export for SD card
docker create --name nook-export nook-system
docker export nook-export | gzip > nook-alpine.tar.gz
docker rm nook-export

# Deploy to SD card (after partitioning)
sudo tar -xzf nook-alpine.tar.gz -C /mnt/alpine/
```

### Testing Components

```bash
# Test FBInk exists (will fail without E-Ink hardware)
docker run --rm nook-system which fbink

# Test Vim configuration
docker run -it --rm nook-system vim

# Test menu system (FBInk commands will fail gracefully)
docker run -it --rm nook-system /usr/local/bin/nook-menu.sh

# Monitor resource usage
docker stats nook-system
```

## Architecture

### Build Strategy

The project uses a multi-stage Docker build:
1. **Debian Builder Stage**: Compiles FBInk and Vim from source (Alpine build issues with FBInk)
2. **Alpine Runtime Stage**: Minimal final image with compiled binaries

### Critical Components

**FBInk**: MANDATORY for E-Ink display. All UI scripts use `fbink` commands with `|| true` to handle Docker testing where E-Ink is unavailable.

**Memory Management**: With 256MB total:
- Alpine base: ~30MB
- Vim + plugins: ~10MB  
- Available for writing: ~200MB

**Power Constraints**: USB keyboard power draw is critical. Powered hub recommended for wireless keyboards.

### Key Files

- `nookwriter.dockerfile`: Multi-stage build (Debian builder + Alpine runtime)
- `config/scripts/nook-menu.sh`: Main UI, handles FBInk failures gracefully
- `config/scripts/sync-notes.sh`: Cloud sync via rclone
- `config/vimrc`: Minimal config with leader mappings
- `docker-compose.yml`: Development configuration
- `docker-compose.hw.yml`: Hardware access overlay

## Development Workflow

### Making Changes

1. **Modify Dockerfile or configs**
2. **Rebuild**: `docker build -t nook-system -f nookwriter.dockerfile .`
3. **Test in container**: `docker run -it --rm nook-system /bin/bash`
4. **Export when ready**: Create tar.gz for SD card deployment

### Adding Software

Consider memory impact before adding packages:
```bash
# Check current size
docker images nook-system

# Test memory usage in container
docker run --rm nook-system free -h
```

### Script Development

All scripts must handle missing hardware gracefully:
```bash
# Good: Won't fail in Docker
fbink -c || true
fbink -y 3 "Hello" || true

# Bad: Will terminate script in Docker
fbink -c
```

## Hardware Deployment

### SD Card Preparation

```bash
# Partition (FAT32 boot + F2FS root)
sudo fdisk /dev/sdX
# Create 100MB FAT32 (type c) + remainder F2FS

# Format
sudo mkfs.vfat -F32 /dev/sdX1
sudo mkfs.f2fs /dev/sdX2

# Extract system
sudo mount /dev/sdX2 /mnt/root
sudo tar -xzf nook-alpine.tar.gz -C /mnt/root/
```

### Kernel Requirements

The Nook needs a custom kernel with USB host support:

**Option 1: nst-kernel** (Recommended)
- Source: https://github.com/felixhaedicke/nst-kernel
- Compile with Android NDK
- Includes USB host + fast E-Ink mode

**Option 2: Pre-built kernels**
- Search XDA Forums for "Nook Simple Touch USB host kernel"
- Version 174+ required (166 lacks USB support)
- Install via ClockworkMod Recovery

### Boot Configuration

Create `/mnt/boot/uEnv.txt`:
```
bootargs=console=ttyS0,115200n8 root=/dev/mmcblk0p2 rootfstype=f2fs rw rootwait mem=256M quiet
bootcmd=mmc rescan; fatload mmc 0:1 0x80300000 uImage; bootm 0x80300000
```

## Testing Strategy

### In Docker (No Hardware)
- Vim functionality and plugins
- Script logic (ignoring FBInk errors)
- Memory usage monitoring
- Package installation

### On Device Only
- E-Ink display rendering
- USB keyboard detection
- WiFi connectivity
- Power consumption

## Common Issues

### FBInk Build Failures
- Must use Debian builder stage (Alpine's musl libc causes issues)
- Current Dockerfile uses bullseye-slim for building

### Memory Constraints
- Avoid heavy plugins (NERDTree, CoC, YCM)
- Lightweight alternatives included: pencil, goyo, zettel, lightline
- Monitor with `free -h` during testing

### USB Keyboard Power
- Wireless keyboards may not work without powered hub
- NST provides limited USB power (<100mA)
- Wired keyboards from ~2011 era work best

## Important Notes

- **OOBE Skip Required**: Hold top-right + swipe on boot logo (B&N servers defunct)
- **Non-Destructive**: Uses SD card boot, preserves original Nook OS
- **E-Ink Refresh**: Full refresh (`fbink -c`) prevents ghosting but flashes screen
- **No GUI**: Pure terminal environment optimized for writing