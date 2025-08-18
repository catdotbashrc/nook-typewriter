#!/bin/bash
#
# Nook Writing System Menu
# ========================
# Main interactive menu for the Nook typewriter interface
#
# Dependencies:
#   - fbink: E-Ink display driver
#   - vim: Text editor
#   - sync-notes.sh: Note synchronization script
#
# Exit codes:
#   0 - Normal exit
#   1 - Display error
#   2 - Missing dependencies

set -euo pipefail
trap 'echo "Error in nook-menu.sh at line $LINENO"' ERR
#

# Source common functions and safety settings
COMMON_PATH="${COMMON_PATH:-/runtime/3-system/common/common.sh}"
if [[ -f "$COMMON_PATH" ]]; then
    source "$COMMON_PATH"
else
    # Fallback safety settings
    set -euo pipefail
    trap 'echo "Error at line $LINENO"' ERR
fi

# Configuration (use common constants if available)
readonly MENU_TIMEOUT="${MENU_TIMEOUT:-30}"
readonly NOTES_DIR="${NOTES_DIR:-$HOME/notes}"
readonly DRAFTS_DIR="${DRAFTS_DIR:-$HOME/drafts}"
readonly SYNC_SCRIPT="/usr/local/bin/sync-notes.sh"

# Display error message on E-Ink
display_error() {
    local message="$1"
    if [[ "${JESTEROS_COMMON_LOADED:-0}" == "1" ]]; then
        display_text "ERROR: $message" 1
        e_sleep "${LONG_DELAY:-3}"
    else
        fbink -y 13 "ERROR: $message" 2>/dev/null || echo "ERROR: $message"
        sleep 3
    fi
}

# Clear and display menu on E-Ink
display_menu() {
    # Clear screen
    fbink -c 2>/dev/null || {
        echo "Warning: fbink not available - displaying in terminal"
        clear
    }
    
    # Display menu items with jester
    local y_pos=3
    for line in \
        "NOOK WRITING SYSTEM" \
        "" \
        "[Z] Zettelkasten Mode" \
        "[D] Draft Mode" \
        "[R] Resume Session" \
        "[S] Sync Notes" \
        "[J] Visit the Jester" \
        "[Q] Shutdown" \
        "" \
        "Select: "
    do
        if [[ -n "$line" ]]; then
            fbink -y "$y_pos" "$line" 2>/dev/null || echo "$line"
        fi
        ((y_pos++))
    done
}

# Initialize and display menu
display_menu

# Get user input with timeout
get_user_choice() {
    local choice=""
    if read -r -n 1 -t "$MENU_TIMEOUT" choice; then
        echo "$choice"
        return 0
    else
        # Timeout - return to menu
        return 1
    fi
}

# Read user selection (properly quoted)
choice="$(get_user_choice)" || exec "$0"

# Create necessary directories
ensure_directories() {
    [[ -d "$NOTES_DIR" ]] || mkdir -p "$NOTES_DIR"
    [[ -d "$DRAFTS_DIR" ]] || mkdir -p "$DRAFTS_DIR"
}

# Start Zettelkasten mode
start_zettelkasten() {
    ensure_directories
    local timestamp
    timestamp="$(date +%Y%m%d%H%M%S)"
    local note_file="$NOTES_DIR/${timestamp}.md"
    vim "$note_file"
}

# Start draft mode
start_draft_mode() {
    ensure_directories
    vim "$DRAFTS_DIR/draft.txt"
}

# Resume last session
resume_session() {
    ensure_directories
    
    # Try draft first, then latest note
    if [[ -f "$DRAFTS_DIR/draft.txt" ]]; then
        vim "$DRAFTS_DIR/draft.txt"
    elif [[ -f "$NOTES_DIR/latest.md" ]]; then
        vim "$NOTES_DIR/latest.md"
    else
        display_error "No previous session found"
        sleep 2
    fi
}

# Sync notes to cloud/storage
sync_notes() {
    if [[ -x "$SYNC_SCRIPT" ]]; then
        "$SYNC_SCRIPT" || display_error "Sync failed"
    else
        display_error "Sync script not found"
    fi
}

# Visit the Court Jester
visit_jester() {
    clear
    # Show jester status
    if [ -f /var/lib/jester/ascii ]; then
        cat /var/lib/jester/ascii
    else
        cat << 'EOF'
     .~"~.~"~.
    /  ^   ^  \    
   |  >  ◡  <  |   
    \  ___  /      
     |~|♦|~|       
    d|     |b      
EOF
    fi
    
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    
    # Show wisdom
    if [ -f /var/lib/jester/wisdom ]; then
        echo "The Jester whispers: '$(cat /var/lib/jester/wisdom)'"
    else
        echo "The Jester says: 'Write first, edit later!'"
    fi
    
    echo ""
    
    # Show word count and achievements
    if [ -f /var/lib/jester/wordcount ]; then
        echo "Words written: $(cat /var/lib/jester/wordcount)"
    fi
    
    if [ -f /var/lib/jester/achievements ]; then
        echo ""
        echo "Your achievements:"
        tail -3 /var/lib/jester/achievements
    fi
    
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    echo "Press any key to return to the menu..."
    read -n 1
}

# Shutdown system safely
shutdown_system() {
    # Try different shutdown methods
    if command -v poweroff >/dev/null 2>&1; then
        poweroff
    elif [[ -x /sbin/poweroff ]]; then
        /sbin/poweroff
    else
        display_error "Cannot shutdown - manual power off required"
        exit 1
    fi
}

# Validate user input for safety
validate_menu_choice() {
    local input="${1:-}"
    # Only allow expected menu options
    if [[ ! "$input" =~ ^[zdrsjqZDRSJQ]$ ]]; then
        return 1
    fi
    return 0
}

# Validate choice before processing
if ! validate_menu_choice "$choice"; then
    # Invalid input - restart menu safely
    exec "$0"
fi

# Process user choice
case "${choice,,}" in
    z)
        start_zettelkasten
        ;;
    d)
        start_draft_mode
        ;;
    r)
        resume_session
        ;;
    s)
        sync_notes
        ;;
    j)
        visit_jester
        ;;
    q)
        shutdown_system
        ;;
    *)
        # Invalid choice - restart menu
        exec "$0"
        ;;
esac

# Return to menu after editing
exec "$0"