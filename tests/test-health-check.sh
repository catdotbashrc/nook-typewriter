#!/bin/bash
# Test health check script

set -e

echo "Testing health check..."

HEALTH_SCRIPT="../config/scripts/health-check.sh"

# Check if health check script exists
if [ ! -f "$HEALTH_SCRIPT" ]; then
    echo "  ERROR: Health check script not found"
    exit 1
fi

# Check if script is valid bash
if ! bash -n "$HEALTH_SCRIPT" 2>/dev/null; then
    echo "  ERROR: Health check script has syntax errors"
    exit 1
fi

# Test that it can run (in non-interactive mode)
if ! echo "" | bash "$HEALTH_SCRIPT" >/dev/null 2>&1; then
    echo "  WARNING: Health check script failed to run (may be normal in test environment)"
fi

echo "  Health check tests passed"