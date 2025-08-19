# Architecture Document

## System Overview

The Nook Typewriter project transforms a Barnes & Noble Nook Simple Touch e-reader into a dedicated, distraction-free writing device. It achieves this through a custom Linux distribution (JokerOS/SquireOS) running in a chroot environment on top of the Nook's Android base, with custom kernel modules providing a medieval-themed writing experience optimized for extreme hardware constraints.

## Tech Stack

### Core System
- **Kernel**: Linux 2.6.29 (Nook hardware requirement)
- **Cross-Compiler**: Android NDK r12b with arm-linux-androideabi toolchain
- **Build Environment**: Docker with multi-stage builds
- **Root Filesystem**: Debian Bullseye (minimal, <30MB compressed)
- **Display Driver**: FBInk for E-Ink management
- **Text Editor**: Vim with custom lightweight configuration

### Development Tools
- **Containerization**: Docker for reproducible builds
- **Version Control**: Git with safety-first branching
- **Testing**: Custom test framework with 90%+ coverage
- **Documentation**: Medieval-themed markdown

## System Architecture

### Layer Stack
```
┌─────────────────────────────────────────┐
│         Writing Applications            │ <-- Vim, user scripts
├─────────────────────────────────────────┤
│         Menu System & Services          │ <-- nook-menu.sh, services
├─────────────────────────────────────────┤
│        JokerOS Kernel Modules           │ <-- /proc/jokeros interface
├─────────────────────────────────────────┤
│      Linux 2.6.29 + Custom Patches      │ <-- Kernel with SquireOS
├─────────────────────────────────────────┤
│        Debian Chroot Environment        │ <-- /data/debian/
├─────────────────────────────────────────┤
│         Android 2.1 (Nook Base)         │ <-- Hardware drivers
├─────────────────────────────────────────┤
│            Nook Hardware                │ <-- ARM CPU, E-Ink, 256MB RAM
└─────────────────────────────────────────┘
```

### Boot Sequence
1. **U-Boot Loader**: Reads kernel from SD card partition 1
2. **Linux Kernel**: Boots with custom initramfs
3. **Android Init**: Starts base system services
4. **Chroot Setup**: Mounts Debian filesystem
5. **JokerOS Init**: Loads kernel modules, starts services
6. **Menu Launch**: Presents writing interface to user

## Core Components

### Kernel Modules (`source/kernel/`)
- **jokeros_core.ko**: Creates `/proc/jokeros/` virtual filesystem
- **jester.ko**: ASCII art mood system based on system health
- **typewriter.ko**: Keystroke tracking and writing statistics
- **wisdom.ko**: Inspirational quotes for writers

### Boot System (`firmware/boot/`)
- **uRamdisk**: Custom initramfs with minimal userland
- **u-boot.bin**: Nook bootloader (unmodified)
- **uImage**: Compiled kernel image with SquireOS patches

### Menu System (`source/scripts/menu/`)
- **nook-menu.sh**: Main menu interface with E-Ink optimization
- **squire-menu.sh**: Alternative lightweight menu
- **Display abstraction**: Handles E-Ink vs terminal output

### Services (`source/scripts/services/`)
- **health-check.sh**: Memory and system monitoring
- **jester-daemon.sh**: Updates ASCII jester mood
- **typewriter-stats.sh**: Writing statistics collector

## Data Flow

### Writing Flow
```
Keyboard Input → USB OTG → Kernel Driver → Vim → File System → SD Card
                                ↓
                        Typewriter Module → /proc/jokeros/stats
```

### Display Flow
```
Application Output → Framebuffer → FBInk → E-Ink Controller → Display
                           ↓
                    Refresh Control (minimize ghosting)
```

### Statistics Flow
```
Keystrokes → typewriter.ko → /proc/jokeros/typewriter/stats
                    ↓
            Menu System → User Display
```

## Memory Management

### Sacred Memory Map (256MB Total)
```
0-95MB:    Operating System (Debian + services)
95-105MB:  Vim and plugins
105-256MB: SACRED WRITING SPACE (DO NOT TOUCH)
```

### Optimization Strategies
- **Aggressive stripping**: Remove all non-essential binaries
- **No documentation**: Strip man pages, locales, examples
- **Busybox utilities**: Single binary for common tools
- **Lazy loading**: Load features only when needed
- **Module unloading**: Free memory when features unused

## Key Design Patterns

### Hardware Abstraction
- **Display abstraction**: Unified interface for E-Ink/terminal
- **Input abstraction**: Keyboard handling across USB/serial
- **Storage abstraction**: SD card with wear leveling awareness

### Safety Patterns
- **Fail-safe defaults**: System boots even if customizations fail
- **Input validation**: All user input sanitized
- **Error recovery**: Graceful degradation on failures
- **Resource limits**: Hard caps on memory usage

### Medieval Theme Integration
- **ASCII art**: Jester moods throughout system
- **Language style**: "By quill and candlelight" messaging
- **Menu design**: Scroll and parchment metaphors
- **Error messages**: Writer-friendly, non-technical

## External Dependencies

### Build Dependencies
- **Docker**: Build environment containerization
- **Android NDK**: Cross-compilation toolchain
- **Linux headers**: 2.6.29 kernel headers
- **XDA tools**: Proven Nook development utilities

### Runtime Dependencies
- **E-Ink display**: 800x600 grayscale framebuffer
- **USB OTG**: Keyboard input support
- **SD card**: Boot and storage medium
- **Power**: USB or battery operation

## Security Considerations

### System Security
- **No network**: Complete isolation from internet
- **Read-only kernel**: Kernel on separate partition
- **User isolation**: Single-user system, no privilege escalation
- **Input validation**: Path traversal protection

### Data Security
- **Local only**: All data stays on SD card
- **No encryption**: Performance trade-off for old hardware
- **Backup strategy**: SD card cloning recommended

## Performance Targets

### Boot Performance
- **Cold boot**: < 20 seconds to menu
- **Vim launch**: < 2 seconds
- **File save**: < 1 second
- **Menu navigation**: < 500ms response

### Runtime Performance
- **CPU usage**: < 30% during writing
- **Memory usage**: < 96MB for OS
- **Battery life**: > 20 hours writing
- **E-Ink refresh**: Minimal, on-demand only

## Testing Strategy

### Test Levels
1. **Unit tests**: Module functionality
2. **Integration tests**: Component interaction
3. **System tests**: Full boot and operation
4. **Hardware tests**: Real device validation

### Safety Testing
- **Memory bounds**: Verify 160MB writing space preserved
- **Error injection**: Test failure recovery
- **Resource exhaustion**: Handle out-of-memory gracefully
- **Input fuzzing**: Validate input sanitization

## Deployment Architecture

### Build Pipeline
1. **Docker build**: Create cross-compilation environment
2. **Kernel compile**: Build kernel with modules
3. **Rootfs creation**: Minimal Debian with customizations
4. **Image packaging**: Create SD card image
5. **Validation**: Run test suite

### Installation Process
1. **SD card preparation**: Partition and format
2. **Image writing**: Deploy kernel and rootfs
3. **Boot verification**: Test on actual hardware
4. **Configuration**: User preferences setup

## Future Considerations

### Planned Enhancements
- **Spell check**: Lightweight spell checking
- **Word count goals**: Daily writing targets
- **Multiple documents**: Better file management
- **Export options**: Convert to common formats

### Known Limitations
- **No networking**: Intentional isolation
- **No graphics**: Text-only environment
- **Limited storage**: SD card size constraints
- **Slow processor**: 800MHz ARM limitation

### Maintenance Strategy
- **Kernel updates**: Security patches only
- **Feature freeze**: Stability over features
- **Community input**: Writer feedback priority
- **Documentation**: Maintain medieval theme

---

*"Architecture by candlelight, for those who write by quill"* 🏰📜