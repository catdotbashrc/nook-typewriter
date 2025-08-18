# JesterOS Test Environment
# Extends unified development base with testing capabilities
# "By quill and candlelight, we test with precision!"

# Build from the unified development base (has all tools needed for testing)
FROM jesteros:dev-base AS jesteros-test

# Copy test scripts into the image
COPY tests/ /tests/
RUN chmod +x /tests/*.sh 2>/dev/null || true

# Create comprehensive validation script
RUN cat > /validate-jesteros.sh << 'EOF'
#!/bin/bash
# JesterOS Comprehensive Test Validation
# Tests all JesterOS functionality in authentic environment
# "By quill and candlelight, we ensure quality!"

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                JESTEROS TEST VALIDATION SUITE                 ║"
echo "║         \"Testing in the true spirit of quality!\"              ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Show test environment
echo -e "${BLUE}Test Environment:${NC}"
echo "  OS: $(cat /etc/issue | head -1)"
echo "  Kernel: $(uname -r 2>/dev/null || echo 'Container kernel')"
echo "  Architecture: $(uname -m)"
echo "  Shell: $SHELL"
echo "  Debian Release: $(cat /etc/debian_version 2>/dev/null || echo 'Lenny 5.0')"
echo ""

test_count=0
passed_tests=0

run_test() {
    local test_name="$1"
    local test_cmd="$2"
    ((test_count++))
    echo -e "${BLUE}Test $test_count: $test_name${NC}"
    if eval "$test_cmd"; then
        echo -e "${GREEN}✓ PASSED${NC}"
        ((passed_tests++))
    else
        echo -e "${RED}✗ FAILED${NC}"
        return 1
    fi
}

# Test 1: Debian Lenny Environment
run_test "Authentic Debian Lenny" '
    [ -f "/etc/issue" ] &&
    grep -q "Debian GNU/Linux 5.0" /etc/issue &&
    [ -f "/etc/debian_version" ]
'

# Test 2: Required Tools Available
run_test "Period-Correct Tools" '
    which sh >/dev/null 2>&1 &&
    which grep >/dev/null 2>&1 &&
    which awk >/dev/null 2>&1 &&
    which sed >/dev/null 2>&1
'

# Test 3: JesterOS Directory Structure
run_test "Directory Structure" '
    [ -d "/runtime/2-application/jesteros" ] &&
    [ -d "/runtime/3-system/common" ] &&
    [ -d "/var/jesteros" ] &&
    [ -d "/var/lib/jester" ]
'

# Test 4: Service Scripts Executable
run_test "Service Scripts" '
    [ -x "/usr/local/bin/jesteros-service-init.sh" ] &&
    [ -x "/runtime/2-application/jesteros/manager.sh" ] &&
    [ -x "/runtime/2-application/jesteros/health-check.sh" ]
'

# Test 5: System Initialization
run_test "System Initialization" '
    /usr/local/bin/jesteros-service-init.sh directories >/dev/null 2>&1 &&
    /usr/local/bin/jesteros-service-init.sh interface >/dev/null 2>&1
'

# Test 6: Interface Files
run_test "Interface Files" '
    [ -s "/var/jesteros/jester" ] &&
    [ -s "/var/jesteros/typewriter/stats" ] &&
    [ -s "/var/jesteros/wisdom" ]
'

# Test 7: Service Manager
run_test "Service Manager" '
    /runtime/2-application/jesteros/manager.sh init >/dev/null 2>&1 &&
    [ -f "/etc/jesteros/services/jester.conf" ] &&
    [ -f "/etc/jesteros/services/health.conf" ]
'

# Test 8: Health Monitoring
run_test "Health Monitoring" '
    /runtime/2-application/jesteros/health-check.sh check >/dev/null 2>&1 &&
    [ -s "/var/jesteros/health/status" ]
'

# Test 9: Medieval Theme
run_test "Medieval Theme" '
    grep -q "jester\|court\|digital" /var/jesteros/jester &&
    grep -q -i "writing\|typewriter" /var/jesteros/typewriter/stats &&
    [ -f "/var/lib/jester/motto" ] &&
    grep -q "quill" /var/lib/jester/motto
'

# Test 10: Shell Compatibility
run_test "Shell Compatibility" '
    bash --version >/dev/null 2>&1 || sh --version >/dev/null 2>&1
'

# Run additional test scripts if present
if [ -d "/tests" ]; then
    echo ""
    echo -e "${YELLOW}Running additional test scripts...${NC}"
    for test_script in /tests/*.sh; do
        if [ -f "$test_script" ] && [ -x "$test_script" ]; then
            echo -e "${BLUE}Running: $(basename $test_script)${NC}"
            if "$test_script"; then
                echo -e "${GREEN}✓ $(basename $test_script) passed${NC}"
            else
                echo -e "${RED}✗ $(basename $test_script) failed${NC}"
            fi
        fi
    done
fi

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                      TEST VALIDATION SUMMARY                  ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "Tests Passed: $passed_tests/$test_count"

if [ $passed_tests -eq $test_count ]; then
    echo -e "${GREEN}🏰 SUCCESS: All tests passed!${NC}"
    echo ""
    echo "✅ Running in authentic Debian Lenny 5.0"
    echo "✅ JesterOS services operational"
    echo "✅ Medieval theming preserved"
    echo "✅ Ready for deployment"
    echo ""
    echo -e "${YELLOW}Sample Output:${NC}"
    echo "========================="
    echo -e "${BLUE}Jester:${NC}"
    head -5 /var/jesteros/jester | sed "s/^/  /"
    echo ""
    echo -e "${GREEN}All systems operational!${NC}"
    echo -e "${YELLOW}\"Quality assured by the digital court!\"${NC}"
    exit 0
else
    echo -e "${RED}❌ Test validation FAILED!${NC}"
    echo "Some tests did not pass"
    exit 1
fi
EOF

# Make validation script executable
RUN chmod +x /validate-jesteros.sh

# Default command runs validation
CMD ["/validate-jesteros.sh"]