#!/bin/bash
# Boot Script with Mischievous Jester
# This runs on Nook startup to show our festive friend!

# Safety settings for reliable boot
set -euo pipefail
trap 'boot_log "ERROR" "Error at line $LINENO in boot-jester.sh"; echo "Error at line $LINENO" >&2' ERR

# Boot logging configuration
BOOT_LOG="${BOOT_LOG:-/var/log/jesteros-boot.log}"
LOG_TIMESTAMP_FORMAT="+%Y-%m-%d %H:%M:%S"

# Boot logging function
boot_log() {
    local level="${1:-INFO}"
    local message="${2:-}"
    local timestamp="$(date "$LOG_TIMESTAMP_FORMAT")"
    echo "[$timestamp] [$level] [boot-jester] $message" >> "$BOOT_LOG" 2>/dev/null || true
    # Also echo to console for debugging
    echo "[boot-jester] $message" >&2
}

boot_log "INFO" "Starting JesterOS boot sequence"

# Source common functions and safety settings
COMMON_PATH="${COMMON_PATH:-/runtime/scripts/lib/common.sh}"
if [[ -f "$COMMON_PATH" ]]; then
    source "$COMMON_PATH"
else
    # Common.sh not found, but safety already set at top
    boot_log "WARN" "Common library not found at $COMMON_PATH"
fi

# E-Ink display initialization
init_display() {
    # Use common display functions if available
    if [[ "${JESTEROS_COMMON_LOADED:-0}" == "1" ]]; then
        clear_display
        debug_log "Display initialized via common library"
        boot_log "INFO" "Display initialized via common library"
    elif command -v fbink >/dev/null 2>&1; then
        # Fallback to direct fbink calls
        fbink -c
        fbink -g brightness=100 2>/dev/null || true
        boot_log "INFO" "Display initialized via fbink"
    fi
}

# Verify JesterOS userspace services
verify_jesteros_services() {
    echo "Verifying JesterOS userspace services..."
    boot_log "INFO" "Checking JesterOS userspace services"
    
    # JesterOS now runs entirely in userspace - no kernel modules needed!
    # Services are provided by shell scripts in /var/jesteros/
    
    if [ -d /var/jesteros ]; then
        echo "✓ JesterOS services directory available"
        boot_log "INFO" "JesterOS userspace services ready at /var/jesteros/"
        
        # Check for key service files
        local services_found=0
        for service in jester typewriter/stats wisdom; do
            if [ -e "/var/jesteros/$service" ]; then
                boot_log "INFO" "Found service: $service"
                ((services_found++))
            fi
        done
        
        echo "✓ JesterOS services available ($services_found services found)"
        boot_log "INFO" "JesterOS ready with $services_found userspace services"
    else
        echo "⚠ JesterOS services directory not found - will be created"
        boot_log "WARN" "JesterOS services directory not found yet"
    fi
}

# Main boot sequence
main() {
    boot_log "INFO" "Starting main boot sequence"
    
    # Verify JesterOS userspace services (no kernel modules needed)
    verify_jesteros_services
    
    # Initialize display
    init_display
    
    # Show the mischievous jester animations
    if [ -x /usr/local/bin/jester-mischief.sh ]; then
        boot_log "INFO" "Starting jester animations"
        /usr/local/bin/jester-mischief.sh boot || boot_log "WARN" "Jester animations failed"
    else
        boot_log "WARN" "Jester animations script not found or not executable"
    fi
    
    # Start the jester daemon in background
    if [ -x /usr/local/bin/jester-daemon.sh ]; then
        boot_log "INFO" "Starting jester daemon"
        /usr/local/bin/jester-daemon.sh start &
        local daemon_pid=$!
        boot_log "INFO" "Jester daemon started with PID $daemon_pid"
    else
        boot_log "ERROR" "Jester daemon script not found or not executable"
    fi
    
    # Brief pause to enjoy the moment
    e_sleep "${BOOT_DELAY:-1}"
    
    # Launch the main menu
    boot_log "INFO" "Launching main menu"
    if [ -x /usr/local/bin/nook-menu.sh ]; then
        exec /usr/local/bin/nook-menu.sh
    else
        boot_log "ERROR" "Main menu script not found or not executable"
        echo "ERROR: Cannot launch main menu!" >&2
        exit 1
    fi
}

# Run the boot sequence
main "$@"