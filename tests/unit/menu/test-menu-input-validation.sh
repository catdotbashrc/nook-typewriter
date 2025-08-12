#!/bin/bash
# Unit Test: Menu input validation

source "$(dirname "$0")/../../test-framework.sh"

init_test "Menu input validation"

menu_script="$PROJECT_ROOT/source/scripts/menu/nook-menu.sh"

if [ ! -f "$menu_script" ]; then
    skip_test "Menu script not found"
fi

# Check for input validation
if grep -q "validate_menu_choice\|case.*in" "$menu_script"; then
    pass_test "Menu input validation present"
else
    fail_test "Menu lacks input validation"
fi