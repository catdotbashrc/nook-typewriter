#!/bin/bash
# Unit Test: Boot scripts exist

source "$(dirname "$0")/../../test-framework.sh"

init_test "Boot scripts existence"

boot_scripts=(
    "$PROJECT_ROOT/source/scripts/boot/boot-jester.sh"
    "$PROJECT_ROOT/source/scripts/boot/init-mvp.sh"
)

found=false
for script in "${boot_scripts[@]}"; do
    if [ -f "$script" ]; then
        found=true
        echo "  ✓ Found: $(basename "$script")"
    fi
done

if $found; then
    pass_test "Boot scripts present"
else
    fail_test "No boot scripts found"
fi