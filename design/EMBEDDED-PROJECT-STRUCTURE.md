# Nook Typewriter - Embedded Project Structure

## Overview

A simplified, embedded-focused project structure that clearly shows this is firmware for an existing hardware device.

## Simplified Project Structure

```text
nook-typewriter/
├── firmware/                   # Everything that runs on the Nook
│   ├── kernel/                # Linux kernel with QuillKernel
│   │   ├── uImage            # Compiled kernel image
│   │   ├── modules/          # Kernel modules
│   │   │   └── squireos.ko   # QuillKernel module
│   │   └── config            # Kernel configuration
│   │
│   ├── rootfs/               # Complete root filesystem
│   │   ├── bin/             # Essential binaries
│   │   ├── etc/             # System configuration
│   │   │   ├── init.d/      # Startup scripts
│   │   │   └── nook.conf    # Main config file
│   │   ├── lib/             # Libraries and kernel modules
│   │   ├── usr/             # User programs
│   │   │   ├── bin/         # User binaries
│   │   │   └── local/       # Custom scripts
│   │   │       ├── bin/     # Our custom programs
│   │   │       │   ├── nook-menu.sh
│   │   │       │   ├── jester-daemon.sh
│   │   │       │   └── common.sh
│   │   │       └── share/   # Shared resources
│   │   │           ├── ascii/  # Jester art
│   │   │           └── vim/    # Vim configs
│   │   └── root/            # User home directory
│   │       ├── notes/       # Writing storage
│   │       ├── drafts/      # Work in progress
│   │       └── .vimrc       # Vim configuration
│   │
│   └── boot/                 # Boot partition contents
│       ├── uImage           # Kernel image
│       ├── uRamdisk         # Initial ramdisk
│       └── uEnv.txt         # Boot environment
│
├── source/                    # Source code for building firmware
│   ├── kernel/               # Kernel source
│   │   ├── nst-kernel-base/ # Base Nook kernel
│   │   └── quillkernel/     # Our kernel modules
│   │       ├── Makefile
│   │       └── src/
│   │           ├── squireos_core.c
│   │           ├── jester.c
│   │           ├── typewriter.c
│   │           └── wisdom.c
│   │
│   ├── scripts/              # System scripts source
│   │   ├── boot/            # Boot sequence
│   │   │   └── boot-jester.sh
│   │   ├── menu/            # Menu system
│   │   │   └── nook-menu.sh
│   │   ├── services/        # Background services
│   │   │   ├── jester-daemon.sh
│   │   │   └── health-check.sh
│   │   └── lib/             # Shared libraries
│   │       └── common.sh
│   │
│   └── configs/              # Configuration files
│       ├── vim/             # Vim setup
│       │   ├── vimrc
│       │   └── colors/
│       ├── system/          # System configs
│       │   ├── fstab
│       │   └── sysctl.conf
│       └── ascii/           # ASCII art
│           └── jester/
│
├── build/                     # Build system
│   ├── docker/               # Build environments
│   │   ├── kernel.dockerfile # Kernel build environment
│   │   └── rootfs.dockerfile # Rootfs build environment
│   │
│   ├── scripts/              # Build scripts
│   │   ├── build-all.sh     # Master build script
│   │   ├── build-kernel.sh  # Kernel builder
│   │   ├── build-rootfs.sh  # Rootfs builder
│   │   └── create-image.sh  # SD card image creator
│   │
│   └── config/               # Build configurations
│       ├── kernel.config    # Kernel config
│       └── packages.list    # Rootfs packages
│
├── tools/                     # Development tools
│   ├── deploy/               # Deployment tools
│   │   ├── flash-sd.sh      # SD card flasher
│   │   ├── backup-nook.sh   # Backup original firmware
│   │   └── verify-sd.sh     # Verify SD card
│   │
│   ├── debug/                # Debugging tools
│   │   ├── serial-console.sh # Serial connection
│   │   └── extract-logs.sh   # Log extraction
│   │
│   └── test/                 # Testing tools
│       ├── test-in-docker.sh # Docker testing
│       └── qemu-test.sh      # QEMU emulation
│
├── releases/                  # Ready-to-flash images
│   ├── nook-typewriter-v1.0.0.img
│   ├── changelog.md
│   └── sha256sums.txt
│
├── docs/                      # Documentation
│   ├── README.md            # Main documentation
│   ├── INSTALL.md           # Installation guide
│   ├── BUILD.md             # Build instructions
│   ├── HARDWARE.md          # Hardware requirements
│   └── TROUBLESHOOTING.md   # Common issues
│
├── Makefile                  # Top-level build commands
├── VERSION                   # Version file
└── LICENSE                   # License file
```

## Key Differences from Previous Structure

### What Changed

1. **Clear Firmware Focus**: Everything that goes on the device is in `firmware/`
2. **Source Separation**: Source code separate from built artifacts
3. **Single Module**: QuillKernel is now one integrated module
4. **Flat Script Structure**: Scripts organized by function, not patterns
5. **Build Artifacts**: Clear separation of build outputs

### Why This is Better for Embedded

- **Obvious Output**: The `firmware/` directory IS what goes on the SD card
- **Clear Build Flow**: source/ → build/ → firmware/ → releases/
- **Hardware-Centric**: Structure matches SD card layout
- **Simple to Understand**: No abstract patterns, just files on a device

## Build System

### Makefile Targets

```makefile
# Top-level Makefile
VERSION := $(shell cat VERSION)
IMAGE_NAME := nook-typewriter-$(VERSION).img

.PHONY: all clean kernel rootfs firmware image release

all: firmware

firmware: kernel rootfs boot
	@echo "Firmware ready in firmware/"

kernel:
	@echo "Building kernel..."
	./build/scripts/build-kernel.sh

rootfs:
	@echo "Building root filesystem..."
	./build/scripts/build-rootfs.sh

boot:
	@echo "Preparing boot files..."
	cp firmware/kernel/uImage firmware/boot/
	./build/scripts/create-uRamdisk.sh

image: firmware
	@echo "Creating SD card image..."
	./build/scripts/create-image.sh $(IMAGE_NAME)

release: image
	@echo "Creating release..."
	mv $(IMAGE_NAME) releases/
	cd releases && sha256sum $(IMAGE_NAME) > sha256sums.txt

clean:
	rm -rf firmware/kernel/uImage
	rm -rf firmware/rootfs/usr/local/bin/*
	rm -rf releases/*.img

install: image
	@echo "Ready to flash to SD card"
	@echo "Run: sudo ./tools/deploy/flash-sd.sh /dev/sdX releases/$(IMAGE_NAME)"
```

## Build Workflow

### 1. Kernel Build

```bash
#!/bin/bash
# build/scripts/build-kernel.sh

# Build kernel with integrated QuillKernel
cd source/kernel/nst-kernel-base
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- uImage

# Copy kernel module source
cp -r ../quillkernel drivers/squireos

# Build modules
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- modules

# Install to firmware directory
cp arch/arm/boot/uImage ../../../firmware/kernel/
cp drivers/squireos/squireos.ko ../../../firmware/kernel/modules/
```

### 2. Root Filesystem Build

```bash
#!/bin/bash
# build/scripts/build-rootfs.sh

# Start with base Debian
docker run --rm -v $(pwd)/firmware/rootfs:/rootfs debian:bullseye-slim \
    bash -c "apt-get update && apt-get install -y --no-install-recommends \
        vim busybox perl"

# Copy our scripts
cp -r source/scripts/* firmware/rootfs/usr/local/bin/

# Copy configurations
cp source/configs/vim/vimrc firmware/rootfs/root/.vimrc
cp -r source/configs/vim/colors firmware/rootfs/usr/local/share/vim/

# Copy ASCII art
cp -r source/configs/ascii firmware/rootfs/usr/local/share/

# Set permissions
chmod +x firmware/rootfs/usr/local/bin/*.sh
```

### 3. SD Card Image Creation

```bash
#!/bin/bash
# build/scripts/create-image.sh

IMAGE=$1
SIZE=2G

# Create image file
dd if=/dev/zero of=$IMAGE bs=1M count=2048

# Partition image
sfdisk $IMAGE << EOF
,100M,c,*
,
EOF

# Format and populate
LOOP=$(losetup -f)
losetup -P $LOOP $IMAGE

# Boot partition (FAT32)
mkfs.vfat ${LOOP}p1
mount ${LOOP}p1 /mnt/boot
cp -r firmware/boot/* /mnt/boot/
umount /mnt/boot

# Root partition (ext4)
mkfs.ext4 ${LOOP}p2
mount ${LOOP}p2 /mnt/root
cp -r firmware/rootfs/* /mnt/root/
umount /mnt/root

losetup -d $LOOP
```

## Deployment Workflow

### For Users

```bash
# 1. Download release
wget https://github.com/you/nook-typewriter/releases/download/v1.0.0/nook-typewriter-v1.0.0.img

# 2. Flash to SD card
sudo dd if=nook-typewriter-v1.0.0.img of=/dev/sdX bs=4M status=progress

# 3. Insert SD card into Nook
# 4. Power on and enjoy writing!
```

### For Developers

```bash
# 1. Make changes in source/
vim source/scripts/menu/nook-menu.sh

# 2. Build firmware
make clean
make firmware

# 3. Test in Docker
docker run -it -v $(pwd)/firmware/rootfs:/data/debian debian:bullseye-slim \
    /data/debian/usr/local/bin/nook-menu.sh

# 4. Create release image
make release

# 5. Flash and test on real hardware
sudo ./tools/deploy/flash-sd.sh /dev/sdX releases/nook-typewriter-dev.img
```

## Directory Purposes

### Core Directories

- **`firmware/`** - The actual files that run on the Nook
- **`source/`** - Source code and configurations
- **`build/`** - Build system and scripts
- **`tools/`** - Development and deployment tools
- **`releases/`** - Ready-to-use SD card images
- **`docs/`** - User and developer documentation

### Why This Structure Works

1. **Clear Output**: `firmware/` mirrors SD card structure exactly
2. **Simple Build**: `make firmware` builds everything
3. **Easy Deploy**: `make install` creates flashable image
4. **Obvious Purpose**: Each directory has one clear purpose
5. **Hardware-Focused**: Structure matches embedded system layout

## Migration from Current Structure

### Phase 1: Reorganize Files

```bash
# Create new structure
mkdir -p firmware/{kernel,rootfs,boot}
mkdir -p source/{kernel,scripts,configs}
mkdir -p build/{docker,scripts,config}
mkdir -p tools/{deploy,debug,test}

# Move kernel source
mv quillkernel source/kernel/
mv nst-kernel-base source/kernel/

# Move scripts
mv config/scripts/* source/scripts/

# Move configs
mv config/* source/configs/
```

### Phase 2: Update Build System

```bash
# Update Docker files
mv *.dockerfile build/docker/

# Create unified Makefile
vim Makefile  # Add targets shown above

# Update build scripts
vim build/scripts/build-all.sh
```

### Phase 3: Test New Structure

```bash
# Build everything
make clean
make firmware

# Test in Docker
make test

# Create image
make image
```

## Benefits of This Structure

### For Users
- **Simple**: Download image, flash SD card, done
- **Clear**: One image file contains everything
- **Reliable**: Tested, versioned releases

### For Developers
- **Organized**: Clear separation of source and build
- **Efficient**: Simple make commands
- **Testable**: Easy Docker and QEMU testing

### For the Project
- **Embedded-Focused**: Structure matches target platform
- **Maintainable**: Clear directory purposes
- **Scalable**: Easy to add new components

---

*"Simplicity is the ultimate sophistication in embedded systems"* ⚙️📟