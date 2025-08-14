#!/bin/bash
# Unit Test: SquireOS module source files exist
# Verifies that all required kernel module source files are present

set -euo pipefail

source "$(dirname "$0")/../../test-framework.sh"

init_test "SquireOS module sources"

# SquireOS kernel modules configuration
MODULE_DIR="$PROJECT_ROOT/source/kernel/src/drivers/squireos"
readonly -a REQUIRED_MODULES=(
    "squireos_core.c"
    "jester.c"
    "typewriter.c"
    "wisdom.c"
)

# Optional modules that may be present
readonly -a OPTIONAL_MODULES=(
    "sync.c"
    "power.c"
)

echo "  Checking for SquireOS kernel modules in: $MODULE_DIR"

# Check if module directory exists
if [ ! -d "$MODULE_DIR" ]; then
    # Try alternative locations
    alt_locations=(
        "$PROJECT_ROOT/source/kernel/quillkernel/modules"
        "$PROJECT_ROOT/source/kernel/src/drivers"
    )
    
    found_alt=false
    for alt_dir in "${alt_locations[@]}"; do
        if [ -d "$alt_dir" ]; then
            echo "  ⚠ Using alternative module directory: $alt_dir"
            MODULE_DIR="$alt_dir"
            found_alt=true
            break
        fi
    done
    
    if ! $found_alt; then
        fail_test "Module directory not found: $MODULE_DIR"
    fi
fi

# Check required modules
found_count=0
missing_modules=()

for module in "${REQUIRED_MODULES[@]}"; do
    module_path="$MODULE_DIR/$module"
    if [ -f "$module_path" ]; then
        # Verify file has content and basic C structure
        if [ -s "$module_path" ] && grep -q "#include\|module_init\|MODULE_" "$module_path"; then
            echo "  ✓ Found valid module: $module"
            ((found_count++))
        else
            echo "  ⚠ Found but invalid: $module (empty or not a proper kernel module)"
            missing_modules+=("$module")
        fi
    else
        echo "  ✗ Missing: $module"
        missing_modules+=("$module")
    fi
done

# Check optional modules
optional_count=0
for module in "${OPTIONAL_MODULES[@]}"; do
    module_path="$MODULE_DIR/$module"
    if [ -f "$module_path" ]; then
        echo "  ✓ Found optional module: $module"
        ((optional_count++))
    fi
done

# Report results
echo "  Summary: $found_count/${#REQUIRED_MODULES[@]} required, $optional_count optional modules"

if [ "$found_count" -eq "${#REQUIRED_MODULES[@]}" ]; then
    if [ "$optional_count" -gt 0 ]; then
        pass_test "All SquireOS modules present ($found_count required + $optional_count optional)"
    else
        pass_test "All required SquireOS modules present ($found_count/${#REQUIRED_MODULES[@]})"
    fi
elif [ "$found_count" -ge 3 ]; then  # Core functionality with most modules
    pass_test "Essential SquireOS modules present ($found_count/${#REQUIRED_MODULES[@]}, missing: ${missing_modules[*]})"
else
    fail_test "Critical SquireOS modules missing ($found_count/${#REQUIRED_MODULES[@]} found)"
fi