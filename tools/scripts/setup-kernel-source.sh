#!/bin/bash
# Setup kernel source for JesterOS build
# Supports local kernel copy or downloading from catdotbashrc/nst-kernel

set -euo pipefail
trap 'echo "Error at line $LINENO"' ERR

# Configuration
KERNEL_REPO="${KERNEL_REPO:-https://github.com/catdotbashrc/nst-kernel.git}"
KERNEL_BRANCH="${KERNEL_BRANCH:-master}"
LOCAL_KERNEL_PATH="/home/jyeary/projects/personal/nook-kernel/nst-kernel/src"
PROJECT_ROOT="${PROJECT_ROOT:-/home/jyeary/projects/personal/nook}"
KERNEL_TARGET_DIR="${PROJECT_ROOT}/source/kernel"

# Colors for output
BOLD='\033[1m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
RESET='\033[0m'

echo -e "${BOLD}═══════════════════════════════════════════════════════════════${RESET}"
echo -e "${BOLD}           Kernel Source Setup for JesterOS${RESET}"
echo -e "${BOLD}═══════════════════════════════════════════════════════════════${RESET}"
echo ""

# Function to validate kernel source
validate_kernel_source() {
    local kernel_path="$1"
    
    # Check for essential kernel files
    # Note: Linux 2.6.29 has Kbuild in root, not Kconfig
    # Kconfig files are in subdirectories like arch/arm/Kconfig
    if [ -f "${kernel_path}/Makefile" ] && \
       [ -d "${kernel_path}/arch/arm" ] && \
       [ -f "${kernel_path}/arch/arm/Kconfig" ]; then
        return 0
    else
        return 1
    fi
}

# Check if kernel source already exists in target directory
if [ -d "${KERNEL_TARGET_DIR}/src" ]; then
    echo -e "${GREEN}✓ Kernel source already exists at ${KERNEL_TARGET_DIR}/src${RESET}"
    if validate_kernel_source "${KERNEL_TARGET_DIR}/src"; then
        echo -e "${GREEN}✓ Kernel source is valid${RESET}"
        exit 0
    else
        echo -e "${YELLOW}⚠ Existing kernel source appears incomplete${RESET}"
        echo "  Will attempt to refresh..."
    fi
fi

# Option 1: Use local kernel copy if available
if [ -d "${LOCAL_KERNEL_PATH}" ]; then
    echo -e "${BOLD}→ Found local kernel at ${LOCAL_KERNEL_PATH}${RESET}"
    
    if validate_kernel_source "${LOCAL_KERNEL_PATH}"; then
        echo -e "${GREEN}✓ Local kernel source is valid${RESET}"
        echo "→ Creating symlink to local kernel..."
        
        # Create parent directory
        mkdir -p "${KERNEL_TARGET_DIR}"
        
        # Remove existing src directory if it exists
        if [ -d "${KERNEL_TARGET_DIR}/src" ] || [ -L "${KERNEL_TARGET_DIR}/src" ]; then
            rm -rf "${KERNEL_TARGET_DIR}/src"
        fi
        
        # Create symlink to local kernel
        ln -s "${LOCAL_KERNEL_PATH}" "${KERNEL_TARGET_DIR}/src"
        
        echo -e "${GREEN}✓ Linked local kernel to ${KERNEL_TARGET_DIR}/src${RESET}"
        echo "  This saves download time and uses your local copy"
        exit 0
    else
        echo -e "${YELLOW}⚠ Local kernel appears incomplete${RESET}"
        echo "  Will download fresh copy instead..."
    fi
fi

# Option 2: Download from catdotbashrc/nst-kernel
echo -e "${BOLD}→ Downloading kernel from ${KERNEL_REPO}${RESET}"
echo "  This may take a few minutes..."

# Create temporary directory for download
TEMP_DIR=$(mktemp -d)
trap "rm -rf ${TEMP_DIR}" EXIT

# Clone the repository
if git clone --depth=1 --branch="${KERNEL_BRANCH}" "${KERNEL_REPO}" "${TEMP_DIR}/nst-kernel"; then
    echo -e "${GREEN}✓ Successfully downloaded kernel source${RESET}"
    
    # Validate downloaded kernel
    if validate_kernel_source "${TEMP_DIR}/nst-kernel"; then
        echo -e "${GREEN}✓ Downloaded kernel is valid${RESET}"
        
        # Create target directory structure
        mkdir -p "${KERNEL_TARGET_DIR}"
        
        # Remove existing src directory if it exists
        if [ -d "${KERNEL_TARGET_DIR}/src" ]; then
            echo "→ Removing old kernel source..."
            rm -rf "${KERNEL_TARGET_DIR}/src"
        fi
        
        # Move downloaded kernel to target location
        mv "${TEMP_DIR}/nst-kernel" "${KERNEL_TARGET_DIR}/src"
        
        echo -e "${GREEN}✓ Kernel source installed at ${KERNEL_TARGET_DIR}/src${RESET}"
        
        # Create a marker file with source info
        cat > "${KERNEL_TARGET_DIR}/src/.kernel-source-info" << EOF
# Kernel Source Information
SOURCE_REPO=${KERNEL_REPO}
SOURCE_BRANCH=${KERNEL_BRANCH}
DOWNLOAD_DATE=$(date +%Y-%m-%d)
DOWNLOAD_TIME=$(date +%H:%M:%S)
EOF
        
        echo -e "${GREEN}✓ Setup complete!${RESET}"
        exit 0
    else
        echo -e "${RED}✗ Downloaded kernel appears invalid${RESET}"
        exit 1
    fi
else
    echo -e "${RED}✗ Failed to download kernel from ${KERNEL_REPO}${RESET}"
    echo "  Please check your internet connection and try again"
    exit 1
fi