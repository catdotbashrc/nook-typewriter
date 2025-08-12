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

# Main boot sequence
main() {
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