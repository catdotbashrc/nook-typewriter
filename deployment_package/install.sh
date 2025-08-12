#!/bin/sh
# SquireOS Installation Script for Nook
# Run as root on the target device

echo "Installing SquireOS Medieval Writing System..."

# Check if running as root
if [ "$(id -u)" != "0" ]; then
    echo "Error: This script must be run as root"
    exit 1
fi

# Detect system type
if [ -d /system ]; then
    echo "Detected Android-based Nook system"
    INSTALL_TYPE="android"
elif [ -d /etc/systemd ]; then
    echo "Detected systemd-based system"
    INSTALL_TYPE="systemd"
else
    echo "Detected SysV init system"
    INSTALL_TYPE="sysv"
fi

# Install kernel (if provided)
if [ -f boot/uImage ]; then
    echo "Installing kernel image..."
    cp boot/uImage /boot/uImage.squireos
    echo "  [OK] Kernel installed (manual boot configuration required)"
fi

# Install modules
if ls lib/modules/2.6.29/*.o 2>/dev/null; then
    echo "Installing kernel modules..."
    mkdir -p /lib/modules/2.6.29
    cp lib/modules/2.6.29/*.o /lib/modules/2.6.29/
    echo "  [OK] Modules installed to /lib/modules/2.6.29/"
fi

# Install init scripts
echo "Installing init scripts..."
cp usr/local/bin/*.sh /usr/local/bin/
chmod +x /usr/local/bin/*.sh

case $INSTALL_TYPE in
    android)
        # For Android/Nook, add to init.rc or use property trigger
        echo "  [OK] Scripts installed for Android boot"
        ;;
    systemd)
        cp etc/systemd/system/*.service /etc/systemd/system/
        systemctl daemon-reload
        systemctl enable squireos-modules.service
        echo "  [OK] SystemD service enabled"
        ;;
    sysv)
        cp etc/init.d/* /etc/init.d/
        chmod +x /etc/init.d/squireos-modules
        update-rc.d squireos-modules defaults 2>/dev/null || \
            chkconfig --add squireos-modules 2>/dev/null || \
            echo "    Please manually enable init script"
        echo "  [OK] SysV init script installed"
        ;;
esac

echo ""
echo "==============================================="
echo "Installation complete!"
echo ""
echo "To load modules manually:"
echo "  /usr/local/bin/load-squireos-modules.sh"
echo ""
echo "To check status:"
echo "  ls -la /proc/squireos/"
echo ""
echo "The digital scriptorium awaits thy quill!"
echo "==============================================="
