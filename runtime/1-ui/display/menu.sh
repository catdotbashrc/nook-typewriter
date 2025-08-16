#!/bin/bash
#
# Menu Component System for QuillKernel UI
# =========================================
# Reusable menu component with medieval theming,
# touch support, and E-Ink optimization
#
# Memory footprint: ~8KB
# Dependencies: display.sh

set -euo pipefail

# Source display library
DISPLAY_LIB="${DISPLAY_LIB:-/usr/local/bin/display.sh}"
if [[ -f "$DISPLAY_LIB" ]]; then
    source "$DISPLAY_LIB"
else
    echo "Error: display.sh not found" >&2
    exit 1
fi

# ═══════════════════════════════════════════════════════════════
# Menu Configuration
# ═══════════════════════════════════════════════════════════════

# Menu item structure
declare -A MENU_ITEMS=()
declare -A MENU_HOTKEYS=()
declare -A MENU_ACTIONS=()
declare -A MENU_STATES=()  # normal, selected, disabled

# Menu state
declare -g MENU_ID=""
declare -g MENU_TITLE=""
declare -g MENU_SELECTED=0
declare -g MENU_ITEM_COUNT=0
declare -g MENU_X=0
declare -g MENU_Y=0
declare -g MENU_WIDTH=0
declare -g MENU_HEIGHT=0
declare -g MENU_STYLE="medieval"
declare -g MENU_SHOW_JESTER=1

# Selection indicators
readonly INDICATOR_NORMAL="  "
readonly INDICATOR_SELECTED="☞ "
readonly INDICATOR_DISABLED="  "
readonly INDICATOR_ACTIVE="▸ "

# ═══════════════════════════════════════════════════════════════
# Menu Creation and Configuration
# ═══════════════════════════════════════════════════════════════

# Create a new menu
menu_create() {
    local id="$1"
    local title="$2"
    local x="${3:-10}"
    local y="${4:-5}"
    local width="${5:-60}"
    local height="${6:-20}"
    
    MENU_ID="$id"
    MENU_TITLE="$title"
    MENU_X="$x"
    MENU_Y="$y"
    MENU_WIDTH="$width"
    MENU_HEIGHT="$height"
    MENU_SELECTED=0
    MENU_ITEM_COUNT=0
    
    # Clear existing items
    MENU_ITEMS=()
    MENU_HOTKEYS=()
    MENU_ACTIONS=()
    MENU_STATES=()
    
    return 0
}

# Add item to menu
menu_add_item() {
    local label="$1"
    local action="$2"
    local hotkey="${3:-}"
    local state="${4:-normal}"  # normal, disabled
    
    MENU_ITEMS[$MENU_ITEM_COUNT]="$label"
    MENU_ACTIONS[$MENU_ITEM_COUNT]="$action"
    MENU_STATES[$MENU_ITEM_COUNT]="$state"
    
    if [[ -n "$hotkey" ]]; then
        MENU_HOTKEYS[$MENU_ITEM_COUNT]="$hotkey"
        # Also create reverse mapping for quick lookup
        MENU_HOTKEYS["key_$hotkey"]="$MENU_ITEM_COUNT"
    fi
    
    ((MENU_ITEM_COUNT++))
    
    return 0
}

# Add separator
menu_add_separator() {
    MENU_ITEMS[$MENU_ITEM_COUNT]="───────────────────"
    MENU_ACTIONS[$MENU_ITEM_COUNT]=""
    MENU_STATES[$MENU_ITEM_COUNT]="disabled"
    ((MENU_ITEM_COUNT++))
}

# ═══════════════════════════════════════════════════════════════
# Menu Rendering
# ═══════════════════════════════════════════════════════════════

# Render the complete menu
menu_render() {
    local refresh_mode="${1:-$REFRESH_FULL}"
    
    # Clear menu area
    display_clear
    
    # Draw border
    _menu_draw_border
    
    # Draw title
    _menu_draw_title
    
    # Draw jester if enabled
    if [[ "$MENU_SHOW_JESTER" == "1" ]]; then
        _menu_draw_jester
    fi
    
    # Draw menu items
    _menu_draw_items
    
    # Draw footer
    _menu_draw_footer
    
    # Refresh display
    display_refresh "$refresh_mode"
    
    return 0
}

# Draw menu border
_menu_draw_border() {
    case "$MENU_STYLE" in
        medieval)
            display_box "$MENU_X" "$MENU_Y" "$MENU_WIDTH" "$MENU_HEIGHT" "medieval"
            ;;
        double)
            display_box "$MENU_X" "$MENU_Y" "$MENU_WIDTH" "$MENU_HEIGHT" "double"
            ;;
        *)
            display_box "$MENU_X" "$MENU_Y" "$MENU_WIDTH" "$MENU_HEIGHT" "single"
            ;;
    esac
}

# Draw menu title
_menu_draw_title() {
    local title_y=$((MENU_Y + 1))
    
    # Medieval decoration
    if [[ "$MENU_STYLE" == "medieval" ]]; then
        local decorated_title="⚔ $MENU_TITLE ⚔"
        display_text_centered "$title_y" "$decorated_title" "$REFRESH_NONE"
        
        # Separator line
        local separator="═══════════════════════════════"
        display_text_centered $((title_y + 1)) "$separator" "$REFRESH_NONE"
    else
        display_text_centered "$title_y" "$MENU_TITLE" "$REFRESH_NONE"
    fi
}

# Draw jester mascot
_menu_draw_jester() {
    local jester_art="  .·:·.  
 ( o o ) 
 | > < | 
  \___/  
  |♦|♦|  "
    
    local jester_x=$((MENU_X + MENU_WIDTH - 12))
    local jester_y=$((MENU_Y + 2))
    
    display_ascii_art "$jester_x" "$jester_y" "$jester_art" "$REFRESH_NONE"
}

# Draw menu items
_menu_draw_items() {
    local start_y=$((MENU_Y + 4))
    local item_x=$((MENU_X + 3))
    
    for ((i = 0; i < MENU_ITEM_COUNT; i++)); do
        local item_y=$((start_y + i))
        local label="${MENU_ITEMS[$i]}"
        local state="${MENU_STATES[$i]}"
        local indicator="$INDICATOR_NORMAL"
        
        # Determine indicator
        if [[ "$i" == "$MENU_SELECTED" ]]; then
            indicator="$INDICATOR_SELECTED"
        elif [[ "$state" == "disabled" ]]; then
            indicator="$INDICATOR_DISABLED"
        fi
        
        # Format item with hotkey if present
        local formatted_item="$indicator"
        if [[ -n "${MENU_HOTKEYS[$i]:-}" ]]; then
            formatted_item="${formatted_item}[${MENU_HOTKEYS[$i]}] $label"
        else
            formatted_item="${formatted_item}$label"
        fi
        
        # Display item
        display_text "$item_x" "$item_y" "$formatted_item" "$REFRESH_NONE"
    done
}

# Draw menu footer
_menu_draw_footer() {
    local footer_y=$((MENU_Y + MENU_HEIGHT - 2))
    
    if [[ "$MENU_STYLE" == "medieval" ]]; then
        local footer_text="Select thy path, noble scribe..."
        display_text_centered "$footer_y" "$footer_text" "$REFRESH_NONE"
    else
        local footer_text="Use arrows to navigate, Enter to select"
        display_text_centered "$footer_y" "$footer_text" "$REFRESH_NONE"
    fi
}

# ═══════════════════════════════════════════════════════════════
# Menu Navigation
# ═══════════════════════════════════════════════════════════════

# Move selection up
menu_move_up() {
    local old_selected="$MENU_SELECTED"
    
    # Find previous non-disabled item
    local new_selected=$((MENU_SELECTED - 1))
    while [[ $new_selected -ge 0 ]] && [[ "${MENU_STATES[$new_selected]}" == "disabled" ]]; do
        ((new_selected--))
    done
    
    if [[ $new_selected -ge 0 ]]; then
        MENU_SELECTED="$new_selected"
        _menu_update_selection "$old_selected" "$MENU_SELECTED"
    fi
}

# Move selection down
menu_move_down() {
    local old_selected="$MENU_SELECTED"
    
    # Find next non-disabled item
    local new_selected=$((MENU_SELECTED + 1))
    while [[ $new_selected -lt $MENU_ITEM_COUNT ]] && [[ "${MENU_STATES[$new_selected]}" == "disabled" ]]; do
        ((new_selected++))
    done
    
    if [[ $new_selected -lt $MENU_ITEM_COUNT ]]; then
        MENU_SELECTED="$new_selected"
        _menu_update_selection "$old_selected" "$MENU_SELECTED"
    fi
}

# Update selection display
_menu_update_selection() {
    local old_index="$1"
    local new_index="$2"
    
    local start_y=$((MENU_Y + 4))
    local item_x=$((MENU_X + 3))
    
    # Clear old selection
    local old_y=$((start_y + old_index))
    local old_label="${MENU_ITEMS[$old_index]}"
    local old_formatted="$INDICATOR_NORMAL"
    if [[ -n "${MENU_HOTKEYS[$old_index]:-}" ]]; then
        old_formatted="${old_formatted}[${MENU_HOTKEYS[$old_index]}] $old_label"
    else
        old_formatted="${old_formatted}$old_label"
    fi
    display_text "$item_x" "$old_y" "$old_formatted" "$REFRESH_NONE"
    
    # Show new selection
    local new_y=$((start_y + new_index))
    local new_label="${MENU_ITEMS[$new_index]}"
    local new_formatted="$INDICATOR_SELECTED"
    if [[ -n "${MENU_HOTKEYS[$new_index]:-}" ]]; then
        new_formatted="${new_formatted}[${MENU_HOTKEYS[$new_index]}] $new_label"
    else
        new_formatted="${new_formatted}$new_label"
    fi
    display_text "$item_x" "$new_y" "$new_formatted" "$REFRESH_PARTIAL"
}

# ═══════════════════════════════════════════════════════════════
# Input Handling
# ═══════════════════════════════════════════════════════════════

# Handle menu input
menu_handle_input() {
    local input="$1"
    
    case "$input" in
        # Arrow navigation
        "UP"|"k")
            menu_move_up
            ;;
        "DOWN"|"j")
            menu_move_down
            ;;
        "ENTER"|" ")
            menu_select_current
            ;;
        # Hotkey handling
        [a-zA-Z0-9])
            if [[ -n "${MENU_HOTKEYS[key_$input]:-}" ]]; then
                local index="${MENU_HOTKEYS[key_$input]}"
                MENU_SELECTED="$index"
                menu_select_current
            fi
            ;;
        "q"|"Q")
            return 1  # Exit menu
            ;;
    esac
    
    return 0
}

# Select current item
menu_select_current() {
    local action="${MENU_ACTIONS[$MENU_SELECTED]}"
    local state="${MENU_STATES[$MENU_SELECTED]}"
    
    if [[ "$state" != "disabled" ]] && [[ -n "$action" ]]; then
        # Execute action
        eval "$action"
        return $?
    fi
    
    return 0
}

# Handle touch input
menu_handle_touch() {
    local touch_x="$1"
    local touch_y="$2"
    
    # Convert to character coordinates
    local coords=$(display_touch_to_char "$touch_x" "$touch_y")
    local char_x=$(echo "$coords" | cut -d' ' -f1)
    local char_y=$(echo "$coords" | cut -d' ' -f2)
    
    # Check if touch is within menu bounds
    if [[ $char_x -ge $MENU_X ]] && [[ $char_x -le $((MENU_X + MENU_WIDTH)) ]] &&
       [[ $char_y -ge $MENU_Y ]] && [[ $char_y -le $((MENU_Y + MENU_HEIGHT)) ]]; then
        
        # Calculate which item was touched
        local start_y=$((MENU_Y + 4))
        local item_index=$((char_y - start_y))
        
        if [[ $item_index -ge 0 ]] && [[ $item_index -lt $MENU_ITEM_COUNT ]]; then
            MENU_SELECTED="$item_index"
            menu_render "$REFRESH_PARTIAL"
            menu_select_current
        fi
    fi
}

# ═══════════════════════════════════════════════════════════════
# Menu Loop
# ═══════════════════════════════════════════════════════════════

# Run menu loop
menu_run() {
    local timeout="${1:-0}"  # 0 = no timeout
    
    # Initial render
    menu_render
    
    # Input loop
    while true; do
        local input=""
        
        if [[ "$timeout" -gt 0 ]]; then
            read -r -s -n 1 -t "$timeout" input || return 2  # Timeout
        else
            read -r -s -n 1 input
        fi
        
        # Handle special keys
        if [[ "$input" == $'\x1b' ]]; then
            # Escape sequence
            read -r -s -n 2 -t 0.1 rest
            case "$rest" in
                "[A") input="UP" ;;
                "[B") input="DOWN" ;;
                "[C") input="RIGHT" ;;
                "[D") input="LEFT" ;;
            esac
        elif [[ "$input" == "" ]]; then
            input="ENTER"
        fi
        
        # Process input
        menu_handle_input "$input" || break
    done
    
    return 0
}

# ═══════════════════════════════════════════════════════════════
# Utility Functions
# ═══════════════════════════════════════════════════════════════

# Get selected item
menu_get_selected() {
    echo "${MENU_ITEMS[$MENU_SELECTED]}"
}

# Get selected action
menu_get_selected_action() {
    echo "${MENU_ACTIONS[$MENU_SELECTED]}"
}

# Set menu style
menu_set_style() {
    MENU_STYLE="$1"
}

# Enable/disable jester
menu_set_jester() {
    MENU_SHOW_JESTER="$1"
}

# ═══════════════════════════════════════════════════════════════
# Export functions
# ═══════════════════════════════════════════════════════════════

export -f menu_create
export -f menu_add_item
export -f menu_add_separator
export -f menu_render
export -f menu_handle_input
export -f menu_handle_touch
export -f menu_run
export -f menu_get_selected
export -f menu_set_style
export -f menu_set_jester

# Mark as loaded
export MENU_LIB_LOADED=1