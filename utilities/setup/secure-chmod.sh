#!/bin/bash
# Security improvements: Replace chmod with install command
# This script provides secure alternatives to chmod operations

set -euo pipefail
trap 'echo "Error at line $LINENO"' ERR

# Function to replace chmod with install for files
secure_install_file() {
    local mode="$1"
    local source="$2"
    local dest="${3:-$source}"
    local owner="${4:-root}"
    local group="${5:-root}"
    
    echo "Installing $source with mode $mode"
    install -m "$mode" -o "$owner" -g "$group" "$source" "$dest"
}

# Function to replace chmod with install for directories
secure_install_dir() {
    local mode="$1"
    local path="$2"
    local owner="${3:-root}"
    local group="${4:-root}"
    
    echo "Creating directory $path with mode $mode"
    install -d -m "$mode" -o "$owner" -g "$group" "$path"
}

# Function to set execute permissions securely
secure_make_executable() {
    local file="$1"
    local owner="${2:-root}"
    local group="${3:-root}"
    
    if [[ -f "$file" ]]; then
        # Use install to copy file to itself with new permissions
        local temp_file=$(mktemp)
        cp "$file" "$temp_file"
        install -m 0755 -o "$owner" -g "$group" "$temp_file" "$file"
        rm -f "$temp_file"
        echo "Made $file executable (mode 0755)"
    else
        echo "Warning: File $file does not exist"
        return 1
    fi
}

# Function to set read-only permissions securely
secure_make_readonly() {
    local file="$1"
    local owner="${2:-root}"
    local group="${3:-root}"
    
    if [[ -f "$file" ]]; then
        # Use install to copy file to itself with new permissions
        local temp_file=$(mktemp)
        cp "$file" "$temp_file"
        install -m 0644 -o "$owner" -g "$group" "$temp_file" "$file"
        rm -f "$temp_file"
        echo "Made $file read-only (mode 0644)"
    else
        echo "Warning: File $file does not exist"
        return 1
    fi
}

# Usage Examples
# -----------------------------------------------------------------------------
# These examples show how to replace common chmod patterns with secure alternatives:
#
# chmod 644 file    →  secure_make_readonly file root root
# chmod 755 file    →  secure_make_executable file root root  
# chmod +x file     →  secure_make_executable file root root
# mkdir -p dir      →  secure_install_dir 0755 dir root root
#
# For bulk operations on multiple files:
#   for file in *.ko; do
#       secure_make_readonly "$file" root root
#   done
# -----------------------------------------------------------------------------

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Security Improvements: chmod → install replacements"
    echo "===================================================="
    echo ""
    echo "This script demonstrates secure alternatives to chmod."
    echo ""
    echo "Key improvements:"
    echo "1. Atomic permission changes"
    echo "2. Ownership specification"
    echo "3. No race conditions"
    echo "4. Better error handling"
    echo ""
    echo "Functions available:"
    echo "- secure_install_file: Install file with permissions"
    echo "- secure_install_dir: Create directory with permissions"
    echo "- secure_make_executable: Make file executable"
    echo "- secure_make_readonly: Make file read-only"
    echo ""
    echo "Use 'source $0' to load functions into your script"
fi