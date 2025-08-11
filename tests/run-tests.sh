#!/bin/bash
# Main test runner for Nook Typewriter
# Executes all test suites and reports results

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test results
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

# Test directory
TEST_DIR="$(dirname "$0")"
cd "$TEST_DIR"

# Function to run a test
run_test() {
    local test_name="$1"
    local test_file="$2"
    
    echo -n "Running $test_name... "
    
    if [ ! -f "$test_file" ]; then
        echo -e "${YELLOW}SKIPPED${NC} (file not found)"
        ((TESTS_SKIPPED++))
        return
    fi
    
    if bash "$test_file" >/tmp/test.log 2>&1; then
        echo -e "${GREEN}PASSED${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}FAILED${NC}"
        echo "  Error output:"
        tail -5 /tmp/test.log | sed 's/^/    /'
        ((TESTS_FAILED++))
    fi
}

# Header
echo "================================"
echo "Nook Typewriter Test Suite"
echo "================================"
echo ""

# Run tests
run_test "Docker Build" "./test-docker-build.sh"
run_test "Vim Modes" "./test-vim-modes.sh"
run_test "Menu System" "./test-menu-system.sh"
run_test "Health Check" "./test-health-check.sh"
run_test "Plugin System" "./test-plugin-system.sh"
run_test "Deployment" "./test-deployment.sh"

# Summary
echo ""
echo "================================"
echo "Test Results"
echo "================================"
echo -e "Passed:  ${GREEN}$TESTS_PASSED${NC}"
echo -e "Failed:  ${RED}$TESTS_FAILED${NC}"
echo -e "Skipped: ${YELLOW}$TESTS_SKIPPED${NC}"
echo ""

# Exit code
if [ $TESTS_FAILED -gt 0 ]; then
    echo -e "${RED}TESTS FAILED${NC}"
    exit 1
else
    echo -e "${GREEN}ALL TESTS PASSED${NC}"
    exit 0
fi