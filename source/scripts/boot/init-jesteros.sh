#!/bin/sh
# JesterOS Init Script
# Initializes all JesterOS userspace services at boot

set -euo pipefail

# Colors for output (if terminal supports)
if [ -t 1 ]; then
    GREEN='\033[0;32m'
    RED='\033[0;31m'
    YELLOW='\033[1;33m'
    NC='\033[0m'
else
    GREEN=''
    RED=''
    YELLOW=''
    NC=''
fi

echo "════════════════════════════════════════"
echo "  JesterOS Initialization"
echo "  Medieval Writing Companion v1.0"
echo "════════════════════════════════════════"
echo ""

# Source paths
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SERVICE_MANAGER="/usr/local/bin/jesteros-service-manager.sh"
BOOT_SPLASH="$SCRIPT_DIR/jesteros-boot-splash.sh"

# Show boot splash if available
if [ -f "$BOOT_SPLASH" ] && [ -x "$BOOT_SPLASH" ]; then
    echo "Displaying royal announcement..."
    "$BOOT_SPLASH" --quick || true
fi

# Create required directories
echo "Preparing the realm..."
mkdir -p /var/jesteros
mkdir -p /var/run/jesteros
mkdir -p /var/log/jesteros
mkdir -p /etc/jesteros/services

# Copy service configurations if they exist
if [ -d "$SCRIPT_DIR/../../configs/services" ]; then
    echo "Installing service scrolls..."
    cp -f "$SCRIPT_DIR/../../configs/services"/*.conf /etc/jesteros/services/ 2>/dev/null || true
fi

# Start service manager if available
if [ -f "$SERVICE_MANAGER" ] && [ -x "$SERVICE_MANAGER" ]; then
    echo ""
    echo "Awakening the service manager..."
    "$SERVICE_MANAGER" start all
else
    echo -e "${YELLOW}Service manager not found at $SERVICE_MANAGER${NC}"
    echo "Starting services manually..."
    
    # Manual service startup fallback
    if [ -f "$SCRIPT_DIR/../services/jester-daemon.sh" ]; then
        echo "  Starting Court Jester..."
        "$SCRIPT_DIR/../services/jester-daemon.sh" start &
    fi
    
    if [ -f "$SCRIPT_DIR/../services/jesteros-tracker.sh" ]; then
        echo "  Starting Writing Tracker..."
        "$SCRIPT_DIR/../services/jesteros-tracker.sh" start &
    fi
    
    if [ -f "$SCRIPT_DIR/../services/health-check.sh" ]; then
        echo "  Starting Health Monitor..."
        "$SCRIPT_DIR/../services/health-check.sh" start &
    fi
fi

# Create /var/jesteros interface
echo ""
echo "Creating mystical interface at /var/jesteros..."
touch /var/jesteros/jester
touch /var/jesteros/wisdom
mkdir -p /var/jesteros/typewriter
touch /var/jesteros/typewriter/stats

# Set initial states
echo "happy" > /var/jesteros/jester
echo "By quill and jest, thy writing quest begins!" > /var/jesteros/wisdom
echo "Words: 0" > /var/jesteros/typewriter/stats

echo ""
echo "════════════════════════════════════════"
echo -e "${GREEN}✓ JesterOS initialization complete!${NC}"
echo "  The Court Jester awaits thy command!"
echo "════════════════════════════════════════"

# If running interactively, show the menu
if [ -t 0 ] && [ -t 1 ]; then
    if [ -f "$SCRIPT_DIR/../menu/nook-menu.sh" ]; then
        sleep 2
        exec "$SCRIPT_DIR/../menu/nook-menu.sh"
    fi
fi

exit 0