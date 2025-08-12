#!/bin/bash
# Create CWM-Compatible Installation Package for SquireOS
# Following XDA Phoenix Project standards

set -euo pipefail

echo "==============================================================="
echo "       Creating CWM Recovery Package for SquireOS"
echo "==============================================================="
echo ""

# Configuration
CWM_DIR="cwm_package"
OUTPUT_ZIP="squireos-cwm-install.zip"

# Clean previous build
rm -rf "$CWM_DIR" "$OUTPUT_ZIP"

# Create CWM directory structure
echo "-> Creating CWM package structure..."
mkdir -p "$CWM_DIR"/{boot,system/lib/modules/2.6.29,META-INF/com/google/android}

# Copy kernel image
if [ -f "firmware/boot/uImage" ]; then
    cp firmware/boot/uImage "$CWM_DIR/boot/"
    echo "  [OK] Kernel image added"
else
    echo "  [WARN] No kernel image found"
fi

# Copy modules (try .ko first, fall back to .o)
if ls firmware/modules/*.ko 2>/dev/null; then
    cp firmware/modules/*.ko "$CWM_DIR/system/lib/modules/2.6.29/"
    echo "  [OK] Kernel modules (.ko) added"
elif ls firmware/modules/*.o 2>/dev/null; then
    # For now, copy .o files as placeholders
    cp firmware/modules/*.o "$CWM_DIR/system/lib/modules/2.6.29/"
    echo "  [OK] Module objects (.o) added (compile to .ko needed)"
else
    echo "  [WARN] No module files found"
fi

# Create update-script for CWM (Edify syntax)
echo "-> Creating CWM update script..."
cat > "$CWM_DIR/META-INF/com/google/android/updater-script" << 'EOF'
# SquireOS Medieval Kernel Installation Script
# For Nook Simple Touch via ClockworkMod Recovery

ui_print("========================================");
ui_print("  SquireOS Medieval Writing System");
ui_print("========================================");
ui_print("");
ui_print("By quill and candlelight,");
ui_print("we update thy digital realm!");
ui_print("");

# Show what we're installing
ui_print("Installing components:");
ui_print("  - QuillKernel with SquireOS support");
ui_print("  - Medieval kernel modules");
ui_print("  - Writing statistics tracker");
ui_print("  - ASCII jester companion");
ui_print("");

# Mount the system partition
ui_print("Mounting system partition...");
mount("ext2", "EMMC", "/dev/block/mmcblk0p2", "/system");

# Backup original kernel (if exists)
ui_print("Backing up original kernel...");
run_program("/sbin/busybox", "cp", "/boot/uImage", "/boot/uImage.backup");

# Extract and install kernel
ui_print("Installing QuillKernel...");
package_extract_file("boot/uImage", "/boot/uImage");

# Extract and install modules
ui_print("Installing SquireOS modules...");
package_extract_dir("system", "/system");

# Set proper permissions for modules
ui_print("Setting permissions...");
set_perm(0, 0, 0644, "/system/lib/modules/2.6.29/squireos_core.ko");
set_perm(0, 0, 0644, "/system/lib/modules/2.6.29/jester.ko");
set_perm(0, 0, 0644, "/system/lib/modules/2.6.29/typewriter.ko");
set_perm(0, 0, 0644, "/system/lib/modules/2.6.29/wisdom.ko");

# Create module loading script
ui_print("Creating boot scripts...");
run_program("/sbin/busybox", "mkdir", "-p", "/system/etc/init.d");

# Write module loading script
run_program("/sbin/busybox", "echo", "#!/system/bin/sh", ">", "/system/etc/init.d/99squireos");
run_program("/sbin/busybox", "echo", "# Load SquireOS modules at boot", ">>", "/system/etc/init.d/99squireos");
run_program("/sbin/busybox", "echo", "insmod /system/lib/modules/2.6.29/squireos_core.ko", ">>", "/system/etc/init.d/99squireos");
run_program("/sbin/busybox", "echo", "insmod /system/lib/modules/2.6.29/jester.ko", ">>", "/system/etc/init.d/99squireos");
run_program("/sbin/busybox", "echo", "insmod /system/lib/modules/2.6.29/typewriter.ko", ">>", "/system/etc/init.d/99squireos");
run_program("/sbin/busybox", "echo", "insmod /system/lib/modules/2.6.29/wisdom.ko", ">>", "/system/etc/init.d/99squireos");

set_perm(0, 0, 0755, "/system/etc/init.d/99squireos");

# Unmount system
ui_print("Unmounting system...");
unmount("/system");

# Final messages
ui_print("");
ui_print("========================================");
ui_print("  Installation Complete!");
ui_print("========================================");
ui_print("");
ui_print("The digital scriptorium is ready!");
ui_print("");
ui_print("After reboot, check /proc/squireos/");
ui_print("  cat /proc/squireos/jester");
ui_print("  cat /proc/squireos/wisdom");
ui_print("");
ui_print("Happy writing!");
EOF

# Create update-binary (stub, CWM provides the real one)
touch "$CWM_DIR/META-INF/com/google/android/update-binary"

echo ""
echo "-> Creating ZIP package..."

# Create the ZIP file (CWM requires specific structure)
cd "$CWM_DIR"
zip -r "../$OUTPUT_ZIP" * >/dev/null 2>&1
cd ..

# Sign the ZIP if signing tool is available
if command -v signapk >/dev/null 2>&1; then
    echo "-> Signing package..."
    signapk testkey.x509.pem testkey.pk8 "$OUTPUT_ZIP" "${OUTPUT_ZIP%.zip}-signed.zip"
    mv "${OUTPUT_ZIP%.zip}-signed.zip" "$OUTPUT_ZIP"
    echo "  [OK] Package signed"
else
    echo "  [INFO] Package not signed (optional for CWM)"
fi

# Calculate size
ZIP_SIZE=$(du -h "$OUTPUT_ZIP" | cut -f1)

echo ""
echo "==============================================================="
echo "           CWM Package Creation Complete!"
echo "==============================================================="
echo ""
echo "Package: $OUTPUT_ZIP ($ZIP_SIZE)"
echo ""
echo "Installation Instructions:"
echo "1. Copy $OUTPUT_ZIP to SD card root"
echo "2. Boot Nook into CWM Recovery (hold n while booting)"
echo "3. Select 'install zip from sdcard'"
echo "4. Choose 'choose zip from sdcard'"  
echo "5. Select $OUTPUT_ZIP"
echo "6. Confirm installation"
echo "7. Reboot system"
echo ""
echo "To verify after reboot:"
echo "  cat /proc/squireos/jester"
echo ""
echo "==============================================================="
echo "'The CWM package is prepared for the digital realm!'"
echo "==============================================================="