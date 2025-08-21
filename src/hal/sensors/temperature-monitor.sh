#!/bin/bash
# MEMORY OPTIMIZATION: Redirect to optimized version
# Saves ~8KB by eliminating duplicate temperature monitor
# Use temperature-monitor-optimized.sh which has identical functionality

set -euo pipefail

# Redirect to optimized implementation
OPTIMIZED_MONITOR="/src/hal/sensors/temperature-monitor-optimized.sh"

if [ -f "$OPTIMIZED_MONITOR" ]; then
    exec "$OPTIMIZED_MONITOR" "$@"
else
    echo "Error: Optimized temperature monitor not found at $OPTIMIZED_MONITOR" >&2
    exit 1
fi