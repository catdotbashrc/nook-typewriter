#!/bin/bash
# Simple test runner for hobby project
# Just run the important stuff!

set -euo pipefail

# Colors for pretty output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

cd "$(dirname "$0")"

echo "═══════════════════════════════════════════════════════════════"
echo "           🎭 NOOK TYPEWRITER TEST SUITE"
echo "           Keeping it simple since 2024!"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "Running tests..."
echo ""

FAILED=0

# Run each test
for test in [0-9]*.sh; do
    if [ -f "$test" ] && [ "$test" != "$(basename "$0")" ]; then
        echo -e "${BLUE}Running: $test${NC}"
        echo "----------------------------------------"
        if bash "$test"; then
            echo -e "${GREEN}✓ PASSED${NC}"
        else
            echo -e "${RED}✗ FAILED${NC}"
            ((FAILED++))
        fi
        echo ""
    fi
done

echo "═══════════════════════════════════════════════════════════════"
echo "                        RESULTS"
echo "═══════════════════════════════════════════════════════════════"
echo ""

if [ "$FAILED" -eq 0 ]; then
    echo -e "${GREEN}🎉 ALL TESTS PASSED!${NC}"
    echo ""
    echo "Your Nook is ready to become a typewriter!"
    echo ""
    echo "Next steps:"
    echo "  1. make firmware"
    echo "  2. make sd-deploy SD_DEVICE=/dev/sdX"
    echo "  3. Insert SD card into Nook"
    echo "  4. Boot and enjoy writing!"
    exit 0
else
    echo -e "${RED}⚠️  $FAILED test(s) failed${NC}"
    echo ""
    if [ "$FAILED" -eq 1 ] && grep -q "functionality" <<< "$test"; then
        echo "Only functionality test failed - probably safe to proceed"
        echo "(You'll just miss some fun features)"
    else
        echo "Fix critical issues before deploying!"
        echo "Especially check 01-safety-check.sh"
    fi
    exit 1
fi