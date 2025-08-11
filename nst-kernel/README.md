# QuillKernel - Medieval-Themed Nook Simple Touch Kernel

Custom Linux kernel 2.6.29 for Barnes & Noble Nook Simple Touch e-reader, featuring medieval theming and optimized for digital typewriter functionality.

```
     .~"~.~"~.
    /  o   o  \    Welcome to QuillKernel!
   |  >  ◡  <  |   Thy digital writing companion
    \  ___  /      
     |~|♦|~|       
```

## Overview

QuillKernel transforms your Nook Simple Touch into SquireOS - a whimsical digital writing device with a medieval court jester as your companion. Based on the original B&N kernel sources with community patches for USB host mode and fast E-ink refresh.

## Features

### 🏰 Medieval Theming
- **Boot Messages**: "By quill and candlelight, we begin..."
- **Court Jester**: ASCII art companion throughout the system
- **/proc/squireos**: Special interface with rotating wisdom
- **Achievement System**: From "Apprentice Scribe" to "Grand Chronicler"

### ⌨️ Writing Features
- **USB Host Mode**: Connect keyboards via OTG adapter
- **Typewriter Module**: Tracks keystrokes, words, and sessions
- **Writing Achievements**: Unlock titles as you write more
- **Power Optimized**: Extended battery for long writing sessions

### 🛠️ Technical Features
- **Fast E-ink Mode**: Reduced ghosting and faster refresh
- **256MB RAM Optimized**: Efficient memory usage
- **Comprehensive Test Suite**: 12+ test scripts included
- **Docker Build Support**: No local toolchain needed

## Quick Start

### Prerequisites
- Nook Simple Touch (rooted)
- USB OTG adapter
- USB keyboard (preferably low-power)
- Linux build environment or Docker

### Building QuillKernel - Simplified!

#### Step 1: Apply Patches
```bash
./squire-kernel-patch.sh
```

#### Step 2: Build (Choose One)

**Docker Build (Recommended - No toolchain needed!)**
```bash
docker build -f Dockerfile.build -t quillkernel .
```

**Traditional Build (Requires ARM toolchain)**
```bash
cd src
make ARCH=arm quill_typewriter_defconfig
make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- uImage
```

That's it! See [SIMPLE-BUILD.md](SIMPLE-BUILD.md) for the complete simplified guide.

### Testing

Run comprehensive test suite:
```bash
cd test
./verify-build-simple.sh  # Check build setup
./run-all-tests.sh        # Full test suite
```

See [Testing Documentation](docs/testing-overview.md) for details.

## Installation

1. **Backup current kernel** (IMPORTANT!)
2. Copy `uImage` to Nook's boot partition
3. Reboot and enjoy your medieval writing experience

Detailed instructions: [Installation Guide](docs/installation.md)

## Documentation

- 📚 [Testing Overview](docs/testing-overview.md) - Complete testing guide
- 🧪 [Test Documentation](docs/test-documentation.md) - Detailed test reference
- ✍️ [Writing Tests](docs/writing-tests.md) - How to add new tests
- 🐳 [Docker Testing](docs/docker-testing.md) - Container-based testing
- 🔧 [CI/CD Integration](docs/ci-integration.md) - Automation setup

## Project Structure

```
nst-kernel/
├── src/                    # Kernel source with QuillKernel patches
├── arch/                   # Architecture-specific code
├── test/                   # Comprehensive test suite
│   ├── verify-build-simple.sh
│   ├── test-usb.sh
│   ├── test-eink.sh
│   └── ... (12 test scripts)
├── docs/                   # Documentation
├── config/                 # Configuration files
└── quillkernel-branding.patch
```

## Test Suite

QuillKernel includes a professional-grade test suite:

- **Build Verification**: Ensures patches and config are correct
- **Static Analysis**: Catches bugs before compilation
- **Hardware Tests**: USB, E-ink, memory testing
- **Software Tests**: /proc interface, module validation
- **Performance Tests**: Boot time, memory usage, benchmarks

All tests handle missing hardware gracefully with clear [SKIP] messages.

## Contributing

1. Fork the repository
2. Create your feature branch
3. Run tests: `./test/verify-build-simple.sh`
4. Commit with conventional format: `feat: add new feature`
5. Push and create Pull Request

## Credits

Based on:
- Original B&N kernel sources
- USB host patches by staylo
- MUSB fixes from kernel.org
- Community contributions from XDA Forums

Medieval theme and QuillKernel modifications by the Derpy Court Jester 🃏

## License

GPL v2 (as per Linux kernel requirements)

---

*"A kernel tested is a manuscript preserved!"* - Ancient Scribal Wisdom