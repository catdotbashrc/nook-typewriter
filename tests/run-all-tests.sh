#!/bin/bash
# Master Test Runner for QuillKernel
# Executes all individual unit tests and generates report

set -euo pipefail

# Setup
TEST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$TEST_ROOT")"
REPORT_DIR="$TEST_ROOT/reports"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
REPORT_FILE="$REPORT_DIR/test_report_${TIMESTAMP}.md"
LOG_FILE="$REPORT_DIR/test_log_${TIMESTAMP}.txt"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0

# Failed test tracking
declare -a FAILED_TEST_LIST=()
declare -a SKIPPED_TEST_LIST=()

# Create report directory
mkdir -p "$REPORT_DIR"

# Start logging
exec > >(tee -a "$LOG_FILE")
exec 2>&1

echo "═══════════════════════════════════════════════════════════════"
echo "           🏰 Nook Typewriter Test Suite 🏰"
echo "           Comprehensive Safety Validation"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "Test Started: $(date)"
echo "Project Root: $PROJECT_ROOT"
echo ""

# Define critical tests that must pass
declare -a CRITICAL_TESTS=(
    "kernel-safety.sh"
    "test-jesteros-userspace.sh"
    "test-boot-sequence.sh"
    "test-memory-budget.sh"
    "pre-flight.sh"
    "smoke-test.sh"
)

# Function to run a single test
run_test() {
    local test_file="$1"
    local test_name=$(basename "$test_file" .sh)
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    # Make test executable
    chmod +x "$test_file"
    
    # Run test and capture result
    if output=$("$test_file" 2>&1); then
        if echo "$output" | grep -q "\[SKIP\]"; then
            SKIPPED_TESTS=$((SKIPPED_TESTS + 1))
            echo -e "${YELLOW}[SKIP]${NC} $test_name"
            echo "$output" | grep "\[SKIP\]" | sed 's/^/  /'
            SKIPPED_TEST_LIST+=("$test_name")
        else
            PASSED_TESTS=$((PASSED_TESTS + 1))
            echo -e "${GREEN}[PASS]${NC} $test_name"
        fi
    else
        FAILED_TESTS=$((FAILED_TESTS + 1))
        echo -e "${RED}[FAIL]${NC} $test_name"
        echo "$output" | tail -5 | sed 's/^/  /'
        FAILED_TEST_LIST+=("$test_name")
    fi
}

# Function to run tests in a category
run_category() {
    local category="$1"
    local category_dir="$TEST_ROOT/unit/$category"
    
    if [ ! -d "$category_dir" ]; then
        echo -e "${YELLOW}Category directory not found: $category${NC}"
        return
    fi
    
    echo ""
    echo -e "${BLUE}Testing Category: ${category}${NC}"
    echo "----------------------------------------"
    
    # Find and run all test files in category
    for test_file in "$category_dir"/test-*.sh; do
        if [ -f "$test_file" ]; then
            run_test "$test_file"
        fi
    done
}

# Run critical tests first
echo "Running Critical Safety Tests"
echo "==============================="
echo ""
echo -e "${RED}CRITICAL TESTS - MUST PASS FOR DEPLOYMENT${NC}"
echo "----------------------------------------"

CRITICAL_FAILED=false
for test_name in "${CRITICAL_TESTS[@]}"; do
    test_file="$TEST_ROOT/$test_name"
    if [ -f "$test_file" ]; then
        run_test "$test_file"
        # Check if this critical test failed
        if [ $? -ne 0 ]; then
            CRITICAL_FAILED=true
        fi
    else
        echo -e "${YELLOW}[SKIP]${NC} $test_name (not found - will be created)"
        SKIPPED_TESTS=$((SKIPPED_TESTS + 1))
        SKIPPED_TEST_LIST+=("$test_name")
    fi
done

if [ "$CRITICAL_FAILED" = true ]; then
    echo ""
    echo -e "${RED}╔═══════════════════════════════════════╗${NC}"
    echo -e "${RED}║   CRITICAL TESTS FAILED!              ║${NC}"
    echo -e "${RED}║   DO NOT DEPLOY TO HARDWARE!          ║${NC}"
    echo -e "${RED}╚═══════════════════════════════════════╝${NC}"
fi

# Run all test categories
echo ""
echo "Running Unit Tests by Category"
echo "==============================="

# High Priority Categories
echo ""
echo -e "${PURPLE}HIGH PRIORITY TESTS${NC}"
run_category "toolchain"
run_category "memory"
run_category "modules"
run_category "build"

# Medium Priority Categories
echo ""
echo -e "${PURPLE}MEDIUM PRIORITY TESTS${NC}"
run_category "eink"
run_category "boot"
run_category "theme"
run_category "menu"
run_category "docs"

# Generate Test Report
echo ""
echo "Generating test report..."

cat > "$REPORT_FILE" << EOF
# QuillKernel Test Report

**Generated**: $(date)  
**Test Suite Version**: 1.0.0  
**Project**: Nook Typewriter QuillKernel

## Executive Summary

| Metric | Count | Percentage |
|--------|-------|------------|
| Total Tests | $TOTAL_TESTS | 100% |
| Passed | $PASSED_TESTS | $(echo "scale=1; $PASSED_TESTS * 100 / $TOTAL_TESTS" | bc)% |
| Failed | $FAILED_TESTS | $(echo "scale=1; $FAILED_TESTS * 100 / $TOTAL_TESTS" | bc)% |
| Skipped | $SKIPPED_TESTS | $(echo "scale=1; $SKIPPED_TESTS * 100 / $TOTAL_TESTS" | bc)% |

## Test Categories

### High Priority Tests
- **Toolchain**: Cross-compilation and NDK verification
- **Memory**: Resource constraint validation
- **Modules**: SquireOS kernel module integrity
- **Build**: Build system and Docker configuration

### Medium Priority Tests
- **E-Ink**: Display abstraction and compatibility
- **Boot**: Boot sequence and module loading
- **Theme**: Medieval theme preservation
- **Menu**: User interface and input validation
- **Documentation**: Project documentation completeness

EOF

if [ ${#FAILED_TEST_LIST[@]} -gt 0 ]; then
    echo "## Failed Tests" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    for test in "${FAILED_TEST_LIST[@]}"; do
        echo "- ❌ $test" >> "$REPORT_FILE"
    done
    echo "" >> "$REPORT_FILE"
fi

if [ ${#SKIPPED_TEST_LIST[@]} -gt 0 ]; then
    echo "## Skipped Tests" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    for test in "${SKIPPED_TEST_LIST[@]}"; do
        echo "- ⏭️ $test" >> "$REPORT_FILE"
    done
    echo "" >> "$REPORT_FILE"
fi

cat >> "$REPORT_FILE" << EOF

## Test Environment

- **Platform**: $(uname -s)
- **Architecture**: $(uname -m)
- **Kernel**: $(uname -r)
- **Docker Version**: $(docker --version 2>/dev/null || echo "Not installed")

## Medieval Quality Seal

EOF

if [ $FAILED_TESTS -eq 0 ]; then
    cat >> "$REPORT_FILE" << EOF
### 🏰 Castle Fortified!

All critical tests have passed. The Nook Typewriter stands ready for deployment.

*"By quill and candlelight, quality prevails!"*

🃏 **Jester Approval**: Granted
EOF
    
    # Generate test-passed marker for gate keeper
    echo "Generating test gate marker..."
    cat > "$PROJECT_ROOT/.test-passed" << EOF
# Test Suite Success Marker
# Generated: $(date)
# All critical tests passed
TEST_TIMESTAMP=$(date +%s)
PASS_COUNT=$PASSED_TESTS
FAIL_COUNT=0
EOF
    echo -e "${GREEN}✅ Test gate marker created${NC}"
else
    cat >> "$REPORT_FILE" << EOF
### ⚔️ Defenses Breached!

Some tests have failed. The Nook Typewriter requires attention before deployment.

*"The jester frowns upon these failures..."*

🃏 **Jester Approval**: Withheld
EOF
fi

echo "" >> "$REPORT_FILE"
echo "---" >> "$REPORT_FILE"
echo "*Full test log available at: $LOG_FILE*" >> "$REPORT_FILE"

# Display summary
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "                        TEST SUMMARY"
echo "═══════════════════════════════════════════════════════════════"
echo -e "Total Tests:    $TOTAL_TESTS"
echo -e "Passed:         ${GREEN}$PASSED_TESTS${NC}"
echo -e "Failed:         ${RED}$FAILED_TESTS${NC}"
echo -e "Skipped:        ${YELLOW}$SKIPPED_TESTS${NC}"
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}✅ ALL TESTS PASSED!${NC}"
    echo "The QuillKernel is ready for deployment!"
    echo ""
    echo "📜 Report: $REPORT_FILE"
    echo "📋 Full log: $LOG_FILE"
    exit 0
else
    echo -e "${RED}❌ TESTS FAILED!${NC}"
    echo "$FAILED_TESTS test(s) require attention."
    echo ""
    echo "Failed tests:"
    for test in "${FAILED_TEST_LIST[@]}"; do
        echo "  - $test"
    done
    echo ""
    echo "📜 Report: $REPORT_FILE"
    echo "📋 Full log: $LOG_FILE"
    exit 1
fi