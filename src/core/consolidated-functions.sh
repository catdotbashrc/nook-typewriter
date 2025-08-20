#!/bin/bash
# consolidated-functions.sh - Centralized function library for JesterOS
# Eliminates code duplication across the runtime system
# Part of Phase 2 consolidation effort

set -euo pipefail

# =============================================================================
# DISPLAY FUNCTIONS (Consolidated from multiple scripts)
# =============================================================================

# Unified display_text function (replaces 2 duplicates)
display_text() {
    local text="${1:-}"
    local refresh="${2:-partial}"  # partial or full
    
    # Check for E-Ink display
    if command -v fbink >/dev/null 2>&1 && [ -e /dev/fb0 ]; then
        case "$refresh" in
            full)
                echo "$text" | fbink -c -
                ;;
            *)
                echo "$text" | fbink -
                ;;
        esac
    else
        # Fallback to terminal
        echo "$text"
    fi
}

# Clear display (unified)
clear_display() {
    if command -v fbink >/dev/null 2>&1 && [ -e /dev/fb0 ]; then
        fbink -c
    else
        clear
    fi
}

# Display error with proper formatting
display_error() {
    local message="${1:-Error occurred}"
    display_text "❌ ERROR: $message" "full"
    [ -n "${LOG_FILE:-}" ] && echo "$(date '+%Y-%m-%d %H:%M:%S') ERROR: $message" >> "$LOG_FILE"
}

# Display status message
display_status() {
    local message="${1:-}"
    local icon="${2:-ℹ️}"
    display_text "$icon $message" "partial"
}

# =============================================================================
# MENU VALIDATION (Consolidated from menu scripts)
# =============================================================================

# Unified menu choice validation (replaces 2 duplicates)
validate_menu_choice() {
    local choice="${1:-}"
    local min="${2:-1}"
    local max="${3:-9}"
    
    # Check if empty
    [ -z "$choice" ] && return 1
    
    # Check if numeric
    if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
        return 1
    fi
    
    # Check range
    if [ "$choice" -lt "$min" ] || [ "$choice" -gt "$max" ]; then
        return 1
    fi
    
    return 0
}

# Safe read with timeout
safe_read() {
    local prompt="${1:-Enter choice: }"
    local timeout="${2:-30}"
    local default="${3:-}"
    local response
    
    if read -t "$timeout" -p "$prompt" response; then
        echo "${response:-$default}"
    else
        echo "$default"
    fi
}

# =============================================================================
# JESTER MOOD FUNCTIONS (Consolidated from 2 scripts)
# =============================================================================

# Unified jester mood update (replaces 2 duplicates)
update_jester_mood() {
    local mood="${1:-happy}"
    local mood_file="/var/jesteros/jester/mood"
    
    # Ensure directory exists
    mkdir -p "$(dirname "$mood_file")" 2>/dev/null || true
    
    # Determine mood based on system state if not provided
    if [ "$mood" = "auto" ]; then
        local free_mem=$(awk '/MemAvailable:/ {print $2}' /proc/meminfo 2>/dev/null || echo "100000")
        local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1 2>/dev/null || echo "50")
        
        if [ "$free_mem" -lt 20000 ]; then
            mood="stressed"
        elif [ "${cpu_usage%%.*}" -gt 80 ]; then
            mood="busy"
        else
            mood="happy"
        fi
    fi
    
    # Write mood
    echo "$mood" > "$mood_file"
    
    # Update ASCII art if available
    local ascii_file="/var/jesteros/jester/ascii"
    case "$mood" in
        happy)
            cat > "$ascii_file" << 'EOF'
     ___
    /^ ^\
   | ◉ ◉ |
   |  ‿  |
    \___/
     |♦|
EOF
            ;;
        stressed)
            cat > "$ascii_file" << 'EOF'
     ___
    /@_@\
   | > < |
   |  ︵  |
    \___/
     |♦|
EOF
            ;;
        busy)
            cat > "$ascii_file" << 'EOF'
     ___
    /- -\
   | ∘ ∘ |
   |  ~  |
    \___/
     |♦|
EOF
            ;;
    esac
}

# Get current jester mood
get_jester_mood() {
    local mood_file="/var/jesteros/jester/mood"
    if [ -f "$mood_file" ]; then
        cat "$mood_file"
    else
        echo "happy"
    fi
}

# =============================================================================
# MONITORING FUNCTIONS (Consolidated)
# =============================================================================

# Unified sensor logging (replaces multiple log_sensor functions)
log_sensor() {
    local message="${1:-}"
    local level="${2:-INFO}"
    local log_file="${SENSOR_LOG:-/var/log/jesteros/sensors.log}"
    
    mkdir -p "$(dirname "$log_file")" 2>/dev/null || true
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$level] $message" >> "$log_file"
}

# Generic monitoring function
monitor_service() {
    local service_name="${1:-unknown}"
    local check_function="${2:-true}"
    local interval="${3:-30}"
    local log_file="/var/log/jesteros/${service_name}.log"
    
    log_sensor "Starting $service_name monitor" "INFO"
    
    while true; do
        if $check_function; then
            log_sensor "$service_name check passed" "DEBUG"
        else
            log_sensor "$service_name check failed" "WARN"
        fi
        sleep "$interval"
    done
}

# =============================================================================
# CONSOLE OPTIMIZATION (Consolidated)
# =============================================================================

# Unified console optimization (replaces 2 duplicates)
optimize_console() {
    # Disable cursor blinking
    echo -e "\033[?25l"
    
    # Set optimal terminal settings for E-Ink
    stty -echo -icanon min 1 time 0 2>/dev/null || true
    
    # Clear scrollback buffer
    echo -e "\033[3J"
    
    # Set up trap to restore on exit
    trap 'echo -e "\033[?25h"; stty sane 2>/dev/null || true' EXIT
}

# Restore console settings
restore_console() {
    echo -e "\033[?25h"  # Show cursor
    stty sane 2>/dev/null || true
}

# =============================================================================
# FONT MANAGEMENT (Consolidated)
# =============================================================================

# Find best font for E-Ink (replaces 2 duplicates)
find_best_font() {
    local size="${1:-12}"
    local font_dirs="/usr/share/fonts /usr/local/share/fonts"
    local best_font=""
    
    # Priority order for E-Ink readability
    local preferred_fonts=(
        "DejaVuSansMono.ttf"
        "LiberationMono-Regular.ttf"
        "DroidSansMono.ttf"
        "Inconsolata.ttf"
        "terminus-font"
    )
    
    for font in "${preferred_fonts[@]}"; do
        for dir in $font_dirs; do
            if find "$dir" -name "$font" 2>/dev/null | head -1; then
                return 0
            fi
        done
    done
    
    # Fallback to any monospace font
    find $font_dirs -name "*mono*.ttf" 2>/dev/null | head -1
}

# =============================================================================
# PATH CONFIGURATION (Replaces hardcoded paths)
# =============================================================================

# Get JesterOS paths (eliminates hardcoded paths)
get_jesteros_path() {
    local component="${1:-}"
    
    # Base paths (configurable via environment)
    local BASE_DIR="${JESTEROS_BASE:-/runtime}"
    local CONFIG_DIR="${JESTEROS_CONFIG:-$BASE_DIR/config}"
    local VAR_DIR="${JESTEROS_VAR:-/var/jesteros}"
    local LOG_DIR="${JESTEROS_LOG:-/var/log/jesteros}"
    
    case "$component" in
        base)       echo "$BASE_DIR" ;;
        config)     echo "$CONFIG_DIR" ;;
        var)        echo "$VAR_DIR" ;;
        log)        echo "$LOG_DIR" ;;
        ui)         echo "$BASE_DIR/1-ui" ;;
        app)        echo "$BASE_DIR/2-application" ;;
        system)     echo "$BASE_DIR/3-system" ;;
        hardware)   echo "$BASE_DIR/4-hardware" ;;
        menu)       echo "$BASE_DIR/1-ui/menu" ;;
        jester)     echo "$VAR_DIR/jester" ;;
        sensors)    echo "$VAR_DIR/sensors" ;;
        power)      echo "$VAR_DIR/power" ;;
        memory)     echo "$CONFIG_DIR/memory.conf" ;;
        *)          echo "$BASE_DIR" ;;
    esac
}

# =============================================================================
# WRITING MODE FUNCTIONS (Consolidated)
# =============================================================================

# Monitor writing activity (replaces 2 duplicates)
monitor_writing() {
    local stats_file="$(get_jesteros_path var)/typewriter/stats"
    local last_count=0
    
    mkdir -p "$(dirname "$stats_file")" 2>/dev/null || true
    
    # Initialize stats if not exists
    if [ ! -f "$stats_file" ]; then
        cat > "$stats_file" << EOF
words=0
keystrokes=0
session_start=$(date +%s)
EOF
    fi
    
    # Check if vim is running
    if pgrep -x vim >/dev/null 2>&1; then
        # Update writing status
        echo "active" > "$(get_jesteros_path var)/typewriter/status"
        update_jester_mood "busy"
    else
        echo "idle" > "$(get_jesteros_path var)/typewriter/status"
        update_jester_mood "auto"
    fi
}

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Safe cleanup function
safe_cleanup() {
    local target="${1:-/tmp/jesteros_*}"
    
    # Only clean JesterOS temp files
    if [[ "$target" == /tmp/jesteros_* ]]; then
        rm -f $target 2>/dev/null || true
    fi
}

# Check if running on actual Nook hardware
is_nook_hardware() {
    # Check for Nook-specific hardware indicators
    if [ -f /sys/devices/platform/omap3epfb/graphics/fb0/epd_refresh ]; then
        return 0
    elif [ -f /sys/class/graphics/fb0/device/name ] && grep -q "eink\|epd" /sys/class/graphics/fb0/device/name 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Get system resource status
get_system_status() {
    local mem_free=$(awk '/MemAvailable:/ {print int($2/1024)}' /proc/meminfo)
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print int($2)}')
    local battery=$(cat /sys/class/power_supply/battery/capacity 2>/dev/null || echo "?")
    
    echo "Memory: ${mem_free}MB | CPU: ${cpu_usage}% | Battery: ${battery}%"
}

# =============================================================================
# EXPORT FUNCTIONS
# =============================================================================

# Export all consolidated functions for use in other scripts
export -f display_text clear_display display_error display_status
export -f validate_menu_choice safe_read
export -f update_jester_mood get_jester_mood
export -f log_sensor monitor_service
export -f optimize_console restore_console
export -f find_best_font
export -f get_jesteros_path
export -f monitor_writing
export -f safe_cleanup is_nook_hardware get_system_status

# Source this file in other scripts with:
# source /src/3-system/common/consolidated-functions.sh