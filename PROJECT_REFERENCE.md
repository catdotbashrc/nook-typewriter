# JesterOS Project Reference
*This document contains the complete project details moved from CLAUDE.md for token efficiency.*

## Table of Contents
1. [Philosophy & Principles](#philosophy--principles)
2. [Complete Architecture](#complete-architecture)
3. [Build System](#build-system)
4. [Testing Procedures](#testing-procedures)
5. [Development Guidelines](#development-guidelines)
6. [Troubleshooting](#troubleshooting)

---

## Philosophy & Principles

### Core Philosophy
Transform a $20 used e-reader into a $400 distraction-free writing device. Every decision prioritizes **writers over features**.

### E-Ink as Feature
- Full refresh = intentional pause for thought
- Ghosting = gentle reminder of previous words
- Slow menus = mindful interaction
- No animations = focused attention

### Development Questions
Before ANY change, ask:
1. Does this help writers write?
2. What RAM does this steal from writing?
3. Will this add distractions?
4. Can writers understand error messages?

---

## Complete Architecture

### Boot Sequence
1. U-Boot loads kernel from SD card
2. Android init starts
3. Chroot to Debian at boot completion
4. Launch `/usr/local/bin/boot-jester.sh`
5. Start JesterOS userspace services
6. Display jester and launch menu system

### System Layers
```
1. Android Base (Nook firmware) → Hardware drivers
2. Linux Chroot → Debian in /data/debian/
3. JesterOS → Userspace jester-themed services
4. Writing Environment → Vim with minimal plugins
```

### Project Structure
```
source/
├── kernel/          # Linux 2.6.29
├── configs/         # System configurations
│   ├── ascii/       # Jester ASCII art
│   ├── system/      # Boot services
│   └── vim/         # Vim configurations
└── utilities/       # System scripts
    ├── boot/        # Boot sequence
    ├── menu/        # Menu system
    ├── services/    # Background services
    └── lib/         # Common functions
```

---

## Build System

### Complete Build Commands

#### Docker Builds
```bash
# Build optimized writing environment
docker build -t nook-writer \
  --build-arg BUILD_MODE=writer \
  -f nookwriter-optimized.dockerfile .

# Export for deployment
docker create --name nook-export nook-writer
docker export nook-export | gzip > nook-writer.tar.gz
docker rm nook-export

# Build kernel
./build_kernel.sh

# Build minimal boot environment
docker build -t nook-mvp-rootfs -f minimal-boot.dockerfile .
```

#### Deployment
```bash
# Install to SD card (requires root)
sudo ./install_to_sdcard.sh

# Test locally
docker run -it --rm nook-mvp-rootfs

# Check memory usage
docker stats nook-mvp-rootfs --no-stream --format "RAM: {{.MemUsage}}"
```

---

## Testing Procedures

### Testing Philosophy
"Test Enough to Sleep Well, Not to Pass an Audit"

### Before Hardware Deployment
1. Run `./tests/smoke-test.sh` (5 minutes)
2. Run `./tests/pre-flight.sh` (safety checklist)
3. Test in Docker first: `./tests/docker-test.sh`
4. Boot from SD card (keeps device safe)

### What We Test
1. **Kernel safety** (prevents bricking)
   - Module compilation without warnings
   - API compatibility with Linux 2.6.29
   - Module loading simulation
2. **Basic functionality**
   - Builds successfully
   - Boots to menu (< 20 seconds)
   - Can write and save files
   - Stays under memory limits

### Performance Targets
- Boot time: < 20 seconds
- Vim launch: < 2 seconds
- Menu response: < 500ms
- Writing save: < 1 second
- Total RAM: < 96MB

---

## Development Guidelines

### Code Quality Standards

#### Shell Scripts
```bash
# Always use
set -euo pipefail
trap 'echo "Error at line $LINENO"' ERR

# Quote variables
echo "$USER_INPUT"  # Good
echo $USER_INPUT    # Bad

# Check commands exist
command -v fbink >/dev/null 2>&1 || echo "No E-Ink support"
```

#### Error Messages
```bash
# BAD: Technical jargon
"Error: fbdev ioctl FBIOGET_VSCREENINFO failed"

# GOOD: Writer-friendly
"E-Ink display not found (normal in Docker testing)"

# BEST: Medieval theme
"Alas! The digital parchment is not ready!"
```

### Security Model
- Input validated through `validate_menu_choice()` and `validate_path()`
- File operations restricted to `/root/{notes,drafts,scrolls}/`
- Path traversal attacks prevented
- No network access
- Single-user device

### Memory Optimization
- Docker multi-stage builds
- Aggressive cleanup of docs/locales
- Busybox-static for utilities
- Module loading only for E-Ink hardware

---

## Troubleshooting

### Common Issues

#### JesterOS services not running
- Services in `/usr/local/bin/`
- Check status: `ps aux | grep jesteros`
- View logs: `cat /var/log/jesteros.log`
- Manual start: `/usr/local/bin/jesteros-userspace.sh`

#### Memory exhaustion
- Check usage: `free -h`
- Remove vim plugins
- Use minimal build mode
- Never exceed 96MB OS usage

#### E-Ink display issues
- FBInk must be ARM compiled
- Fallback to terminal in Docker
- Manual refresh: `fbink -c`

---

## Contributing Guidelines

### Welcome Contributions
✅ Reducing memory usage
✅ Better writing tools
✅ Battery life improvements
✅ More medieval whimsy
✅ Writer workflow enhancements
✅ Shell script security
✅ Boot time optimizations

### Unwelcome Changes
❌ Web browsers or internet
❌ Development tools
❌ Media players
❌ Anything using >5MB RAM
❌ Features requiring constant refresh
❌ Scripts without error handling
❌ Removing safety validations

---

*"By quill and candlelight, we code for those who write"* 🕯️📜