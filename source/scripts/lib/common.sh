#!/bin/bash
# Common functions and settings for JesterOS scripts
# By quill and candlelight, we maintain consistency

# === Shell Safety Settings ===
set -euo pipefail
IFS=$'\n\t'

# === Error Handling ===
# Enhanced error handler with context
error_handler() {
    local line_no=$1
    local exit_code=$2
    local script_name="${BASH_SOURCE[1]##*/}"
    
    # Writer-friendly error messages
    echo "Alas! The digital parchment has encountered an error!" >&2
    echo "Script: $script_name" >&2
    echo "Line: $line_no" >&2
    echo "Exit code: $exit_code" >&2
    
    # Log to system log if available
    if command -v logger >/dev/null 2>&1; then
        logger -t "squireos" "Error in $script_name at line $line_no (exit: $exit_code)"
    fi
    
    return $exit_code
}

# Set trap for all scripts that source this
trap 'error_handler $LINENO $?' ERR

# === Constants ===
# Boot and timing constants
readonly BOOT_DELAY=2
readonly MENU_TIMEOUT=3
readonly JESTER_UPDATE_INTERVAL=30
readonly QUICK_DELAY=0.3
readonly MEDIUM_DELAY=0.8
readonly LONG_DELAY=2

# Paths
readonly SQUIREOS_PROC="/var/jesteros"
readonly JESTER_DIR="/var/lib/jester"
readonly NOTES_DIR="/root/notes"
readonly DRAFTS_DIR="/root/drafts"
readonly SCROLLS_DIR="/root/scrolls"

# === Common Functions ===

# Safe variable check
var_exists() {
    local var_name="$1"
    [[ -n "${!var_name:-}" ]]
}

# Validate menu choice
validate_menu_choice() {
    local choice="${1:-}"
    local max="${2:-9}"
    
    if [[ -z "$choice" ]]; then
        return 1
    fi
    
    if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
        return 1
    fi
    
    if (( choice < 1 || choice > max )); then
        return 1
    fi
    
    return 0
}

# E-Ink aware sleep
e_sleep() {
    local duration="${1:-$QUICK_DELAY}"
    sleep "$duration"
}

# === Display Abstraction ===

# Check if we have E-Ink display
has_eink() {
    command -v fbink >/dev/null 2>&1
}

# Display text with E-Ink support
display_text() {
    local text="$1"
    local refresh="${2:-0}"  # 0=no refresh, 1=refresh
    
    if has_eink; then
        if [[ "$refresh" == "1" ]]; then
            echo "$text" | fbink -c -
        else
            echo "$text" | fbink -
        fi
    else
        # Fallback for Docker/testing
        echo "$text"
    fi
}

# Clear display
clear_display() {
    if has_eink; then
        fbink -c >/dev/null 2>&1 || true
    else
        clear
    fi
}

# Display banner with proper formatting
display_banner() {
    local title="$1"
    local width=40
    local border=$(printf '=%.0s' $(seq 1 $width))
    
    display_text "$border"
    display_text "  $title"
    display_text "$border"
}

# === Safety Wrappers ===

# Safe file operations
safe_touch() {
    local file="$1"
    local dir=$(dirname "$file")
    
    [[ -d "$dir" ]] || mkdir -p "$dir"
    touch "$file"
}

# Safe config loading
load_config() {
    local config_file="${1:-/etc/nook.conf}"
    
    if [[ -r "$config_file" ]]; then
        # shellcheck source=/dev/null
        source "$config_file"
    else
        echo "Warning: Config file not found: $config_file" >&2
    fi
}

# === Input Validation ===

# Sanitize user input
sanitize_input() {
    local input="${1:-}"
    # Remove control characters and limit length
    echo "$input" | tr -cd '[:print:]' | cut -c1-100
}

# Validate path (prevent traversal)
validate_path() {
    local path="${1:-}"
    
    # Check for path traversal attempts
    if [[ "$path" =~ \.\. ]]; then
        return 1
    fi
    
    # Ensure path is within allowed directories
    case "$path" in
        "$NOTES_DIR"/*|"$DRAFTS_DIR"/*|"$SCROLLS_DIR"/*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# === Logging Functions ===

# Log message with timestamp
log_message() {
    local level="${1:-INFO}"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] [$level] $message" >> /var/log/squireos.log
}

# Debug logging (only if debug mode)
debug_log() {
    if [[ "${DEBUG:-0}" == "1" ]]; then
        log_message "DEBUG" "$1"
    fi
}

# === Export Common Variables ===
export SQUIREOS_VERSION="1.0.0"
export SQUIREOS_COMMON_LOADED=1

# Indicate successful loading
debug_log "Common library loaded successfully"