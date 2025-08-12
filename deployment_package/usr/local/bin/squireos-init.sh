#!/system/bin/sh
# SquireOS Early Boot Integration for Nook
# Runs during Android boot to load medieval modules
# "Before the digital dawn, we prepare the scriptorium"

# Android/Nook specific paths
CHROOT_PATH=/data/debian
MODULE_PATH=$CHROOT_PATH/lib/modules/2.6.29
LOG_FILE=/data/squireos-boot.log

# Logging
log() {
    echo "$(date): $1" >> $LOG_FILE
    echo "$1"
}

# Banner
show_banner() {
    echo "======================================="
    echo "    SquireOS Medieval Boot Sequence"
    echo "======================================="
    echo "     'By quill and candlelight,'"
    echo "      'the digital realm awakens'"
    echo "======================================="
}

# Main boot sequence
main() {
    show_banner | tee -a $LOG_FILE
    
    log "Starting SquireOS module loading..."
    
    # Check if we're on a Nook with proper kernel
    if [ -f /proc/cpuinfo ] && grep -q "OMAP3" /proc/cpuinfo; then
        log "Detected OMAP3 processor (Nook hardware)"
    else
        log "Warning: Not running on expected Nook hardware"
    fi
    
    # Load modules if they exist
    if [ -d "$MODULE_PATH" ]; then
        log "Found module directory: $MODULE_PATH"
        
        # Load in order
        for module in squireos_core jester typewriter wisdom; do
            if [ -f "$MODULE_PATH/${module}.ko" ]; then
                log "Loading $module..."
                if insmod "$MODULE_PATH/${module}.ko" 2>>$LOG_FILE; then
                    log "  [OK] $module loaded"
                else
                    log "  [FAIL] $module failed to load"
                fi
            else
                log "  [SKIP] $module.ko not found"
            fi
        done
    else
        log "Module directory not found: $MODULE_PATH"
    fi
    
    # Verify /proc/squireos exists
    if [ -d /proc/squireos ]; then
        log "Success! SquireOS interface available at /proc/squireos"
        
        # Display jester on E-Ink if fbink is available
        if [ -f /proc/squireos/jester ] && which fbink >/dev/null 2>&1; then
            log "Displaying jester on E-Ink..."
            cat /proc/squireos/jester | fbink -S
        fi
    else
        log "Warning: /proc/squireos not created"
    fi
    
    log "SquireOS boot sequence complete"
    
    # Set property for Android to know we're ready
    setprop squireos.loaded 1 2>/dev/null || true
}

# Run main
main

exit 0