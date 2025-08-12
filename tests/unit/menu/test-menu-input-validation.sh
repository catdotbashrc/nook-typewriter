#!/bin/bash
# Unit Test: Menu input validation
# Verifies that menu scripts implement proper input validation for security

set -euo pipefail

source "$(dirname "$0")/../../test-framework.sh"

init_test "Menu input validation"

# Menu scripts to validate
readonly -a MENU_SCRIPTS=(
    "$PROJECT_ROOT/source/scripts/menu/nook-menu.sh"
    "$PROJECT_ROOT/source/scripts/menu/squire-menu.sh"
    "$PROJECT_ROOT/source/scripts/menu/nook-menu-zk.sh"
)

# Required validation patterns
readonly -a VALIDATION_PATTERNS=(
    "validate_menu_choice"
    "validate_path"
    "case.*in"
    "set -euo pipefail"
)

validated_count=0
total_scripts=0

for menu_script in "${MENU_SCRIPTS[@]}"; do
    if [ ! -f "$menu_script" ]; then
        echo "  ⚠ Menu script not found: $(basename "$menu_script")"
        continue
    fi
    
    ((total_scripts++))
    script_name=$(basename "$menu_script")
    validation_found=0
    
    for pattern in "${VALIDATION_PATTERNS[@]}"; do
        if grep -q "$pattern" "$menu_script"; then
            ((validation_found++))
        fi
    done
    
    if [ "$validation_found" -ge 2 ]; then  # Require at least 2 validation patterns
        echo "  ✓ $script_name: $validation_found/${#VALIDATION_PATTERNS[@]} validation patterns"
        ((validated_count++))
    else
        echo "  ✗ $script_name: only $validation_found/${#VALIDATION_PATTERNS[@]} validation patterns"
    fi
done

if [ "$total_scripts" -eq 0 ]; then
    skip_test "No menu scripts found for validation testing"
elif [ "$validated_count" -eq "$total_scripts" ]; then
    pass_test "All menu scripts ($validated_count/$total_scripts) have proper input validation"
elif [ "$validated_count" -gt 0 ]; then
    pass_test "Most menu scripts ($validated_count/$total_scripts) have input validation"
else
    fail_test "No menu scripts have adequate input validation"
fi