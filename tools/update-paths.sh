#!/bin/bash
# Update path references from numbered directories to proper structure

set -euo pipefail

echo "Updating path references in shell scripts..."

# Define path mappings
declare -A PATH_MAPPINGS=(
    ["1-ui/menu"]="services/menu"
    ["1-ui/display"]="services/menu"  # display.sh is in menu
    ["2-application/jesteros"]="services/jester"
    ["2-application/tracker"]="services/tracker"
    ["3-system/common"]="services/system"
    ["3-system/services"]="services/system"
    ["3-system/display"]="services/menu"  # font-setup.sh
    ["4-hardware"]="hal"
    ["src/services/1-ui"]="src/services/menu"
    ["src/services/2-application"]="src/services/jester"
    ["src/services/3-system"]="src/services/system"
    ["src/services/4-hardware"]="src/hal"
)

# Find all shell scripts
SCRIPTS=$(find . -name "*.sh" -type f 2>/dev/null | grep -v ".git")

# Update each script
for script in $SCRIPTS; do
    modified=false
    
    # Check if file contains any numbered directories
    if grep -qE "1-ui|2-application|3-system|4-hardware|runtime/" "$script" 2>/dev/null; then
        echo "Updating: $script"
        
        # Create temp file
        temp_file=$(mktemp)
        cp "$script" "$temp_file"
        
        # Apply all mappings
        for old_path in "${!PATH_MAPPINGS[@]}"; do
            new_path="${PATH_MAPPINGS[$old_path]}"
            
            # Update various path patterns
            sed -i "s|/${old_path}/|/${new_path}/|g" "$temp_file"
            sed -i "s|\"${old_path}/|\"${new_path}/|g" "$temp_file"
            sed -i "s|'${old_path}/|'${new_path}/|g" "$temp_file"
            sed -i "s|\${.*}/${old_path}/|\${.*}/${new_path}/|g" "$temp_file"
        done
        
        # Special case: update runtime base paths
        sed -i 's|/src/services/|/src/services/|g' "$temp_file"
        sed -i 's|"src/services/|"src/services/|g' "$temp_file"
        sed -i 's|RUNTIME_BASE:-/src/services|RUNTIME_BASE:-/src/services|g' "$temp_file"
        
        # Fix double paths that may have been created
        sed -i 's|/src/services/menu/|/src/services/menu/|g' "$temp_file"
        sed -i 's|/src/services/jester/|/src/services/jester/|g' "$temp_file"
        sed -i 's|/src/services/system/|/src/services/system/|g' "$temp_file"
        sed -i 's|/src/services/tracker/|/src/services/tracker/|g' "$temp_file"
        
        # Copy back if changed
        if ! diff -q "$script" "$temp_file" >/dev/null; then
            cp "$temp_file" "$script"
            modified=true
        fi
        
        rm "$temp_file"
        
        if $modified; then
            echo "  ✓ Updated"
        else
            echo "  - No changes needed"
        fi
    fi
done

echo "Path update complete!"

# Show summary
echo ""
echo "Summary of changes:"
echo "  1-ui/* → services/menu/*"
echo "  2-application/* → services/jester/* or services/tracker/*"
echo "  3-system/* → services/system/*"
echo "  4-hardware/* → hal/*"
echo "  runtime/* → src/services/*"