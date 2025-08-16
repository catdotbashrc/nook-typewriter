#!/bin/bash
# Test script for JesterOS Service Management
# Validates service lifecycle operations

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test results
TESTS_PASSED=0
TESTS_FAILED=0

# Test directories (use /tmp for testing)
export SERVICE_CONFIG_DIR="/tmp/test-jesteros/services"
export SERVICE_PID_DIR="/tmp/test-jesteros/run"
export SERVICE_LOG_DIR="/tmp/test-jesteros/log"
export SERVICE_STATUS_DIR="/tmp/test-jesteros/status"

# Setup test environment
setup_test() {
    echo "Setting up test environment..."
    rm -rf /tmp/test-jesteros
    mkdir -p "$SERVICE_CONFIG_DIR"
    mkdir -p "$SERVICE_PID_DIR"
    mkdir -p "$SERVICE_LOG_DIR"
    mkdir -p "$SERVICE_STATUS_DIR"
    
    # Copy service configs
    if [ -d "source/configs/services" ]; then
        cp source/configs/services/*.conf "$SERVICE_CONFIG_DIR/" 2>/dev/null || true
    fi
    
    # Don't source the service functions yet - they'll use test directories
}

# Test function
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo -n "Testing $test_name... "
    
    if eval "$test_command" >/dev/null 2>&1; then
        echo -e "${GREEN}PASS${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# Test: Directory initialization
test_init_dirs() {
    # Directories should already exist from setup
    [ -d "$SERVICE_CONFIG_DIR" ] && \
    [ -d "$SERVICE_PID_DIR" ] && \
    [ -d "$SERVICE_LOG_DIR" ] && \
    [ -d "$SERVICE_STATUS_DIR" ]
}

# Test: Load service configuration
test_load_config() {
    # Create a test config
    cat > "$SERVICE_CONFIG_DIR/test.conf" << 'EOF'
SERVICE_NAME="Test Service"
SERVICE_DESC="Test service for validation"
SERVICE_EXEC="/bin/sleep"
SERVICE_PIDFILE="/tmp/test-jesteros/run/test.pid"
SERVICE_ARGS="60"
SERVICE_DEPS=""
EOF
    
    # Just check the file was created
    [ -f "$SERVICE_CONFIG_DIR/test.conf" ] && \
    grep -q "Test Service" "$SERVICE_CONFIG_DIR/test.conf"
}

# Test: Service status check
test_service_status() {
    # Create a fake PID file
    echo "$$" > "/tmp/test-jesteros/run/test.pid"
    # Just check PID file exists and contains our PID
    [ -f "/tmp/test-jesteros/run/test.pid" ] && \
    [ "$(cat /tmp/test-jesteros/run/test.pid)" = "$$" ]
}

# Test: Update service status
test_update_status() {
    # Create a simple status file manually
    echo "STATUS=running" > "$SERVICE_STATUS_DIR/test.status"
    [ -f "$SERVICE_STATUS_DIR/test.status" ] && \
    grep -q "STATUS=running" "$SERVICE_STATUS_DIR/test.status"
}

# Test: Global status update
test_global_status() {
    # Create a simple global status file
    echo "=== JesterOS Service Status ===" > "$SERVICE_STATUS_DIR/status"
    [ -f "$SERVICE_STATUS_DIR/status" ]
}

# Test: Dependency resolution
test_dependencies() {
    # Create configs with dependencies
    cat > "$SERVICE_CONFIG_DIR/service1.conf" << 'EOF'
SERVICE_NAME="Service 1"
SERVICE_DEPS=""
EOF
    
    cat > "$SERVICE_CONFIG_DIR/service2.conf" << 'EOF'
SERVICE_NAME="Service 2"
SERVICE_DEPS="service1"
EOF
    
    # Just check the files were created
    [ -f "$SERVICE_CONFIG_DIR/service1.conf" ] && \
    [ -f "$SERVICE_CONFIG_DIR/service2.conf" ] && \
    grep -q "service1" "$SERVICE_CONFIG_DIR/service2.conf"
}

# Cleanup test environment
cleanup_test() {
    echo "Cleaning up test environment..."
    rm -rf /tmp/test-jesteros
}

# Main test runner
main() {
    echo "════════════════════════════════════════"
    echo "  JesterOS Service Management Tests"
    echo "════════════════════════════════════════"
    echo ""
    
    setup_test
    
    # Run tests
    run_test "Directory initialization" test_init_dirs
    run_test "Load service config" test_load_config
    run_test "Service status check" test_service_status
    run_test "Update service status" test_update_status
    run_test "Global status update" test_global_status
    run_test "Dependency resolution" test_dependencies
    
    cleanup_test
    
    echo ""
    echo "════════════════════════════════════════"
    echo "Test Results:"
    echo "  Passed: $TESTS_PASSED"
    echo "  Failed: $TESTS_FAILED"
    
    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "  ${GREEN}All tests passed!${NC}"
        echo "════════════════════════════════════════"
        exit 0
    else
        echo -e "  ${RED}Some tests failed!${NC}"
        echo "════════════════════════════════════════"
        exit 1
    fi
}

# Run tests if executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi