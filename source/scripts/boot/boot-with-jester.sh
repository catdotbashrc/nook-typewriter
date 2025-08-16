#!/bin/sh
# Complete JesterOS Boot Sequence
# Shows splash screen, then initializes JesterOS userspace

# Enhanced safety settings for reliable boot
set -euo pipefail
trap 'echo "Error in boot-with-jester.sh at line $LINENO" >&2' ERR

# Boot logging
BOOT_LOG="${BOOT_LOG:-/var/log/jesteros-boot.log}"
boot_log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [boot-with-jester] $1" >> "$BOOT_LOG" 2>/dev/null || true
    echo "[boot] $1" >&2
}

boot_log "Starting complete JesterOS boot sequence"

# Detect if we're on E-Ink display
IS_EINK=0
if [ -e /dev/fb0 ] && command -v fbink >/dev/null 2>&1; then
    IS_EINK=1
    boot_log "E-Ink display detected"
else
    boot_log "No E-Ink display found, using terminal output"
fi

# Show appropriate splash screen
show_splash() {
    if [ "$IS_EINK" = "1" ]; then
        # E-Ink optimized version
        /usr/local/bin/jester-splash-eink.sh
    else
        # Terminal version (for testing)
        if [ -f /usr/local/bin/jester-dance.sh ]; then
            # Animated version if available
            /usr/local/bin/jester-dance.sh
        else
            # Static version as fallback
            /usr/local/bin/jester-splash.sh
        fi
    fi
}

# Initialize JesterOS
init_jesteros() {
    echo "Initializing JesterOS services..."
    
    # Start the userspace implementation
    /usr/local/bin/jesteros-userspace.sh
    
    # Start the tracker daemon
    /usr/local/bin/jesteros-tracker.sh &
    TRACKER_PID=$!
    echo $TRACKER_PID > /var/run/jesteros-tracker.pid
    
    echo "JesterOS ready at /var/jesteros/"
}

# Main boot sequence
main() {
    # Show our glorious jester splash!
    show_splash
    
    # Initialize JesterOS
    init_jesteros
    
    # Show final ready message
    if [ "$IS_EINK" = "1" ]; then
        # For E-Ink, show a simple ready screen
        clear
        cat << 'READY'
    
    ========================================
              NOOK TYPEWRITER READY
    ========================================
    
             Type 'vim' to begin writing
    
           JesterOS monitoring active at:
              /var/jesteros/
    
    ========================================
    
READY
    else
        # For terminal, show the jester status
        echo ""
        echo "========================================="
        cat /var/jesteros/jester
        echo "========================================="
    fi
}

# Run the boot sequence
main "$@"