#!/bin/sh
# JesterOS Module Loading Script [DEPRECATED]
# NOTE: JesterOS now runs entirely in userspace - no kernel modules needed!
# This script is kept for reference but does nothing
# "By quill and candlelight, we awaken the digital scriptorium"

# Safety settings for reliable module loading
set -eu
trap 'echo "Error in load-jesteros-modules.sh at line $LINENO" >&2' ERR

# Configuration
MODULE_DIR="/lib/modules/2.6.29"
LOG_FILE="/var/log/jesteros.log"
PROC_ROOT="/var/jesteros"

# Logging function
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
    echo "$1"
}

# ASCII banner for boot
show_banner() {
    cat << 'EOF'
===============================================
      JesterOS Medieval Writing System
===============================================
         .~"~.~"~.
        /  o   o  \    
       |  >  u  <  |   Your digital squire
        \  ___  /      awakens...
         |~|*|~|       
===============================================
EOF
}

# Module loading function
load_module() {
    local module_name="$1"
    local module_file="$MODULE_DIR/$module_name.ko"
    
    if [ -f "$module_file" ]; then
        log_message "Loading module: $module_name"
        if insmod "$module_file" 2>/dev/null; then
            log_message "  [OK] $module_name loaded successfully"
            return 0
        else
            log_message "  [WARN] Failed to load $module_name"
            return 1
        fi
    else
        log_message "  [SKIP] $module_name not found at $module_file"
        return 2
    fi
}

# Verify module loaded by checking /proc interface
verify_module() {
    local proc_path="$1"
    
    if [ -e "$proc_path" ]; then
        log_message "  [OK] Verified: $proc_path exists"
        return 0
    else
        log_message "  [WARN] Not found: $proc_path"
        return 1
    fi
}

# Main loading sequence
main() {
    # Show banner
    show_banner
    
    # Create log directory if needed
    mkdir -p "$(dirname "$LOG_FILE")"
    
    log_message "========================================="
    log_message "JesterOS Userspace Service Starting"
    log_message "========================================="
    
    # JesterOS is now entirely userspace - no kernel modules!
    log_message "[INFO] JesterOS runs in userspace - no kernel modules to load"
    log_message "[INFO] Starting userspace services instead..."
    
    # Start JesterOS userspace services
    if [ -x /usr/local/bin/jesteros-userspace.sh ]; then
        /usr/local/bin/jesteros-userspace.sh start
        log_message "[OK] JesterOS userspace services started"
    elif [ -x /source/scripts/services/jester-daemon.sh ]; then
        /source/scripts/services/jester-daemon.sh &
        log_message "[OK] Jester daemon started"
    else
        log_message "[INFO] JesterOS userspace script not found (normal in minimal boot)"
    fi
    
    # Display initial jester greeting if available
    if [ -f "$PROC_ROOT/jester" ]; then
        log_message ""
        log_message "The Court Jester speaks:"
        cat "$PROC_ROOT/jester" | tee -a "$LOG_FILE"
    fi
    
    # Display wisdom of the day
    if [ -f "$PROC_ROOT/wisdom" ]; then
        log_message ""
        log_message "Today's Writing Wisdom:"
        cat "$PROC_ROOT/wisdom" | tee -a "$LOG_FILE"
    fi
    
    log_message ""
    log_message "========================================="
    log_message "JesterOS modules loaded successfully!"
    log_message "Digital scriptorium ready for writing."
    log_message "========================================="
    
    # Create success marker
    touch /var/run/jesteros.loaded
}

# Run main function
main "$@"

exit 0