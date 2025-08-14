#!/bin/bash
# Unit Test: SquireOS Makefile configuration

source "$(dirname "$0")/../../test-framework.sh"

init_test "SquireOS Makefile"

makefile_path="$PROJECT_ROOT/source/kernel/src/drivers/squireos/Makefile"

assert_file_exists "$makefile_path" "SquireOS Makefile"

# Check for module compilation rules
has_modules=$(grep -c "obj-\$(CONFIG_SQUIREOS)" "$makefile_path" || echo 0)

assert_greater_than "$has_modules" 0 "Module compilation rules present"

pass_test "SquireOS Makefile configured correctly"