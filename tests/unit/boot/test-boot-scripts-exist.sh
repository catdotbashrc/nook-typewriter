#!/bin/bash
# Unit Test: Boot scripts exist
# Tests that essential boot scripts are present and accessible

set -euo pipefail

source "$(dirname "$0")/../../test-framework.sh"

init_test "Boot scripts existence"

# Define required boot scripts
readonly -a BOOT_SCRIPTS=(
    "$PROJECT_ROOT/source/scripts/boot/boot-jester.sh"
    "$PROJECT_ROOT/source/scripts/boot/squireos-boot.sh"
)

# Track found and missing scripts
found_count=0
missing_scripts=()

for script in "${BOOT_SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        ((found_count++))
        echo "  ✓ Found: $(basename "$script")"
    else
        missing_scripts+=("$(basename "$script")")
        echo "  ✗ Missing: $(basename "$script")"
    fi
done

# Require at least one boot script
if [ "$found_count" -gt 0 ]; then
    if [ ${#missing_scripts[@]} -eq 0 ]; then
        pass_test "All boot scripts present ($found_count found)"
    else
        pass_test "Essential boot scripts present ($found_count found, ${#missing_scripts[@]} missing)"
    fi
else
    fail_test "No boot scripts found - system cannot boot"
fi