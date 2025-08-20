#!/system/bin/sh
# JesterOS Boot Integration for Nook Touch
# Hybrid Android/JesterOS initialization
# "Where silicon meets parchment, the digital scriptorium awakens"

# Safety settings for reliable boot
set -eu
trap 'echo "Error in jesteros-init.sh at line $LINENO" >&2' ERR

# Android/JesterOS paths
JESTEROS_ROOT=/var/jesteros
RUNTIME_DIR=/system/jesteros
LOG_FILE=/data/jesteros-boot.log
PID_FILE=/data/jesteros.pid

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

# Create mount points and directories
setup_filesystem() {
    log_info "Setting up JesterOS filesystem..."
    
    # Create JesterOS directories
    mkdir -p $JESTEROS_ROOT 2>/dev/null || true
    mkdir -p $JESTEROS_ROOT/typewriter 2>/dev/null || true
    mkdir -p $JESTEROS_ROOT/ascii 2>/dev/null || true
    mkdir -p /data/jesteros 2>/dev/null || true
    
    # Create runtime directories
    mkdir -p $RUNTIME_DIR/bin 2>/dev/null || true
    mkdir -p $RUNTIME_DIR/lib 2>/dev/null || true
    mkdir -p $RUNTIME_DIR/etc 2>/dev/null || true
    
    # Set permissions
    chmod 755 $JESTEROS_ROOT 2>/dev/null || true
    chmod 755 $RUNTIME_DIR 2>/dev/null || true
    
    log_info "Filesystem setup complete"
}

# Start JesterOS services
start_services() {
    log_info "Starting JesterOS services..."
    
    # Clear boot counter to prevent factory reset
    if [ -f /system/bin/clrbootcount.sh ]; then
        /system/bin/clrbootcount.sh
        log_info "Boot counter cleared"
    fi
    
    # Start memory guardian
    if [ -f $RUNTIME_DIR/bin/memory-guardian.sh ]; then
        $RUNTIME_DIR/bin/memory-guardian.sh &
        echo $! > /data/memory-guardian.pid
        log_info "Memory guardian started (PID: $(cat /data/memory-guardian.pid))"
    fi
    
    # Initialize E-ink display
    if [ -c /dev/fb0 ]; then
        echo 1 > /sys/class/graphics/fb0/blank 2>/dev/null || true
        echo 0 > /sys/class/graphics/fb0/blank 2>/dev/null || true
        log_info "E-ink display initialized"
    fi
    
    # Start JesterOS daemon
    if [ -f $RUNTIME_DIR/bin/jester-daemon.sh ]; then
        $RUNTIME_DIR/bin/jester-daemon.sh &
        echo $! > $PID_FILE
        log_info "JesterOS daemon started (PID: $(cat $PID_FILE))"
    fi
    
    log_info "All services started"
}

# Main boot sequence
main() {
    show_banner | tee -a $LOG_FILE
    
    log "Starting JesterOS initialization..."
    
    # Check if we're on a Nook with proper kernel
    if [ -f /proc/cpuinfo ] && grep -q "OMAP3" /proc/cpuinfo; then
        log "Detected OMAP3 processor (Nook hardware) ✓"
    else
        log "Warning: Not running on expected Nook hardware"
    fi
    
    # Setup filesystem
    setup_filesystem
    
    # Start services
    start_services
    
    # Verify JesterOS is ready
    if [ -d $JESTEROS_ROOT ] && [ -f $PID_FILE ]; then
        log_info "Success! JesterOS is ready at $JESTEROS_ROOT"
        log_info "Jester daemon running (PID: $(cat $PID_FILE))"
        
        # Display welcome message on E-Ink if possible
        if [ -f $JESTEROS_ROOT/ascii/jester.txt ] && which fbink >/dev/null 2>&1; then
            log_info "Displaying jester on E-Ink..."
            cat $JESTEROS_ROOT/ascii/jester.txt | fbink -S
        fi
    else
        log_error "JesterOS initialization incomplete"
    fi
    
    log "JesterOS boot sequence complete"
    
    # Set property for Android to know we're ready
    setprop jesteros.loaded 1 2>/dev/null || true
    setprop jesteros.version "1.0.0-alpha.1" 2>/dev/null || true
}

# Run main
main

exit 0