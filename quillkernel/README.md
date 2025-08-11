# QuillKernel - Medieval-Themed Nook Simple Touch Kernel

A custom Linux kernel 2.6.29 for Barnes & Noble Nook Simple Touch, built on felixhaedicke's kernel with USB host and fast display support, enhanced with medieval theming and typewriter features.

## Base Kernel

Built on top of [felixhaedicke/nst-kernel](https://github.com/felixhaedicke/nst-kernel) which provides:
- USB host mode fixes (essential for keyboards)
- Fast E-ink display mode support
- Based on B&N firmware 1.2.x sources

## QuillKernel Enhancements

### 🏰 Medieval Kernel Modules
- `/proc/squireos/` - Main medieval interface
- `/proc/squireos/jester` - ASCII art companion
- `/proc/squireos/wisdom` - Rotating writing quotes
- `/proc/squireos/typewriter/stats` - Writing statistics

### ⌨️ Typewriter Features
- Keystroke tracking at kernel level
- Word counting algorithm
- Writing session management
- Achievement system (Apprentice → Grand Chronicler)

### 🎨 Boot Experience
- Medieval boot messages
- Jester ASCII art during startup
- "By quill and candlelight" motto
- Writer-friendly error messages

## Directory Structure

```
quillkernel/
├── README.md                     # This file
├── Dockerfile                    # Build environment
├── modules/                      # Our kernel modules
│   ├── squireos_core.c          # Main /proc interface
│   ├── jester.c                 # Jester personality
│   ├── typewriter.c             # Writing statistics
│   ├── wisdom.c                 # Quote system
│   └── Makefile                 # Module build
├── patches/                      # Clean patches to apply
│   ├── 01-medieval-boot.patch   # Boot messages
│   └── 02-squireos-hooks.patch  # Kernel hooks
├── config/
│   └── quillkernel_defconfig    # Our kernel config
└── build.sh                      # Build script
```

## Building

```bash
# Using Docker (recommended)
docker build -t quillkernel-builder .
docker run -v $(pwd):/build quillkernel-builder

# Manual build
./build.sh
```

## Installation

The built kernel (`uImage`) replaces the kernel on your Nook's SD card boot partition.

## Philosophy

Every feature serves writers. No distractions, just words and whimsy.