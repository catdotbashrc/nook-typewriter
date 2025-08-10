# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This project transforms a Barnes & Noble Nook Simple Touch (NST) e-reader into a minimalist Linux-based typewriter. The device has severe hardware constraints: 800 MHz ARM CPU, 256MB RAM, and a 6-inch E-Ink display that requires special handling.

## Key Commands

### Building the Docker Image
```bash
docker build -t nook-system -f nookwriter.dockerfile .
```

### Running the Container
```bash
# Development mode with config mounted read-only
docker-compose up -d

# With hardware access (for testing E-Ink features)
docker-compose -f docker-compose.yml -f docker-compose.hw.yml up -d

# Access the container
docker-compose exec nookwriter bash
```

### Creating System Export for Nook
```bash
docker create --name nook-export nook-system
docker export nook-export | gzip > nook-alpine.tar.gz
docker rm nook-export
```

## Architecture

### Two Implementation Paths

1. **Android Path**: Uses rooted Android 2.1 with Jota Text Editor
2. **Alpine Linux Path**: Complete OS replacement via SD card boot

The codebase focuses on the Alpine Linux path as it provides better performance and control.

### Critical Components

**FBInk Integration**: The E-Ink display requires FBInk library for proper refresh handling. Direct framebuffer writes cause ghosting. All display output in scripts uses `fbink` commands.

**Memory Constraints**: With only 256MB RAM, every component must be minimal:
- Alpine Linux base (~5MB)
- BusyBox instead of GNU coreutils
- Minimal Vim build
- No GUI components

**USB Power Limitations**: The microUSB port may not provide sufficient power for modern wireless keyboards. Code assumes potential need for powered USB hub.

### File Structure Context

- `config/scripts/nook-menu.sh`: Main UI, uses FBInk for E-Ink rendering
- `config/scripts/sync-notes.sh`: Cloud sync via rclone, expects pre-configured remotes
- `nookwriter.dockerfile`: Multi-stage build compiling FBInk and Vim from source
- `config/vimrc`: Minimal config with leader key mappings for writing modes

### Key Technical Decisions

1. **F2FS Filesystem**: Used for SD card root partition for better flash endurance
2. **Boot via uEnv.txt**: Allows custom kernel parameters without modifying bootloader
3. **Statically Linked Binaries**: FBInk and rclone distributed as single binaries
4. **No Networking by Default**: WiFi disabled at boot to save power

## Development Workflow

### Docker-Based Development (Recommended)
The project has evolved to use Docker as the primary development method:

1. Build and configure everything in Docker container on fast hardware
2. Export container as filesystem image
3. Deploy to SD card with single extraction

```bash
# Build with all configurations
docker build -t nook-system -f nookwriter.dockerfile .

# Export for deployment
docker create --name nook-export nook-system
docker export nook-export | gzip > nook-alpine.tar.gz
docker rm nook-export

# Deploy to SD card
sudo tar -xzf nook-alpine.tar.gz -C /mnt/alpine/
```

This approach avoids slow on-device compilation and risky live modifications.

### Memory Optimization Insights
From claude-chat.md analysis:
- After Alpine boots, ~200MB RAM is available (not the conservative 50MB assumed)
- Vim with full features uses only 8-10MB
- Can comfortably run 1000 undo levels, multiple plugins, syntax highlighting
- GPU/camera can be disabled in kernel to reclaim 16-20MB more

### Script Development Notes
- All scripts must handle FBInk failures gracefully (E-Ink not available in Docker)
- Use `|| true` after FBInk commands to prevent script termination
- Scripts should work both on device and in Docker container
- Menu system (`nook-menu.sh`) uses FBInk for E-Ink text rendering

## Hardware-Specific Considerations

### E-Ink Display
- Full refresh (`fbink -c`) clears ghosting but causes screen flash
- Partial updates are faster but may leave artifacts
- IR touchscreen (not capacitive) - works differently than modern screens

### USB Keyboard Connectivity
Critical insight from claude-chat.md:
- 2.4GHz wireless keyboards theoretically work but power is the main risk
- NST's microUSB port may not provide sufficient power (designed for <100mA devices)
- Powered USB hub likely required for stable wireless keyboard operation
- Wired low-power keyboards from 2011 era are most reliable

### SD Card Requirements
- Must use bootable SD card method (non-destructive)
- Two versions of CWM available:
  - Use `sd_2gb_clockwork-rc2.zip` (not 128MB version)
  - Use `CWM-Recovery-noKeys.zip` (touch-only navigation)
- Card must be ≤32GB, partitioned as FAT32 (boot) + F2FS (root)

## Cloud Sync Options

### Rsync (SSH-based)
- Most flexible option for personal servers
- Works over WiFi when enabled
- Can sync to any SSH-accessible destination

### Rclone (Cloud services)
- Pre-configure for Dropbox, Google Drive, OneDrive
- Single static binary - no dependencies
- Config stored in Docker image for instant use

## Testing Without Hardware

The Docker environment allows testing most functionality:
- Vim configuration and plugins (full featured, not minimal)
- Shell scripts (FBInk commands will fail gracefully)
- File synchronization logic
- Alpine package management
- Memory usage profiling

Hardware-specific features require actual device:
- E-Ink display rendering
- USB host mode functionality
- Power consumption testing
- WiFi connectivity

## Common Issues from Community Experience

### OOBE Skip
- Required due to defunct B&N servers
- Specific gesture: hold top-right button + swipe on logo
- Must complete before any other modifications

### Kernel Selection

Due to availability issues with Guevor's kernel v176, we recommend:

**Option 1: nst-kernel (Recommended)**
- Source: https://github.com/felixhaedicke/nst-kernel
- Features: USB host support + fast display mode
- Requires Android NDK for compilation
- Based on B&N sources with community patches

**Option 2: Alternative USB Host Kernels**
- Search XDA Forums for any kernel with "USB host" support
- Versions 174+ typically include USB support
- Look for kernels by developers: Guevor, mali100, latuk

**Important Notes:**
- Version 166 does NOT support USB host
- Custom kernel installation is separate from rooting
- Use ClockworkMod Recovery for installation

### Plugin Recommendations
Lightweight plugins suitable for 256MB device:
- vim-pencil (2KB) - soft wrapping for prose
- vim-goyo (5KB) - distraction-free mode
- vim-zettel (8KB) - note linking
- vim-litecorrect (1KB) - typo fixes
- Avoid: NERDTree, airline, YCM, CoC (too heavy)