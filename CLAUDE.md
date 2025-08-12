# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Philosophy

This transforms a $20 used e-reader into a $400 distraction-free writing device. Every decision prioritizes **writers over features**.

### Critical Constraints

```yaml
Hardware Limits:
  CPU: 800 MHz ARM (slower than 2008 iPhone)
  RAM: 256MB total (160MB for writing after OS)
  Display: 6" E-Ink (800x600, 16 grayscale)
  Storage: SD card based
  Power: <100mA USB output
```

### Memory Budget - DO NOT VIOLATE
```
Reserved for OS:     95MB (Debian base)
Reserved for Vim:    10MB (editor + plugins)
SACRED Writing Space: 160MB (DO NOT TOUCH)
```

## High-Level Architecture

### System Layers
```
1. Android Base (Nook firmware) → Provides hardware drivers
2. Linux Chroot (SquireOS) → Debian in /data/debian/
3. QuillKernel → Custom medieval-themed kernel modules
4. Writing Environment → Vim with minimal plugins
```

### Key Components

**QuillKernel** (`quillkernel/modules/`)
- `squireos_core.c`: Creates `/proc/squireos/` filesystem
- `jester.c`: ASCII art mood system based on system state
- `typewriter.c`: Tracks keystrokes and writing achievements
- `wisdom.c`: Rotating writing quotes for inspiration

**Build System**
- Two Docker environments: OS (`nookwriter-optimized.dockerfile`) and Kernel (`quillkernel/Dockerfile`)
- Kernel uses Android NDK r10e with ARM cross-compiler
- OS has two modes: minimal (2MB RAM) or writer (5MB RAM)

**Boot Sequence**
1. U-Boot loads kernel from SD card
2. Android init starts
3. Chroot to Debian at boot completion
4. Launch `/usr/local/bin/boot-jester.sh`
5. Display menu via `nook-menu.sh`

## Essential Development Commands

### Building the System

```bash
# Build optimized writing environment (recommended)
docker build -t nook-writer --build-arg BUILD_MODE=writer -f nookwriter-optimized.dockerfile .

# Export for deployment
docker create --name nook-export nook-writer
docker export nook-export | gzip > nook-writer.tar.gz
docker rm nook-export

# Build QuillKernel (from quillkernel/ directory)
./build.sh  # One-command kernel build with Docker

# Alternative: Build rootfs with script
./scripts/build-rootfs.sh --output nook-debian.tar.gz
```

### Testing

```bash
# Run full test suite
./tests/run-tests.sh

# Test individual components
./tests/test-docker-build.sh   # Container builds
./tests/test-vim-modes.sh       # Vim configurations
./tests/test-health-check.sh    # System health
./tests/test-plugin-system.sh   # Plugin framework

# Test in Docker (won't have E-Ink)
docker run -it --rm nook-writer vim /tmp/test.txt
docker run --rm nook-writer /usr/local/bin/nook-menu.sh

# Check memory impact of changes
docker stats nook-writer --no-stream --format "RAM: {{.MemUsage}}"
```

### Deployment

```bash
# Deploy to SD card (requires root)
sudo ./deploy-to-nook.sh /dev/sdX  # Replace X with your SD card

# Verify SD card structure
./scripts/verify-sd-card.sh /dev/sdX

# Troubleshoot boot issues
./troubleshoot-sd.sh /dev/sdX
```

### Kernel Development

```bash
# Check if QuillKernel modules are loaded (on device)
cat /proc/squireos/jester      # Should show ASCII jester
cat /proc/squireos/typewriter/stats  # Writing statistics
cat /proc/squireos/wisdom       # Random writing quote

# Monitor writing statistics
watch -n 5 'cat /proc/squireos/typewriter/stats'
```

## Writer-First Development Rules

### Before ANY Change, Ask:
1. **Does this help writers write?**
2. **What RAM does this steal from writing?**
3. **Will this add distractions?**
4. **Can writers understand the error messages?**

### E-Ink Considerations
- Full refresh (`fbink -c`) = intentional pause for thought
- Ghosting = gentle reminder of previous words
- Slow menus = mindful interaction
- No animations = focused attention

### Common Issues & Solutions

**Kernel modules not loading:**
- Modules go in `/lib/modules/2.6.29/` in rootfs
- Add `insmod /lib/modules/squireos_core.ko` to boot scripts
- Check `dmesg` for module errors

**Memory exhaustion:**
- Run `free -h` to check usage
- Remove unnecessary vim plugins
- Use minimal build mode if needed
- Never exceed 96MB OS usage

**E-Ink display issues:**
- FBInk must be compiled for ARM (`fbink-v1.25.0-armv7`)
- Fallback to terminal output in Docker
- Manual refresh: `fbink -c`

## Code Quality Standards

### Shell Scripts
```bash
# Always use for new scripts
set -euo pipefail
trap 'echo "Error at line $LINENO"' ERR

# Quote all variables
echo "$USER_INPUT"  # Good
echo $USER_INPUT    # Bad - injection risk

# Check commands exist
command -v fbink >/dev/null 2>&1 || echo "No E-Ink support"
```

### Kernel Modules (C)
```c
// Always validate buffer sizes
snprintf(buffer, sizeof(buffer), format, args);  // Good
sprintf(buffer, format, args);  // Bad - overflow risk

// Check for integer overflow
if (stats.words < UINT32_MAX) stats.words++;

// Use proper locking for shared data
spin_lock(&stats_lock);
// ... modify stats ...
spin_unlock(&stats_lock);
```

### Error Messages
```bash
# BAD: Technical jargon
"Error: fbdev ioctl FBIOGET_VSCREENINFO failed"

# GOOD: Writer-friendly
"E-Ink display not found (normal in Docker testing)"

# BEST: Medieval theme
"Alas! The digital parchment is not ready!"
```

## Testing Philosophy

### What Must Be Tested
- Boot process to menu (< 20 seconds)
- Vim launches with < 10MB RAM usage
- Writing plugins work (Goyo, Pencil)
- No network access possible
- Jester appears at boot
- Statistics track correctly

### Performance Targets
- Boot time: < 20 seconds
- Vim launch: < 2 seconds
- Menu response: < 500ms
- Writing save: < 1 second
- Total RAM usage: < 96MB

## Contributing Guidelines

### Welcome Contributions
✅ Reducing memory usage
✅ Better writing tools (spell check, thesaurus)
✅ Battery life improvements
✅ More medieval whimsy
✅ Writer workflow enhancements

### Unwelcome Changes
❌ Web browsers or internet features
❌ Development tools (compilers, interpreters)
❌ Media players or graphics
❌ Anything using >5MB RAM
❌ Features requiring constant refresh

## Philosophy Reminders

> "Every feature is a potential distraction"

> "RAM saved is words written"

> "E-Ink limitations are features"

> "When in doubt, choose simplicity"

> "The jester reminds us: writing should be joyful"

---

*"By quill and candlelight, we code for those who write"* 🕯️📜