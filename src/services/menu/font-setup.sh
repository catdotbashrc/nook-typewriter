#!/bin/bash
# Font configuration redirect - MEMORY OPTIMIZATION
# The actual font setup is now in the hardware layer where it belongs
# Saved ~4KB by eliminating this duplicate

set -euo pipefail

# Redirect to hardware layer implementation
HARDWARE_FONT_SETUP="/src/hal/eink/font-setup.sh"

if [ -f "$HARDWARE_FONT_SETUP" ]; then
    exec "$HARDWARE_FONT_SETUP" "$@"
else
    echo "Error: Hardware font setup not found at $HARDWARE_FONT_SETUP" >&2
    exit 1
fi