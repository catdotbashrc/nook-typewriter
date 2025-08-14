#!/bin/bash
# Migration script to reorganize project to embedded structure
# This script helps transition from current structure to simplified embedded layout

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Project root (one level up from tools/)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo -e "${GREEN}=== Nook Typewriter Structure Migration ===${NC}"
echo "Migrating to simplified embedded project structure..."
echo "Project root: $PROJECT_ROOT"
echo

# Confirmation
read -p "This will reorganize your project structure. Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Migration cancelled."
    exit 1
fi

# Create new directory structure
echo -e "${YELLOW}Creating new directory structure...${NC}"

# Firmware directories
mkdir -p "$PROJECT_ROOT/firmware/kernel/modules"
mkdir -p "$PROJECT_ROOT/firmware/rootfs/"{bin,etc/init.d,lib,usr/bin,usr/local/bin,usr/local/share/ascii,usr/local/share/vim/colors,root}
mkdir -p "$PROJECT_ROOT/firmware/boot"

# Source directories
mkdir -p "$PROJECT_ROOT/source/kernel"
mkdir -p "$PROJECT_ROOT/source/scripts/"{boot,menu,services,lib}
mkdir -p "$PROJECT_ROOT/source/configs/"{vim/colors,system,ascii/jester}

# Build directories
mkdir -p "$PROJECT_ROOT/build/"{docker,scripts,config}

# Tools directories (keep existing tools/ but reorganize)
mkdir -p "$PROJECT_ROOT/tools/"{deploy,debug,test}

# Releases directory
mkdir -p "$PROJECT_ROOT/releases"

echo -e "${GREEN}✓ Directory structure created${NC}"

# Move kernel source
echo -e "${YELLOW}Migrating kernel source...${NC}"

if [[ -d "$PROJECT_ROOT/quillkernel" ]]; then
    cp -r "$PROJECT_ROOT/quillkernel" "$PROJECT_ROOT/source/kernel/"
    echo "  Moved quillkernel → source/kernel/quillkernel"
fi

if [[ -d "$PROJECT_ROOT/nst-kernel-base" ]]; then
    cp -r "$PROJECT_ROOT/nst-kernel-base" "$PROJECT_ROOT/source/kernel/"
    echo "  Moved nst-kernel-base → source/kernel/nst-kernel-base"
fi

# Move scripts to organized structure
echo -e "${YELLOW}Organizing scripts...${NC}"

if [[ -d "$PROJECT_ROOT/config/scripts" ]]; then
    # Boot scripts
    [[ -f "$PROJECT_ROOT/config/scripts/boot-jester.sh" ]] && \
        cp "$PROJECT_ROOT/config/scripts/boot-jester.sh" "$PROJECT_ROOT/source/scripts/boot/"
    [[ -f "$PROJECT_ROOT/config/scripts/squireos-boot.sh" ]] && \
        cp "$PROJECT_ROOT/config/scripts/squireos-boot.sh" "$PROJECT_ROOT/source/scripts/boot/"
    
    # Menu scripts
    [[ -f "$PROJECT_ROOT/config/scripts/nook-menu.sh" ]] && \
        cp "$PROJECT_ROOT/config/scripts/nook-menu.sh" "$PROJECT_ROOT/source/scripts/menu/"
    [[ -f "$PROJECT_ROOT/config/scripts/nook-menu-plugin.sh" ]] && \
        cp "$PROJECT_ROOT/config/scripts/nook-menu-plugin.sh" "$PROJECT_ROOT/source/scripts/menu/"
    [[ -f "$PROJECT_ROOT/config/scripts/squire-menu.sh" ]] && \
        cp "$PROJECT_ROOT/config/scripts/squire-menu.sh" "$PROJECT_ROOT/source/scripts/menu/"
    
    # Service scripts
    [[ -f "$PROJECT_ROOT/config/scripts/jester-daemon.sh" ]] && \
        cp "$PROJECT_ROOT/config/scripts/jester-daemon.sh" "$PROJECT_ROOT/source/scripts/services/"
    [[ -f "$PROJECT_ROOT/config/scripts/health-check.sh" ]] && \
        cp "$PROJECT_ROOT/config/scripts/health-check.sh" "$PROJECT_ROOT/source/scripts/services/"
    
    # Library scripts
    [[ -f "$PROJECT_ROOT/config/scripts/common.sh" ]] && \
        cp "$PROJECT_ROOT/config/scripts/common.sh" "$PROJECT_ROOT/source/scripts/lib/"
    
    echo -e "${GREEN}✓ Scripts organized${NC}"
fi

# Move configurations
echo -e "${YELLOW}Migrating configurations...${NC}"

if [[ -d "$PROJECT_ROOT/config" ]]; then
    # Vim configs
    [[ -f "$PROJECT_ROOT/config/vimrc" ]] && \
        cp "$PROJECT_ROOT/config/vimrc" "$PROJECT_ROOT/source/configs/vim/"
    [[ -f "$PROJECT_ROOT/config/vimrc-writer" ]] && \
        cp "$PROJECT_ROOT/config/vimrc-writer" "$PROJECT_ROOT/source/configs/vim/"
    [[ -d "$PROJECT_ROOT/config/colors" ]] && \
        cp -r "$PROJECT_ROOT/config/colors"/* "$PROJECT_ROOT/source/configs/vim/colors/" 2>/dev/null || true
    
    # System configs
    [[ -d "$PROJECT_ROOT/config/system" ]] && \
        cp -r "$PROJECT_ROOT/config/system"/* "$PROJECT_ROOT/source/configs/system/" 2>/dev/null || true
    
    # ASCII art
    [[ -d "$PROJECT_ROOT/config/splash" ]] && \
        cp -r "$PROJECT_ROOT/config/splash"/* "$PROJECT_ROOT/source/configs/ascii/jester/" 2>/dev/null || true
    
    echo -e "${GREEN}✓ Configurations migrated${NC}"
fi

# Move Docker files
echo -e "${YELLOW}Moving Docker build files...${NC}"

for dockerfile in "$PROJECT_ROOT"/*.dockerfile; do
    if [[ -f "$dockerfile" ]]; then
        filename=$(basename "$dockerfile")
        cp "$dockerfile" "$PROJECT_ROOT/build/docker/"
        echo "  Moved $filename → build/docker/"
    fi
done

# Move QuillKernel Dockerfile if exists
[[ -f "$PROJECT_ROOT/quillkernel/Dockerfile" ]] && \
    cp "$PROJECT_ROOT/quillkernel/Dockerfile" "$PROJECT_ROOT/build/docker/kernel.dockerfile"

echo -e "${GREEN}✓ Docker files moved${NC}"

# Create essential build scripts
echo -e "${YELLOW}Creating build scripts...${NC}"

# Main build script
cat > "$PROJECT_ROOT/build/scripts/build-all.sh" << 'EOF'
#!/bin/bash
# Master build script for Nook Typewriter firmware

set -euo pipefail

echo "Building Nook Typewriter firmware..."

# Build kernel
./build/scripts/build-kernel.sh

# Build rootfs
./build/scripts/build-rootfs.sh

# Create boot files
./build/scripts/create-boot.sh

echo "Build complete! Firmware ready in firmware/"
EOF

chmod +x "$PROJECT_ROOT/build/scripts/build-all.sh"

# Kernel build script
cat > "$PROJECT_ROOT/build/scripts/build-kernel.sh" << 'EOF'
#!/bin/bash
# Build kernel with QuillKernel modules

set -euo pipefail

echo "Building kernel..."

# Use Docker to build kernel
docker build -f build/docker/kernel.dockerfile -t nook-kernel-builder .

# Extract built kernel
docker run --rm -v $(pwd)/firmware/kernel:/output nook-kernel-builder \
    bash -c "cp /build/uImage /output/ && cp /build/modules/*.ko /output/modules/"

echo "Kernel build complete"
EOF

chmod +x "$PROJECT_ROOT/build/scripts/build-kernel.sh"

echo -e "${GREEN}✓ Build scripts created${NC}"

# Create simplified Makefile
echo -e "${YELLOW}Creating Makefile...${NC}"

cat > "$PROJECT_ROOT/Makefile" << 'EOF'
# Nook Typewriter - Embedded Linux Distribution
VERSION := 1.0.0
IMAGE_NAME := nook-typewriter-$(VERSION).img

.PHONY: all clean kernel rootfs firmware image release help

help:
	@echo "Nook Typewriter Build System"
	@echo "============================"
	@echo "make firmware  - Build complete firmware"
	@echo "make kernel    - Build kernel only"
	@echo "make rootfs    - Build root filesystem only"
	@echo "make image     - Create SD card image"
	@echo "make release   - Create release package"
	@echo "make clean     - Clean build artifacts"

all: firmware

firmware: kernel rootfs
	@echo "Firmware ready in firmware/"

kernel:
	@echo "Building kernel..."
	./build/scripts/build-kernel.sh

rootfs:
	@echo "Building root filesystem..."
	./build/scripts/build-rootfs.sh

image: firmware
	@echo "Creating SD card image..."
	./build/scripts/create-image.sh $(IMAGE_NAME)

release: image
	@echo "Creating release $(VERSION)..."
	mv $(IMAGE_NAME) releases/
	cd releases && sha256sum $(IMAGE_NAME) > $(IMAGE_NAME).sha256

clean:
	rm -rf firmware/kernel/*.ko
	rm -rf firmware/rootfs/usr/local/bin/*
	rm -f releases/*.img

.DEFAULT_GOAL := help
EOF

echo -e "${GREEN}✓ Makefile created${NC}"

# Create VERSION file
echo "1.0.0" > "$PROJECT_ROOT/VERSION"

# Move existing tests to new location
if [[ -d "$PROJECT_ROOT/tests" ]]; then
    echo -e "${YELLOW}Moving tests...${NC}"
    cp -r "$PROJECT_ROOT/tests"/* "$PROJECT_ROOT/tools/test/" 2>/dev/null || true
    echo -e "${GREEN}✓ Tests moved${NC}"
fi

# Create deployment tools
echo -e "${YELLOW}Creating deployment tools...${NC}"

cat > "$PROJECT_ROOT/tools/deploy/flash-sd.sh" << 'EOF'
#!/bin/bash
# Flash Nook Typewriter image to SD card

set -euo pipefail

if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <device> <image>"
    echo "Example: $0 /dev/sdb nook-typewriter-v1.0.0.img"
    exit 1
fi

DEVICE=$1
IMAGE=$2

if [[ ! -b "$DEVICE" ]]; then
    echo "Error: $DEVICE is not a block device"
    exit 1
fi

if [[ ! -f "$IMAGE" ]]; then
    echo "Error: Image file $IMAGE not found"
    exit 1
fi

echo "WARNING: This will erase all data on $DEVICE"
read -p "Continue? (y/N) " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled"
    exit 1
fi

echo "Flashing $IMAGE to $DEVICE..."
sudo dd if="$IMAGE" of="$DEVICE" bs=4M status=progress conv=fsync

echo "Flash complete! You can now insert the SD card into your Nook."
EOF

chmod +x "$PROJECT_ROOT/tools/deploy/flash-sd.sh"

echo -e "${GREEN}✓ Deployment tools created${NC}"

# Create .gitignore for new structure
echo -e "${YELLOW}Updating .gitignore...${NC}"

cat > "$PROJECT_ROOT/.gitignore" << 'EOF'
# Build artifacts
firmware/kernel/uImage
firmware/kernel/modules/*.ko
firmware/rootfs/usr/local/bin/*
firmware/boot/*

# Release images
releases/*.img
releases/*.sha256

# Build temporary files
build/tmp/
*.o
*.ko
*.mod.c
*.mod
*.cmd

# Docker
.dockerignore

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Logs
*.log

# Backup files
*.bak
*~
EOF

echo -e "${GREEN}✓ .gitignore updated${NC}"

# Summary
echo
echo -e "${GREEN}=== Migration Complete ===${NC}"
echo
echo "New structure created. Your original files are preserved."
echo
echo "Next steps:"
echo "1. Review the new structure in:"
echo "   - firmware/  (output files)"
echo "   - source/    (source code)"
echo "   - build/     (build system)"
echo
echo "2. Test the build:"
echo "   make firmware"
echo
echo "3. Once verified, you can remove old directories:"
echo "   - config/"
echo "   - quillkernel/"
echo "   - nst-kernel-base/"
echo
echo "4. Update your git repository:"
echo "   git add ."
echo "   git commit -m 'Migrate to embedded project structure'"
echo
echo -e "${GREEN}Happy writing!${NC} 🕯️📜"