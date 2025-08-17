#!/bin/bash
# Quick JesterOS Integration Test
# "Testing the essential functionality!"

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[TEST]${NC} $1"
}

error() {
    echo -e "${RED}[FAIL]${NC} $1"
}

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                  JESTEROS QUICK TEST                          ║"
echo "║         \"By quill and candlelight, we validate!\"               ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

test_count=0
passed_tests=0

# Test 1: Basic directory structure
echo "Test 1: Directory Structure"
if [ -d "/runtime/2-application/jesteros" ] && [ -d "/var/jesteros" ]; then
    log "✓ Core directories exist"
    ((passed_tests++))
else
    error "✗ Missing core directories"
fi
((test_count++))

# Test 2: Service scripts exist
echo "Test 2: Service Scripts"
if [ -x "/usr/local/bin/jesteros-service-init.sh" ] && [ -x "/runtime/2-application/jesteros/manager.sh" ]; then
    log "✓ Service scripts are executable"
    ((passed_tests++))
else
    error "✗ Service scripts missing or not executable"
fi
((test_count++))

# Test 3: Directory initialization
echo "Test 3: Directory Initialization"
if /usr/local/bin/jesteros-service-init.sh directories >/dev/null 2>&1; then
    log "✓ Directory initialization works"
    ((passed_tests++))
else
    error "✗ Directory initialization failed"
fi
((test_count++))

# Test 4: Interface creation
echo "Test 4: Interface Creation"
if /usr/local/bin/jesteros-service-init.sh interface >/dev/null 2>&1; then
    log "✓ Interface creation works"
    ((passed_tests++))
else
    error "✗ Interface creation failed"
fi
((test_count++))

# Test 5: Interface files exist and have content
echo "Test 5: Interface Content"
if [ -s "/var/jesteros/jester" ] && [ -s "/var/jesteros/typewriter/stats" ] && [ -s "/var/jesteros/wisdom" ]; then
    log "✓ Interface files created with content"
    ((passed_tests++))
else
    error "✗ Interface files missing or empty"
fi
((test_count++))

# Test 6: Service manager initialization
echo "Test 6: Service Manager"
if /runtime/2-application/jesteros/manager.sh init >/dev/null 2>&1; then
    log "✓ Service manager initialization works"
    ((passed_tests++))
else
    error "✗ Service manager initialization failed"
fi
((test_count++))

# Test 7: Health check functionality
echo "Test 7: Health Check"
if /runtime/2-application/jesteros/health-check.sh check >/dev/null 2>&1; then
    log "✓ Health check works"
    ((passed_tests++))
else
    error "✗ Health check failed"
fi
((test_count++))

# Test 8: Content validation
echo "Test 8: Content Validation"
if grep -q "jester\|court" /var/jesteros/jester && grep -q -i "writing\|words" /var/jesteros/typewriter/stats; then
    log "✓ Content has proper theming"
    ((passed_tests++))
else
    error "✗ Content validation failed"
fi
((test_count++))

# Summary
echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                        TEST SUMMARY                           ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "Total Tests: $test_count"
echo -e "Passed: ${GREEN}$passed_tests${NC}"
echo -e "Failed: $((test_count - passed_tests))${NC}"
echo ""

if [ $passed_tests -eq $test_count ]; then
    echo -e "${GREEN}🎭 All tests passed! JesterOS userspace services are working!${NC}"
    echo ""
    echo "Sample outputs:"
    echo "Jester:"
    head -3 /var/jesteros/jester
    echo ""
    echo "Writing Stats:"
    head -3 /var/jesteros/typewriter/stats
    echo ""
    echo "Health Status:"
    head -3 /var/jesteros/health/status 2>/dev/null || echo "Health status will be available after full service startup"
    echo ""
    echo -e "${GREEN}✅ JesterOS userspace migration is COMPLETE and FUNCTIONAL!${NC}"
    exit 0
else
    echo -e "${RED}⚠️  Some tests failed!${NC}"
    exit 1
fi