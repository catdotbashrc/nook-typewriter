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

# Examples of replacements for create-cwm-sdcard.sh

# Replace: chmod 644 /system/kernel
# With:
example_kernel_permissions() {
    if [[ -f /system/kernel ]]; then
        secure_make_readonly /system/kernel root root
    fi
}

# Replace: chmod 644 /system/lib/modules/*.ko
# With:
example_module_permissions() {
    for module in /system/lib/modules/*.ko; do
        if [[ -f "$module" ]]; then
            secure_make_readonly "$module" root root
        fi
    done
}

# Replace: chmod 755 /system/bin/load-squireos.sh
# With:
example_script_permissions() {
    if [[ -f /system/bin/load-squireos.sh ]]; then
        secure_make_executable /system/bin/load-squireos.sh root root
    fi
}

# Replace: chmod +x script.sh
# With:
example_make_executable() {
    local script="$1"
    secure_make_executable "$script" root root
}

# Demonstration of secure directory creation
example_create_directories() {
    # Replace mkdir -p with secure_install_dir
    secure_install_dir 0755 /var/jesteros root root
    secure_install_dir 0750 /var/jesteros/private root root
    secure_install_dir 0700 /var/jesteros/secure root root
}

# Demonstration of secure file installation
example_install_files() {
    local source_file="/tmp/example.txt"
    local dest_file="/etc/jesteros/config.txt"
    
    # Create example file
    echo "Example config" > "$source_file"
    
    # Install with specific permissions
    secure_install_file 0644 "$source_file" "$dest_file" root root
    
    # Clean up
    rm -f "$source_file"
}

# Function to patch existing scripts
patch_script_chmod_usage() {
    local script="$1"
    local backup="${script}.backup"
    
    if [[ ! -f "$script" ]]; then
        echo "Script $script not found"
        return 1
    fi
    
    # Create backup
    cp "$script" "$backup"
    
    # Replace chmod patterns
    sed -i \
        -e 's/chmod 644 \(.*\)/install -m 0644 \1 \1/g' \
        -e 's/chmod 755 \(.*\)/install -m 0755 \1 \1/g' \
        -e 's/chmod +x \(.*\)/install -m 0755 \1 \1/g' \
        "$script"
    
    echo "Patched $script (backup at $backup)"
}

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