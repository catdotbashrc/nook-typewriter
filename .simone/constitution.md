# Project Constitution

## Project
- **Name**: Nook Typewriter
- **Description**: Transform a $20 Nook e-reader into a distraction-free writing device

## Tech Stack
- **Language**: C, Shell Script
- **Framework**: Linux Kernel 2.6.29, Embedded Debian
- **Package Manager**: make, Docker

## Structure
```
source/         - Kernel and system implementation
tests/          - Comprehensive test suite
docs/           - Medieval-themed documentation
build/          - Cross-compilation environment
firmware/       - Boot and hardware configs
```

## Essential Commands
```bash
# Build everything
make firmware

# Build kernel only
./build_kernel.sh

# Run tests
make test

# Deploy to SD card
make install
```

## Critical Rules
- **NEVER violate 160MB sacred writing space** - This memory is reserved for writers
- **Every feature must help writers write** - No distractions or unnecessary features
- **Test before hardware deployment** - Always run smoke tests before SD card install
- **Maintain medieval theme** - Keep the whimsy and jester spirit alive
- **Memory budget is sacred** - OS must stay under 96MB total
- **E-Ink limitations are features** - Embrace slow refresh as mindful interaction
- **Safety-first development** - Input validation and error handling in all scripts

---

*"By quill and candlelight, we code for those who write"* 🕯️📜