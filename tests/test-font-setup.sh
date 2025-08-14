#!/bin/bash
# Test font configuration setup
# Validates Terminus fonts are properly installed and configured

set -euo pipefail
trap 'echo "Test failed at line $LINENO"' ERR

# Colors for output (if terminal supports it)
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    NC='\033[0m' # No Color
else
    RED=''
    GREEN=''
    YELLOW=''
    NC=''
fi

echo "==================================="
echo "    Font Configuration Test"
echo "==================================="
echo ""

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test function
run_test() {
    local test_name="$1"
    local test_cmd="$2"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    echo -n "Testing $test_name... "
    
    if eval "$test_cmd" >/dev/null 2>&1; then
        echo -e "${GREEN}PASSED${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}FAILED${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Test 1: Check if font packages can be installed
echo "1. Docker Build Tests"
echo "---------------------"

# Build minimal test image
echo "Building minimal boot image with fonts..."
if docker build -t nook-font-test -f build/docker/minimal-boot.dockerfile . >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Minimal boot image builds with font packages"
else
    echo -e "${RED}✗${NC} Failed to build minimal boot image"
    exit 1
fi

# Build writer image
echo "Building writer image with fonts..."
if docker build -t nook-writer-font-test -f build/docker/nookwriter-optimized.dockerfile . >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Writer image builds with font packages"
else
    echo -e "${RED}✗${NC} Failed to build writer image"
    exit 1
fi

echo ""
echo "2. Font Availability Tests"
echo "--------------------------"

# Test font directories exist
run_test "Font directory exists" \
    "docker run --rm nook-font-test sh -c 'test -d /usr/share/consolefonts'"

# Test Terminus fonts are installed
run_test "Terminus fonts installed" \
    "docker run --rm nook-font-test sh -c 'ls /usr/share/consolefonts/ter-*.psf.gz >/dev/null 2>&1'"

# Test setfont command exists
run_test "setfont command available" \
    "docker run --rm nook-font-test sh -c 'which setfont'"

echo ""
echo "3. Font Configuration Script Tests"
echo "-----------------------------------"

# Test font-setup.sh exists in writer image
run_test "font-setup.sh exists" \
    "docker run --rm nook-writer-font-test sh -c 'test -f /usr/local/bin/font-setup.sh'"

# Test font-setup.sh is executable
run_test "font-setup.sh is executable" \
    "docker run --rm nook-writer-font-test sh -c 'test -x /usr/local/bin/font-setup.sh'"

# Test font-setup.sh syntax
run_test "font-setup.sh syntax valid" \
    "docker run --rm nook-writer-font-test sh -c 'bash -n /usr/local/bin/font-setup.sh'"

echo ""
echo "4. Boot Integration Tests"
echo "-------------------------"

# Test boot script includes font setup
run_test "Boot script calls font-setup.sh" \
    "docker run --rm nook-writer-font-test sh -c 'grep -q font-setup.sh /usr/local/bin/boot-jester.sh'"

# Test minimal init includes font configuration
run_test "Minimal init configures font" \
    "docker run --rm nook-font-test sh -c 'grep -q setfont /init'"

echo ""
echo "5. Memory Impact Test"
echo "---------------------"

# Check memory usage of font packages
echo "Checking memory impact..."
BASE_SIZE=$(docker images -q debian:bullseye-slim | xargs docker inspect -f '{{.Size}}' | head -1)
TEST_SIZE=$(docker images -q nook-font-test | xargs docker inspect -f '{{.Size}}' | head -1)
FONT_OVERHEAD=$((TEST_SIZE - BASE_SIZE))
FONT_OVERHEAD_MB=$((FONT_OVERHEAD / 1024 / 1024))

if [ "$FONT_OVERHEAD_MB" -lt 10 ]; then
    echo -e "${GREEN}✓${NC} Font packages add only ${FONT_OVERHEAD_MB}MB (acceptable)"
else
    echo -e "${YELLOW}⚠${NC} Font packages add ${FONT_OVERHEAD_MB}MB (review needed)"
fi

echo ""
echo "==================================="
echo "Test Summary"
echo "==================================="
echo "Tests Run:    $TESTS_RUN"
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
if [ "$TESTS_FAILED" -gt 0 ]; then
    echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"
else
    echo -e "Tests Failed: ${GREEN}$TESTS_FAILED${NC}"
fi

# Clean up test images
echo ""
echo "Cleaning up test images..."
docker rmi nook-font-test nook-writer-font-test >/dev/null 2>&1 || true

if [ "$TESTS_FAILED" -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✓ All font configuration tests passed!${NC}"
    echo "Terminus fonts are ready for E-Ink readability!"
    exit 0
else
    echo ""
    echo -e "${RED}✗ Some tests failed. Please review the configuration.${NC}"
    exit 1
fi