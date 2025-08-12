#!/bin/bash
# High Priority Test Suite for QuillKernel
# Tests critical functionality: toolchain, memory, modules, boot

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0

# Test results array
declare -a TEST_RESULTS

# Test framework functions
run_test() {
    local test_name="$1"
    local test_function="$2"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -e "${BLUE}[TEST]${NC} Running: $test_name"
    
    if $test_function; then
        PASSED_TESTS=$((PASSED_TESTS + 1))
        echo -e "${GREEN}[PASS]${NC} $test_name"
        TEST_RESULTS+=("PASS: $test_name")
    else
        FAILED_TESTS=$((FAILED_TESTS + 1))
        echo -e "${RED}[FAIL]${NC} $test_name"
        TEST_RESULTS+=("FAIL: $test_name")
    fi
}

skip_test() {
    local test_name="$1"
    local reason="$2"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    SKIPPED_TESTS=$((SKIPPED_TESTS + 1))
    echo -e "${YELLOW}[SKIP]${NC} $test_name - $reason"
    TEST_RESULTS+=("SKIP: $test_name - $reason")
}

# Assertion helpers
assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Values should be equal}"
    
    if [ "$expected" = "$actual" ]; then
        return 0
    else
        echo "  Assertion failed: $message"
        echo "    Expected: $expected"
        echo "    Actual: $actual"
        return 1
    fi
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-Should contain substring}"
    
    if echo "$haystack" | grep -q "$needle"; then
        return 0
    else
        echo "  Assertion failed: $message"
        echo "    Looking for: $needle"
        return 1
    fi
}

assert_file_exists() {
    local file="$1"
    local message="${2:-File should exist}"
    
    if [ -f "$file" ]; then
        return 0
    else
        echo "  Assertion failed: $message"
        echo "    File not found: $file"
        return 1
    fi
}

assert_pass() {
    local message="$1"
    echo "  ✓ $message"
    return 0
}

assert_fail() {
    local message="$1"
    echo "  ✗ $message"
    return 1
}

# =============================================================================
# HIGH PRIORITY TESTS - Critical for boot and functionality
# =============================================================================

echo "═══════════════════════════════════════════════════════════════"
echo "       QuillKernel High Priority Test Suite"
echo "       Testing Critical Components"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# -----------------------------------------------------------------------------
# 1. TOOLCHAIN COMPATIBILITY TESTS
# -----------------------------------------------------------------------------

test_docker_image_exists() {
    if docker images | grep -q "quillkernel-unified"; then
        assert_pass "Unified Docker image exists"
        return 0
    else
        assert_fail "Unified Docker image not found"
        return 1
    fi
}

test_ndk_version() {
    if ! docker images | grep -q "quillkernel-unified"; then
        echo "  Building Docker image for testing..."
        docker build -t quillkernel-unified -f build/docker/kernel-xda-proven.dockerfile build/docker/ >/dev/null 2>&1
    fi
    
    local ndk_version=$(docker run --rm quillkernel-unified arm-linux-androideabi-gcc --version 2>/dev/null | head -1)
    if echo "$ndk_version" | grep -q "4.9"; then
        assert_pass "NDK 4.9 toolchain verified (XDA-proven)"
        return 0
    else
        assert_fail "Incorrect NDK version: $ndk_version"
        return 1
    fi
}

test_cross_compiler_path() {
    local compiler_exists=$(docker run --rm quillkernel-unified which arm-linux-androideabi-gcc 2>/dev/null)
    if [ -n "$compiler_exists" ]; then
        assert_pass "Cross-compiler found at: $compiler_exists"
        return 0
    else
        assert_fail "Cross-compiler not found in Docker image"
        return 1
    fi
}

# -----------------------------------------------------------------------------
# 2. MEMORY CONSTRAINT TESTS
# -----------------------------------------------------------------------------

test_docker_memory_limit() {
    # Test that Docker containers respect memory limits
    local mem_test=$(docker run --rm -m 256m quillkernel-unified free -m 2>/dev/null | grep Mem | awk '{print $2}')
    if [ "$mem_test" -le 256 ]; then
        assert_pass "Docker memory limit enforced: ${mem_test}MB"
        return 0
    else
        assert_fail "Docker memory limit not enforced: ${mem_test}MB"
        return 1
    fi
}

test_kernel_config_memory() {
    # Check kernel config for memory-efficient settings
    if [ -f source/kernel/src/.config ]; then
        local has_minimal=$(grep -c "CONFIG_EMBEDDED=y" source/kernel/src/.config || echo 0)
        if [ "$has_minimal" -gt 0 ]; then
            assert_pass "Kernel configured for embedded systems"
            return 0
        else
            assert_fail "Kernel not optimized for embedded systems"
            return 1
        fi
    else
        skip_test "test_kernel_config_memory" "Kernel config not yet generated"
        return 0
    fi
}

# -----------------------------------------------------------------------------
# 3. SQUIREOS MODULE TESTS
# -----------------------------------------------------------------------------

test_module_source_exists() {
    local modules=("squireos_core.c" "jester.c" "typewriter.c" "wisdom.c")
    local all_found=true
    
    for module in "${modules[@]}"; do
        if [ ! -f "source/kernel/src/drivers/squireos/$module" ]; then
            echo "  Missing module source: $module"
            all_found=false
        fi
    done
    
    if $all_found; then
        assert_pass "All SquireOS module sources present"
        return 0
    else
        assert_fail "Some SquireOS modules missing"
        return 1
    fi
}

test_module_kconfig() {
    if [ -f "source/kernel/src/drivers/squireos/Kconfig" ]; then
        local has_squireos=$(grep -c "config SQUIREOS" source/kernel/src/drivers/squireos/Kconfig || echo 0)
        if [ "$has_squireos" -gt 0 ]; then
            assert_pass "SquireOS Kconfig present and configured"
            return 0
        else
            assert_fail "SquireOS Kconfig incomplete"
            return 1
        fi
    else
        assert_fail "SquireOS Kconfig missing"
        return 1
    fi
}

test_module_makefile() {
    if [ -f "source/kernel/src/drivers/squireos/Makefile" ]; then
        local has_modules=$(grep -c "obj-\$(CONFIG_SQUIREOS)" source/kernel/src/drivers/squireos/Makefile || echo 0)
        if [ "$has_modules" -gt 0 ]; then
            assert_pass "SquireOS Makefile configured correctly"
            return 0
        else
            assert_fail "SquireOS Makefile incomplete"
            return 1
        fi
    else
        assert_fail "SquireOS Makefile missing"
        return 1
    fi
}

# -----------------------------------------------------------------------------
# 4. UIMAGE GENERATION TESTS
# -----------------------------------------------------------------------------

test_build_script_exists() {
    if [ -f "build_unified_kernel.sh" ]; then
        assert_pass "Unified build script exists"
        return 0
    else
        assert_fail "Unified build script missing"
        return 1
    fi
}

test_build_script_executable() {
    if [ -x "build_unified_kernel.sh" ]; then
        assert_pass "Build script is executable"
        return 0
    else
        assert_fail "Build script not executable"
        return 1
    fi
}

test_dockerfile_exists() {
    if [ -f "build/docker/kernel-xda-proven.dockerfile" ]; then
        assert_pass "XDA-proven Dockerfile exists"
        return 0
    else
        assert_fail "XDA-proven Dockerfile missing"
        return 1
    fi
}

test_dockerfile_ndk_download() {
    if grep -q "android-ndk-r12b" build/docker/kernel-xda-proven.dockerfile 2>/dev/null; then
        assert_pass "Dockerfile configured for NDK r12b (XDA-proven)"
        return 0
    else
        assert_fail "Dockerfile not using XDA-proven NDK version"
        return 1
    fi
}

# -----------------------------------------------------------------------------
# RUN ALL HIGH PRIORITY TESTS
# -----------------------------------------------------------------------------

echo "1. Toolchain Compatibility Tests"
echo "---------------------------------"
run_test "Docker image exists" test_docker_image_exists
run_test "NDK version correct" test_ndk_version
run_test "Cross-compiler available" test_cross_compiler_path

echo ""
echo "2. Memory Constraint Tests"
echo "--------------------------"
run_test "Docker memory limits" test_docker_memory_limit
run_test "Kernel memory config" test_kernel_config_memory

echo ""
echo "3. SquireOS Module Tests"
echo "------------------------"
run_test "Module sources exist" test_module_source_exists
run_test "Module Kconfig present" test_module_kconfig
run_test "Module Makefile configured" test_module_makefile

echo ""
echo "4. uImage Generation Tests"
echo "--------------------------"
run_test "Build script exists" test_build_script_exists
run_test "Build script executable" test_build_script_executable
run_test "XDA Dockerfile exists" test_dockerfile_exists
run_test "Dockerfile NDK version" test_dockerfile_ndk_download

# -----------------------------------------------------------------------------
# TEST SUMMARY
# -----------------------------------------------------------------------------

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "                    HIGH PRIORITY TEST RESULTS"
echo "═══════════════════════════════════════════════════════════════"
echo -e "Total Tests:    $TOTAL_TESTS"
echo -e "Passed:         ${GREEN}$PASSED_TESTS${NC}"
echo -e "Failed:         ${RED}$FAILED_TESTS${NC}"
echo -e "Skipped:        ${YELLOW}$SKIPPED_TESTS${NC}"
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}✓ All high priority tests passed!${NC}"
    echo "  QuillKernel critical components verified"
    exit 0
else
    echo -e "${RED}✗ Some high priority tests failed${NC}"
    echo "  Please address critical issues before deployment"
    echo ""
    echo "Failed tests:"
    for result in "${TEST_RESULTS[@]}"; do
        if [[ $result == FAIL* ]]; then
            echo "  - $result"
        fi
    done
    exit 1
fi