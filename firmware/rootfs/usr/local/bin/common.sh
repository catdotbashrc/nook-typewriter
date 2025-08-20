#!/bin/bash
# Common functions library for Nook scripts
# Provides unified logging, error handling, and utility functions

set -euo pipefail

# ============================================================================
# Color Definitions
# ============================================================================
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly BOLD='\033[1m'
readonly NC='\033[0m' # No Color

# ============================================================================
# Logging Functions
# ============================================================================

# Info message with arrow prefix
log_info() {
    echo -e "${GREEN}→${NC} $1"
}

# Warning message with warning symbol
log_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Error message to stderr with X symbol
log_error() {
    echo -e "${RED}✗${NC} $1" >&2
}

# Success message with checkmark
log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

# Backward compatibility aliases
print_info() { log_info "$@"; }
print_warn() { log_warn "$@"; }
print_error() { log_error "$@"; }

# ============================================================================
# Path Resolution
# ============================================================================

# Get the directory of the current script
get_script_dir() {
    echo "$(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)"
}

# Get project root (assumes scripts are in PROJECT_ROOT/scripts/)
get_project_root() {
    local script_dir=$(get_script_dir)
    echo "$(cd "$script_dir/.." && pwd)"
}

# ============================================================================
# Error Handling
# ============================================================================

# Standard error trap handler
error_handler() {
    local line_no=$1
    local bash_lineno=$2
    local last_command=$3
    local code=$4
    
    log_error "Error occurred in script: ${BASH_SOURCE[1]}"
    log_error "Line $line_no: Command '$last_command' exited with status $code"
}

# Setup error handling for a script
setup_error_handling() {
    set -euo pipefail
    trap 'error_handler $? $LINENO "$BASH_COMMAND" $?' ERR
}

# ============================================================================
# Safety Checks
# ============================================================================

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root"
        exit 1
    fi
}

# Check if not running as root (for safety)
check_not_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "This script should not be run as root for safety"
        exit 1
    fi
}

# Check for required commands
check_requirements() {
    local missing_tools=()
    for tool in "$@"; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log_error "Missing required tools: ${missing_tools[*]}"
        return 1
    fi
    return 0
}

# ============================================================================
# File Operations
# ============================================================================

# Safe file backup
backup_file() {
    local file="$1"
    local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
    
    if [[ -f "$file" ]]; then
        cp "$file" "$backup"
        log_info "Backed up: $file → $backup"
    fi
}

# Create directory if it doesn't exist
ensure_dir() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        log_info "Created directory: $dir"
    fi
}

# ============================================================================
# Medieval Theme Support
# ============================================================================

# Jester ASCII art for fun messages
show_jester() {
    cat << 'EOF'
    .~"~.~"~.
   /  o   o  \
  |  >  ◡  <  |
   \  ___  /
    |~|♦|~|
EOF
}

# Medieval-themed messages
medieval_success() {
    log_success "By quill and candlelight, $1!"
}

medieval_error() {
    log_error "Alas! $1"
}

# ============================================================================
# Export Common Variables
# ============================================================================

# Export functions for use in sourcing scripts
export -f log_info log_warn log_error log_success
export -f print_info print_warn print_error
export -f get_script_dir get_project_root
export -f error_handler setup_error_handling
export -f check_root check_not_root check_requirements
export -f backup_file ensure_dir
export -f show_jester medieval_success medieval_error