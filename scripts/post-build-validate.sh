#!/bin/bash
# Post-build validation for JesterOS
set -euo pipefail

source "$(dirname "$0")/lib/validation.sh"

echo "Running post-build validation..."

# Validate kernel image
if [ -f "platform/nook-touch/boot/uImage" ]; then
    validate_build_output "platform/nook-touch/boot/uImage" 1000000 || exit 1
    echo "✓ Kernel image validated"
else
    echo "✗ Kernel image not found"
    exit 1
fi

# Validate modules if built
for module in platform/nook-touch/lib/modules/*.ko; do
    if [ -f "$module" ]; then
        validate_build_output "$module" 1000 || exit 1
    fi
done

echo "✓ Post-build validation passed"