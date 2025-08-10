#!/bin/bash
# Optimize kernel configuration for Nook typewriter use

echo "=== Nook Typewriter Kernel Optimization ==="
echo "This script will help optimize the kernel for typewriter use"
echo ""

# Ensure we're in the kernel source directory
cd "$(dirname "$0")/src" || exit 1

# Start with the base gossamer config
echo "Loading base Gossamer configuration..."
make ARCH=arm nook_typewriter_defconfig

# Now we'll use the kernel configuration system to make changes
echo ""
echo "Optimizations to consider:"
echo "1. Disable unused network protocols (IPX, AppleTalk, etc.)"
echo "2. Remove unnecessary file systems (keeping only EXT2/3, FAT32)"
echo "3. Disable unused USB device classes"
echo "4. Remove sound support (not needed for typewriter)"
echo "5. Optimize suspend/resume timing"
echo ""

# Function to disable config option
disable_option() {
    echo "# $1 is not set" >> .config
    echo "Disabled: $1"
}

# Function to enable config option
enable_option() {
    echo "$1=y" >> .config
    echo "Enabled: $1"
}

# Create a custom configuration
cat > .config << 'EOF'
# Start with existing config
EOF
cat arch/arm/configs/nook_typewriter_defconfig >> .config

# Make optimizations
echo ""
echo "Applying typewriter optimizations..."

# Disable sound subsystem (not needed)
disable_option CONFIG_SOUND

# Disable unnecessary network protocols
disable_option CONFIG_IPX
disable_option CONFIG_ATALK
disable_option CONFIG_DECNET
disable_option CONFIG_PHONET

# Disable unnecessary file systems
disable_option CONFIG_JFS_FS
disable_option CONFIG_XFS_FS
disable_option CONFIG_BTRFS_FS
disable_option CONFIG_REISERFS_FS

# Optimize USB for HID only
enable_option CONFIG_USB_HID
enable_option CONFIG_HID_SUPPORT

# Optimize power management
enable_option CONFIG_PM_RUNTIME
enable_option CONFIG_CPU_IDLE
enable_option CONFIG_NO_HZ

# Run oldconfig to validate
echo ""
echo "Validating configuration..."
make ARCH=arm oldconfig

# Save the optimized config
cp .config arch/arm/configs/nook_typewriter_defconfig

echo ""
echo "=== Optimization Complete ==="
echo "The optimized configuration has been saved to:"
echo "  arch/arm/configs/nook_typewriter_defconfig"
echo ""
echo "To build with this config:"
echo "  ./build-kernel.sh"
echo ""
echo "For further customization, run:"
echo "  make ARCH=arm menuconfig"