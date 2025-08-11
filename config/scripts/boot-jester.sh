#!/bin/bash
# Boot Script with Mischievous Jester
# This runs on Nook startup to show our festive friend!

# E-Ink display initialization
init_display() {
    # Initialize FBInk if available
    if command -v fbink >/dev/null 2>&1; then
        # Clear and initialize E-Ink
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
    sleep 1
    
    # Launch the main menu
    exec /usr/local/bin/nook-menu.sh
}

# Run the boot sequence
main "$@"