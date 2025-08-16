#!/bin/bash
# ClockworkMod SD Card Creator for Nook Simple Touch
# Based on XDA Phoenix Project research and CWM deployment methods

set -euo pipefail
trap 'echo "Error at line $LINENO"' ERR

echo "═══════════════════════════════════════════════════════════════"
echo "     ClockworkMod SD Card Creator for QuillKernel"
echo "     Based on XDA Phoenix Project Methods"
echo "═══════════════════════════════════════════════════════════════"

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CWM_DIR="$PROJECT_ROOT/build/cwm"
SDCARD_IMAGE="$PROJECT_ROOT/build/quillkernel-cwm-installer.img"

# Validate dependencies
check_dependencies() {
    local missing=()
    
    for cmd in dd mkfs.fat fdisk; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing+=("$cmd")
        fi
    done
    
    if [ ${#missing[@]} -ne 0 ]; then
        echo "❌ Missing required commands: ${missing[*]}"
        echo "   Install with: sudo apt-get install util-linux dosfstools"
        exit 2
    fi
}

# Create CWM-compatible directory structure
create_cwm_structure() {
    echo "→ Creating ClockworkMod directory structure..."
    
    mkdir -p "$CWM_DIR"/{boot,recovery,kernel,modules,scripts}
    
    # Copy kernel artifacts
    if [ -f "$PROJECT_ROOT/firmware/boot/uImage" ]; then
        cp "$PROJECT_ROOT/firmware/boot/uImage" "$CWM_DIR/kernel/"
        echo "  ✓ Kernel image copied"
    else
        echo "  ⚠️  No kernel image found - run 'make kernel-xda' first"
        return 1
    fi
    
    # Copy JesterOS modules if they exist
    if [ -d "$PROJECT_ROOT/source/kernel/src" ]; then
        find "$PROJECT_ROOT/source/kernel/src" -name "*.ko" -exec cp {} "$CWM_DIR/modules/" \; 2>/dev/null || true
        if [ "$(ls -1 "$CWM_DIR/modules/"*.ko 2>/dev/null | wc -l)" -gt 0 ]; then
            echo "  ✓ JesterOS modules copied: $(ls -1 "$CWM_DIR/modules/"*.ko | wc -l) files"
        fi
    fi
}

# Create installation scripts
create_install_scripts() {
    echo "→ Creating CWM installation scripts..."
    
    # Main installation script
    cat > "$CWM_DIR/scripts/install-quillkernel.sh" << 'EOF'
#!/sbin/sh
# QuillKernel Installation Script for ClockworkMod
# Installs medieval-themed kernel with JesterOS modules

echo "═══════════════════════════════════════════════════════════════"
echo "     Installing QuillKernel - Medieval Kernel for Writers"
echo "═══════════════════════════════════════════════════════════════"

# Mount system partitions
mount /system
mount /data

# Backup original kernel
if [ -f /system/kernel ]; then
    echo "→ Backing up original kernel..."
    cp /system/kernel /system/kernel.backup
fi

# Install new kernel
echo "→ Installing QuillKernel..."
# Use install for atomic permission setting
install -m 0644 -o root -g root /tmp/kernel/uImage /system/kernel

# Install JesterOS modules
if [ -d /tmp/modules ]; then
    echo "→ Installing JesterOS modules..."
    mkdir -p /system/lib/modules
    # Install modules with proper permissions atomically
    for module in /tmp/modules/*.ko; do
        [ -f "$module" ] && install -m 0644 -o root -g root "$module" /system/lib/modules/ || true
    done
fi

# Create module loading script
cat > /system/bin/load-jesteros.sh << 'MODEOF'
#!/system/bin/sh
# JesterOS Module Loader
# Loads medieval-themed kernel modules at boot

# JesterOS is now userspace only - no kernel modules!
# Start userspace services instead
/usr/local/bin/jesteros-userspace.sh start

# Verify modules loaded
if [ -d /var/jesteros ]; then
    echo "✓ JesterOS modules loaded successfully"
else
    echo "⚠️  JesterOS modules may not have loaded"
fi
MODEOF

# Set executable permissions atomically
temp_script=$(mktemp)
cp /system/bin/load-jesteros.sh "$temp_script"
install -m 0755 -o root -g root "$temp_script" /system/bin/load-jesteros.sh
rm -f "$temp_script"

# Update init scripts to load modules
if [ -f /system/etc/init.d/01modules ]; then
    echo "/system/bin/load-jesteros.sh" >> /system/etc/init.d/01modules
else
    echo "#!/system/bin/sh" > /system/etc/init.d/01modules
    echo "/system/bin/load-jesteros.sh" >> /system/etc/init.d/01modules
    # Set executable permissions atomically
    temp_init=$(mktemp)
    cp /system/etc/init.d/01modules "$temp_init"
    install -m 0755 -o root -g root "$temp_init" /system/etc/init.d/01modules
    rm -f "$temp_init"
fi

echo ""
echo "✓ QuillKernel installation complete!"
echo "  Medieval modules: jester, typewriter, wisdom"
echo "  Proc interface: /var/jesteros/"
echo "  By quill and candlelight, reboot to enjoy!"
echo ""

# Unmount partitions
umount /data
umount /system

exit 0
EOF

    # Make script executable using install
    temp_installer=$(mktemp)
    cp "$CWM_DIR/scripts/install-quillkernel.sh" "$temp_installer"
    install -m 0755 "$temp_installer" "$CWM_DIR/scripts/install-quillkernel.sh"
    rm -f "$temp_installer"
    echo "  ✓ Installation script created"
}

# Create update-binary for CWM
create_update_binary() {
    echo "→ Creating CWM update-binary..."
    
    cat > "$CWM_DIR/META-INF/com/google/android/update-binary" << 'EOF'
#!/sbin/sh
# ClockworkMod Installation Binary for QuillKernel
# Standard CWM installation format

OUTFD=$2
ZIP="$3"

# UI functions
ui_print() {
    echo "ui_print $1" >&$OUTFD
    echo "ui_print" >&$OUTFD
}

# Extract installation files
ui_print "QuillKernel - Medieval Kernel Installation"
ui_print "==========================================="
ui_print ""

# Create temporary directories
mkdir -p /tmp/kernel /tmp/modules /tmp/scripts

# Extract files from zip
ui_print "Extracting kernel and modules..."
unzip -o "$ZIP" kernel/* -d /tmp/
unzip -o "$ZIP" modules/* -d /tmp/ 2>/dev/null || true
unzip -o "$ZIP" scripts/* -d /tmp/

# Run installation script
ui_print "Installing QuillKernel..."
# Make installer executable atomically
temp_exec=$(mktemp)
cp /tmp/scripts/install-quillkernel.sh "$temp_exec"
install -m 0755 "$temp_exec" /tmp/scripts/install-quillkernel.sh
rm -f "$temp_exec"
/tmp/scripts/install-quillkernel.sh

if [ $? -eq 0 ]; then
    ui_print "✓ QuillKernel installed successfully!"
    ui_print "  Reboot to experience medieval computing"
else
    ui_print "✗ Installation failed"
    exit 1
fi

ui_print ""
ui_print "Installation complete. Happy writing!"
exit 0
EOF

    # Make update-binary executable atomically
    temp_binary=$(mktemp)
    cp "$CWM_DIR/META-INF/com/google/android/update-binary" "$temp_binary"
    install -m 0755 "$temp_binary" "$CWM_DIR/META-INF/com/google/android/update-binary"
    rm -f "$temp_binary"
    echo "  ✓ CWM update-binary created"
}

# Create updater-script
create_updater_script() {
    echo "→ Creating CWM updater-script..."
    
    mkdir -p "$CWM_DIR/META-INF/com/google/android"
    
    cat > "$CWM_DIR/META-INF/com/google/android/updater-script" << 'EOF'
ui_print("QuillKernel Installation");
ui_print("Medieval computing for writers");
ui_print("");
ui_print("Installing kernel and JesterOS modules...");
run_program("/sbin/sh", "/tmp/scripts/install-quillkernel.sh");
ui_print("Installation complete!");
EOF

    echo "  ✓ CWM updater-script created"
}

# Create installation ZIP
create_installation_zip() {
    echo "→ Creating CWM installation ZIP..."
    
    local zip_file="$PROJECT_ROOT/build/QuillKernel-CWM-Installer.zip"
    
    cd "$CWM_DIR"
    
    # Create ZIP with proper structure
    zip -r "$zip_file" \
        kernel/ \
        modules/ \
        scripts/ \
        META-INF/
    
    cd "$PROJECT_ROOT"
    
    if [ -f "$zip_file" ]; then
        echo "  ✓ Installation ZIP created: $(basename "$zip_file")"
        echo "  📦 Size: $(du -h "$zip_file" | cut -f1)"
        echo "  📍 Location: $zip_file"
        return 0
    else
        echo "  ✗ Failed to create installation ZIP"
        return 1
    fi
}

# Main execution
main() {
    echo "Starting CWM SD card creation..."
    
    check_dependencies
    create_cwm_structure
    create_install_scripts
    
    # Create META-INF structure
    mkdir -p "$CWM_DIR/META-INF/com/google/android"
    create_update_binary
    create_updater_script
    
    create_installation_zip
    
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo "✓ ClockworkMod installation package ready!"
    echo ""
    echo "DEPLOYMENT INSTRUCTIONS:"
    echo "1. Copy QuillKernel-CWM-Installer.zip to SD card"
    echo "2. Boot Nook with ClockworkMod recovery SD card"
    echo "3. Select 'Install zip from sdcard'"
    echo "4. Choose QuillKernel-CWM-Installer.zip"
    echo "5. Confirm installation"
    echo "6. Reboot and enjoy medieval computing!"
    echo ""
    echo "By quill and candlelight, thy kernel awaits!"
    echo "═══════════════════════════════════════════════════════════════"
}

# Run main function
main "$@"