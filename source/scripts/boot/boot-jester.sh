#!/bin/bash
# Boot Script with Mischievous Jester
# This runs on Nook startup to show our festive friend!

# Source common functions and safety settings
COMMON_PATH="${COMMON_PATH:-/usr/local/bin/common.sh}"
if [[ -f "$COMMON_PATH" ]]; then
    source "$COMMON_PATH"
else
    # Fallback safety settings if common.sh not found
    set -euo pipefail
    trap 'echo "Error at line $LINENO"' ERR
fi

# E-Ink display initialization
init_display() {
    # Use common display functions if available
    if [[ "${SQUIREOS_COMMON_LOADED:-0}" == "1" ]]; then
        clear_display
        debug_log "Display initialized via common library"
    elif command -v fbink >/dev/null 2>&1; then
        # Fallback to direct fbink calls
        fbink -c
        fbink -g brightness=100 2>/dev/null || true
    fi
}

# Load SquireOS kernel modules
load_squireos_modules() {
    echo "Loading SquireOS modules..."
    
    # Load modules in proper order
    if [ -d /lib/modules/2.6.29 ]; then
        # Core module first
        if [ -f /lib/modules/2.6.29/squireos_core.ko ]; then
            insmod /lib/modules/2.6.29/squireos_core.ko 2>/dev/null || true
        fi
        
        # Then the feature modules
        for module in jester typewriter wisdom; do
            if [ -f /lib/modules/2.6.29/${module}.ko ]; then
                insmod /lib/modules/2.6.29/${module}.ko 2>/dev/null || true
            fi
        done
    fi
    
    # Verify modules loaded
    if [ -d /proc/squireos ]; then
        echo "✓ SquireOS modules loaded successfully"
    else
        echo "⚠ SquireOS modules may not be available"
    fi
}

# Main boot sequence
main() {
    # Load kernel modules
    load_squireos_modules
    
    # Initialize display
    init_display
    
    # Show the mischievous jester animations
    /usr/local/bin/jester-mischief.sh boot
    
    # Start the jester daemon in background
    /usr/local/bin/jester-daemon.sh start &
    
    # Brief pause to enjoy the moment
    e_sleep "${BOOT_DELAY:-1}"
    
    # Launch the main menu
    exec /usr/local/bin/nook-menu.sh
}

# Run the boot sequence
main "$@"