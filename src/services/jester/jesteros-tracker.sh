#!/bin/bash
# JesterOS Writing Tracker Service - Executable Wrapper
# Links to the main tracker implementation for service manager compatibility

# Find the actual tracker implementation
if [ -f "/src/services/jester/tracker.sh" ]; then
    TRACKER_IMPL="/src/services/jester/tracker.sh"
elif [ -f "$(dirname "$0")/tracker.sh" ]; then
    TRACKER_IMPL="$(dirname "$0")/tracker.sh"
else
    echo "Error: Tracker implementation not found" >&2
    echo "Searched:" >&2
    echo "  - /src/services/jester/tracker.sh" >&2
    echo "  - $(dirname "$0")/tracker.sh" >&2
    exit 1
fi

# Execute the tracker with all passed arguments
exec "$TRACKER_IMPL" "$@"