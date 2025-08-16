# Modern Packager for Nook Typewriter
# Purpose: Efficiently package scripts, configs, and create SD card images
# Uses modern tools for speed while maintaining Lenny compatibility for output
# This handles everything EXCEPT kernel/binary compilation

FROM debian:bookworm-slim AS packager

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install modern packaging and image creation tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    # File manipulation and archiving
    rsync \
    tar \
    gzip \
    xz-utils \
    zip \
    # Filesystem tools
    e2fsprogs \
    dosfstools \
    parted \
    # Image creation and manipulation
    qemu-utils \
    # For creating boot scripts
    u-boot-tools \
    # Text processing (for script validation)
    shellcheck \
    # Git for version info
    git \
    # Basic utilities
    file \
    findutils \
    grep \
    sed \
    gawk \
    # For creating squashfs if needed
    squashfs-tools \
    # For potential future: creating ISOs
    genisoimage \
    # Checksum tools
    coreutils \
    # Make for running Makefile targets
    make \
    # Python for any helper scripts
    python3-minimal \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /usr/share/doc/* \
    && rm -rf /usr/share/man/*

# Install specific tools for SD card image creation
RUN apt-get update && apt-get install -y --no-install-recommends \
    fdisk \
    kpartx \
    && rm -rf /var/lib/apt/lists/*

# Create working directories
WORKDIR /build
RUN mkdir -p \
    /build/input \
    /build/output \
    /build/temp \
    /build/scripts \
    /build/configs

# Add a helper script for creating SD card images
RUN cat > /usr/local/bin/create-sd-image.sh << 'EOF'
#!/bin/bash
set -euo pipefail

# Create SD card image for Nook Typewriter
# Usage: create-sd-image.sh <output.img> <size_mb>

OUTPUT="${1:-nook-typewriter.img}"
SIZE_MB="${2:-2048}"

echo "Creating ${SIZE_MB}MB SD card image: ${OUTPUT}"

# Create blank image
dd if=/dev/zero of="${OUTPUT}" bs=1M count="${SIZE_MB}" status=progress

# Create partitions (matching Nook layout)
# Partition 1: FAT32 boot (256MB)
# Partition 2: ext4 root (remaining space)
parted -s "${OUTPUT}" \
    mklabel msdos \
    mkpart primary fat32 1MiB 257MiB \
    mkpart primary ext4 257MiB 100% \
    set 1 boot on

echo "✓ SD card image created: ${OUTPUT}"
EOF
RUN chmod +x /usr/local/bin/create-sd-image.sh

# Add script packaging helper
RUN cat > /usr/local/bin/package-scripts.sh << 'EOF'
#!/bin/bash
set -euo pipefail

# Package Nook Typewriter scripts and configs
# Maintains compatibility with Debian Lenny target

SOURCE_DIR="${1:-/build/input}"
OUTPUT_DIR="${2:-/build/output}"

echo "═══════════════════════════════════════════"
echo "     Nook Typewriter Script Packager"
echo "     Target: Debian Lenny (glibc 2.7)"
echo "═══════════════════════════════════════════"

# Validate all shell scripts
echo "→ Validating shell scripts..."
find "${SOURCE_DIR}" -name "*.sh" -type f | while read -r script; do
    # Check for bashisms that won't work in Lenny's dash/bash
    if shellcheck --shell=bash --exclude=SC2039,SC3037 "$script"; then
        echo "  ✓ $(basename "$script")"
    else
        echo "  ⚠ $(basename "$script") has warnings"
    fi
done

# Package scripts maintaining structure
echo "→ Packaging scripts..."
cd "${SOURCE_DIR}"
tar czf "${OUTPUT_DIR}/nook-scripts.tar.gz" \
    --exclude="*.git*" \
    --exclude="*.o" \
    --exclude="*.ko" \
    scripts/ configs/ 2>/dev/null || true

# Create manifest
echo "→ Creating manifest..."
find scripts/ configs/ -type f 2>/dev/null | sort > "${OUTPUT_DIR}/manifest.txt"

echo "✓ Scripts packaged successfully"
echo "  Output: ${OUTPUT_DIR}/nook-scripts.tar.gz"
echo "  Files: $(wc -l < "${OUTPUT_DIR}/manifest.txt")"
EOF
RUN chmod +x /usr/local/bin/package-scripts.sh

# Add rootfs assembly helper
RUN cat > /usr/local/bin/assemble-rootfs.sh << 'EOF'
#!/bin/bash
set -euo pipefail

# Assemble root filesystem for Nook Typewriter
# Combines Lenny base with modern scripts

LENNY_BASE="${1:-/build/input/lenny-rootfs.tar.gz}"
SCRIPTS_PKG="${2:-/build/input/nook-scripts.tar.gz}"
OUTPUT_DIR="${3:-/build/output}"

echo "→ Assembling Nook Typewriter rootfs..."

# Create temp directory for assembly
TEMP_ROOT="/build/temp/rootfs"
mkdir -p "${TEMP_ROOT}"

# Extract Lenny base if provided
if [ -f "${LENNY_BASE}" ]; then
    echo "  Extracting Lenny base..."
    tar xzf "${LENNY_BASE}" -C "${TEMP_ROOT}"
fi

# Overlay scripts and configs
if [ -f "${SCRIPTS_PKG}" ]; then
    echo "  Adding scripts and configs..."
    tar xzf "${SCRIPTS_PKG}" -C "${TEMP_ROOT}/usr/local"
fi

# Create essential directories
mkdir -p "${TEMP_ROOT}/root/notes"
mkdir -p "${TEMP_ROOT}/root/drafts"
mkdir -p "${TEMP_ROOT}/root/scrolls"
mkdir -p "${TEMP_ROOT}/var/jesteros"

# Set proper permissions (compatible with old systems)
find "${TEMP_ROOT}" -name "*.sh" -exec chmod 755 {} \;

# Create final tarball
echo "  Creating final rootfs..."
cd "${TEMP_ROOT}"
tar czf "${OUTPUT_DIR}/nook-rootfs-complete.tar.gz" .

echo "✓ Rootfs assembled: ${OUTPUT_DIR}/nook-rootfs-complete.tar.gz"
echo "  Size: $(du -h "${OUTPUT_DIR}/nook-rootfs-complete.tar.gz" | cut -f1)"
EOF
RUN chmod +x /usr/local/bin/assemble-rootfs.sh

# Add validation script for Lenny compatibility
RUN cat > /usr/local/bin/validate-lenny-compat.sh << 'EOF'
#!/bin/bash
set -euo pipefail

# Validate scripts for Debian Lenny compatibility
# Checks for features not available in old bash/dash

echo "→ Checking Lenny compatibility..."

# Features to avoid (not in Lenny's bash 3.2/dash)
PROBLEMS=0

# Check for bash 4+ features
for file in "$@"; do
    if grep -qE '\[\[.*=~.*\]\]|declare -A|${!.*}|\$\(\(<.*>\)\)' "$file"; then
        echo "  ⚠ $file: Uses bash 4+ features"
        ((PROBLEMS++))
    fi
    
    # Check for modern coreutils features
    if grep -qE 'readlink -f|stat --format|date --iso' "$file"; then
        echo "  ⚠ $file: Uses modern coreutils"
        ((PROBLEMS++))
    fi
done

if [ $PROBLEMS -eq 0 ]; then
    echo "✓ All scripts compatible with Lenny"
else
    echo "⚠ Found $PROBLEMS compatibility issues"
fi

exit $PROBLEMS
EOF
RUN chmod +x /usr/local/bin/validate-lenny-compat.sh

# Create entrypoint script
RUN cat > /entrypoint.sh << 'EOF'
#!/bin/bash
set -euo pipefail

echo "═══════════════════════════════════════════════════════════════"
echo "           🏰 Nook Typewriter Modern Packager 🏰"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "Available commands:"
echo "  package-scripts.sh    - Package scripts and configs"
echo "  assemble-rootfs.sh    - Combine Lenny base with scripts"
echo "  create-sd-image.sh    - Create bootable SD card image"
echo "  validate-lenny-compat.sh - Check script compatibility"
echo ""
echo "Mount points:"
echo "  /build/input  - Source files"
echo "  /build/output - Generated packages"
echo ""

# If no command specified, run bash
if [ $# -eq 0 ]; then
    exec /bin/bash
else
    exec "$@"
fi
EOF
RUN chmod +x /entrypoint.sh

# Metadata
LABEL maintainer="Nook Typewriter Project" \
      description="Modern packaging tools for Nook Typewriter scripts and images" \
      version="1.0.0" \
      target="Debian Lenny compatibility"

# Set up volumes for input/output
VOLUME ["/build/input", "/build/output"]

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]