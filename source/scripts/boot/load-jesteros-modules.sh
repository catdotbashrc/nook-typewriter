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
LOG_FILE="/var/log/squireos.log"
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
    log_message "JesterOS Module Loading Service Starting"
    log_message "========================================="
    
    # Load modules in dependency order
    log_message "Loading JesterOS kernel modules..."
    
    # 1. Core module first (creates /var/jesteros)
    if load_module "squireos_core"; then
        verify_module "$PROC_ROOT"
        
        # 2. Load feature modules (depend on core)
        load_module "jester"
        verify_module "$PROC_ROOT/jester"
        
        load_module "typewriter"
        verify_module "$PROC_ROOT/typewriter"
        
        load_module "wisdom"
        verify_module "$PROC_ROOT/wisdom"
    else
        log_message "[ERROR] Core module failed, skipping feature modules"
        exit 1
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
    touch /var/run/squireos.loaded
}

# Run main function
main "$@"

exit 0