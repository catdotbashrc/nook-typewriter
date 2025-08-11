#!/bin/bash
#
# Common Library Functions for Nook Scripts
# ==========================================
# Shared utilities and functions used across multiple scripts
#
# Usage:
#   source /path/to/common-lib.sh
#
# Functions provided:
#   - Logging (log_info, log_warn, log_error, log_success)
#   - Error handling (die, check_command)
#   - File operations (ensure_dir, backup_file)
#   - System checks (is_wsl, is_root, check_disk_space)
#

# Prevent multiple sourcing
[[ -n "${NOOK_COMMON_LIB_LOADED:-}" ]] && return 0
readonly NOOK_COMMON_LIB_LOADED=1

# ============================================================================
# Color definitions
# ============================================================================
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[1;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_RESET='\033[0m'

# ============================================================================
# Logging functions
# ============================================================================

# Log informational message
# Usage: log_info "message"
log_info() {
    echo -e "${COLOR_GREEN}[INFO]${COLOR_RESET} $*" >&2
}

# Log warning message
# Usage: log_warn "message"
log_warn() {
    echo -e "${COLOR_YELLOW}[WARN]${COLOR_RESET} $*" >&2
}

# Log error message
# Usage: log_error "message"
log_error() {
    echo -e "${COLOR_RED}[ERROR]${COLOR_RESET} $*" >&2
}

# Log success message with checkmark
# Usage: log_success "message"
log_success() {
    echo -e "${COLOR_GREEN}✓${COLOR_RESET} $*" >&2
}

# Log debug message (only if DEBUG is set)
# Usage: log_debug "message"
log_debug() {
    [[ -n "${DEBUG:-}" ]] && echo -e "${COLOR_BLUE}[DEBUG]${COLOR_RESET} $*" >&2
    return 0
}

# ============================================================================
# Error handling
# ============================================================================

# Exit with error message
# Usage: die "error message" [exit_code]
die() {
    local message="$1"
    local exit_code="${2:-1}"
    log_error "$message"
    exit "$exit_code"
}

# Check if command exists
# Usage: check_command "command_name"
check_command() {
    local cmd="$1"
    if ! command -v "$cmd" >/dev/null 2>&1; then
        die "Required command not found: $cmd" 2
    fi
}

# Run command with error checking
# Usage: run_or_die "command" "error message"
run_or_die() {
    local cmd="$1"
    local error_msg="${2:-Command failed: $1}"
    
    if ! eval "$cmd"; then
        die "$error_msg"
    fi
}

# ============================================================================
# File operations
# ============================================================================

# Ensure directory exists
# Usage: ensure_dir "/path/to/dir"
ensure_dir() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        log_debug "Creating directory: $dir"
        mkdir -p "$dir" || die "Failed to create directory: $dir"
    fi
}

# Backup file if it exists
# Usage: backup_file "/path/to/file"
backup_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        local backup="${file}.bak.$(date +%Y%m%d%H%M%S)"
        log_debug "Backing up $file to $backup"
        cp "$file" "$backup" || log_warn "Failed to backup $file"
    fi
}

# Check if file is readable
# Usage: check_readable "/path/to/file"
check_readable() {
    local file="$1"
    if [[ ! -r "$file" ]]; then
        die "Cannot read file: $file" 3
    fi
}

# ============================================================================
# System checks
# ============================================================================

# Check if running in WSL
# Usage: if is_wsl; then ...; fi
is_wsl() {
    grep -qi microsoft /proc/version 2>/dev/null
}

# Check if running as root
# Usage: if is_root; then ...; fi
is_root() {
    [[ $EUID -eq 0 ]]
}

# Check available disk space
# Usage: check_disk_space "/path" 1000000  # Check for 1GB
check_disk_space() {
    local path="$1"
    local required_kb="${2:-100000}"  # Default 100MB
    
    local available_kb
    available_kb=$(df -k "$path" | tail -1 | awk '{print $4}')
    
    if [[ $available_kb -lt $required_kb ]]; then
        die "Insufficient disk space: ${available_kb}KB available, ${required_kb}KB required"
    fi
}

# Get SD card device (for Nook scripts)
# Usage: device=$(find_sd_card)
find_sd_card() {
    local size_gb="${1:-16}"  # Default to 16GB card
    
    # Look for disk around the specified size
    lsblk -b -o NAME,SIZE,TYPE | grep disk | while read -r name size type; do
        size_gb_actual=$((size / 1000000000))
        if [[ $size_gb_actual -ge $((size_gb - 2)) ]] && \
           [[ $size_gb_actual -le $((size_gb + 2)) ]]; then
            echo "/dev/$name"
            return 0
        fi
    done
    
    return 1
}

# ============================================================================
# User interaction
# ============================================================================

# Ask yes/no question
# Usage: if confirm "Continue?"; then ...; fi
confirm() {
    local prompt="${1:-Continue?}"
    local default="${2:-n}"  # Default to 'no'
    
    local yn_prompt="y/n"
    if [[ "${default,,}" == "y" ]]; then
        yn_prompt="Y/n"
    else
        yn_prompt="y/N"
    fi
    
    echo -n "$prompt ($yn_prompt): "
    read -r -n 1 response
    echo
    
    response="${response:-$default}"
    [[ "${response,,}" == "y" ]]
}

# Show progress indicator
# Usage: show_progress "message"
show_progress() {
    local message="$1"
    echo -n "$message"
    
    # Simple spinner
    local spin='⣾⣽⣻⢿⡿⣟⣯⣷'
    local i=0
    while kill -0 $$ 2>/dev/null; do
        i=$(( (i+1) % ${#spin} ))
        printf "\r%s %s" "$message" "${spin:$i:1}"
        sleep 0.1
    done
}

# ============================================================================
# Nook-specific utilities
# ============================================================================

# Check if fbink is available
# Usage: if has_fbink; then ...; fi
has_fbink() {
    command -v fbink >/dev/null 2>&1
}

# Display message on E-Ink or terminal
# Usage: display_message "message" [y_position]
display_message() {
    local message="$1"
    local y_pos="${2:-5}"
    
    if has_fbink; then
        fbink -y "$y_pos" "$message" 2>/dev/null
    else
        echo "$message"
    fi
}

# Clear E-Ink display or terminal
# Usage: clear_display
clear_display() {
    if has_fbink; then
        fbink -c 2>/dev/null
    else
        clear
    fi
}

# ============================================================================
# Validation utilities
# ============================================================================

# Validate partition type
# Usage: validate_partition "/dev/sda1" "vfat"
validate_partition() {
    local partition="$1"
    local expected_type="$2"
    
    local actual_type
    actual_type=$(lsblk -no FSTYPE "$partition" 2>/dev/null)
    
    if [[ "$actual_type" != "$expected_type" ]]; then
        log_error "Partition $partition is $actual_type, expected $expected_type"
        return 1
    fi
    return 0
}

# Validate file size
# Usage: validate_file_size "/path/to/file" 1000000  # At least 1MB
validate_file_size() {
    local file="$1"
    local min_size="${2:-0}"
    
    if [[ ! -f "$file" ]]; then
        log_error "File not found: $file"
        return 1
    fi
    
    local size
    size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null || echo 0)
    
    if [[ $size -lt $min_size ]]; then
        log_error "File too small: $file ($size bytes, minimum $min_size)"
        return 1
    fi
    return 0
}

# ============================================================================
# Cleanup handlers
# ============================================================================

# Array to store cleanup functions
declare -a CLEANUP_FUNCTIONS=()

# Register cleanup function
# Usage: add_cleanup "command"
add_cleanup() {
    CLEANUP_FUNCTIONS+=("$1")
}

# Execute cleanup functions
# Usage: Usually called via trap
cleanup() {
    local exit_code=$?
    
    log_debug "Running cleanup functions..."
    
    for func in "${CLEANUP_FUNCTIONS[@]}"; do
        log_debug "Cleanup: $func"
        eval "$func" || true
    done
    
    exit $exit_code
}

# Set up cleanup trap
# Usage: setup_cleanup_trap
setup_cleanup_trap() {
    trap cleanup EXIT INT TERM
}

# ============================================================================
# Script initialization
# ============================================================================

# Initialize common settings
init_common() {
    # Enable strict error handling if not already set
    set -euo pipefail
    
    # Set up cleanup trap
    setup_cleanup_trap
    
    # Export common variables
    export NOOK_PROJECT_DIR="${NOOK_PROJECT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
    export NOOK_CONFIG_DIR="${NOOK_CONFIG_DIR:-$NOOK_PROJECT_DIR/config}"
    export NOOK_SCRIPTS_DIR="${NOOK_SCRIPTS_DIR:-$NOOK_PROJECT_DIR/scripts}"
    
    log_debug "Nook common library loaded"
    log_debug "Project dir: $NOOK_PROJECT_DIR"
}

# Auto-initialize if not sourced interactively
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    init_common
fi