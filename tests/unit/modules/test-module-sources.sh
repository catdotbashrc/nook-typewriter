#!/bin/bash
# Unit Test: SquireOS module source files exist

source "$(dirname "$0")/../../test-framework.sh"

init_test "SquireOS module sources"

modules=("squireos_core.c" "jester.c" "typewriter.c" "wisdom.c")
all_found=true

for module in "${modules[@]}"; do
    module_path="$PROJECT_ROOT/source/kernel/src/drivers/squireos/$module"
    if [ ! -f "$module_path" ]; then
        echo "  Missing module source: $module"
        all_found=false
    else
        echo "  ✓ Found: $module"
    fi
done

if $all_found; then
    pass_test "All SquireOS module sources present"
else
    fail_test "Some SquireOS modules missing"
fi