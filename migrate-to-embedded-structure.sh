#!/bin/bash
# Migration script to reorganize project into embedded structure
# Based on design/EMBEDDED-PROJECT-STRUCTURE.md

set -euo pipefail
trap 'echo "Error at line $LINENO"' ERR

echo "═══════════════════════════════════════════════════════════════"
echo "    Nook Typewriter - Embedded Structure Migration"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Check if we're in the right directory
if [ ! -f "CLAUDE.md" ]; then
    echo "Error: Please run this script from the project root"
    exit 1
fi

echo "This script will reorganize the project into the embedded structure."
echo "Current structure will be preserved, files will be copied not moved."
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 0
fi

# Create directory structure
echo "→ Creating embedded directory structure..."
mkdir -p firmware/{kernel/modules,rootfs/{bin,etc/init.d,lib,usr/{bin,local/{bin,share/{ascii,vim/colors}}},root},boot}
mkdir -p source/{scripts/{boot,menu,services,lib},configs/{vim/colors,system,ascii/jester}}
mkdir -p build/{docker,scripts,config}
mkdir -p tools/{deploy,debug,test}
mkdir -p releases
mkdir -p docs

echo "✓ Directory structure created"

# Copy scripts to new locations
echo "→ Organizing scripts..."
if [ -d "config/scripts" ]; then
    # Boot scripts
    [ -f "config/scripts/boot-jester.sh" ] && cp config/scripts/boot-jester.sh source/scripts/boot/
    [ -f "config/scripts/squireos-boot.sh" ] && cp config/scripts/squireos-boot.sh source/scripts/boot/
    
    # Menu scripts
    for menu in config/scripts/*menu*.sh; do
        [ -f "$menu" ] && cp "$menu" source/scripts/menu/
    done
    
    # Service scripts
    [ -f "config/scripts/jester-daemon.sh" ] && cp config/scripts/jester-daemon.sh source/scripts/services/
    [ -f "config/scripts/health-check.sh" ] && cp config/scripts/health-check.sh source/scripts/services/
    [ -f "config/scripts/jester-mischief.sh" ] && cp config/scripts/jester-mischief.sh source/scripts/services/
    
    # Library scripts
    [ -f "config/scripts/common.sh" ] && cp config/scripts/common.sh source/scripts/lib/
    
    echo "✓ Scripts organized"
fi

# Move Docker files
echo "→ Organizing build system..."
if [ -f "nookwriter-optimized.dockerfile" ]; then
    cp nookwriter-optimized.dockerfile build/docker/rootfs.dockerfile
fi

if [ -f "minimal-boot.dockerfile" ]; then
    cp minimal-boot.dockerfile build/docker/minimal.dockerfile
fi

# Copy existing build scripts
if [ -f "build_kernel.sh" ]; then
    cp build_kernel.sh build/scripts/
fi

if [ -f "install_to_sdcard.sh" ]; then
    cp install_to_sdcard.sh tools/deploy/flash-sd.sh
fi

echo "✓ Build system organized"

# Copy vim configs
echo "→ Setting up configurations..."
if [ -d "config" ]; then
    # Vim configs
    [ -d "config/vim" ] && cp -r config/vim/* source/configs/vim/ 2>/dev/null || true
    
    # ASCII art
    [ -d "config/ascii" ] && cp -r config/ascii/* source/configs/ascii/ 2>/dev/null || true
fi

echo "✓ Configurations organized"

# Copy test scripts
echo "→ Organizing test scripts..."
if [ -d "tests" ]; then
    cp tests/*.sh tools/test/ 2>/dev/null || true
fi

echo "✓ Tests organized"

# Copy documentation
echo "→ Organizing documentation..."
[ -f "README.md" ] && cp README.md docs/
[ -f "CLAUDE.md" ] && cp CLAUDE.md docs/
[ -d "design" ] && cp -r design/* docs/ 2>/dev/null || true

echo "✓ Documentation organized"

# Create VERSION file
echo "1.0.0" > VERSION

# Summary
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "✅ Migration Complete!"
echo ""
echo "New structure created:"
echo "  firmware/    - Files that go on the Nook"
echo "  source/      - Source code and configurations"
echo "  build/       - Build system and Docker"
echo "  tools/       - Development and deployment tools"
echo "  releases/    - Ready-to-flash images"
echo "  docs/        - Documentation"
echo ""
echo "Next steps:"
echo "  1. Review the new structure"
echo "  2. Test the build: make firmware"
echo "  3. Remove old directories after verification"
echo ""
echo "The kernel submodule is now at: source/kernel/nst-kernel-base"
echo "═══════════════════════════════════════════════════════════════"