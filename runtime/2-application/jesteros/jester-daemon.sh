#!/bin/bash
# JesterOS Court Jester Service - Executable Wrapper
# Links to the main daemon implementation for service manager compatibility

# Find the actual daemon implementation
if [ -f "/runtime/2-application/jesteros/daemon.sh" ]; then
    DAEMON_IMPL="/runtime/2-application/jesteros/daemon.sh"
elif [ -f "$(dirname "$0")/daemon.sh" ]; then
    DAEMON_IMPL="$(dirname "$0")/daemon.sh"
else
    echo "Error: Jester daemon implementation not found" >&2
    echo "Searched:" >&2
    echo "  - /runtime/2-application/jesteros/daemon.sh" >&2
    echo "  - $(dirname "$0")/daemon.sh" >&2
    exit 1
fi

# Execute the daemon with all passed arguments
exec "$DAEMON_IMPL" "$@"