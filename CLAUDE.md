# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Philosophy

This transforms a $20 used e-reader into a $400 distraction-free writing device. Every decision prioritizes **writers over features**.

### Architecture Principle
**JesterOS Userspace**: The jester services (mood, typewriter stats, wisdom quotes) now run in userspace for simplicity and reliability (~10KB).

**Minimal Kernel**: Keep the kernel lean and stable - all enhancements happen in userspace to avoid kernel compilation complexity.

### Critical Constraints

```yaml
Hardware Limits:
  CPU: 800 MHz ARM Cortex-A8 (OMAP3621 GOSSAMER)
  RAM: 233MB total (35MB available after Android base system)
  Display: 6" E-Ink Pearl (600x1600, 16 grayscale)
  Storage: SD card based
  Power: <100mA USB output
```

### Memory Budget - CRITICAL REALITY (Updated from ADB device analysis)
```
Android Base System:  188MB (measured from real device over 6+ hours)
JesterOS Userspace:    10MB (ASCII art, stats, wisdom - ABSOLUTE MAXIMUM)
Vim + Minimal Config:   8MB (no syntax highlighting, minimal history)
Available for Writing: 27MB (REALISTIC MAXIMUM - this constraint is a FEATURE!)
```

**REALITY CHECK**: ADB analysis of real Nook device (192.168.12.111:5555) shows only 35MB total available.
**PHILOSOPHY**: This constraint ENHANCES writing focus - forces true minimalism and distraction-free experience!

## High-Level Architecture

### System Layers
```
1. Android Base (Nook firmware) → Provides hardware drivers
2. Linux Chroot → Debian in /data/debian/
3. JesterOS → Userspace jester-themed services
4. Writing Environment → Vim with minimal plugins
```

### Key Components

**JesterOS Services** (userspace implementation)
- Creates `/var/jesteros/` filesystem interface
- `jester`: ASCII art mood system based on system state
- `typewriter/stats`: Tracks keystrokes and writing achievements
- `wisdom`: Rotating writing quotes for inspiration
- Simple shell scripts - no kernel compilation needed!

**Build System**
- Main kernel build: `./build_kernel.sh` (Docker-based with `jokernel-builder` image)
- Minimal boot environment: `minimal-boot.dockerfile` for MVP testing (<30MB)
- Kernel uses Android NDK r10e with ARM cross-compiler targeting Linux 2.6.29
- Cross-compilation: `arm-linux-androideabi-` toolchain

**Boot Sequence**
1. U-Boot loads kernel from SD card
2. Android init starts
3. Chroot to Debian at boot completion
4. Launch `/usr/local/bin/boot-jester.sh` or MVP init script
5. Start JesterOS userspace services
6. Display jester and launch menu system

## Essential Development Commands

### Building the System

```bash
# Build optimized writing environment (recommended)
docker build -t nook-writer --build-arg BUILD_MODE=writer -f nookwriter-optimized.dockerfile .

# Export for deployment
docker create --name nook-export nook-writer
docker export nook-export | gzip > nook-writer.tar.gz
docker rm nook-export

# Build QuillKernel (main build script)
./build_kernel.sh  # One-command kernel build with Docker

# Build minimal boot environment for testing
docker build -t nook-mvp-rootfs -f minimal-boot.dockerfile .
docker create --name nook-export nook-mvp-rootfs
docker export nook-export | gzip > nook-mvp-rootfs.tar.gz
docker rm nook-export
```

### Testing

```bash
# Run improvement validation tests
./tests/test-improvements.sh    # Validates script improvements and safety measures

# Test JesterOS userspace services
./test-jesteros-userspace.sh

# Test in Docker (won't have E-Ink)
docker run -it --rm nook-writer vim /tmp/test.txt
docker run --rm nook-writer /usr/local/bin/nook-menu.sh

# Check memory impact of changes
docker stats nook-writer --no-stream --format "RAM: {{.MemUsage}}"
```

### Deployment

```bash
# Install to SD card (requires root)
sudo ./install_to_sdcard.sh

# Test Docker image locally (no E-Ink support)
docker run -it --rm nook-mvp-rootfs

# Check memory usage
docker stats nook-mvp-rootfs --no-stream --format "RAM: {{.MemUsage}}"
```

### JesterOS Development

```bash
# Check JesterOS services (on device)
cat /var/jesteros/jester      # Should show ASCII jester
cat /var/jesteros/typewriter/stats  # Writing statistics
cat /var/jesteros/wisdom       # Random writing quote

# Monitor writing statistics
watch -n 5 'cat /var/jesteros/typewriter/stats'

# Install JesterOS userspace
./install-jesteros-userspace.sh
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

**JesterOS services not running:**
- Services installed in `/usr/local/bin/` 
- Started by init script at boot
- Check service status: `ps aux | grep jesteros`
- View logs: `cat /var/log/jesteros.log`
- Manual start: `/usr/local/bin/jesteros-userspace.sh`

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

### "Test Enough to Sleep Well, Not to Pass an Audit"

This is a **hobby project for fun and learning**. Keep testing simple and practical:

#### Before ANY Hardware Deployment
1. Run `./tests/smoke-test.sh` (takes 5 minutes)
2. Run `./tests/pre-flight.sh` (safety checklist)
3. Test in Docker first: `./tests/docker-test.sh`
4. Boot from SD card (keeps device safe)

#### What We Test (Priority Order)
1. **Kernel safety** (most critical - prevents bricking!)
   - Module compilation without warnings
   - API compatibility with Linux 2.6.29
   - Module loading simulation
   - No obvious memory/resource issues
2. **Basic functionality**
   - Builds successfully  
   - Boots to menu (< 20 seconds)
   - Can write and save files
   - Stays under memory limits

#### What We DON'T Test
- 90% code coverage
- Every edge case scenario
- Performance microseconds
- Enterprise compliance metrics

#### Performance Targets (Realistic)
- Boot time: < 20 seconds
- Vim launch: < 2 seconds  
- Menu response: < 500ms
- Writing save: < 1 second
- Total RAM usage: < 96MB (needs reality check!)

**Remember**: Time spent over-testing = less time spent writing!

## Critical Project Structure

### Current Architecture (Post-Kernel Integration)
```
source/
├── kernel/              # Linux 2.6.29 with SquireOS modules
│   ├── src/            # Full kernel source tree
│   └── test/           # Module testing scripts
├── configs/            # System configurations
│   ├── ascii/          # Jester ASCII art collections
│   ├── system/         # Boot services and system files
│   └── vim/            # Vim configurations for writing
└── scripts/            # System scripts organized by function
    ├── boot/           # Boot sequence scripts
    ├── menu/           # Menu system implementations
    ├── services/       # Background services
    └── lib/            # Common library functions
```

## Analysis and Testing Scope

### IMPORTANT: Code Analysis Boundaries
When analyzing this project for security, quality, or performance:

**EXCLUDE from analysis** (vanilla Linux kernel - NOT our code):
- `source/kernel/src/` - This is the unmodified Linux 2.6.29 kernel
- Any `.c` or `.h` files in kernel directories
- The 2,986 files with unsafe C functions are in vanilla kernel, accepted risk

**INCLUDE in analysis** (our actual project code):
- `source/scripts/` - All our shell scripts (boot, menu, services)
- `source/configs/` - Configuration files
- `build/` - Build scripts and Dockerfiles
- `tools/` - Maintenance and deployment tools
- `tests/` - Test suites
- `docs/` - Documentation

### Security Focus Areas
Focus security analysis ONLY on our code:
- Shell scripts in `source/scripts/` (check for safety headers, input validation)
- Build scripts (check for proper error handling)
- Menu systems (check for path traversal protection)
- Boot scripts (check for race conditions)

The Linux 2.6.29 kernel's unsafe functions are a **documented accepted risk** mitigated by:
- Air-gapped operation (no network)
- Minimal attack surface (no external input)
- Read-only filesystem
- Single-user device

### Script Safety Standards
All shell scripts now implement:
- `set -euo pipefail` for fail-fast behavior
- Input validation functions (`validate_menu_choice`, `validate_path`)
- Display abstraction for E-Ink compatibility
- Standardized error handling with `error_handler`
- Path traversal protection
- Safe file operations with directory creation

## Contributing Guidelines

### Welcome Contributions
✅ Reducing memory usage
✅ Better writing tools (spell check, thesaurus)
✅ Battery life improvements
✅ More medieval whimsy
✅ Writer workflow enhancements
✅ Shell script security improvements
✅ Boot time optimizations

### Unwelcome Changes
❌ Web browsers or internet features
❌ Development tools (compilers, interpreters)
❌ Media players or graphics
❌ Anything using >5MB RAM
❌ Features requiring constant refresh
❌ Scripts without proper error handling
❌ Removing safety validations

### Development Workflow Rules

**ALWAYS prefer updating existing files over creating new ones:**
- ✅ Edit existing scripts to add functionality
- ✅ Update existing documentation files
- ✅ Enhance existing configurations
- ✅ Extend existing test suites
- ❌ Create new files when existing ones can be updated
- ❌ Duplicate functionality in separate files
- ❌ Create new documentation when existing docs can be enhanced

**File Creation Guidelines:**
- Only create new files when functionality is genuinely distinct
- Consolidate similar functions into existing modules
- Update existing README/docs rather than creating new ones
- Extend existing test files rather than creating parallel tests

**Memory Constraint Reasoning:**
With only 35MB available RAM, every file matters. Fewer files = less memory overhead, simpler maintenance, and better focus on core writing functionality.

## Key Implementation Details

### JesterOS Service Startup
1. Init script runs at boot
2. JesterOS userspace services start
3. `/var/jesteros/` interface becomes available
4. Menu system reads from `/var/jesteros/{jester,typewriter/stats,wisdom}`

### Security Model
- All user input validated through `validate_menu_choice()` and `validate_path()`
- File operations restricted to `/root/{notes,drafts,scrolls}/` directories
- Path traversal attacks prevented by canonicalization checks
- No network access or external communication

### Memory Optimization Strategies
- Docker multi-stage builds minimize final image size
- Aggressive cleanup removes docs, locales, and static libraries
- Busybox-static provides essential utilities in single binary
- Module loading only when hardware supports E-Ink display

## Philosophy Reminders

> "Every feature is a potential distraction"

> "RAM saved is words written"

> "E-Ink limitations are features"

> "When in doubt, choose simplicity"

> "The jester reminds us: writing should be joyful"

> "By quill and candlelight, quality prevails!"

---

*"By quill and candlelight, we code for those who write"* 🕯️📜

## Activity Logging

You have access to the `log_activity` tool. Use it to record your activities after every activity that is relevant for the project. This helps track development progress and understand what has been done.