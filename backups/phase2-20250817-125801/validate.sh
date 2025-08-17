#!/bin/bash
# Validate path migration

echo "Validating path migration..."

# Source config
source /runtime/config/jesteros.conf

# Check for remaining hardcoded paths
echo "Checking for remaining hardcoded paths..."
grep -r "/usr/local/bin\|/var/jesteros\|/runtime/[1-4]" runtime/**/*.sh 2>/dev/null | \
    grep -v "JESTEROS\|LAYER\|CONFIG" | \
    grep -v "^#" | head -20

echo "Done!"
