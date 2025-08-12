#!/bin/bash
# Unit Test: SquireOS Kconfig configuration

source "$(dirname "$0")/../../test-framework.sh"

init_test "SquireOS Kconfig"

kconfig_path="$PROJECT_ROOT/source/kernel/src/drivers/squireos/Kconfig"

assert_file_exists "$kconfig_path" "SquireOS Kconfig file"

# Check for SquireOS config entries
has_squireos=$(grep -c "config SQUIREOS" "$kconfig_path" || echo 0)

assert_greater_than "$has_squireos" 0 "SquireOS config entries present"

pass_test "SquireOS Kconfig properly configured"