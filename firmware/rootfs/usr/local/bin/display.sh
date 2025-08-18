#!/bin/bash
#
# Display Abstraction Layer for QuillKernel UI
# =============================================
# Provides unified interface for E-Ink and terminal display
# with intelligent refresh management and zone optimization
#
# Memory footprint: ~15KB
# Dependencies: fbink (optional), common.sh

set -euo pipefail

# Source common functions if available
COMMON_PATH="${COMMON_PATH:-/runtime/3-system/common/common.sh}"
[[ -f "$COMMON_PATH" ]] && source "$COMMON_PATH"

# ═══════════════════════════════════════════════════════════════
# Display Configuration
# ═══════════════════════════════════════════════════════════════

readonly DISPLAY_WIDTH=800
readonly DISPLAY_HEIGHT=600
readonly DISPLAY_CHARS_WIDTH=100  # 800px / 8px per char
readonly DISPLAY_LINES=37          # 600px / 16px per line

# Refresh modes
readonly REFRESH_FULL="full"
readonly REFRESH_PARTIAL="partial"
readonly REFRESH_NONE="none"

# Zone definitions (8 zones for partial refresh)
readonly ZONES_HORIZONTAL=4
readonly ZONES_VERTICAL=2
readonly ZONE_WIDTH=$((DISPLAY_WIDTH / ZONES_HORIZONTAL))
readonly ZONE_HEIGHT=$((DISPLAY_HEIGHT / ZONES_VERTICAL))

# Display state
declare -g DISPLAY_INITIALIZED=0
declare -g HAS_EINK=0
declare -g LAST_REFRESH_TIME=0
declare -g GHOSTING_COUNTER=0
declare -a DIRTY_ZONES=()

# ═══════════════════════════════════════════════════════════════
# Initialization
# ═══════════════════════════════════════════════════════════════

display_init() {
    local force_terminal="${1:-0}"
    
    if [[ "$force_terminal" == "1" ]]; then
        HAS_EINK=0
    elif command -v fbink >/dev/null 2>&1; then
        HAS_EINK=1
        # Initialize fbink with optimal settings
        fbink -q -y 0 -x 0 "" 2>/dev/null || HAS_EINK=0
    else
        HAS_EINK=0
    fi
    
    DISPLAY_INITIALIZED=1
    LAST_REFRESH_TIME=$(date +%s)
    GHOSTING_COUNTER=0
    
    # Clear display on init
    display_clear
    
    return 0
}

# Check if display is initialized
display_check_init() {
    if [[ "$DISPLAY_INITIALIZED" != "1" ]]; then
        display_init
    fi
}

# ═══════════════════════════════════════════════════════════════
# Core Display Functions
# ═══════════════════════════════════════════════════════════════

# Clear display with full refresh
display_clear() {
    display_check_init
    
    if [[ "$HAS_EINK" == "1" ]]; then
        fbink -c 2>/dev/null || true
    else
        clear
    fi
    
    # Reset zones
    DIRTY_ZONES=()
    GHOSTING_COUNTER=0
    
    return 0
}

# Display text at specific position
display_text() {
    local x="${1:-0}"
    local y="${2:-0}"
    local text="$3"
    local refresh_mode="${4:-$REFRESH_PARTIAL}"
    
    display_check_init
    
    if [[ "$HAS_EINK" == "1" ]]; then
        # E-Ink display
        if [[ "$refresh_mode" == "$REFRESH_FULL" ]]; then
            fbink -c -y "$y" -x "$x" "$text" 2>/dev/null || echo "$text"
        else
            fbink -y "$y" -x "$x" "$text" 2>/dev/null || echo "$text"
        fi
    else
        # Terminal display with ANSI positioning
        printf "\033[%d;%dH%s" "$((y + 1))" "$((x + 1))" "$text"
    fi
    
    # Mark zone as dirty
    _mark_zone_dirty "$x" "$y"
    
    return 0
}

# Display centered text
display_text_centered() {
    local y="$1"
    local text="$2"
    local refresh_mode="${3:-$REFRESH_PARTIAL}"
    
    local text_length=${#text}
    local x=$(( (DISPLAY_CHARS_WIDTH - text_length) / 2 ))
    
    display_text "$x" "$y" "$text" "$refresh_mode"
}

# ═══════════════════════════════════════════════════════════════
# Box and Border Drawing
# ═══════════════════════════════════════════════════════════════

# Draw a box with borders
display_box() {
    local x="$1"
    local y="$2"
    local width="$3"
    local height="$4"
    local style="${5:-single}"  # single, double, medieval
    
    local top_left top_right bottom_left bottom_right horizontal vertical
    
    case "$style" in
        double)
            top_left="╔"
            top_right="╗"
            bottom_left="╚"
            bottom_right="╝"
            horizontal="═"
            vertical="║"
            ;;
        medieval)
            top_left="╒"
            top_right="╕"
            bottom_left="╘"
            bottom_right="╛"
            horizontal="═"
            vertical="│"
            ;;
        *)  # single
            top_left="┌"
            top_right="┐"
            bottom_left="└"
            bottom_right="┘"
            horizontal="─"
            vertical="│"
            ;;
    esac
    
    # Top border
    local top_border="${top_left}"
    for ((i = 0; i < width - 2; i++)); do
        top_border="${top_border}${horizontal}"
    done
    top_border="${top_border}${top_right}"
    display_text "$x" "$y" "$top_border" "$REFRESH_NONE"
    
    # Side borders
    for ((i = 1; i < height - 1; i++)); do
        display_text "$x" "$((y + i))" "$vertical" "$REFRESH_NONE"
        display_text "$((x + width - 1))" "$((y + i))" "$vertical" "$REFRESH_NONE"
    done
    
    # Bottom border
    local bottom_border="${bottom_left}"
    for ((i = 0; i < width - 2; i++)); do
        bottom_border="${bottom_border}${horizontal}"
    done
    bottom_border="${bottom_border}${bottom_right}"
    display_text "$x" "$((y + height - 1))" "$bottom_border" "$REFRESH_NONE"
    
    return 0
}

# Fill a rectangular area
display_fill_rect() {
    local x="$1"
    local y="$2"
    local width="$3"
    local height="$4"
    local char="${5:- }"  # Default to space
    
    local fill_line=""
    for ((i = 0; i < width; i++)); do
        fill_line="${fill_line}${char}"
    done
    
    for ((i = 0; i < height; i++)); do
        display_text "$x" "$((y + i))" "$fill_line" "$REFRESH_NONE"
    done
    
    return 0
}

# ═══════════════════════════════════════════════════════════════
# ASCII Art Display
# ═══════════════════════════════════════════════════════════════

# Display ASCII art from string
display_ascii_art() {
    local x="$1"
    local y="$2"
    local art="$3"
    local refresh_mode="${4:-$REFRESH_PARTIAL}"
    
    local line_num=0
    while IFS= read -r line; do
        display_text "$x" "$((y + line_num))" "$line" "$REFRESH_NONE"
        ((line_num++))
    done <<< "$art"
    
    if [[ "$refresh_mode" != "$REFRESH_NONE" ]]; then
        display_refresh "$refresh_mode"
    fi
    
    return 0
}

# Display centered ASCII art
display_ascii_art_centered() {
    local y="$1"
    local art="$2"
    local refresh_mode="${3:-$REFRESH_PARTIAL}"
    
    # Find longest line for centering
    local max_length=0
    while IFS= read -r line; do
        local len=${#line}
        [[ $len -gt $max_length ]] && max_length=$len
    done <<< "$art"
    
    local x=$(( (DISPLAY_CHARS_WIDTH - max_length) / 2 ))
    display_ascii_art "$x" "$y" "$art" "$refresh_mode"
}

# ═══════════════════════════════════════════════════════════════
# Refresh Management
# ═══════════════════════════════════════════════════════════════

# Intelligent refresh based on zones
display_refresh() {
    local mode="${1:-$REFRESH_PARTIAL}"
    
    display_check_init
    
    if [[ "$HAS_EINK" == "1" ]]; then
        case "$mode" in
            "$REFRESH_FULL")
                fbink -c 2>/dev/null || true
                GHOSTING_COUNTER=0
                ;;
            "$REFRESH_PARTIAL")
                # Only refresh dirty zones
                if [[ ${#DIRTY_ZONES[@]} -gt 0 ]]; then
                    # For now, do a partial refresh
                    # In a real implementation, would refresh only dirty zones
                    fbink -s 2>/dev/null || true
                fi
                ((GHOSTING_COUNTER++))
                ;;
            "$REFRESH_NONE")
                # No refresh
                ;;
        esac
    fi
    
    # Clear dirty zones
    DIRTY_ZONES=()
    
    # Check for anti-ghosting refresh
    _check_anti_ghosting
    
    return 0
}

# Mark a zone as dirty
_mark_zone_dirty() {
    local x="$1"
    local y="$2"
    
    local zone_x=$((x / ZONE_WIDTH))
    local zone_y=$((y / ZONE_HEIGHT))
    local zone_id=$((zone_y * ZONES_HORIZONTAL + zone_x))
    
    # Add to dirty zones if not already there
    local found=0
    for zone in "${DIRTY_ZONES[@]}"; do
        [[ "$zone" == "$zone_id" ]] && found=1 && break
    done
    
    [[ "$found" == "0" ]] && DIRTY_ZONES+=("$zone_id")
}

# Check if anti-ghosting refresh is needed
_check_anti_ghosting() {
    local current_time=$(date +%s)
    local time_diff=$((current_time - LAST_REFRESH_TIME))
    
    # Full refresh every 10 minutes or 50 partial refreshes
    if [[ $time_diff -gt 600 ]] || [[ $GHOSTING_COUNTER -gt 50 ]]; then
        display_refresh "$REFRESH_FULL"
        LAST_REFRESH_TIME=$current_time
    fi
}

# ═══════════════════════════════════════════════════════════════
# Touch Input Handling
# ═══════════════════════════════════════════════════════════════

# Get touch coordinates (simulated in terminal)
display_get_touch() {
    if [[ "$HAS_EINK" == "1" ]]; then
        # Would read from touch device
        # For now, return simulated coordinates
        echo "400 300"  # Center of screen
    else
        # Terminal mode - use mouse if available
        echo "400 300"
    fi
}

# Convert touch coordinates to character position
display_touch_to_char() {
    local touch_x="$1"
    local touch_y="$2"
    
    local char_x=$((touch_x / 8))   # 8 pixels per character
    local char_y=$((touch_y / 16))  # 16 pixels per line
    
    echo "$char_x $char_y"
}

# ═══════════════════════════════════════════════════════════════
# Status Bar
# ═══════════════════════════════════════════════════════════════

# Display status bar at bottom
display_status_bar() {
    local left="$1"
    local center="$2"
    local right="$3"
    
    local y=$((DISPLAY_LINES - 2))
    
    # Clear status bar area
    display_fill_rect 0 "$y" "$DISPLAY_CHARS_WIDTH" 1 " "
    
    # Display sections
    display_text 2 "$y" "$left" "$REFRESH_NONE"
    display_text_centered "$y" "$center" "$REFRESH_NONE"
    
    local right_x=$((DISPLAY_CHARS_WIDTH - ${#right} - 2))
    display_text "$right_x" "$y" "$right" "$REFRESH_NONE"
    
    # Draw separator line above
    local separator=""
    for ((i = 0; i < DISPLAY_CHARS_WIDTH; i++)); do
        separator="${separator}─"
    done
    display_text 0 $((y - 1)) "$separator" "$REFRESH_PARTIAL"
}

# ═══════════════════════════════════════════════════════════════
# Utility Functions
# ═══════════════════════════════════════════════════════════════

# Save current display state
display_save_state() {
    local state_file="${1:-/tmp/display.state}"
    
    {
        echo "DISPLAY_INITIALIZED=$DISPLAY_INITIALIZED"
        echo "HAS_EINK=$HAS_EINK"
        echo "LAST_REFRESH_TIME=$LAST_REFRESH_TIME"
        echo "GHOSTING_COUNTER=$GHOSTING_COUNTER"
    } > "$state_file"
}

# Restore display state
display_restore_state() {
    local state_file="${1:-/tmp/display.state}"
    
    [[ -f "$state_file" ]] && source "$state_file"
}

# Get display info
display_info() {
    cat <<EOF
Display Information:
  Initialized: $DISPLAY_INITIALIZED
  E-Ink Available: $HAS_EINK
  Resolution: ${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}
  Character Grid: ${DISPLAY_CHARS_WIDTH}x${DISPLAY_LINES}
  Zones: ${ZONES_HORIZONTAL}x${ZONES_VERTICAL}
  Ghosting Counter: $GHOSTING_COUNTER
  Dirty Zones: ${#DIRTY_ZONES[@]}
EOF
}

# ═══════════════════════════════════════════════════════════════
# Export functions for use by other components
# ═══════════════════════════════════════════════════════════════

export -f display_init
export -f display_clear
export -f display_text
export -f display_text_centered
export -f display_box
export -f display_fill_rect
export -f display_ascii_art
export -f display_ascii_art_centered
export -f display_refresh
export -f display_get_touch
export -f display_touch_to_char
export -f display_status_bar
export -f display_info

# Mark as loaded
export DISPLAY_LIB_LOADED=1

# Auto-initialize if sourced directly
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && display_init