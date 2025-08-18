#!/bin/bash
# Comprehensive JesterOS Validation
# Consolidates phase1, phase2, and phase3 validation scripts
# "By quill and candlelight, we validate thoroughly!"
#
# Usage: ./comprehensive-validation.sh
# Returns: 0 if all phases pass, 1 if any phase fails
# Runs: All 7 numbered test scripts in order

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║           JESTEROS COMPREHENSIVE VALIDATION                   ║"
echo "║          \"Testing all aspects of the digital court!\"          ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

PHASE_PASSED=0
PHASE_FAILED=0

# Function to run a test phase and track results
run_phase() {
    local phase_name="$1"   # Display name for the test
    local test_script="$2"  # Script to execute
    
    echo -e "${BLUE}═══ $phase_name ═══${NC}"
    
    if [ -f "$test_script" ]; then
        if bash "$test_script"; then
            echo -e "${GREEN}✓ $phase_name passed${NC}"
            ((PHASE_PASSED++))
        else
            echo -e "${RED}✗ $phase_name failed${NC}"
            ((PHASE_FAILED++))
        fi
    else
        echo -e "${YELLOW}⚠ $phase_name script not found: $test_script${NC}"
    fi
    echo ""
}

# Phase 1: Safety and Prerequisites (critical checks)
echo -e "${BLUE}PHASE 1: Safety & Prerequisites${NC}"
run_phase "Safety Check" "./01-safety-check.sh"
run_phase "Boot Readiness" "./02-boot-test.sh"

# Phase 2: Core Functionality (basic operations)
echo -e "${BLUE}PHASE 2: Core Functionality${NC}"
run_phase "Functionality" "./03-functionality.sh"
run_phase "Docker Smoke Test" "./04-docker-smoke.sh"

# Phase 3: Quality & Experience (polish and UX)
echo -e "${BLUE}PHASE 3: Quality & Experience${NC}"
run_phase "Consistency" "./05-consistency-check.sh"
run_phase "Memory Guard" "./06-memory-guard.sh"
run_phase "Writer Experience" "./07-writer-experience.sh"

# Summary
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                    VALIDATION SUMMARY                         ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "Phases Passed: $PHASE_PASSED"
echo "Phases Failed: $PHASE_FAILED"
echo ""

if [ $PHASE_FAILED -eq 0 ]; then
    echo -e "${GREEN}🏰 SUCCESS: All validation phases passed!${NC}"
    echo "The digital court is ready for deployment!"
    exit 0
else
    echo -e "${RED}❌ FAILURE: $PHASE_FAILED phases failed${NC}"
    echo "Fix issues before deployment!"
    exit 1
fi