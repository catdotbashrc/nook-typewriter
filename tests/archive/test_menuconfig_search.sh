#!/bin/bash
# Script to search for JESTEROS in menuconfig

set -euo pipefail

cd /home/jyeary/projects/personal/nook/source/kernel/src

# Use expect-like input to search in menuconfig
(echo -e "/\nJESTEROS\n\n\n\n\n" | make ARCH=arm menuconfig 2>/dev/null) &
MENU_PID=$!

# Wait a bit for menuconfig to process
sleep 2

# Kill menuconfig
kill $MENU_PID 2>/dev/null

echo "Search completed. Check .config.old for any changes."