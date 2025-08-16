#!/bin/bash
# Simple test runner for hobby project
# Just run the important stuff!

set -euo pipefail

# Colors for pretty output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

cd "$(dirname "$0")"

echo "═══════════════════════════════════════════════════════════════"
echo "           🎭 NOOK TYPEWRITER TEST SUITE v2.0"
echo "           7 Tests for Hobby Robustness™"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "Test Categories:"
echo "  🛡️  Show Stoppers (MUST PASS) - Will it brick?"
echo "  🚧 Writing Blockers (SHOULD PASS) - Can you write?"
echo "  ✨ Writer Experience (NICE TO PASS) - Is it pleasant?"
echo ""
echo "Starting test run (~30 seconds total)..."
echo ""

CRITICAL_FAILED=0
IMPORTANT_FAILED=0
NICE_FAILED=0

# Category 1: Show Stoppers (MUST PASS)
echo -e "${RED}═══ SHOW STOPPERS (Must Pass) ═══${NC}"
for test in 01-safety-check.sh 02-boot-test.sh; do
    if [ -f "$test" ]; then
        echo -e "${BLUE}Running: $test${NC}"
        echo "----------------------------------------"
        if bash "$test"; then
            echo -e "${GREEN}✓ PASSED${NC}"
        else
            echo -e "${RED}✗ FAILED - DO NOT DEPLOY!${NC}"
            ((CRITICAL_FAILED++))
        fi
        echo ""
    fi
done

# Category 2: Writing Blockers (SHOULD PASS)
echo -e "${YELLOW}═══ WRITING BLOCKERS (Should Pass) ═══${NC}"
for test in 04-docker-smoke.sh 05-consistency-check.sh 06-memory-guard.sh; do
    if [ -f "$test" ]; then
        echo -e "${BLUE}Running: $test${NC}"
        echo "----------------------------------------"
        if bash "$test"; then
            echo -e "${GREEN}✓ PASSED${NC}"
        else
            echo -e "${YELLOW}✗ FAILED - Writing may be impacted${NC}"
            ((IMPORTANT_FAILED++))
        fi
        echo ""
    fi
done

# Category 3: Writer Experience (NICE TO PASS)
echo -e "${PURPLE}═══ WRITER EXPERIENCE (Nice to Pass) ═══${NC}"
for test in 03-functionality.sh 07-writer-experience.sh; do
    if [ -f "$test" ]; then
        echo -e "${BLUE}Running: $test${NC}"
        echo "----------------------------------------"
        if bash "$test"; then
            echo -e "${GREEN}✓ PASSED${NC}"
        else
            echo -e "${PURPLE}✗ FAILED - Experience degraded${NC}"
            ((NICE_FAILED++))
        fi
        echo ""
    fi
done

echo "═══════════════════════════════════════════════════════════════"
echo "                        RESULTS"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Calculate total failures
TOTAL_FAILED=$((CRITICAL_FAILED + IMPORTANT_FAILED + NICE_FAILED))

# Display results by category
if [ "$CRITICAL_FAILED" -gt 0 ]; then
    echo -e "${RED}❌ CRITICAL FAILURES: $CRITICAL_FAILED${NC}"
    echo "   DO NOT DEPLOY - Risk of device damage!"
    echo ""
fi

if [ "$IMPORTANT_FAILED" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  IMPORTANT FAILURES: $IMPORTANT_FAILED${NC}"
    echo "   Writing functionality may be impacted"
    echo ""
fi

if [ "$NICE_FAILED" -gt 0 ]; then
    echo -e "${PURPLE}💭 NICE-TO-HAVE FAILURES: $NICE_FAILED${NC}"
    echo "   Some features missing, but usable"
    echo ""
fi

# Overall assessment
if [ "$TOTAL_FAILED" -eq 0 ]; then
    echo -e "${GREEN}🎉 PERFECT SCORE - ALL 7 TESTS PASSED!${NC}"
    echo ""
    echo "Your Nook is ready to become a typewriter!"
    echo ""
    echo "Next steps:"
    echo "  1. make firmware"
    echo "  2. make sd-deploy SD_DEVICE=/dev/sdX"
    echo "  3. Insert SD card into Nook"
    echo "  4. Boot and enjoy writing!"
    exit 0
elif [ "$CRITICAL_FAILED" -gt 0 ]; then
    echo -e "${RED}🛑 DEPLOYMENT BLOCKED${NC}"
    echo ""
    echo "Critical safety issues detected!"
    echo "Fix Show Stopper tests before proceeding."
    exit 1
elif [ "$IMPORTANT_FAILED" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  PROCEED WITH CAUTION${NC}"
    echo ""
    echo "Core functionality issues detected."
    echo "You can deploy, but writing experience may suffer."
    echo "Recommendation: Fix Writing Blocker tests first."
    exit 1
else
    echo -e "${GREEN}✅ GOOD ENOUGH TO SHIP!${NC}"
    echo ""
    echo "Only nice-to-have features missing."
    echo "Deploy and iterate!"
    exit 0
fi