#!/bin/bash
# Functionality test - Check if fun stuff works
# Not critical, but nice to have

set -euo pipefail

echo "✨ FUNCTIONALITY TEST - The fun stuff"
echo "====================================="
echo ""

# ASCII art (because jesters!)
echo -n "✓ Jester ASCII art... "
if [ -d "../source/configs/ascii" ] || [ -f "../source/configs/ascii/jester-collection.txt" ]; then
    echo "YES (jesters ready!)"
else
    echo "Missing (no fun allowed)"
fi

# Service scripts
echo -n "✓ Service scripts... "
SERVICE_COUNT=$(ls ../source/scripts/services/*.sh 2>/dev/null | wc -l || echo "0")
if [ "$SERVICE_COUNT" -gt 0 ]; then
    echo "YES ($SERVICE_COUNT services)"
else
    echo "None (basic mode only)"
fi

# Vim config
echo -n "✓ Vim configuration... "
if [ -d "../source/configs/vim" ] || [ -f "../config/vim/vimrc" ]; then
    echo "YES (writer mode ready)"
else
    echo "Missing (stock vim)"
fi

# Memory check - are we being reasonable?
echo -n "✓ Script count reasonable... "
TOTAL_SCRIPTS=$(find ../source/scripts -name "*.sh" 2>/dev/null | wc -l || echo "0")
if [ "$TOTAL_SCRIPTS" -lt 50 ]; then
    echo "YES ($TOTAL_SCRIPTS scripts)"
elif [ "$TOTAL_SCRIPTS" -lt 100 ]; then
    echo "OK ($TOTAL_SCRIPTS scripts - getting heavy)"
else
    echo "TOO MANY! ($TOTAL_SCRIPTS scripts)"
fi

# Docker check
echo -n "✓ Docker environment... "
if docker images 2>/dev/null | grep -q "jesteros\|jokernel\|quillkernel"; then
    echo "YES (ready to build)"
else
    echo "Not built (run: docker build -t jokernel-builder .)"
fi

echo ""
echo "✅ FUNCTIONALITY CHECK COMPLETE"
echo "Not all features need to work for a successful boot!"
exit 0