#!/bin/bash
# Functionality test - Check if fun stuff works
# Not critical, but nice to have
#
# Usage: ./03-functionality.sh
# Returns: 0 always (non-critical features)
# Dependencies: Docker (optional)
# Test Category: Writer Experience (NICE TO PASS)

set -euo pipefail

# ============================================================================
# FUNCTIONALITY TEST - The fun stuff
# ============================================================================
printf '\n✨ FUNCTIONALITY TEST - The fun stuff\n'
printf '=====================================\n\n'

# Check 1: ASCII art (medieval theme elements)
printf "✓ Jester ASCII art... "
if [ -d "../source/configs/ascii" ] || \
   [ -f "../source/configs/ascii/jester-collection.txt" ]; then
    printf "YES (jesters ready!)\n"
else
    printf "Missing (no fun allowed)\n"
fi

# Check 2: Service scripts (background functionality)
printf "✓ Service scripts... "
if [ -d "../source/scripts/services" ]; then
    service_count=$(find ../source/scripts/services -name "*.sh" 2>/dev/null | wc -l | tr -d ' ')
    service_count=${service_count:-0}
else
    service_count=0
fi
if [ "${service_count}" -gt 0 ]; then
    printf "YES (%d services)\n" "${service_count}"
else
    printf "None (basic mode only)\n"
fi

# Check 3: Vim config (writer-optimized editor settings)
printf "✓ Vim configuration... "
if [ -d "../source/configs/vim" ] || \
   [ -f "../config/vim/vimrc" ]; then
    printf "YES (writer mode ready)\n"
else
    printf "Missing (stock vim)\n"
fi

# Check 4: Script count (memory/bloat check)
printf "✓ Script count reasonable... "
if [ -d "../source/scripts" ]; then
    total_scripts=$(find ../source/scripts -name "*.sh" 2>/dev/null | wc -l | tr -d ' ')
    total_scripts=${total_scripts:-0}
else
    total_scripts=0
fi
if [ "${total_scripts}" -lt 50 ]; then
    printf "YES (%d scripts)\n" "${total_scripts}"
elif [ "${total_scripts}" -lt 100 ]; then
    printf "OK (%d scripts - getting heavy)\n" "${total_scripts}"
else
    printf "TOO MANY! (%d scripts)\n" "${total_scripts}"
fi

# Check 5: Docker environment (build readiness)
printf "✓ Docker environment... "
if command -v docker >/dev/null 2>&1 && \
   docker images 2>/dev/null | grep -qE "jesteros|jokernel|quillkernel"; then
    printf "YES (ready to build)\n"
else
    printf "Not built (run: docker build -t jokernel-builder .)\n"
fi

# Test result summary
printf '\n'
printf '✅ FUNCTIONALITY CHECK COMPLETE\n'
printf 'Not all features need to work for a successful boot!\n'
exit 0