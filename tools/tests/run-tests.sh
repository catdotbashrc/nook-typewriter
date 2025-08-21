#!/bin/bash
# Three-Stage Test Runner for Nook TypeWriter
# Supports pre-build, post-build, and runtime testing stages

set -euo pipefail

# Colors for pretty output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Test stage configuration
TEST_STAGE=${TEST_STAGE:-post-build}
export TEST_STAGE

cd "$(dirname "$0")"

echo "═══════════════════════════════════════════════════════════════"
echo "           🎭 NOOK TYPEWRITER TEST SUITE v3.0"
echo "           Three-Stage Testing Architecture"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo -e "${CYAN}Current Stage: $TEST_STAGE${NC}"
echo ""

case "$TEST_STAGE" in
    pre-build)
        echo "🔨 PRE-BUILD STAGE - Testing build tools in scripts/"
        echo "Target: Development and deployment scripts"
        ;;
    post-build)
        echo "📦 POST-BUILD STAGE - Testing Docker output in source/scripts/"
        echo "Target: Runtime scripts that will run on Nook"
        ;;
    runtime)
        echo "🚀 RUNTIME STAGE - Testing execution in Docker container"
        echo "Target: Actual behavior validation"
        ;;
    *)
        echo -e "${RED}ERROR: Invalid TEST_STAGE=$TEST_STAGE${NC}"
        echo "Valid stages: pre-build, post-build, runtime"
        exit 1
        ;;
esac

echo ""
echo "Test Categories:"
echo "  🛡️  Show Stoppers (MUST PASS) - Will it brick?"
echo "  🚧 Writing Blockers (SHOULD PASS) - Can you write?"
echo "  ✨ Writer Experience (NICE TO PASS) - Is it pleasant?"
echo ""
echo "Starting $TEST_STAGE test run..."
echo ""

CRITICAL_FAILED=0
IMPORTANT_FAILED=0
NICE_FAILED=0

# Determine which tests to run based on stage
SHOW_STOPPER_TESTS=()
WRITING_BLOCKER_TESTS=()
EXPERIENCE_TESTS=()

case "$TEST_STAGE" in
    pre-build)
        # Pre-build: Test build tools
        SHOW_STOPPER_TESTS=("01-safety-check.sh")
        WRITING_BLOCKER_TESTS=()
        EXPERIENCE_TESTS=()
        ;;
    post-build)
        # Post-build: Test Docker-generated scripts
        SHOW_STOPPER_TESTS=("01-safety-check.sh" "02-boot-test.sh")
        WRITING_BLOCKER_TESTS=("05-consistency-check.sh" "06-memory-guard.sh")
        EXPERIENCE_TESTS=("03-functionality.sh" "07-writer-experience.sh")
        ;;
    runtime)
        # Runtime: Test actual execution
        SHOW_STOPPER_TESTS=("02-boot-test.sh")
        WRITING_BLOCKER_TESTS=("04-docker-smoke.sh")
        EXPERIENCE_TESTS=("07-writer-experience.sh")
        ;;
esac

# Category 1: Show Stoppers (MUST PASS)
if [ ${#SHOW_STOPPER_TESTS[@]} -gt 0 ]; then
    echo -e "${RED}═══ SHOW STOPPERS (Must Pass) ═══${NC}"
    for test in "${SHOW_STOPPER_TESTS[@]}"; do
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
fi

# Category 2: Writing Blockers (SHOULD PASS)
if [ ${#WRITING_BLOCKER_TESTS[@]} -gt 0 ]; then
    echo -e "${YELLOW}═══ WRITING BLOCKERS (Should Pass) ═══${NC}"
    for test in "${WRITING_BLOCKER_TESTS[@]}"; do
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
fi

# Category 3: Writer Experience (NICE TO PASS)
if [ ${#EXPERIENCE_TESTS[@]} -gt 0 ]; then
    echo -e "${PURPLE}═══ WRITER EXPERIENCE (Nice to Pass) ═══${NC}"
    for test in "${EXPERIENCE_TESTS[@]}"; do
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
fi

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

# Stage-specific guidance
echo -e "${CYAN}Stage: $TEST_STAGE${NC}"
case "$TEST_STAGE" in
    pre-build)
        echo "Next: Run 'make docker-build' then 'TEST_STAGE=post-build make test'"
        ;;
    post-build)
        echo "Next: Run 'TEST_STAGE=runtime make test' to validate execution"
        ;;
    runtime)
        echo "Testing complete! Deploy if all critical tests pass."
        ;;
esac
echo ""

# Overall assessment
if [ "$TOTAL_FAILED" -eq 0 ]; then
    echo -e "${GREEN}🎉 PERFECT SCORE - ALL TESTS PASSED!${NC}"
    echo ""
    echo "Your Nook is ready for the next stage!"
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
    echo "You can proceed, but writing experience may suffer."
    echo "Recommendation: Fix Writing Blocker tests first."
    exit 1
else
    echo -e "${GREEN}✅ GOOD ENOUGH TO PROCEED!${NC}"
    echo ""
    echo "Only nice-to-have features missing."
    echo "Continue to next stage!"
    exit 0
fi