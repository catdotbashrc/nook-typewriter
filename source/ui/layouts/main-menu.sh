#!/bin/bash
#
# Main Menu Layout for QuillKernel
# =================================
# Primary interface using the component system
# with medieval theming and E-Ink optimization
#
# Memory footprint: ~5KB
# Dependencies: menu.sh, display.sh

set -euo pipefail

# Source component libraries
MENU_LIB="${MENU_LIB:-/usr/local/bin/menu.sh}"
DISPLAY_LIB="${DISPLAY_LIB:-/usr/local/bin/display.sh}"

for lib in "$MENU_LIB" "$DISPLAY_LIB"; do
    if [[ -f "$lib" ]]; then
        source "$lib"
    else
        echo "Error: Required library $lib not found" >&2
        exit 1
    fi
done

# ═══════════════════════════════════════════════════════════════
# Configuration
# ═══════════════════════════════════════════════════════════════

readonly MENU_VERSION="1.0.0"
readonly MENU_TIMEOUT=30
readonly NOTES_DIR="${NOTES_DIR:-$HOME/scrolls}"
readonly DRAFTS_DIR="${DRAFTS_DIR:-$HOME/drafts}"

# Menu actions (functions defined below)
declare -g LAST_OPENED_FILE=""
declare -g WRITING_SESSION_START=""

# ═══════════════════════════════════════════════════════════════
# Menu Actions
# ═══════════════════════════════════════════════════════════════

# Start writing chamber (main writing mode)
action_writing_chamber() {
    display_clear
    
    # Show transitional message
    local message="Entering the Writing Chamber..."
    display_text_centered 10 "$message" "$REFRESH_FULL"
    sleep 1
    
    # Launch vim with Goyo (distraction-free mode)
    if command -v vim >/dev/null 2>&1; then
        # Create new scroll with timestamp
        local timestamp=$(date +%Y%m%d_%H%M%S)
        local new_file="$NOTES_DIR/scroll_${timestamp}.txt"
        
        # Ensure directory exists
        mkdir -p "$NOTES_DIR"
        
        # Add medieval header to new file
        cat > "$new_file" << 'EOF'
═══════════════════════════════════════════════════════════════
                    📜 New Scroll 📜
═══════════════════════════════════════════════════════════════

Date: 
Scribe: 
Subject: 

────────────────────────────────────────────────────────────────


EOF
        # Set the date
        sed -i "s/Date: /Date: $(date '+%B %d, %Y')/" "$new_file"
        
        # Launch vim with focus mode
        WRITING_SESSION_START=$(date +%s)
        vim "+Goyo" "+PencilSoft" "$new_file"
        
        # Record last file
        LAST_OPENED_FILE="$new_file"
    else
        display_error "Alas! The writing quill (vim) is not available!"
        sleep 2
    fi
    
    return 0
}

# Browse library of scrolls
action_library() {
    display_clear
    display_text_centered 5 "═══ Library of Scrolls ═══" "$REFRESH_FULL"
    
    local y_pos=8
    local count=0
    
    # List recent scrolls
    if [[ -d "$NOTES_DIR" ]]; then
        while IFS= read -r file; do
            ((count++))
            local basename=$(basename "$file")
            local size=$(stat -c%s "$file" 2>/dev/null || echo "0")
            local words=$(wc -w < "$file" 2>/dev/null || echo "0")
            
            display_text 5 "$y_pos" "[$count] $basename ($words words)" "$REFRESH_NONE"
            ((y_pos++))
            
            [[ $count -ge 10 ]] && break
        done < <(find "$NOTES_DIR" -name "*.txt" -type f -printf "%T@ %p\n" | sort -rn | cut -d' ' -f2)
    fi
    
    if [[ $count -eq 0 ]]; then
        display_text_centered 10 "No scrolls found in thy library" "$REFRESH_NONE"
    fi
    
    display_text_centered 20 "Press any key to return..." "$REFRESH_PARTIAL"
    read -n 1 -s
    
    return 0
}

# Show chronicle (statistics)
action_chronicle() {
    display_clear
    
    # Display header with ASCII art
    local chronicle_header="
    ═══════════════════════════════════
         📊 Writing Chronicle 📊
    ═══════════════════════════════════"
    
    display_ascii_art_centered 3 "$chronicle_header" "$REFRESH_FULL"
    
    local y_pos=8
    
    # Calculate statistics
    local total_scrolls=0
    local total_words=0
    local total_lines=0
    local today_words=0
    
    if [[ -d "$NOTES_DIR" ]]; then
        total_scrolls=$(find "$NOTES_DIR" -name "*.txt" -type f | wc -l)
        
        for file in "$NOTES_DIR"/*.txt; do
            [[ -f "$file" ]] || continue
            local words=$(wc -w < "$file" 2>/dev/null || echo "0")
            local lines=$(wc -l < "$file" 2>/dev/null || echo "0")
            total_words=$((total_words + words))
            total_lines=$((total_lines + lines))
            
            # Check if modified today
            if [[ $(date -r "$file" +%Y%m%d) == $(date +%Y%m%d) ]]; then
                today_words=$((today_words + words))
            fi
        done
    fi
    
    # Check kernel statistics if available
    local kernel_stats=""
    if [[ -f /proc/squireos/typewriter/stats ]]; then
        kernel_stats=$(cat /proc/squireos/typewriter/stats 2>/dev/null || echo "")
    fi
    
    # Display statistics
    display_text 10 "$y_pos" "Scrolls in Library: $total_scrolls" "$REFRESH_NONE"
    ((y_pos += 2))
    display_text 10 "$y_pos" "Total Words Written: $total_words" "$REFRESH_NONE"
    ((y_pos++))
    display_text 10 "$y_pos" "Total Lines Scribed: $total_lines" "$REFRESH_NONE"
    ((y_pos++))
    display_text 10 "$y_pos" "Words Written Today: $today_words" "$REFRESH_NONE"
    
    if [[ -n "$kernel_stats" ]]; then
        ((y_pos += 2))
        display_text 10 "$y_pos" "═══ Kernel Statistics ═══" "$REFRESH_NONE"
        ((y_pos++))
        display_text 10 "$y_pos" "$kernel_stats" "$REFRESH_NONE"
    fi
    
    ((y_pos += 3))
    display_text_centered "$y_pos" "Press any key to return..." "$REFRESH_PARTIAL"
    read -n 1 -s
    
    return 0
}

# Sync scrolls to cloud
action_sync() {
    display_clear
    
    # Show raven animation
    local raven="
       ,-.-.
      ( o o )
       |>o<|
      /  ^  \\
     /_/ \\_\\
    "
    
    display_ascii_art_centered 5 "$raven" "$REFRESH_FULL"
    display_text_centered 12 "Sending scrolls by raven..." "$REFRESH_NONE"
    
    # Check for sync script
    if [[ -f /usr/local/bin/sync-notes.sh ]]; then
        display_refresh "$REFRESH_PARTIAL"
        /usr/local/bin/sync-notes.sh
        display_text_centered 14 "✓ Scrolls dispatched successfully!" "$REFRESH_PARTIAL"
    else
        display_text_centered 14 "⚠ No raven available for dispatch" "$REFRESH_PARTIAL"
    fi
    
    sleep 2
    return 0
}

# Visit the jester
action_jester() {
    display_clear
    
    # Check for jester messages
    local jester_message="Greetings, noble scribe!"
    
    if [[ -f /proc/squireos/jester ]]; then
        # Get jester mood from kernel
        local jester_art=$(cat /proc/squireos/jester 2>/dev/null || echo "")
        if [[ -n "$jester_art" ]]; then
            display_ascii_art_centered 5 "$jester_art" "$REFRESH_FULL"
        fi
    else
        # Default jester
        local default_jester="
     .·:·.·:·.
    /  o   o  \\
   |  >  ᵕ  <  |
    \\  ___  /
     |~|~|~|
    /|  ♦  |\\
   d |     | b
      |   |
     /|   |\\
    (_)   (_)
        "
        display_ascii_art_centered 5 "$default_jester" "$REFRESH_FULL"
    fi
    
    # Get wisdom if available
    if [[ -f /proc/squireos/wisdom ]]; then
        local wisdom=$(cat /proc/squireos/wisdom 2>/dev/null || echo "Write with passion!")
        display_text_centered 18 "\"$wisdom\"" "$REFRESH_NONE"
    else
        display_text_centered 18 "\"The pen is mightier than the sword!\"" "$REFRESH_NONE"
    fi
    
    display_text_centered 21 "Press any key to return..." "$REFRESH_PARTIAL"
    read -n 1 -s
    
    return 0
}

# Resume last session
action_resume() {
    if [[ -n "$LAST_OPENED_FILE" ]] && [[ -f "$LAST_OPENED_FILE" ]]; then
        vim "+Goyo" "+PencilSoft" "$LAST_OPENED_FILE"
    else
        # Find most recent file
        local recent_file=$(find "$NOTES_DIR" -name "*.txt" -type f -printf "%T@ %p\n" 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2)
        
        if [[ -n "$recent_file" ]] && [[ -f "$recent_file" ]]; then
            vim "+Goyo" "+PencilSoft" "$recent_file"
            LAST_OPENED_FILE="$recent_file"
        else
            display_clear
            display_text_centered 10 "No previous scroll to resume" "$REFRESH_FULL"
            sleep 2
        fi
    fi
    
    return 0
}

# Quest complete (shutdown)
action_shutdown() {
    display_clear
    
    # Farewell message
    local farewell="
    ═══════════════════════════════════
         Fare thee well, noble scribe!
         May thy quill never run dry!
    ═══════════════════════════════════
    "
    
    display_ascii_art_centered 8 "$farewell" "$REFRESH_FULL"
    
    # Show sleeping jester
    local sleeping_jester="
       .·:·.
      ( - - )
      | > < |
       \\___/
        zzZ
    "
    
    display_ascii_art_centered 14 "$sleeping_jester" "$REFRESH_NONE"
    display_refresh "$REFRESH_FULL"
    
    sleep 2
    
    # Perform shutdown
    if [[ -f /usr/local/bin/shutdown-nook.sh ]]; then
        /usr/local/bin/shutdown-nook.sh
    else
        # Fallback
        sync
        poweroff 2>/dev/null || shutdown -h now 2>/dev/null || echo "Manual shutdown required"
    fi
    
    exit 0
}

# ═══════════════════════════════════════════════════════════════
# Main Menu Setup
# ═══════════════════════════════════════════════════════════════

# Initialize display
display_init

# Create main menu
menu_create "main" "SQUIREOS WRITING SYSTEM" 5 3 70 22
menu_set_style "medieval"
menu_set_jester 1

# Add menu items
menu_add_item "Writing Chamber - Begin thy work" "action_writing_chamber" "W"
menu_add_item "Library of Scrolls - Browse writings" "action_library" "L"
menu_add_item "Chronicle - View thy statistics" "action_chronicle" "C"
menu_add_item "Resume Last Scroll" "action_resume" "R"
menu_add_separator
menu_add_item "Send Scrolls by Raven (Sync)" "action_sync" "S"
menu_add_item "Visit the Jester" "action_jester" "J"
menu_add_separator
menu_add_item "Quest Complete (Shutdown)" "action_shutdown" "Q"

# ═══════════════════════════════════════════════════════════════
# Main Loop
# ═══════════════════════════════════════════════════════════════

# Show boot message if this is first run
if [[ ! -f /tmp/.menu_shown ]]; then
    display_clear
    
    # Show boot jester
    local boot_jester="
         .·:·.·:·.
        /  o   o  \\
       |  >  ᵕ  <  |
        \\  ___  /
         |~|~|~|
        /|  ♦  |\\
       d |     | b
          |   |
         /|   |\\
        (_)   (_)
    
      SquireOS v$MENU_VERSION
    \"At your service!\""
    
    display_ascii_art_centered 5 "$boot_jester" "$REFRESH_FULL"
    sleep 2
    
    touch /tmp/.menu_shown
fi

# Run menu loop
while true; do
    menu_run "$MENU_TIMEOUT"
    
    # Check exit status
    case $? in
        0)  # Normal menu action
            continue
            ;;
        1)  # User quit
            action_shutdown
            ;;
        2)  # Timeout
            # Could go to screensaver or sleep mode
            display_clear
            display_text_centered 10 "Menu timeout - Press any key..." "$REFRESH_FULL"
            read -n 1 -s
            ;;
    esac
done