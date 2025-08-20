# Architecture Document

## System Overview

JesterOS/JoKernel transforms a Barnes & Noble Nook Simple Touch e-reader into a dedicated, distraction-free writing device through a custom Linux distribution running on top of Android's hardware initialization layer, featuring a medieval-themed 4-layer service architecture optimized for extreme hardware constraints (256MB RAM, E-Ink display).

## Tech Stack

### Core System
- **Kernel**: Linux 2.6.29-jester (required for Nook hardware)
- **Cross-Compiler**: Android NDK r10e with arm-linux-androideabi-4.9
- **Build Environment**: Docker with BuildKit optimization
- **Base OS**: Debian Lenny 5.0 (minimal, <31MB rootfs)
- **Init System**: Android init (hardware) → JesterOS init (userspace)
- **Display Driver**: E-Ink framebuffer with FBInk support
- **Text Editor**: Vim with E-Ink optimized configurations

### Development Tools
- **Containerization**: Docker with multi-stage builds
- **Version Control**: Git with GitHub CLI integration
- **Testing**: 3-stage pipeline (pre-build, post-build, runtime)
- **Documentation**: Medieval-themed markdown
- **Activity Tracking**: Simone MCP integration

## System Architecture

### 4-Layer JesterOS Stack (35 scripts)
```
┌─────────────────────────────────────────┐
│      Layer 1: UI (8 scripts)            │ Display, menus, themes
├─────────────────────────────────────────┤
│   Layer 2: Application (9 scripts)      │ JesterOS services, writing tools
├─────────────────────────────────────────┤
│     Layer 3: System (6 scripts)         │ Common functions, memory guard
├─────────────────────────────────────────┤
│    Layer 4: Hardware (8 scripts)        │ Battery, buttons, USB, sensors
├─────────────────────────────────────────┤
│        Init Layer (4 scripts)           │ Boot orchestration
└─────────────────────────────────────────┘
```

### Boot Sequence
```
Power On → ROM Loader → MLO (16KB) → U-Boot (159KB) → 
Linux Kernel (1.9MB) → Android Init → JesterOS Init → 
4-Layer Services → Menu System
```

### Memory Architecture
```
┌─────────────────────────────┐
│   Sacred Writing Space      │ 160MB (NEVER TOUCH)
├─────────────────────────────┤
│   JesterOS + Services       │ 95MB max (enforced)
├─────────────────────────────┤
│   Kernel + Drivers          │ ~30MB
├─────────────────────────────┤
│   Hardware Reserved         │ ~31MB
└─────────────────────────────┘
Total: 256MB
```

## Core Components

### Runtime Scripts (`runtime/`)
**Layer 1 - UI**:
- `display.sh`, `menu.sh` - Display abstraction
- `jester-menu.sh`, `nook-menu.sh` - Menu systems
- `power-menu.sh`, `git-menu.sh` - Specialized menus

**Layer 2 - Application**:
- `daemon.sh`, `jester-daemon.sh` - Medieval assistant
- `tracker.sh`, `manager.sh` - Statistics tracking
- `git-installer.sh`, `git-manager.sh` - Version control

**Layer 3 - System**:
- `common.sh` - Shared functions and constants
- `consolidated-functions.sh` - Deduplicated utilities
- `memory-guardian.sh` - 95MB limit enforcement
- `unified-monitor.sh` - System monitoring

**Layer 4 - Hardware**:
- `button-handler.sh` - Physical button management
- `usb-keyboard-manager.sh` - External keyboard support
- `battery-monitor.sh`, `power-optimizer.sh` - Power management
- `temperature-monitor.sh` - Thermal monitoring

### Firmware Components (`firmware/`)
- **Bootloaders**: MLO (16KB), u-boot.bin (159KB) - Protected files
- **Kernel**: uImage (1.9MB) at load address 0x80008000
- **Android Layer**: init binary, DSP drivers (baseimage.dof 1.2MB)
- **E-Ink**: wvf.bin (93KB waveform data)

### Build System (`build/`, `docker/`)
- **Docker Images**: 
  - `jesteros:lenny-base` - Minimal Debian base
  - `jesteros-production` - Production rootfs
  - `kernel-xda-proven-optimized` - Kernel builder
- **Scripts**: Kernel build, image creation, bootloader extraction

## Data Flow

### Writing Flow
```
USB Keyboard → Kernel Driver → Vim → File System → SD Card
                     ↓
            Writing Statistics → /var/jesteros/typewriter/stats
```

### Display Flow
```
Application → Framebuffer → E-Ink Controller → Display
                  ↓
          Refresh Control (200-980ms delay)
```

### Service Communication
```
Init Scripts → Common Functions → Service Scripts → Proc Interface
                      ↓
              Error Handler → Logger → System Log
```

## Testing Architecture

### 3-Stage Pipeline
1. **Pre-Build**: Test build tools and scripts
2. **Post-Build**: Validate Docker output
3. **Runtime**: Test execution in container

### Critical Tests
- `01-safety-check.sh` - Safety validations
- `02-boot-test.sh` - Boot sequence
- `05-consistency-check.sh` - File consistency
- `06-memory-guard.sh` - Memory limits

## Deployment Strategy

### SD Card Structure
- **Partition 1**: 50MB vfat (bootloaders, kernel)
- **Partition 2**: 200MB ext4 (JesterOS rootfs)
- **Partition 3**: Remaining ext4 (user data)

### Installation Methods
1. **Direct SD Boot**: Write image, insert, boot
2. **CWM Recovery**: 128MB installer image
3. **NookManager**: Compatible with v0.5.0

## Design Decisions

### Why Android Init?
Hardware drivers (E-Ink, touch, battery) require Android's hardware abstraction layer. JesterOS runs in userspace on top.

### Why Debian Lenny?
Smallest stable Debian that supports ARM with required libraries. Modern versions exceed memory constraints.

### Why 4-Layer Architecture?
Clear separation of concerns optimized for embedded constraints:
- UI isolated from hardware
- Applications independent of system services
- System layer provides shared functionality
- Hardware layer abstracts device specifics

### Why Medieval Theme?
Creates focused writing environment, reduces digital anxiety, maintains project whimsy while serving practical purpose (mindful interaction).

## Performance Characteristics

### Resource Usage
- **Boot Time**: ~30 seconds to menu
- **Memory**: 85-90MB typical usage
- **CPU**: Event-driven, <5% idle
- **Battery**: <1.5% daily drain target

### Bottlenecks
- E-Ink refresh (200-980ms)
- SD card I/O speed
- 800MHz single-core CPU
- 256MB RAM ceiling

## Security Model

### Strengths
- No network services
- Read-only kernel/boot
- Input validation throughout
- Error trapping in all scripts

### Limitations
- Root execution required
- No privilege separation
- Physical access assumed

## Future Considerations

### Scalability Path
- Plugin system for menu extensions
- Service composition patterns
- Configuration-driven behavior
- Module loading for features

### Technical Debt
- Shell script standardization (bash vs sh)
- Init script consolidation
- Service dependency management
- Configuration centralization

---

*Architecture designed for writers, not engineers* 🏰