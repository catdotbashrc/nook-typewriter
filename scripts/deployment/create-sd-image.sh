#!/bin/bash
# ==============================================================================
# Nook Typewriter SD Card Image Builder
# Creates bootable SD card image (.img) for Nook Simple Touch
# ==============================================================================

set -euo pipefail

# Configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
readonly BUILD_DIR="${PROJECT_ROOT}/build"
readonly OUTPUT_DIR="${PROJECT_ROOT}/releases"
readonly FIRMWARE_DIR="${PROJECT_ROOT}/firmware"
readonly NST_KERNEL_DIR="${PROJECT_ROOT}/nst-kernel"

# Image settings
readonly IMAGE_SIZE_MB=512
readonly BOOT_SIZE_MB=100
readonly ROOT_SIZE_MB=400
readonly IMAGE_NAME="nook-typewriter-$(date +%Y%m%d).img"
readonly OUTPUT_IMAGE="${OUTPUT_DIR}/${IMAGE_NAME}"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Medieval themed messages
readonly JESTER_ASCII="
    .~\"~.~\"~.
   /  o   o  \\\\
  |  >  ◡  <  |
   \\  ___  /
    |~|♦|~|
"

# -----------------------------------------------------------------------------
# Helper Functions
# -----------------------------------------------------------------------------

log_info() {
    echo -e "${GREEN}→${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1" >&2
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

cleanup() {
    local exit_code=$?
    if [[ -n "${LOOP_DEVICE:-}" ]]; then
        log_info "Cleaning up loop devices..."
        sudo umount "${LOOP_DEVICE}p1" 2>/dev/null || true
        sudo umount "${LOOP_DEVICE}p2" 2>/dev/null || true
        sudo losetup -d "${LOOP_DEVICE}" 2>/dev/null || true
    fi
    if [[ -d "${MOUNT_BOOT:-}" ]]; then
        sudo umount "${MOUNT_BOOT}" 2>/dev/null || true
        sudo rm -rf "${MOUNT_BOOT}"
    fi
    if [[ -d "${MOUNT_ROOT:-}" ]]; then
        sudo umount "${MOUNT_ROOT}" 2>/dev/null || true
        sudo rm -rf "${MOUNT_ROOT}"
    fi
    if [[ ${exit_code} -ne 0 ]]; then
        log_error "Script failed with exit code ${exit_code}"
        [[ -f "${OUTPUT_IMAGE}" ]] && rm -f "${OUTPUT_IMAGE}"
    fi
}

check_requirements() {
    log_info "Checking requirements..."
    
    local missing_tools=()
    
    # Check for required tools
    for tool in parted mkfs.vfat mkfs.ext4 losetup dd gzip; do
        if ! command -v "${tool}" &> /dev/null; then
            missing_tools+=("${tool}")
        fi
    done
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log_error "Missing required tools: ${missing_tools[*]}"
        log_info "Install with: sudo apt-get install parted dosfstools e2fsprogs util-linux gzip"
        exit 1
    fi
    
    # Check for sudo access
    if ! sudo -n true 2>/dev/null; then
        log_warn "This script requires sudo access for loop devices and mounting"
        sudo true # Prompt for password
    fi
    
    log_success "All requirements met"
}

check_inputs() {
    log_info "Checking input files..."
    
    # Check for kernel
    local kernel_found=false
    if [[ -f "${NST_KERNEL_DIR}/build/uImage" ]]; then
        KERNEL_IMAGE="${NST_KERNEL_DIR}/build/uImage"
        kernel_found=true
    elif [[ -f "${FIRMWARE_DIR}/boot/uImage" ]]; then
        KERNEL_IMAGE="${FIRMWARE_DIR}/boot/uImage"
        kernel_found=true
    elif [[ -f "${PROJECT_ROOT}/boot/uImage" ]]; then
        KERNEL_IMAGE="${PROJECT_ROOT}/boot/uImage"
        kernel_found=true
    fi
    
    if [[ "${kernel_found}" == "false" ]]; then
        log_error "Kernel uImage not found!"
        log_info "Expected locations:"
        log_info "  - ${NST_KERNEL_DIR}/build/uImage"
        log_info "  - ${FIRMWARE_DIR}/boot/uImage"
        log_info "Build kernel first with: cd nst-kernel && ./build-jester-kernel.sh"
        exit 1
    fi
    
    log_success "Found kernel: ${KERNEL_IMAGE}"
    
    # Check for rootfs (Docker image or tar.gz)
    local rootfs_found=false
    if docker images | grep -q "nook-system"; then
        ROOTFS_SOURCE="docker"
        rootfs_found=true
        log_success "Found Docker image: nook-system"
    elif [[ -f "${PROJECT_ROOT}/nook-debian.tar.gz" ]]; then
        ROOTFS_SOURCE="tarball"
        ROOTFS_TARBALL="${PROJECT_ROOT}/nook-debian.tar.gz"
        rootfs_found=true
        log_success "Found rootfs tarball: ${ROOTFS_TARBALL}"
    elif [[ -f "${FIRMWARE_DIR}/rootfs.tar.gz" ]]; then
        ROOTFS_SOURCE="tarball"
        ROOTFS_TARBALL="${FIRMWARE_DIR}/rootfs.tar.gz"
        rootfs_found=true
        log_success "Found rootfs tarball: ${ROOTFS_TARBALL}"
    fi
    
    if [[ "${rootfs_found}" == "false" ]]; then
        log_error "Root filesystem not found!"
        log_info "Build rootfs first with: docker build -t nook-system -f nookwriter-optimized.dockerfile ."
        exit 1
    fi
    
    # Check for U-Boot config
    if [[ -f "${PROJECT_ROOT}/boot/uEnv.txt" ]]; then
        UENV_FILE="${PROJECT_ROOT}/boot/uEnv.txt"
        log_success "Found U-Boot config: ${UENV_FILE}"
    elif [[ -f "${PROJECT_ROOT}/boot/uEnv-enhanced.txt" ]]; then
        UENV_FILE="${PROJECT_ROOT}/boot/uEnv-enhanced.txt"
        log_success "Found U-Boot config: ${UENV_FILE}"
    else
        log_warn "No uEnv.txt found, will create default"
        UENV_FILE=""
    fi
}

create_image_file() {
    log_info "Creating ${IMAGE_SIZE_MB}MB image file..."
    
    # Create output directory if it doesn't exist
    mkdir -p "${OUTPUT_DIR}"
    
    # Create sparse image file
    dd if=/dev/zero of="${OUTPUT_IMAGE}" bs=1M count=0 seek="${IMAGE_SIZE_MB}" status=none
    
    log_success "Created image: ${OUTPUT_IMAGE}"
}

partition_image() {
    log_info "Creating partition table..."
    
    # Create partition table with parted
    # Partition 1: FAT16 boot partition (100MB)
    # Partition 2: ext4 root partition (remaining space)
    
    sudo parted -s "${OUTPUT_IMAGE}" \
        mklabel msdos \
        mkpart primary fat16 1MiB "${BOOT_SIZE_MB}MiB" \
        mkpart primary ext4 "${BOOT_SIZE_MB}MiB" 100% \
        set 1 boot on
    
    log_success "Partition table created"
    
    # Show partition info
    sudo parted "${OUTPUT_IMAGE}" print
}

setup_loop_device() {
    log_info "Setting up loop device..."
    
    # Create loop device with partition support
    LOOP_DEVICE=$(sudo losetup -f --show -P "${OUTPUT_IMAGE}")
    
    if [[ -z "${LOOP_DEVICE}" ]]; then
        log_error "Failed to create loop device"
        exit 1
    fi
    
    log_success "Loop device created: ${LOOP_DEVICE}"
    
    # Wait for partition devices to appear
    sleep 2
    
    # Verify partition devices exist
    if [[ ! -b "${LOOP_DEVICE}p1" ]] || [[ ! -b "${LOOP_DEVICE}p2" ]]; then
        log_error "Partition devices not found"
        sudo losetup -d "${LOOP_DEVICE}"
        exit 1
    fi
}

format_partitions() {
    log_info "Formatting partitions..."
    
    # Format boot partition as FAT16
    sudo mkfs.vfat -F 16 -n "NOOK_BOOT" "${LOOP_DEVICE}p1"
    log_success "Boot partition formatted (FAT16)"
    
    # Format root partition as ext4 without journal
    sudo mkfs.ext4 -L "NOOK_ROOT" -O "^has_journal,^huge_file" "${LOOP_DEVICE}p2"
    log_success "Root partition formatted (ext4)"
}

mount_partitions() {
    log_info "Mounting partitions..."
    
    # Create mount points
    MOUNT_BOOT=$(mktemp -d /tmp/nook-boot.XXXXXX)
    MOUNT_ROOT=$(mktemp -d /tmp/nook-root.XXXXXX)
    
    # Mount partitions
    sudo mount "${LOOP_DEVICE}p1" "${MOUNT_BOOT}"
    sudo mount "${LOOP_DEVICE}p2" "${MOUNT_ROOT}"
    
    log_success "Partitions mounted"
}

install_boot_files() {
    log_info "Installing boot files..."
    
    # Copy kernel
    sudo cp "${KERNEL_IMAGE}" "${MOUNT_BOOT}/uImage"
    log_success "Kernel installed"
    
    # Create or copy U-Boot environment
    if [[ -n "${UENV_FILE}" ]]; then
        sudo cp "${UENV_FILE}" "${MOUNT_BOOT}/uEnv.txt"
    else
        # Create default uEnv.txt
        cat << 'EOF' | sudo tee "${MOUNT_BOOT}/uEnv.txt" > /dev/null
# Nook Typewriter U-Boot Environment
# Medieval-themed distraction-free writing device

# Boot arguments for QuillKernel
bootargs=console=ttyS0,115200n8 root=/dev/mmcblk0p2 rootfstype=ext4 rootwait rw mem=256M fbcon=rotate:1 epd=pearl quiet

# Load kernel from SD card
bootcmd=fatload mmc 0:1 0x80000000 uImage; bootm 0x80000000

# Medieval boot message
bootdelay=2
stderr=serial
stdin=serial
stdout=serial

# Memory configuration (preserve 160MB for writing)
memsize=256M
memstart=0x80000000
EOF
    fi
    log_success "Boot configuration installed"
    
    # Create boot flag file for rooted Nook detection
    echo "boot_from_sd=1" | sudo tee "${MOUNT_BOOT}/boot.flag" > /dev/null
    
    # Show boot partition contents
    log_info "Boot partition contents:"
    ls -lh "${MOUNT_BOOT}/"
}

install_rootfs() {
    log_info "Installing root filesystem..."
    
    if [[ "${ROOTFS_SOURCE}" == "docker" ]]; then
        log_info "Exporting from Docker image..."
        # Export from Docker
        docker create --name nook-export nook-system
        docker export nook-export | sudo tar -xf - -C "${MOUNT_ROOT}/"
        docker rm nook-export
    else
        log_info "Extracting from tarball..."
        # Extract from tarball
        sudo tar -xzf "${ROOTFS_TARBALL}" -C "${MOUNT_ROOT}/"
    fi
    
    log_success "Root filesystem installed"
    
    # Set up critical directories and permissions
    log_info "Setting up filesystem structure..."
    
    # Create writing directories
    sudo mkdir -p "${MOUNT_ROOT}/root/writing"
    sudo mkdir -p "${MOUNT_ROOT}/root/notes"
    sudo mkdir -p "${MOUNT_ROOT}/root/drafts"
    
    # Fix permissions
    sudo chmod 755 "${MOUNT_ROOT}/sbin/init" 2>/dev/null || true
    sudo chmod 755 "${MOUNT_ROOT}/etc/init.d/"* 2>/dev/null || true
    
    # Create fstab for boot
    cat << 'EOF' | sudo tee "${MOUNT_ROOT}/etc/fstab" > /dev/null
# Nook Typewriter filesystem table
/dev/mmcblk0p2  /        ext4  noatime,nodiratime,errors=remount-ro  0  1
/dev/mmcblk0p1  /boot    vfat  defaults                               0  2
proc            /proc    proc  defaults                               0  0
sysfs           /sys     sysfs defaults                               0  0
tmpfs           /tmp     tmpfs size=10M,noatime                       0  0
tmpfs           /var/log tmpfs size=5M,noatime                        0  0
EOF
    
    # Install SquireOS modules if available
    if [[ -d "${NST_KERNEL_DIR}/drivers/squireos" ]]; then
        log_info "Installing SquireOS kernel modules..."
        sudo mkdir -p "${MOUNT_ROOT}/lib/modules/2.6.29"
        for module in "${NST_KERNEL_DIR}/drivers/squireos/"*.ko; do
            if [[ -f "${module}" ]]; then
                sudo cp "${module}" "${MOUNT_ROOT}/lib/modules/2.6.29/"
                log_success "Installed: $(basename "${module}")"
            fi
        done
    fi
    
    # Create module loading script
    cat << 'EOF' | sudo tee "${MOUNT_ROOT}/etc/init.d/load-squireos-modules" > /dev/null
#!/bin/sh
### BEGIN INIT INFO
# Provides:          load-squireos-modules
# Required-Start:    $local_fs
# Required-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:
# Short-Description: Load SquireOS kernel modules
### END INIT INFO

case "$1" in
    start)
        echo "Loading SquireOS modules..."
        for module in /lib/modules/2.6.29/*.ko; do
            if [ -f "$module" ]; then
                insmod "$module" 2>/dev/null && echo "  → Loaded $(basename $module)"
            fi
        done
        # Show the jester if available
        [ -f /proc/squireos/jester ] && cat /proc/squireos/jester
        ;;
    stop)
        ;;
    *)
        echo "Usage: $0 {start|stop}"
        exit 1
        ;;
esac
EOF
    sudo chmod 755 "${MOUNT_ROOT}/etc/init.d/load-squireos-modules"
    
    # Calculate and show filesystem usage
    local rootfs_size=$(sudo du -sh "${MOUNT_ROOT}" | cut -f1)
    log_info "Root filesystem size: ${rootfs_size}"
}

finalize_image() {
    log_info "Finalizing image..."
    
    # Sync filesystem
    sync
    sync
    
    # Unmount partitions
    sudo umount "${MOUNT_BOOT}"
    sudo umount "${MOUNT_ROOT}"
    
    # Remove loop device
    sudo losetup -d "${LOOP_DEVICE}"
    
    # Clear variables to prevent cleanup
    LOOP_DEVICE=""
    
    log_success "Image finalized"
    
    # Compress image
    log_info "Compressing image..."
    gzip -c "${OUTPUT_IMAGE}" > "${OUTPUT_IMAGE}.gz"
    
    # Show final sizes
    local img_size=$(ls -lh "${OUTPUT_IMAGE}" | awk '{print $5}')
    local gz_size=$(ls -lh "${OUTPUT_IMAGE}.gz" | awk '{print $5}')
    
    log_success "Image created successfully!"
    echo
    echo -e "${BLUE}${JESTER_ASCII}${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}✓ SD Card Image Build Complete!${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo
    echo "  Image file:      ${OUTPUT_IMAGE} (${img_size})"
    echo "  Compressed:      ${OUTPUT_IMAGE}.gz (${gz_size})"
    echo
    echo "To flash to SD card:"
    echo "  1. Insert SD card (8GB minimum)"
    echo "  2. Identify device with: lsblk"
    echo "  3. Flash with:"
    echo "     sudo dd if=${OUTPUT_IMAGE} of=/dev/sdX bs=4M status=progress conv=fsync"
    echo "     (Replace /dev/sdX with your SD card device)"
    echo
    echo "Or use Balena Etcher for a GUI tool:"
    echo "  https://www.balena.io/etcher/"
    echo
    echo -e "${YELLOW}By quill and candlelight, thy device awaits!${NC}"
}

# -----------------------------------------------------------------------------
# Main Execution
# -----------------------------------------------------------------------------

main() {
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}       Nook Typewriter SD Card Image Builder${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo
    
    # Set up error handling
    trap cleanup EXIT
    
    # Run build steps
    check_requirements
    check_inputs
    create_image_file
    partition_image
    setup_loop_device
    format_partitions
    mount_partitions
    install_boot_files
    install_rootfs
    finalize_image
}

# Run main function
main "$@"