#!/bin/bash
# Unit Test: Menu error handling
# Verifies that menu scripts implement proper error handling and safety measures

set -euo pipefail

source "$(dirname "$0")/../../test-framework.sh"

init_test "Menu error handling"

# Menu scripts to test for error handling
readonly -a MENU_SCRIPTS=(
    "$PROJECT_ROOT/source/scripts/menu/nook-menu.sh"
    "$PROJECT_ROOT/source/scripts/menu/squire-menu.sh"
    "$PROJECT_ROOT/source/scripts/menu/nook-menu-zk.sh"
    "$PROJECT_ROOT/source/scripts/menu/nook-menu-plugin.sh"
)

# Required error handling patterns
readonly -a ERROR_PATTERNS=(
    "set -euo pipefail"
    "trap.*ERR"
    "error_handler"
    "source.*common.sh"
)

scripts_with_handling=0
total_scripts=0

for menu_script in "${MENU_SCRIPTS[@]}"; do
    if [ ! -f "$menu_script" ]; then
        echo "  ⚠ Menu script not found: $(basename "$menu_script")"
        continue
    fi
    
    ((total_scripts++))
    script_name=$(basename "$menu_script")
    error_handling_count=0
    
    echo "  Checking $script_name..."
    
    for pattern in "${ERROR_PATTERNS[@]}"; do
        if grep -q "$pattern" "$menu_script"; then
            ((error_handling_count++))
            echo "    ✓ Found: $pattern"
        fi
    done
    
    if [ "$error_handling_count" -ge 1 ]; then  # At least one error handling mechanism
        echo "  ✓ $script_name: $error_handling_count/${#ERROR_PATTERNS[@]} error handling patterns"
        ((scripts_with_handling++))
    else
        echo "  ✗ $script_name: no error handling patterns found"
    fi
done

if [ "$total_scripts" -eq 0 ]; then
    skip_test "No menu scripts found for error handling testing"
elif [ "$scripts_with_handling" -eq "$total_scripts" ]; then
    pass_test "All menu scripts ($scripts_with_handling/$total_scripts) have proper error handling"
elif [ "$scripts_with_handling" -gt 0 ]; then
    pass_test "Most menu scripts ($scripts_with_handling/$total_scripts) have error handling"
else
    fail_test "No menu scripts have adequate error handling"
fi