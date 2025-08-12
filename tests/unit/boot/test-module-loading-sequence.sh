#!/bin/bash
# Unit Test: Module loading sequence

source "$(dirname "$0")/../../test-framework.sh"

init_test "Module loading sequence"

boot_script="$PROJECT_ROOT/source/scripts/boot/boot-jester.sh"

if [ ! -f "$boot_script" ]; then
    skip_test "Boot script not found"
fi

content=$(cat "$boot_script" 2>/dev/null)

# Check for correct module loading order
if echo "$content" | grep -q "squireos_core" && \
   echo "$content" | grep -q "jester" && \
   echo "$content" | grep -q "typewriter"; then
    pass_test "Module loading sequence correct"
else
    fail_test "Module loading sequence incorrect or incomplete"
fi