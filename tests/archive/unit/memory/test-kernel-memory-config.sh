#!/bin/bash
# Unit Test: Kernel configured for embedded systems

set -euo pipefail

source "$(dirname "$0")/../../test-framework.sh"

init_test "Kernel memory configuration"

# Check if kernel config exists
if [ ! -f "$PROJECT_ROOT/source/kernel/src/.config" ]; then
    skip_test "Kernel config not yet generated"
fi

# Check for embedded system optimization
has_minimal=$(grep -c "CONFIG_EMBEDDED=y" "$PROJECT_ROOT/source/kernel/src/.config" || echo 0)

if [ "$has_minimal" -gt 0 ]; then
    pass_test "Kernel configured for embedded systems"
else
    fail_test "Kernel not optimized for embedded systems"
fi