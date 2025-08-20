#!/system/bin/sh
# JesterOS Early Boot Integration for Nook
# Runs during Android boot to load medieval modules
# "Before the digital dawn, we prepare the scriptorium"

# Safety settings for reliable boot
set -eu
trap 'echo "Error in jesteros-init.sh at line $LINENO" >&2' ERR

# Android/Nook specific paths
CHROOT_PATH=/data/debian
MODULE_PATH=$CHROOT_PATH/lib/modules/2.6.29
LOG_FILE=/data/jesteros-boot.log

# Enhanced logging with timestamps
LOG_TIMESTAMP_FORMAT="+%Y-%m-%d %H:%M:%S"

# Enhanced logging function with levels
log() {
    local level="${2:-INFO}"
    local message="$1"
    local timestamp="$(date "$LOG_TIMESTAMP_FORMAT")"
    echo "[$timestamp] [$level] [jesteros-init] $message" >> $LOG_FILE 2>/dev/null || true
    echo "[jesteros-init] $message"
}

# Convenience logging functions
log_info() { log "$1" "INFO"; }
log_error() { log "$1" "ERROR"; }
log_debug() { log "$1" "DEBUG"; }

# Banner
show_banner() {
    log_info "Displaying JesterOS boot banner"
    echo "======================================="
    echo "    JesterOS Medieval Boot Sequence"
    echo "======================================="
    echo "     'By quill and candlelight,'"
    echo "      'the digital realm awakens'"
    echo "======================================="
}

# Main boot sequence
main() {
    show_banner | tee -a $LOG_FILE
    
    log "Starting JesterOS module loading..."
    
    # Check if we're on a Nook with proper kernel
    if [ -f /proc/cpuinfo ] && grep -q "OMAP3" /proc/cpuinfo; then
        log "Detected OMAP3 processor (Nook hardware)"
    else
        log "Warning: Not running on expected Nook hardware"
    fi
    
    # JesterOS runs in userspace - no kernel modules needed!
    log_info "JesterOS is userspace-only - skipping module loading"
    log_info "Services will be provided by shell scripts in /var/jesteros/"
    
    # Verify JesterOS userspace directory exists
    if [ -d /var/jesteros ]; then
        log_info "Success! JesterOS interface available at /var/jesteros"
        
        # Display jester on E-Ink if fbink is available
        if [ -f /var/jesteros/jester ] && which fbink >/dev/null 2>&1; then
            log_info "Displaying jester on E-Ink..."
            cat /var/jesteros/jester | fbink -S
        fi
    else
        log_info "JesterOS directory will be created by jesteros-userspace.sh"
    fi
    
    log "JesterOS boot sequence complete"
    
    # Set property for Android to know we're ready
    setprop jesteros.loaded 1 2>/dev/null || true
}

# Run main
main

exit 0