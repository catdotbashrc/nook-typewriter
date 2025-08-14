# Nook Typewriter System Architecture Design

## Executive Summary

A minimalist, RAM-conscious architecture designed for a 256MB e-reader transformed into a distraction-free writing device. Every architectural decision prioritizes writers over features, with a whimsical medieval theme throughout.

## System Constraints

```yaml
Hardware:
  CPU: 800 MHz ARM Cortex-A8
  RAM: 256MB DDR2 (96MB OS limit)
  Display: 6" E-Ink (800x600, 16 grayscale, 1-2s refresh)
  Storage: 2GB internal + SD card
  Input: USB OTG for keyboard
  Power: 1500mAh battery

Software:
  Kernel: Linux 2.6.29 with integrated SquireOS subsystem
  Base OS: Android 2.1 (driver layer only)
  Writing OS: Debian Bullseye (chroot)
  No network: Intentionally offline
```

## Architectural Principles

1. **Memory is Sacred**: Every byte counts toward the 96MB limit
2. **Simplicity Over Features**: Less code = more writing space
3. **E-Ink First**: Design around 1-2 second refresh cycles
4. **Medieval Whimsy**: Joy through themed interactions
5. **Offline by Design**: No distractions, no vulnerabilities

## System Architecture Layers

```
┌─────────────────────────────────────────────────────────┐
│                    User Interface Layer                  │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │   Vim UI    │  │  Menu System │  │ Jester ASCII │  │
│  │  (Goyo +    │  │   (nook-     │  │  Animations  │  │
│  │   Pencil)   │  │   menu.sh)   │  │              │  │
│  └─────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────┐
│                  Application Services                    │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │   Writing   │  │   Jester     │  │    Health    │  │
│  │   Modes     │  │   Daemon     │  │   Monitor    │  │
│  │  (Draft/ZK) │  │              │  │              │  │
│  └─────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────┐
│                    System Services                       │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │   Display   │  │  File System │  │   Process    │  │
│  │   Manager   │  │   Manager    │  │   Manager    │  │
│  │   (FBInk)   │  │              │  │              │  │
│  └─────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────┐
│                  Kernel Interface Layer                  │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │ QuillKernel │  │    procfs    │  │     sysfs    │  │
│  │   Modules   │  │  Interface   │  │   Interface  │  │
│  └─────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────┐
│                    Hardware Abstraction                  │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │   E-Ink     │  │     USB      │  │    Power     │  │
│  │   Driver    │  │   OTG/HID    │  │  Management  │  │
│  └─────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
```

## Component Design

### 1. Boot System Architecture

```
Boot Sequence:
┌──────────────┐
│   U-Boot     │ (1s)
└──────┬───────┘
       ▼
┌──────────────┐
│ Linux Kernel │ (3s)
└──────┬───────┘
       ▼
┌──────────────┐
│Android Init  │ (2s)
└──────┬───────┘
       ▼
┌──────────────┐
│   Chroot     │ (1s)
│   Debian     │
└──────┬───────┘
       ▼
┌──────────────┐
│ SquireOS     │ (2s)
│    Boot      │
└──────┬───────┘
       ▼
┌──────────────┐
│ Jester Init  │ (1s)
└──────┬───────┘
       ▼
┌──────────────┐
│  Main Menu   │ (Total: ~10s)
└──────────────┘
```

### 2. Memory Management Architecture

```
RAM Allocation (256MB Total):
┌────────────────────────────────┐
│ Android/Drivers (96MB)         │ Reserved
├────────────────────────────────┤
│ Linux Kernel (32MB)            │ System
├────────────────────────────────┤
│ SquireOS Base (64MB)           │ OS
│ ├─ Debian Core (40MB)          │
│ ├─ Shell/Utils (15MB)          │
│ └─ Services (9MB)              │
├────────────────────────────────┤
│ Vim + Plugins (10MB)           │ Editor
├────────────────────────────────┤
│ Writing Buffer (54MB)          │ User Space
│ ├─ Active Document (10MB)      │
│ ├─ Undo History (4MB)          │
│ └─ Free Space (40MB)           │
└────────────────────────────────┘
```

### 3. Display System Architecture

```
E-Ink Display Pipeline:
┌─────────────┐
│ Application │
└──────┬──────┘
       │ Text/Graphics
       ▼
┌─────────────┐
│  common.sh  │
│  Display    │
│ Abstraction │
└──────┬──────┘
       │ Commands
       ▼
┌─────────────┐
│    FBInk    │
│   Library   │
└──────┬──────┘
       │ Framebuffer
       ▼
┌─────────────┐
│ /dev/fb0    │
│ Framebuffer │
└──────┬──────┘
       │ Pixels
       ▼
┌─────────────┐
│ E-Ink Panel │
│  Controller │
└─────────────┘

Refresh Strategies:
- Full Refresh: Menu changes, mode switches
- Partial Update: Typing, cursor movement
- Ghost Tolerance: Accept mild ghosting for speed
```

### 4. QuillKernel Module Architecture

```
Integrated SquireOS Kernel Subsystem:
┌──────────────────────────────┐
│   Linux Kernel 2.6.29         │
│   drivers/squireos/           │
└───────────┬──────────────────┘
            │
    ┌───────┴────────────────────┐
    │    squireos.ko             │
    │  (Unified kernel module)    │
    └───────────┬─────────────────┘
                │
    ┌───────────┴──────────────────┐
    │  Integrated Components:       │
    │  ├─ squireos_core.c          │
    │  ├─ jester.c (ASCII art)     │
    │  ├─ typewriter.c (stats)     │
    │  └─ wisdom.c (quotes)        │
    └──────────────────────────────┘

Build Integration:
- Built as part of kernel (CONFIG_SQUIREOS=y)
- Or as loadable module (CONFIG_SQUIREOS=m)
- Located in: nst-kernel-base/src/drivers/squireos/

Interfaces:
/proc/squireos/
├── jester          (ASCII art display)
├── typewriter/
│   ├── stats       (writing statistics)
│   └── achievements (writing milestones)
├── wisdom          (rotating quotes)
└── motto           (system motto)
```

### 5. Service Architecture

```
System Services:
┌─────────────────────────────────────┐
│         Service Manager             │
│         (systemd-light)             │
└──────────────┬──────────────────────┘
               │
    ┌──────────┼──────────┬───────────┐
    ▼          ▼          ▼           ▼
┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐
│Jester  │ │Health  │ │Plugin  │ │Future  │
│Daemon  │ │Monitor │ │System  │ │Services│
│        │ │        │ │        │ │        │
│Priority│ │Priority│ │Priority│ │Priority│
│High    │ │Medium  │ │Low     │ │Low     │
└────────┘ └────────┘ └────────┘ └────────┘

Resource Limits per Service:
- CPU: Max 10% per service
- Memory: Max 2MB per service
- I/O: Throttled to preserve battery
```

### 6. Storage Architecture

```
Storage Layout:
┌─────────────────────────────────────┐
│          SD Card (Boot)             │
│  /boot/                             │
│  ├── uImage (kernel)                │
│  ├── uRamdisk (initrd)              │
│  └── uEnv.txt (boot config)         │
├─────────────────────────────────────┤
│         SD Card (Root)              │
│  /                                  │
│  ├── /data/debian/ (chroot)         │
│  ├── /root/notes/ (writing)         │
│  ├── /root/drafts/ (work)           │
│  └── /root/scrolls/ (complete)      │
├─────────────────────────────────────┤
│      Internal Flash (2GB)           │
│  Android System (preserved)         │
└─────────────────────────────────────┘
```

## Security Architecture

```
Security Layers:
┌─────────────────────────────────────┐
│      Application Security           │
│  - Input validation                 │
│  - Path traversal prevention        │
│  - No network stack                 │
└─────────────────────────────────────┘
                ▼
┌─────────────────────────────────────┐
│       System Security               │
│  - Read-only base system            │
│  - Minimal attack surface           │
│  - No unnecessary services          │
└─────────────────────────────────────┘
                ▼
┌─────────────────────────────────────┐
│      Physical Security              │
│  - No wireless radios               │
│  - USB input only                   │
│  - Encrypted notes (optional)       │
└─────────────────────────────────────┘
```

## Performance Architecture

### Optimization Strategies

1. **Boot Optimization**
   - Parallel service startup where possible
   - Lazy loading of non-critical components
   - Cached jester animations

2. **Memory Optimization**
   - Shared libraries where possible
   - Aggressive memory limits per process
   - Swap disabled (too slow on SD card)

3. **E-Ink Optimization**
   - Batch display updates
   - Partial refresh for typing
   - Full refresh only on mode changes

4. **Power Optimization**
   - CPU frequency scaling
   - Aggressive idle states
   - Minimal background processes

## Deployment Architecture

```
Build Pipeline:
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   Source     │────▶│    Docker    │────▶│   Artifacts  │
│   Code       │     │    Build     │     │              │
└──────────────┘     └──────────────┘     └──────────────┘
                            │                      │
                    ┌───────┴────────┐            │
                    ▼                ▼            ▼
            ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
            │ Unified      │ │   RootFS     │ │  SD Card     │
            │ Kernel+      │ │   Build      │ │   Image      │
            │ SquireOS     │ │              │ │              │
            └──────────────┘ └──────────────┘ └──────────────┘

Build Components:
- Kernel: nst-kernel-base/src/ (Linux 2.6.29)
- Modules: nst-kernel-base/src/drivers/squireos/
- Docker: nst-kernel-base/build/Dockerfile
- Script: nst-kernel-base/build/build.sh

Deployment Targets:
- Development: Docker container (no E-Ink)
- Testing: QEMU ARM emulation
- Production: Physical Nook device
```

## Future Architecture Considerations

### Potential Enhancements (Memory Permitting)

1. **Spell Check Service** (~3MB)
   - Minimal dictionary
   - Suggestion engine
   - User dictionary

2. **Git Integration** (~5MB)
   - Local versioning only
   - Commit on save
   - History browsing

3. **Export Service** (~2MB)
   - PDF generation
   - Markdown to HTML
   - Format conversion

### Architectural Boundaries

**Never Add**:
- Network stack (security risk)
- Web browser (distraction)
- Development tools (wrong purpose)
- Media players (distraction)
- Complex file managers (unnecessary)

**Always Preserve**:
- <96MB OS footprint
- <10 second boot time
- Medieval theme consistency
- Writer-first focus
- Offline operation

## Implementation Roadmap

### Phase 1: Foundation (Current)
✅ Core boot system
✅ QuillKernel modules
✅ Basic menu system
✅ Vim integration
✅ Jester daemon

### Phase 2: Optimization
✅ Common library (common.sh)
✅ Boot time optimization
✅ Memory monitoring
⬜ Battery optimization
⬜ E-Ink refresh optimization

### Phase 3: Enhancement
⬜ Plugin system completion
⬜ Advanced writing modes
⬜ Statistics dashboard
⬜ Achievement system
⬜ Export capabilities

### Phase 4: Polish
⬜ Full test coverage
⬜ Performance profiling
⬜ Documentation completion
⬜ User manual
⬜ Community features

## Architecture Decision Records (ADRs)

### ADR-001: Chroot over Native Debian
**Decision**: Use chroot Debian instead of native installation
**Rationale**: Preserves original Nook firmware, allows recovery
**Consequences**: Slight overhead, but acceptable

### ADR-002: No Network Stack
**Decision**: Completely remove network capabilities
**Rationale**: Eliminates distractions and security risks
**Consequences**: Manual file transfer via SD card

### ADR-003: Medieval Theme Throughout
**Decision**: Implement consistent medieval theme
**Rationale**: Adds joy and personality to the writing experience
**Consequences**: Slight code overhead, massive user delight

### ADR-004: FBInk for Display
**Decision**: Use FBInk library for E-Ink control
**Rationale**: Mature, optimized for e-readers
**Consequences**: Dependency on external library

### ADR-005: Kernel 2.6.29 Retention
**Decision**: Keep ancient kernel instead of upgrading
**Rationale**: Stable, tested, has required drivers
**Consequences**: Missing modern features, acceptable trade-off

### ADR-006: Integrated Kernel Module Architecture
**Decision**: Integrate QuillKernel modules directly into kernel source tree
**Rationale**: Simplifies build process, ensures compatibility, single build environment
**Consequences**: Modules now part of kernel tree at drivers/squireos/, unified Docker build

## Monitoring & Observability

```
Health Monitoring:
┌─────────────────────────────────────┐
│         Health Check System          │
└──────────────┬──────────────────────┘
               │
    Monitors:  │
    ┌──────────┼──────────┬───────────┐
    ▼          ▼          ▼           ▼
┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐
│Memory  │ │CPU     │ │Storage │ │Battery │
│Usage   │ │Usage   │ │Space   │ │Level   │
│        │ │        │ │        │ │        │
│<96MB   │ │<50%    │ │>100MB  │ │>20%    │
└────────┘ └────────┘ └────────┘ └────────┘

Logs:
/var/log/squireos.log (rotated at 1MB)
/proc/squireos/stats (kernel statistics)
```

## Conclusion

This architecture prioritizes:
1. **Minimal resource usage** (RAM is sacred)
2. **Fast, responsive writing** (E-Ink optimized)
3. **Joy in simplicity** (medieval whimsy)
4. **Reliability over features** (writer-first)
5. **Security through isolation** (offline by design)

The layered architecture ensures clean separation of concerns while maintaining the critical 96MB memory budget. Every component serves the singular purpose: enabling distraction-free writing with joy.

---

*"Architecture is frozen music, and our music is a simple medieval tune"* 🏰📜