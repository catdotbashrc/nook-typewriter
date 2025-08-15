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
echo "           QuillKernel Comprehensive Test Suite"
echo "           Individual Unit Test Execution"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "Test Started: $(date)"
echo "Project Root: $PROJECT_ROOT"
echo ""

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

# Run all test categories
echo "Running Test Suite"
echo "==============================="

# Core Safety Tests
echo ""
echo -e "${PURPLE}CORE SAFETY TESTS${NC}"
echo "----------------------------------------"
if [ -f "$TEST_ROOT/kernel-safety.sh" ]; then
    run_test "$TEST_ROOT/kernel-safety.sh"
fi
if [ -f "$TEST_ROOT/pre-flight.sh" ]; then
    run_test "$TEST_ROOT/pre-flight.sh"
fi

# Userspace Service Tests
echo ""
echo -e "${PURPLE}USERSPACE SERVICE TESTS${NC}"
echo "----------------------------------------"
if [ -f "$TEST_ROOT/test-userspace-services.sh" ]; then
    run_test "$TEST_ROOT/test-userspace-services.sh"
fi
if [ -f "$TEST_ROOT/test-service-management.sh" ]; then
    run_test "$TEST_ROOT/test-service-management.sh"
fi

# Integration Tests
echo ""
echo -e "${PURPLE}INTEGRATION TESTS${NC}"
echo "----------------------------------------"
if [ -f "$TEST_ROOT/test-jesteros-integration.sh" ]; then
    run_test "$TEST_ROOT/test-jesteros-integration.sh"
fi

# High Priority Categories (if unit tests exist)
if [ -d "$TEST_ROOT/unit" ]; then
    echo ""
    echo -e "${PURPLE}UNIT TESTS${NC}"
    run_category "toolchain"
    run_category "memory"
    run_category "modules"
    run_category "build"
    run_category "eink"
    run_category "boot"
    run_category "theme"
    run_category "menu"
    run_category "docs"
fi

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

### Core Safety Tests
- **Kernel Safety**: Validates kernel and userspace safety
- **Pre-Flight**: Deployment readiness checks

### Userspace Service Tests
- **Service Components**: JesterOS userspace service validation
- **Service Management**: Service lifecycle and dependency testing

### Integration Tests
- **Boot to Menu**: Complete system flow validation
- **Memory Compliance**: Resource usage verification

### Unit Tests (if available)
- **Toolchain**: Cross-compilation and NDK verification
- **Memory**: Resource constraint validation
- **Build**: Build system and Docker configuration
- **E-Ink**: Display abstraction and compatibility
- **Boot**: Boot sequence validation
- **Theme**: Medieval theme preservation
- **Menu**: User interface and input validation

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

All critical tests have passed. The QuillKernel stands ready for deployment.

*"By quill and candlelight, quality prevails!"*

🃏 **Jester Approval**: Granted
EOF
else
    cat >> "$REPORT_FILE" << EOF
### ⚔️ Defenses Breached!

Some tests have failed. The QuillKernel requires attention before deployment.

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