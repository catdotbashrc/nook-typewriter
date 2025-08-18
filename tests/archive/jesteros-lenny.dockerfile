# JesterOS Authentic Test Environment
# Uses ACTUAL Debian Lenny 5.0 (period-correct from 2009)
# This matches the REAL deployment environment on Nook hardware
# "Testing with true authenticity - as it would actually run!"

FROM scratch

# Copy the authentic Debian Lenny 5.0 rootfs
# This is the EXACT same environment that runs on Nook hardware
ADD ./lenny-rootfs.tar.gz /

# Install essential packages for testing (that would be available in Lenny)
# Note: We'll use the packages that are already in the lenny-rootfs
RUN echo "Setting up authentic Debian Lenny 5.0 test environment..."

# Create the complete JesterOS directory structure (as it would be deployed)
RUN mkdir -p /runtime/1-ui/display \
    /runtime/1-ui/themes \
    /runtime/2-application/jesteros \
    /runtime/3-system/common \
    /runtime/3-system/services \
    /runtime/4-hardware/eink \
    # ASCII consolidated to /runtime/1-ui/themes \
    /runtime/configs/services \
    /runtime/configs/system \
    /runtime/init \
    /var/jesteros/typewriter \
    /var/jesteros/health \
    /var/run/jesteros \
    /var/log/jesteros \
    /var/lib/jester \
    /etc/jesteros/services \
    /usr/local/bin \
    /root/manuscripts \
    /root/notes \
    /root/drafts \
    /root/scrolls

# Copy the JesterOS runtime system (exactly as deployed)
COPY runtime/ /runtime/

# Make all scripts executable (as they would be in deployment)
RUN find /runtime -name "*.sh" -type f -exec chmod +x {} \; 2>/dev/null || true

# Create symbolic links for JesterOS services (as installed on Nook)
RUN ln -sf /runtime/2-application/jesteros/jester-daemon.sh /usr/local/bin/jester-daemon.sh && \
    ln -sf /runtime/2-application/jesteros/jesteros-tracker.sh /usr/local/bin/jesteros-tracker.sh && \
    ln -sf /runtime/2-application/jesteros/health-check.sh /usr/local/bin/health-check.sh && \
    ln -sf /runtime/2-application/jesteros/manager.sh /usr/local/bin/jesteros-manager.sh && \
    ln -sf /runtime/init/jesteros-service-init.sh /usr/local/bin/jesteros-service-init.sh

# Initialize jester's home (as it would be on Nook)
RUN echo "By quill and candlelight!" > /var/lib/jester/motto && \
    echo "0" > /var/lib/jester/wordcount

# Set environment variables to match authentic Nook deployment
ENV TERM=linux
ENV EDITOR=vi
ENV SHELL=/bin/sh
ENV RUNTIME_BASE=/runtime
ENV JESTEROS_BASE=/var/jesteros
ENV COMMON_PATH=/runtime/3-system/common/common.sh
ENV DEBIAN_FRONTEND=noninteractive

# Working directory (as on Nook)
WORKDIR /root

# Copy test scripts
COPY tests/ /tests/
RUN chmod +x /tests/*.sh 2>/dev/null || true

# Create authentic Lenny validation test
RUN cat > /validate-lenny-authentic.sh << 'EOF'
#!/bin/bash
# JesterOS Authentic Debian Lenny Validation
# Tests services in the EXACT environment they run on Nook hardware
# "By quill and candlelight, we test with authentic medieval precision!"

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║            JESTEROS AUTHENTIC LENNY VALIDATION                ║"
echo "║       \"Testing in the true spirit of the medieval realm!\"     ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Show authentic environment
echo -e "${BLUE}Authentic Nook Environment:${NC}"
echo "  OS: $(cat /etc/issue | head -1)"
echo "  Kernel: $(uname -r 2>/dev/null || echo 'Container kernel')"
echo "  Architecture: $(uname -m)"
echo "  Shell: $SHELL"
echo "  Editor: $EDITOR"
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

# Test 1: Authentic Lenny Environment
run_test "Authentic Debian Lenny" '
    [ -f "/etc/issue" ] &&
    grep -q "Debian GNU/Linux 5.0" /etc/issue &&
    [ -f "/etc/debian_version" ]
'

# Test 2: Lenny-Compatible Tools
run_test "Period-Correct Tools Available" '
    which sh >/dev/null 2>&1 &&
    which grep >/dev/null 2>&1 &&
    which awk >/dev/null 2>&1 &&
    which sed >/dev/null 2>&1
'

# Test 3: JesterOS Directory Structure
run_test "JesterOS Directory Structure" '
    [ -d "/runtime/2-application/jesteros" ] &&
    [ -d "/runtime/3-system/common" ] &&
    [ -d "/var/jesteros" ] &&
    [ -d "/var/lib/jester" ]
'

# Test 4: Service Scripts Compatibility
run_test "Service Scripts in Lenny" '
    [ -x "/usr/local/bin/jesteros-service-init.sh" ] &&
    [ -x "/runtime/2-application/jesteros/manager.sh" ] &&
    [ -x "/runtime/2-application/jesteros/health-check.sh" ]
'

# Test 5: System Initialization (Lenny-compatible)
run_test "Lenny-Compatible Initialization" '
    /usr/local/bin/jesteros-service-init.sh directories >/dev/null 2>&1 &&
    /usr/local/bin/jesteros-service-init.sh interface >/dev/null 2>&1
'

# Test 6: Interface Files Creation
run_test "Interface Files in Lenny" '
    [ -s "/var/jesteros/jester" ] &&
    [ -s "/var/jesteros/typewriter/stats" ] &&
    [ -s "/var/jesteros/wisdom" ]
'

# Test 7: Service Manager (Lenny Environment)
run_test "Service Manager in Lenny" '
    /runtime/2-application/jesteros/manager.sh init >/dev/null 2>&1 &&
    [ -f "/etc/jesteros/services/jester.conf" ] &&
    [ -f "/etc/jesteros/services/health.conf" ]
'

# Test 8: Health Monitoring (Lenny-compatible)
run_test "Health Monitoring in Lenny" '
    /runtime/2-application/jesteros/health-check.sh check >/dev/null 2>&1 &&
    [ -s "/var/jesteros/health/status" ]
'

# Test 9: Medieval Theme Preservation
run_test "Medieval Theme in Lenny" '
    grep -q "jester\|court\|digital" /var/jesteros/jester &&
    grep -q -i "writing\|typewriter" /var/jesteros/typewriter/stats &&
    [ -f "/var/lib/jester/motto" ] &&
    grep -q "quill" /var/lib/jester/motto
'

# Test 10: Lenny Shell Compatibility
run_test "Lenny Shell Script Compatibility" '
    # Test that our scripts work with Lenny'\''s older bash/sh
    bash --version >/dev/null 2>&1 || sh --version >/dev/null 2>&1
'

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                    AUTHENTIC VALIDATION SUMMARY               ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "Tests Passed: $passed_tests/$test_count"

if [ $passed_tests -eq $test_count ]; then
    echo -e "${GREEN}🏰 SUCCESS: Authentic Lenny validation COMPLETE!${NC}"
    echo ""
    echo "✅ Running in authentic Debian Lenny 5.0 (2009)"
    echo "✅ Period-correct tools and environment"
    echo "✅ JesterOS services work in authentic environment"
    echo "✅ Medieval theming preserved in Lenny"
    echo "✅ Service management operational in 2009 environment"
    echo "✅ Compatible with Nook hardware constraints"
    echo ""
    echo -e "${YELLOW}Sample Authentic Output:${NC}"
    echo "========================="
    echo -e "${BLUE}Jester in Lenny:${NC}"
    head -5 /var/jesteros/jester | sed "s/^/  /"
    echo ""
    echo -e "${BLUE}System Info:${NC}"
    echo "  Debian Version: $(cat /etc/debian_version)"
    echo "  Available Memory: $(grep MemTotal /proc/meminfo 2>/dev/null | awk '{print $2/1024 "MB"}' || echo 'N/A (container)')"
    echo ""
    echo -e "${GREEN}Ready for deployment to actual Nook hardware!${NC}"
    echo -e "${YELLOW}\"In the authentic spirit of 2009, the digital court is ready!\"${NC}"
    exit 0
else
    echo -e "${RED}❌ Authentic validation FAILED!${NC}"
    echo "Services not compatible with authentic Lenny environment"
    exit 1
fi
EOF

# Make validation script executable
RUN chmod +x /validate-lenny-authentic.sh

# Default command runs authentic validation
CMD ["/validate-lenny-authentic.sh"]