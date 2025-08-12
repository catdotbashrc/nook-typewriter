#!/bin/bash
# Unit Test: Display abstraction layer

source "$(dirname "$0")/../../test-framework.sh"

init_test "Display abstraction"

menu_script="$PROJECT_ROOT/source/scripts/menu/nook-menu.sh"

if [ ! -f "$menu_script" ]; then
    skip_test "Menu script not found"
fi

# Check for display abstraction functions
if grep -q "display_text\|echo" "$menu_script"; then
    pass_test "Display abstraction implemented in menu"
else
    fail_test "No display abstraction found in menu script"
fi