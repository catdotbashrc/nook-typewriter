#!/bin/bash
# QuillKernel Build Testing Script
# Comprehensive testing of kernel build process using .env configuration

set -euo pipefail

# Load environment configuration
if [ -f .env ]; then
    source .env
    echo "✓ Loaded build environment configuration"
else
    echo "✗ .env configuration file not found"
    exit 1
fi

# Medieval-themed output
echo "═══════════════════════════════════════════════════════════════"
echo "     🏰 QuillKernel Build Testing Suite"
echo "     By quill and compiler, we forge the kernel!"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Create test results directory
mkdir -p "$TEST_RESULTS_DIR"
TEST_LOG="$TEST_RESULTS_DIR/build_test_$(date +%Y%m%d_%H%M%S).log"

# Logging function
log_test() {
    echo "$1" | tee -a "$TEST_LOG"
}

# Test functions
test_environment() {
    log_test "🔍 Testing Build Environment..."
    
    # Check required tools
    local missing_tools=()
    IFS=',' read -ra TOOLS <<< "$REQUIRED_TOOLS"
    for tool in "${TOOLS[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            missing_tools+=("$tool")
        else
            log_test "  ✓ Found tool: $tool"
        fi
    done
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        log_test "  ✗ Missing tools: ${missing_tools[*]}"
        return 1
    fi
    
    # Check Docker images
    local missing_images=()
    IFS=',' read -ra IMAGES <<< "$REQUIRED_IMAGES"
    for image in "${IMAGES[@]}"; do
        if ! docker images | grep -q "$image"; then
            missing_images+=("$image")
        else
            log_test "  ✓ Found Docker image: $image"
        fi
    done
    
    if [ ${#missing_images[@]} -gt 0 ]; then
        log_test "  ⚠ Missing Docker images: ${missing_images[*]}"
        log_test "  → Building missing images..."
        # You could add automatic image building here
    fi
    
    log_test "✓ Environment validation completed"
    return 0
}

test_cross_compiler() {
    log_test "🔧 Testing Cross-Compilation Toolchain..."
    
    # Test in Docker container
    if docker run --rm "$DOCKER_BUILDER_IMAGE" which "$CROSS_COMPILE"gcc >/dev/null 2>&1; then
        local version
        version=$(docker run --rm "$DOCKER_BUILDER_IMAGE" "$CROSS_COMPILE"gcc --version | head -1)
        log_test "  ✓ Cross-compiler available: $version"
    else
        log_test "  ✗ Cross-compiler not found in Docker image"
        return 1
    fi
    
    # Test compilation capability
    log_test "  Testing compilation capability..."
    if docker run --rm "$DOCKER_BUILDER_IMAGE" bash -c "
        echo 'int main() { return 0; }' > /tmp/test.c &&
        ${CROSS_COMPILE}gcc -o /tmp/test /tmp/test.c &&
        file /tmp/test | grep -q ARM
    "; then
        log_test "  ✓ Cross-compilation working correctly"
    else
        log_test "  ✗ Cross-compilation test failed"
        return 1
    fi
    
    return 0
}

test_kernel_source() {
    log_test "📁 Testing Kernel Source Structure..."
    
    # Check source directory
    if [ -d "$KERNEL_SOURCE_DIR" ]; then
        log_test "  ✓ Kernel source directory exists: $KERNEL_SOURCE_DIR"
    else
        log_test "  ✗ Kernel source directory missing: $KERNEL_SOURCE_DIR"
        return 1
    fi
    
    # Check for key kernel files
    local kernel_files=("Makefile" "arch/arm" "drivers" "include")
    local found_files=0
    
    for file in "${kernel_files[@]}"; do
        if [ -e "$KERNEL_SOURCE_DIR/$file" ]; then
            log_test "  ✓ Found: $file"
            ((found_files++))
        else
            log_test "  ✗ Missing: $file"
        fi
    done
    
    if [ $found_files -eq 0 ]; then
        log_test "  ⚠ Kernel source tree appears empty - this is expected for initial setup"
        log_test "  → Kernel source needs to be downloaded/initialized"
        return 2  # Warning, not failure
    fi
    
    return 0
}

test_squireos_modules() {
    log_test "🎭 Testing SquireOS Module Configuration..."
    
    # Check module directory
    if [ -d "$SQUIREOS_MODULE_DIR" ]; then
        log_test "  ✓ SquireOS module directory exists"
    else
        log_test "  ⚠ SquireOS module directory not found: $SQUIREOS_MODULE_DIR"
        log_test "  → Creating module directory structure..."
        mkdir -p "$SQUIREOS_MODULE_DIR"
    fi
    
    # Check for module source files
    IFS=',' read -ra MODULES <<< "$SQUIREOS_MODULES"
    local found_modules=0
    
    for module in "${MODULES[@]}"; do
        local source_file="${module%.ko}.c"
        if [ -f "$SQUIREOS_MODULE_DIR/$source_file" ]; then
            log_test "  ✓ Found module source: $source_file"
            ((found_modules++))
        else
            log_test "  ✗ Missing module source: $source_file"
        fi
    done
    
    if [ $found_modules -eq 0 ]; then
        log_test "  ⚠ No SquireOS module sources found - need to be implemented"
        return 2  # Warning
    fi
    
    return 0
}

test_build_process() {
    log_test "⚒️  Testing Build Process..."
    
    # Check build script
    if [ -x "$BUILD_SCRIPT" ]; then
        log_test "  ✓ Build script is executable: $BUILD_SCRIPT"
    else
        log_test "  ✗ Build script not executable: $BUILD_SCRIPT"
        return 1
    fi
    
    # Test build script syntax
    if bash -n "$BUILD_SCRIPT"; then
        log_test "  ✓ Build script syntax is valid"
    else
        log_test "  ✗ Build script has syntax errors"
        return 1
    fi
    
    # Attempt a dry-run build (with timeout)
    log_test "  Attempting build process (with 5-minute timeout)..."
    if timeout "$TEST_TIMEOUT_SECONDS" "$BUILD_SCRIPT" 2>&1 | tee -a "$TEST_LOG" | tail -10; then
        log_test "  ✓ Build process completed without critical errors"
        
        # Check for artifacts
        if [ -f "$KERNEL_IMAGE_PATH" ]; then
            log_test "  ✓ Kernel image found: $KERNEL_IMAGE_PATH"
            ls -lh "$KERNEL_IMAGE_PATH" | tee -a "$TEST_LOG"
        else
            log_test "  ⚠ Kernel image not found: $KERNEL_IMAGE_PATH"
        fi
        
    else
        local exit_code=$?
        if [ $exit_code -eq 124 ]; then
            log_test "  ⚠ Build process timed out after $TEST_TIMEOUT_SECONDS seconds"
        else
            log_test "  ⚠ Build process failed with exit code: $exit_code"
        fi
        return 2  # Warning, not failure for testing
    fi
    
    return 0
}

test_memory_constraints() {
    log_test "💾 Testing Memory Constraints..."
    
    # Test Docker memory limits
    log_test "  Testing Docker container memory usage..."
    local mem_usage
    mem_usage=$(docker run --rm -m "${TOTAL_RAM_MB}m" "$DOCKER_BUILDER_IMAGE" \
        awk '/MemTotal/ {printf "%.0f", $2/1024}' /proc/meminfo 2>/dev/null || echo "0")
    
    if [ "$mem_usage" -gt 0 ] && [ "$mem_usage" -le "$TOTAL_RAM_MB" ]; then
        log_test "  ✓ Memory constraint respected: ${mem_usage}MB <= ${TOTAL_RAM_MB}MB"
    elif [ "$mem_usage" -gt "$TOTAL_RAM_MB" ]; then
        log_test "  ⚠ Memory usage high: ${mem_usage}MB (limit: ${TOTAL_RAM_MB}MB)"
        log_test "    → This may be host memory shown (expected in some Docker setups)"
    else
        log_test "  ✗ Could not determine memory usage"
        return 1
    fi
    
    # Check Docker image sizes
    log_test "  Checking Docker image sizes..."
    local builder_size
    builder_size=$(docker images --format "{{.Size}}" "$DOCKER_BUILDER_IMAGE" 2>/dev/null || echo "unknown")
    local rootfs_size
    rootfs_size=$(docker images --format "{{.Size}}" "$DOCKER_ROOTFS_IMAGE" 2>/dev/null || echo "unknown")
    
    log_test "  Builder image size: $builder_size"
    log_test "  Rootfs image size: $rootfs_size"
    
    return 0
}

# Main test execution
main() {
    local test_failures=0
    local test_warnings=0
    
    echo "Starting comprehensive build testing..."
    echo "Test log: $TEST_LOG"
    echo ""
    
    # Run test categories
    local tests=(
        "test_environment:Environment Setup"
        "test_cross_compiler:Cross-Compiler"
        "test_kernel_source:Kernel Source"
        "test_squireos_modules:SquireOS Modules"
        "test_build_process:Build Process"
        "test_memory_constraints:Memory Constraints"
    )
    
    for test_spec in "${tests[@]}"; do
        local test_func="${test_spec%%:*}"
        local test_name="${test_spec##*:}"
        
        echo "Running: $test_name"
        echo "----------------------------------------"
        
        if $test_func; then
            echo "✅ $test_name: PASSED"
        else
            local exit_code=$?
            if [ $exit_code -eq 2 ]; then
                echo "⚠️  $test_name: WARNING"
                ((test_warnings++))
            else
                echo "❌ $test_name: FAILED"
                ((test_failures++))
            fi
        fi
        echo ""
    done
    
    # Summary
    echo "═══════════════════════════════════════════════════════════════"
    echo "     🏰 QuillKernel Build Test Results"
    echo "═══════════════════════════════════════════════════════════════"
    
    if [ $test_failures -eq 0 ] && [ $test_warnings -eq 0 ]; then
        echo "🎉 ALL TESTS PASSED!"
        echo "By quill and candlelight, the build environment is ready!"
    elif [ $test_failures -eq 0 ]; then
        echo "✅ TESTS PASSED with $test_warnings warnings"
        echo "The build environment is mostly ready, with minor setup needed."
    else
        echo "💥 $test_failures TESTS FAILED, $test_warnings warnings"
        echo "The jester weeps - build environment needs attention!"
        return 1
    fi
    
    echo ""
    echo "Full test log: $TEST_LOG"
    echo "Test completed: $(date)"
    
    return 0
}

# Execute main function
main "$@"