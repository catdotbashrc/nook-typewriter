#!/bin/bash
# Nook Menu System with Plugin Support
# Enhanced version of the original menu with plugin architecture

set -eu

# Plugin support variables
declare -A menu_items
declare -A menu_handlers
PLUGIN_DIR="/usr/local/lib/nook-plugins"
export NOOK_VERSION="1.0"
export NOOK_WRITING_DIR="$HOME/notes"
export NOOK_USER_HOME="$HOME"
export NOOK_PLUGIN_DIR="$PLUGIN_DIR"

# Function to register menu items from plugins
register_menu_item() {
    local key="$1"
    local label="$2"
    local handler="$3"
    menu_items["$key"]="$label"
    menu_handlers["$key"]="$handler"
    [ "${NOOK_DEBUG:-0}" = "1" ] && echo "Registered plugin: $label" >&2
}

# Load plugins if directory exists
load_plugins() {
    if [ -d "$PLUGIN_DIR" ]; then
        for plugin in "$PLUGIN_DIR"/*.sh; do
            if [ -f "$plugin" ]; then
                [ "${NOOK_DEBUG:-0}" = "1" ] && echo "Loading plugin: $plugin" >&2
                source "$plugin" || echo "Failed to load plugin: $plugin" >&2
            fi
        done
        # Call startup hooks if defined
        type -t on_menu_start >/dev/null 2>&1 && on_menu_start
    fi
}

# Main menu loop
main_menu() {
    while true; do
        # Clear screen and show menu
        fbink -c 2>/dev/null || clear
        fbink -y 2 "NOOK WRITING SYSTEM" 2>/dev/null || echo "NOOK WRITING SYSTEM"
        fbink -y 3 "══════════════════════" 2>/dev/null || echo "══════════════════════"
        
        # Core menu items
        fbink -y 5 "[Z] Zettelkasten Mode" 2>/dev/null || echo "[Z] Zettelkasten Mode"
        fbink -y 6 "[D] Draft Mode" 2>/dev/null || echo "[D] Draft Mode"
        fbink -y 7 "[R] Resume Session" 2>/dev/null || echo "[R] Resume Session"
        fbink -y 8 "[S] Sync Notes" 2>/dev/null || echo "[S] Sync Notes"
        fbink -y 9 "[Q] Shutdown" 2>/dev/null || echo "[Q] Shutdown"
        
        # Plugin menu items
        local y_pos=11
        for key in "${!menu_items[@]}"; do
            fbink -y "$y_pos" "${menu_items[$key]}" 2>/dev/null || echo "${menu_items[$key]}"
            ((y_pos++))
        done
        
        ((y_pos++))
        fbink -y "$y_pos" "Select: " 2>/dev/null || echo -n "Select: "
        
        # Read single character with timeout
        read -r -n 1 -t 30 choice || true
        
        # Handle core menu items
        case "${choice:-}" in
            z|Z)
                type -t on_vim_launch >/dev/null 2>&1 && on_vim_launch
                mkdir -p ~/notes
                vim ~/notes/"$(date +%Y%m%d%H%M%S)".md
                type -t on_vim_exit >/dev/null 2>&1 && on_vim_exit
                ;;
            d|D)
                type -t on_vim_launch >/dev/null 2>&1 && on_vim_launch
                mkdir -p ~/drafts
                vim ~/drafts/draft.txt
                type -t on_vim_exit >/dev/null 2>&1 && on_vim_exit
                ;;
            r|R)
                type -t on_vim_launch >/dev/null 2>&1 && on_vim_launch
                if [ -f ~/drafts/draft.txt ]; then
                    vim ~/drafts/draft.txt
                else
                    vim ~/notes/latest.md
                fi
                type -t on_vim_exit >/dev/null 2>&1 && on_vim_exit
                ;;
            s|S)
                /usr/local/bin/sync-notes.sh 2>/dev/null || echo "Sync failed"
                sleep 2
                ;;
            q|Q)
                type -t on_menu_exit >/dev/null 2>&1 && on_menu_exit
                fbink -c 2>/dev/null || clear
                fbink -y 5 "Fare thee well!" 2>/dev/null || echo "Fare thee well!"
                sleep 1
                /sbin/poweroff 2>/dev/null || poweroff
                ;;
            *)
                # Check if it's a plugin handler
                if [ -n "${menu_handlers[$choice]:-}" ]; then
                    ${menu_handlers[$choice]}
                fi
                ;;
        esac
    done
}

# Load plugins and start menu
load_plugins
main_menu