# Nook Typewriter Architecture Overview

Understanding how the Nook typewriter system works helps you customize, troubleshoot, and extend it.

## System Architecture

```
┌─────────────────────────────────────────────┐
│                  User Interface              │
│        Menu System (Bash) + FBInk Display    │
├─────────────────────────────────────────────┤
│              Application Layer               │
│     Vim + Plugins │ rclone │ System Utils   │
├─────────────────────────────────────────────┤
│                Debian Linux                  │
│         Base System + Package Manager        │
├─────────────────────────────────────────────┤
│              Custom Kernel                   │
│        USB Host + E-Ink + Power Mgmt         │
├─────────────────────────────────────────────┤
│              Hardware Layer                  │
│   TI OMAP 3621 │ 256MB RAM │ E-Ink Display  │
└─────────────────────────────────────────────┘
```

## Key Components

### 1. Hardware Foundation

The Nook Simple Touch provides:

- **CPU**: Texas Instruments OMAP 3621 (800 MHz ARM Cortex-A8)
- **RAM**: 256MB (shared with GPU)
- **Storage**: 2GB internal + SD card slot
- **Display**: 6" Pearl E-Ink (800x600, 16 grayscale)
- **Connectivity**: WiFi 802.11 b/g/n
- **I/O**: MicroUSB (OTG capable with custom kernel)

### 2. Kernel Layer

The custom kernel enables:

- **USB Host Mode**: Essential for keyboard support
- **Power Management**: Aggressive sleep states for battery life
- **E-Ink Driver**: Proper refresh and ghosting prevention
- **Memory Management**: Optimized for limited RAM

Key kernel modules:
```
omap3epfb     - E-Paper framebuffer driver
musb_hdrc     - USB OTG controller
zforce        - Touchscreen driver (can be disabled)
tiwlan_drv    - WiFi driver
```

### 3. Operating System

Debian 11 (Bullseye) provides:

- **Init System**: systemd (minimal configuration)
- **Package Management**: apt/dpkg for easy software installation
- **Libraries**: Full glibc compatibility
- **Filesystem**: F2FS for SD card optimization

Memory footprint:
```
Kernel:         ~15MB
Base system:    ~80MB
Services:       ~10MB
Free memory:    ~150MB
```

### 4. Display System

FBInk manages the E-Ink display:

```
Application → Framebuffer → FBInk → E-Ink Controller
     ↓            ↓           ↓            ↓
   Text       /dev/fb0    Dithering   Physical display
```

Features:
- Text rendering optimized for E-Ink
- Automatic partial refresh
- Full refresh on demand
- Image display support

### 5. User Interface

The menu system (`nook-menu.sh`) provides:

```bash
┌─────────────────────────┐
│   NOOK WRITER MENU      │
├─────────────────────────┤
│ 1. Vim Editor           │
│ 2. File Browser         │
│ 3. Sync to Cloud        │
│ 4. System Info          │
│ 5. WiFi Setup           │
│ 6. Settings             │
│ 7. Terminal             │
│ 8. Power Off            │
└─────────────────────────┘
```

Design principles:
- No mouse needed (keyboard only)
- Clear E-Ink rendering
- Fast navigation
- Error recovery

## Boot Process

Understanding boot helps troubleshooting:

1. **U-Boot** (bootloader)
   - Reads `uEnv.txt` from SD card
   - Loads kernel into memory
   - Passes boot arguments

2. **Kernel initialization**
   - Mounts root filesystem
   - Initializes hardware
   - Starts init process

3. **Systemd startup**
   - Minimal service set
   - No GUI, no unnecessary daemons
   - Custom startup script

4. **Menu launch**
   - Clears framebuffer
   - Displays menu via FBInk
   - Waits for user input

Boot time: ~20 seconds

## Memory Management

Critical with only 256MB:

### Memory Map
```
0-15MB:    Kernel + modules
15-95MB:   Debian base system
95-105MB:  Vim + plugins
105-115MB: Active processes
115-256MB: Free for user data + buffers
```

### Optimization Strategies

1. **Minimal services**: No X11, no unnecessary daemons
2. **Swap disabled**: SD card too slow, wears out
3. **Tmpfs limited**: Only essential temporary files
4. **Aggressive caching**: Kernel tuned for interactivity

## File System Layout

```
/
├── boot/           # Kernel and boot config
├── usr/            # Debian packages
├── home/           
│   └── writer/     # User home
│       ├── writing/    # Documents
│       └── .vim/       # Vim config
├── opt/
│   └── nook/       # Custom scripts
└── mnt/
    └── internal/   # Original Nook storage
```

## Power Management

Battery life is crucial:

### Active Optimizations
- CPU frequency scaling (200-800 MHz)
- Aggressive idle states
- WiFi power save mode
- USB selective suspend

### Sleep Behavior
- Screen timeout: 5 minutes
- Deep sleep: 30 minutes
- Wake sources: Power button, USB

### Battery Life
- Active writing: 20-30 hours
- Standby: 2-3 weeks
- With WiFi: Reduced by 40%

## Security Model

Simplified for single-user device:

- No password by default
- Physical access = full access
- Optional: SSH with key-only auth
- Firewall: Blocks incoming connections
- Updates: Manual only

## Extension Points

Where to add features:

### 1. Menu System
Edit `/opt/nook/scripts/nook-menu.sh`:
```bash
# Add new option
"9") 
    launch_my_app
    ;;
```

### 2. Vim Plugins
Add to `/home/writer/.vim/pack/plugins/start/`

### 3. System Services
Create systemd unit in `/etc/systemd/system/`

### 4. Kernel Modules
Build and load custom modules for hardware

## Performance Characteristics

Understanding limits helps set expectations:

| Operation | Performance |
|-----------|-------------|
| Boot time | 20 seconds |
| Vim startup | 2 seconds |
| File save | Instant (<10KB) |
| Full refresh | 0.5 seconds |
| Partial refresh | 0.1 seconds |
| WiFi connect | 5-10 seconds |

## Design Decisions

### Why Bash for UI?
- Minimal memory usage
- Easy to modify
- No compilation needed
- Works with keyboard-only

### Why FBInk?
- Only maintained E-Ink library
- Handles refresh properly
- Text rendering optimized
- Active development

### Why F2FS?
- Designed for flash storage
- Better wear leveling
- Faster than ext4 on SD
- Good recovery features

## Debugging Tools

Built-in tools for troubleshooting:

```bash
# System state
free -h          # Memory usage
df -h            # Disk usage
top              # Process monitor
dmesg            # Kernel messages

# Display testing
fbink -c         # Clear screen
fbink -y 10 "Test"  # Draw text

# Network
ip addr          # Network config
ping -c 1 google.com  # Connectivity
```

## Future Architecture Considerations

Possible improvements:

1. **Framebuffer optimization**: Custom lightweight renderer
2. **Memory compression**: ZRAM for more usable RAM
3. **Kernel tweaks**: Further size reduction
4. **Alternative shells**: Dash for faster scripts
5. **Custom init**: Replace systemd for faster boot

The architecture prioritizes stability and usability over maximum optimization, making it maintainable and extensible.

---

🏗️ **Key insight**: The architecture is intentionally simple. Complexity is the enemy of reliability in a 256MB device.