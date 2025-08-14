#!/bin/bash
# JesterOS Userspace Installation Script
# "The simplest solution is often the wisest" - Jester's Wisdom

set -euo pipefail

echo "═══════════════════════════════════════════"
echo "    JesterOS Userspace Installation"
echo "    No kernel compilation required!"
echo "═══════════════════════════════════════════"
echo

# Check if running as root (needed for /etc/init.d)
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root for system installation"
    echo "Or run with --user for local testing"
    if [ "${1:-}" != "--user" ]; then
        exit 1
    fi
fi

# Installation paths
if [ "${1:-}" = "--user" ]; then
    # User mode - install locally for testing
    INSTALL_DIR="$HOME/.local/bin"
    INIT_DIR="$HOME/.config/init"
    VAR_DIR="$HOME/.local/var/jesteros"
    echo "Installing in user mode to $HOME/.local/"
else
    # System mode - install globally
    INSTALL_DIR="/usr/local/bin"
    INIT_DIR="/etc/init.d"
    VAR_DIR="/var/jesteros"
    echo "Installing system-wide..."
fi

# Create directories
mkdir -p "$INSTALL_DIR"
mkdir -p "$INIT_DIR"
mkdir -p "$VAR_DIR"

# Copy main scripts
echo "→ Installing JesterOS scripts..."
cp source/scripts/boot/jesteros-userspace.sh "$INSTALL_DIR/"
cp source/scripts/services/jesteros-tracker.sh "$INSTALL_DIR/"
cp source/scripts/boot/jester-splash.sh "$INSTALL_DIR/" 2>/dev/null || true
cp source/scripts/boot/jester-splash-eink.sh "$INSTALL_DIR/" 2>/dev/null || true
cp source/scripts/boot/jester-dance.sh "$INSTALL_DIR/" 2>/dev/null || true
cp source/scripts/boot/boot-with-jester.sh "$INSTALL_DIR/" 2>/dev/null || true
chmod +x "$INSTALL_DIR"/*.sh

# Install init script (system mode only)
if [ "${1:-}" != "--user" ]; then
    echo "→ Installing init script..."
    cp source/configs/system/jesteros.init "$INIT_DIR/jesteros"
    chmod +x "$INIT_DIR/jesteros"
    
    # Try to enable at boot (may fail on non-standard systems)
    if command -v update-rc.d >/dev/null 2>&1; then
        echo "→ Enabling JesterOS at boot..."
        update-rc.d jesteros defaults
    elif command -v chkconfig >/dev/null 2>&1; then
        chkconfig --add jesteros
    else
        echo "! Could not auto-enable at boot. Please add manually."
    fi
fi

# Initialize JesterOS immediately for testing
echo "→ Initializing JesterOS..."
"$INSTALL_DIR/jesteros-userspace.sh"

echo
echo "═══════════════════════════════════════════"
echo "    ✅ JesterOS Installation Complete!"
echo "═══════════════════════════════════════════"
echo
echo "Test your installation:"
echo "  cat $VAR_DIR/jester"
echo "  cat $VAR_DIR/typewriter/stats"  
echo "  cat $VAR_DIR/wisdom"
echo
echo "Start the service:"
if [ "${1:-}" = "--user" ]; then
    echo "  $INSTALL_DIR/jesteros-tracker.sh &"
else
    echo "  service jesteros start"
    echo "  service jesteros status"
fi
echo
echo "The Jester awaits thy words! 🎭"
echo "(Note: On actual Nook, no emoji will appear)"
echo