#!/bin/bash
# Unit Test: Menu script exists

source "$(dirname "$0")/../../test-framework.sh"

init_test "Menu script existence"

menu_script="$PROJECT_ROOT/source/scripts/menu/nook-menu.sh"

assert_file_exists "$menu_script" "Menu script"

pass_test "Menu script found at expected location"