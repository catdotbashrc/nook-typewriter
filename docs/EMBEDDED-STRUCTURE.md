# Embedded Project Structure

## Overview

The Nook Typewriter project has been reorganized into an embedded-focused structure that clearly separates source code, build artifacts, and deployment files.

## Directory Structure

```
nook-typewriter/
├── firmware/           # Everything that runs on the Nook
├── source/            # Source code for building firmware
│   └── kernel/
│       ├── nst-kernel-base/  # Git submodule (kernel source)
│       └── quillkernel/      # Our medieval kernel modules
├── build/             # Build system
├── tools/             # Development tools
├── releases/          # Ready-to-flash images
└── docs/              # Documentation
```

## Git Submodule

The kernel source is maintained as a git submodule at:
- **Path**: `source/kernel/nst-kernel-base`
- **Repository**: https://github.com/catdotbashrc/nst-kernel.git

### Working with the Submodule

```bash
# Clone with submodules
git clone --recursive https://github.com/yourusername/nook-typewriter.git

# Or if already cloned
git submodule init
git submodule update

# Update submodule to latest
cd source/kernel/nst-kernel-base
git pull origin master
cd ../../..
git add source/kernel/nst-kernel-base
git commit -m "Update kernel submodule"
```

## Build System

The project uses a Makefile-based build system:

```bash
# Build everything
make firmware

# Build specific components
make kernel     # Build kernel with QuillKernel
make rootfs     # Build root filesystem
make boot       # Prepare boot files

# Create SD card image
make image

# Create release
make release
```

## Firmware Output

After building, the `firmware/` directory contains everything needed for the SD card:

```
firmware/
├── kernel/         # Kernel and modules
│   ├── uImage     # Kernel image
│   └── modules/   # Kernel modules
├── rootfs/        # Complete filesystem
└── boot/          # Boot partition files
```

## Development Workflow

1. **Make changes** in `source/`
2. **Build** with `make firmware`
3. **Test** with `make docker-test`
4. **Create image** with `make image`
5. **Deploy** with `make install`

## Migration from Old Structure

If you have the old structure, run:
```bash
./migrate-to-embedded-structure.sh
```

This will reorganize files into the new embedded structure without deleting the originals.

## Key Benefits

- **Clear separation**: Source vs. built artifacts
- **Embedded focus**: Structure matches target device
- **Simple builds**: One command builds everything
- **Git-friendly**: Submodule for kernel, main repo for our code

---

*"By quill and candlelight, we organize for clarity"* 📜🏗️