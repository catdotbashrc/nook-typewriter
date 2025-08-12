#!/bin/bash
# Unit Test: Menu error handling

source "$(dirname "$0")/../../test-framework.sh"

init_test "Menu error handling"

menu_script="$PROJECT_ROOT/source/scripts/menu/nook-menu.sh"

if [ ! -f "$menu_script" ]; then
    skip_test "Menu script not found"
fi

# Check for proper error handling
if grep -q "set -euo pipefail\|trap" "$menu_script"; then
    pass_test "Menu has proper error handling"
else
    fail_test "Menu lacks error handling"
fi