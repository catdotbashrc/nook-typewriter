#!/bin/bash
# Foundation Validation Script for QuillKernel Project
# Phase 1: Validate existing build system and prepare for hardware testing

set -euo pipefail
trap 'echo "Error at line $LINENO"' ERR

echo "═══════════════════════════════════════════════════════════════"
echo "           QuillKernel Foundation Validation"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test results
TESTS_PASSED=0
TESTS_FAILED=0

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo -n "→ Testing $test_name... "
    if eval "$test_command" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ PASSED${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗ FAILED${NC}"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Function to check memory usage
check_memory() {
    local image="$1"
    local max_mb="$2"
    
    echo -n "→ Checking memory for $image... "
    
    # Run container and check memory stats
    local container_id=$(docker run -d --rm "$image" sleep 10 2>/dev/null || echo "")
    
    if [ -z "$container_id" ]; then
        echo -e "${YELLOW}⚠ Couldn't start container${NC}"
        return 1
    fi
    
    sleep 2
    local mem_usage=$(docker stats --no-stream --format "{{.MemUsage}}" "$container_id" | awk '{print $1}' | sed 's/MiB//')
    docker kill "$container_id" > /dev/null 2>&1 || true
    
    # Convert to integer for comparison
    mem_int=$(echo "$mem_usage" | cut -d'.' -f1)
    
    if [ "$mem_int" -lt "$max_mb" ]; then
        echo -e "${GREEN}✓ ${mem_usage}MB < ${max_mb}MB${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗ ${mem_usage}MB > ${max_mb}MB${NC}"
        ((TESTS_FAILED++))
        return 1
    fi
}

echo "═══════════════════════════════════════════════════════════════"
echo "STAGE 1: Docker Images Validation"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Check if Docker images exist
run_test "Docker daemon running" "docker info"
run_test "QuillKernel builder image exists" "docker images | grep -q quillkernel-builder"
run_test "MVP rootfs image exists" "docker images | grep -q nook-mvp-rootfs"
run_test "Nook writer image exists" "docker images | grep -q nook-writer"

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "STAGE 2: Build System Validation"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Check build scripts
run_test "QuillKernel build script exists" "[ -f quillkernel/build.sh ]"
run_test "QuillKernel build script is executable" "[ -x quillkernel/build.sh ]"
run_test "Kernel build script exists" "[ -f build_kernel.sh ]"
run_test "Install script exists" "[ -f install_to_sdcard.sh ]"

# Check kernel modules source
run_test "squireos_core.c exists" "[ -f quillkernel/modules/squireos_core.c ]"
run_test "jester.c exists" "[ -f quillkernel/modules/jester.c ]"
run_test "typewriter.c exists" "[ -f quillkernel/modules/typewriter.c ]"
run_test "wisdom.c exists" "[ -f quillkernel/modules/wisdom.c ]"
run_test "Module Makefile exists" "[ -f quillkernel/modules/Makefile ]"

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "STAGE 3: Memory Budget Compliance"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Check memory usage of Docker images (skip if containers can't run)
if docker info > /dev/null 2>&1; then
    check_memory "nook-mvp-rootfs" 96 || true
    # Note: Other images might not have proper entrypoints for memory testing
else
    echo -e "${YELLOW}⚠ Docker not available for memory testing${NC}"
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "STAGE 4: Kernel Configuration"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Check kernel submodule
run_test "Kernel submodule initialized" "[ -d nst-kernel-base/src ]"
run_test "Kernel Makefile exists" "[ -f nst-kernel-base/src/Makefile ]"
run_test "ARM architecture files exist" "[ -d nst-kernel-base/src/arch/arm ]"

# Check for NDK toolchain in Docker
echo -n "→ Checking Android NDK in Docker... "
if docker run --rm quillkernel-builder which arm-linux-androideabi-gcc > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Cross-compiler found${NC}"
    ((TESTS_PASSED++))
else
    echo -e "${YELLOW}⚠ Cross-compiler not verified${NC}"
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "STAGE 5: Output Artifacts"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Check for expected outputs
run_test "Rootfs tarball exists" "[ -f quillkernel/nook-mvp-rootfs.tar.gz ]"

# Check tarball size
echo -n "→ Checking rootfs size... "
if [ -f quillkernel/nook-mvp-rootfs.tar.gz ]; then
    size_mb=$(du -m quillkernel/nook-mvp-rootfs.tar.gz | cut -f1)
    if [ "$size_mb" -lt 50 ]; then
        echo -e "${GREEN}✓ ${size_mb}MB (good for SD card)${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${YELLOW}⚠ ${size_mb}MB (larger than expected)${NC}"
    fi
else
    echo -e "${RED}✗ File not found${NC}"
    ((TESTS_FAILED++))
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "VALIDATION SUMMARY"
echo "═══════════════════════════════════════════════════════════════"
echo ""

total_tests=$((TESTS_PASSED + TESTS_FAILED))
echo "Tests Run: $total_tests"
echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Failed: ${RED}$TESTS_FAILED${NC}"

if [ "$TESTS_FAILED" -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✓ Foundation validation PASSED!${NC}"
    echo "Ready to proceed to Phase 2: Integration & Build"
else
    echo ""
    echo -e "${YELLOW}⚠ Foundation validation incomplete${NC}"
    echo "Please fix the failed tests before proceeding"
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "NEXT STEPS"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "1. If all tests passed:"
echo "   - Run: ./build_kernel.sh"
echo "   - Prepare SD card for deployment"
echo ""
echo "2. If tests failed:"
echo "   - Check Docker installation"
echo "   - Rebuild missing images"
echo "   - Initialize git submodules"
echo ""
echo "3. For memory issues:"
echo "   - Review Docker image layers"
echo "   - Remove unnecessary packages"
echo "   - Use minimal base images"
echo ""
echo "═══════════════════════════════════════════════════════════════"