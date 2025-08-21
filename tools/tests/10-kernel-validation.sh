#!/bin/bash
# ===================================================================
# JesterOS Kernel Build Validation
# ===================================================================
# Tests the kernel build process comprehensively:
# - Build environment validation
# - Cross-compilation toolchain
# - Configuration correctness
# - Size and format constraints
# - Boot compatibility
# ===================================================================

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source test configuration
source "$PROJECT_ROOT/tests/test-config.sh" || {
    echo "Failed to source test-config.sh"
    exit 1
}

# Test configuration
TEST_NAME="Kernel Build Validation"
TEST_CRITICAL=true
KERNEL_MAX_SIZE=$((2 * 1024 * 1024))  # 2MB max for uImage
KERNEL_BUILD_SCRIPT="$PROJECT_ROOT/scripts/build/build_kernel.sh"
KERNEL_CONFIG="$PROJECT_ROOT/vendor/kernel/src/.config"
KERNEL_SOURCE_DIR="$PROJECT_ROOT/vendor/kernel/src"

# Expected kernel parameters for Nook
EXPECTED_LOAD_ADDR="0x80008000"
EXPECTED_ENTRY_POINT="0x80008000"
EXPECTED_ARCH="arm"
EXPECTED_VERSION="2.6.29"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0

# Test helper functions
pass_test() {
    local test_name="$1"
    echo -e "${GREEN}✓${NC} $test_name"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

fail_test() {
    local test_name="$1"
    local reason="$2"
    echo -e "${RED}✗${NC} $test_name"
    echo -e "  ${YELLOW}Reason: $reason${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

info_msg() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# ===================================================================
# Test Functions
# ===================================================================

test_environment_files() {
    echo -e "\n${GREEN}[TEST]${NC} Checking environment configuration..."
    
    if [[ -f "$PROJECT_ROOT/.kernel.env" ]]; then
        pass_test ".kernel.env exists"
        
        # Check for critical variables
        if grep -q "LOADADDR=" "$PROJECT_ROOT/.kernel.env"; then
            pass_test "LOADADDR configured"
        else
            fail_test "LOADADDR missing" "Required for U-Boot"
        fi
        
        if grep -q "CROSS_COMPILE=" "$PROJECT_ROOT/.kernel.env"; then
            pass_test "CROSS_COMPILE configured"
        else
            fail_test "CROSS_COMPILE missing" "Required for ARM build"
        fi
    else
        fail_test ".kernel.env missing" "Environment configuration required"
    fi
    
    if [[ -f "$PROJECT_ROOT/.env" ]]; then
        pass_test ".env exists"
    else
        fail_test ".env missing" "Build environment configuration required"
    fi
}

test_build_script_exists() {
    echo -e "\n${GREEN}[TEST]${NC} Checking kernel build script..."
    
    if [[ -f "$KERNEL_BUILD_SCRIPT" ]]; then
        pass_test "Build script exists"
        
        if [[ -x "$KERNEL_BUILD_SCRIPT" ]]; then
            pass_test "Build script is executable"
        else
            fail_test "Build script not executable" "Missing execute permission"
        fi
        
        # Check for dangerous commands
        if grep -q "rm -rf /" "$KERNEL_BUILD_SCRIPT" 2>/dev/null; then
            fail_test "DANGEROUS: Script contains 'rm -rf /'"
            return 1
        else
            pass_test "Build script appears safe"
        fi
    else
        fail_test "Build script missing" "build/scripts/build_kernel.sh not found"
        return 1
    fi
}

test_docker_environment() {
    echo -e "\n${GREEN}[TEST]${NC} Checking Docker environment..."
    
    # Check if Docker is available
    if command -v docker &>/dev/null; then
        pass_test "Docker is installed"
        
        # Check if Docker daemon is running
        if docker info &>/dev/null; then
            pass_test "Docker daemon is running"
        else
            fail_test "Docker daemon not running" "Start Docker service"
        fi
        
        # Check for kernel build Dockerfile
        if [[ -f "$PROJECT_ROOT/docker/builder.dockerfile" ]]; then
            pass_test "Kernel Dockerfile exists (builder.dockerfile)"
        elif [[ -f "$PROJECT_ROOT/build/docker/kernel-xda-proven-optimized.dockerfile" ]]; then
            pass_test "Kernel Dockerfile exists (legacy path)"
        else
            fail_test "Kernel Dockerfile missing" "docker/builder.dockerfile not found"
        fi
    else
        fail_test "Docker not installed" "Docker is required for cross-compilation"
        return 1
    fi
}

test_cross_compilation_toolchain() {
    echo -e "\n${GREEN}[TEST]${NC} Checking cross-compilation requirements..."
    
    # Check if build script references ARM toolchain
    if grep -q -i "arm-linux\|arm-eabi\|ARCH=arm" "$KERNEL_BUILD_SCRIPT" 2>/dev/null; then
        pass_test "ARM toolchain referenced"
    else
        fail_test "No ARM toolchain found" "Build script must use ARM cross-compiler"
    fi
    
    # Check for CROSS_COMPILE variable
    if grep -q "CROSS_COMPILE" "$KERNEL_BUILD_SCRIPT" 2>/dev/null; then
        pass_test "CROSS_COMPILE variable set"
    else
        fail_test "CROSS_COMPILE not configured" "Must set CROSS_COMPILE for ARM"
    fi
    
    # Check for Android NDK (commonly used for Nook)
    if grep -q "android-ndk\|NDK" "$KERNEL_BUILD_SCRIPT" 2>/dev/null; then
        pass_test "Android NDK toolchain detected"
    else
        info_msg "Android NDK not detected (may use other toolchain)"
    fi
}

test_kernel_configuration() {
    echo -e "\n${GREEN}[TEST]${NC} Validating kernel configuration..."
    
    # Check for kernel config or defconfig
    if [[ -f "$KERNEL_CONFIG" ]]; then
        pass_test "Kernel .config exists"
    elif [[ -f "$PROJECT_ROOT/vendor/kernel/src/arch/arm/configs/nook_defconfig" ]]; then
        pass_test "Nook defconfig exists"
    elif [[ -f "$PROJECT_ROOT/vendor/kernel/src/arch/arm/configs/omap3621_gossamer_evt1c_defconfig" ]]; then
        pass_test "OMAP3621 Gossamer defconfig exists (used by build script)"
    elif [[ -f "$PROJECT_ROOT/vendor/kernel/src/arch/arm/configs/omap3621_evt1a_defconfig" ]]; then
        pass_test "OMAP3621 EVT1A defconfig exists"
    else
        fail_test "No kernel config found" "Need .config or defconfig for Nook"
    fi
    
    # Check critical kernel options (if .config exists)
    if [[ -f "$KERNEL_CONFIG" ]]; then
        # Check for OMAP support
        if grep -q "CONFIG_ARCH_OMAP=y" "$KERNEL_CONFIG" 2>/dev/null; then
            pass_test "OMAP architecture enabled"
        else
            fail_test "OMAP not enabled" "Nook requires CONFIG_ARCH_OMAP=y"
        fi
        
        # Check for framebuffer (E-ink display)
        if grep -q "CONFIG_FB=y" "$KERNEL_CONFIG" 2>/dev/null; then
            pass_test "Framebuffer support enabled"
        else
            fail_test "Framebuffer not enabled" "E-ink needs CONFIG_FB=y"
        fi
        
        # Check for initramfs support
        if grep -q "CONFIG_BLK_DEV_INITRD=y" "$KERNEL_CONFIG" 2>/dev/null; then
            pass_test "Initramfs support enabled"
        else
            fail_test "Initramfs not enabled" "Boot needs CONFIG_BLK_DEV_INITRD=y"
        fi
    else
        info_msg "Skipping config checks (no .config yet)"
    fi
}

test_memory_constraints() {
    echo -e "\n${GREEN}[TEST]${NC} Checking memory constraints..."
    
    # Check if kernel config limits memory appropriately
    if [[ -f "$KERNEL_CONFIG" ]]; then
        # Check for 256MB memory configuration
        if grep -q "CONFIG_CMDLINE.*mem=256M\|CONFIG_MEMORY.*256" "$KERNEL_CONFIG" 2>/dev/null; then
            pass_test "256MB memory configured"
        else
            info_msg "Memory limit not in config (may be in bootargs)"
        fi
        
        # Check for memory optimization options
        if grep -q "CONFIG_EMBEDDED=y" "$KERNEL_CONFIG" 2>/dev/null; then
            pass_test "Embedded optimizations enabled"
        else
            fail_test "Not optimized for embedded" "Enable CONFIG_EMBEDDED=y"
        fi
        
        # Check if unnecessary features are disabled
        if grep -q "CONFIG_DEBUG_KERNEL=y" "$KERNEL_CONFIG" 2>/dev/null; then
            fail_test "Debug kernel enabled" "Disable for production (wastes memory)"
        else
            pass_test "Debug features disabled"
        fi
    else
        info_msg "Memory checks pending (no .config)"
    fi
}

test_uboot_compatibility() {
    echo -e "\n${GREEN}[TEST]${NC} Testing U-Boot compatibility..."
    
    # Check if uImage is created (either via make uImage or mkimage)
    if grep -q "uImage\|mkimage" "$KERNEL_BUILD_SCRIPT" 2>/dev/null; then
        pass_test "uImage generation configured"
        
        # Check for correct load address (make uImage uses built-in default which is correct for ARM)
        if grep -q "$EXPECTED_LOAD_ADDR\|LOADADDR.*0x80008000" "$KERNEL_BUILD_SCRIPT" 2>/dev/null; then
            pass_test "Correct load address ($EXPECTED_LOAD_ADDR)"
        elif grep -q "make.*uImage" "$KERNEL_BUILD_SCRIPT" 2>/dev/null; then
            pass_test "Load address (using make uImage default for ARM)"
        else
            info_msg "Load address not explicitly specified (using kernel defaults)"
        fi
        
        # Check for correct entry point
        if grep -q "$EXPECTED_ENTRY_POINT" "$KERNEL_BUILD_SCRIPT" 2>/dev/null; then
            pass_test "Correct entry point ($EXPECTED_ENTRY_POINT)"
        else
            info_msg "Entry point not specified (defaults to load address)"
        fi
    else
        fail_test "No uImage generation" "Kernel must be converted to uImage format"
    fi
}

test_kernel_version() {
    echo -e "\n${GREEN}[TEST]${NC} Checking kernel version requirements..."
    
    # Check for 2.6.29 (required for Nook hardware)
    if [[ -f "$KERNEL_SOURCE_DIR/Makefile" ]]; then
        local version=$(grep "^VERSION = " "$KERNEL_SOURCE_DIR/Makefile" 2>/dev/null | cut -d' ' -f3)
        local patchlevel=$(grep "^PATCHLEVEL = " "$KERNEL_SOURCE_DIR/Makefile" 2>/dev/null | cut -d' ' -f3)
        local sublevel=$(grep "^SUBLEVEL = " "$KERNEL_SOURCE_DIR/Makefile" 2>/dev/null | cut -d' ' -f3)
        
        if [[ "$version.$patchlevel.$sublevel" == "2.6.29" ]]; then
            pass_test "Correct kernel version (2.6.29)"
        else
            fail_test "Wrong kernel version" "Found $version.$patchlevel.$sublevel, need 2.6.29"
        fi
    else
        info_msg "Kernel source not downloaded yet"
    fi
}

test_build_dependencies() {
    echo -e "\n${GREEN}[TEST]${NC} Checking build dependencies..."
    
    # Check for required host tools
    local required_tools=("make" "gcc" "bc" "bison" "flex")
    
    for tool in "${required_tools[@]}"; do
        if command -v "$tool" &>/dev/null; then
            pass_test "$tool available"
        else
            # Check if Docker will provide it
            if grep -q "RUN.*install.*$tool" "$PROJECT_ROOT/docker/builder.dockerfile" 2>/dev/null; then
                pass_test "$tool (via Docker)"
            elif grep -q "RUN.*install.*$tool" "$PROJECT_ROOT/build/docker/kernel-xda-proven-optimized.dockerfile" 2>/dev/null; then
                pass_test "$tool (via Docker - legacy path)"
            else
                fail_test "$tool missing" "Required for kernel compilation"
            fi
        fi
    done
}

test_output_paths() {
    echo -e "\n${GREEN}[TEST]${NC} Checking output paths..."
    
    # Check where kernel will be output  
    if grep -q "platform/nook-touch/boot/uImage\|firmware/boot/uImage\|boot/uImage" "$KERNEL_BUILD_SCRIPT" 2>/dev/null; then
        pass_test "Output path configured"
    else
        fail_test "Output path unclear" "Script should copy uImage to platform/nook-touch/boot/"
    fi
    
    # Check if script creates necessary directories
    if grep -q "mkdir -p.*platform/nook-touch/boot\|mkdir -p.*firmware/boot\|mkdir -p.*boot" "$KERNEL_BUILD_SCRIPT" 2>/dev/null; then
        pass_test "Creates output directories"
    else
        fail_test "Missing mkdir for output" "Should create directories before copying"
    fi
}

test_android_patches() {
    echo -e "\n${GREEN}[TEST]${NC} Checking for Android/Nook patches..."
    
    # Check if there are Android-specific patches
    if [[ -d "$PROJECT_ROOT/source/kernel/patches" ]]; then
        local patch_count=$(find "$PROJECT_ROOT/source/kernel/patches" -name "*.patch" 2>/dev/null | wc -l)
        if [[ $patch_count -gt 0 ]]; then
            pass_test "Found $patch_count kernel patches"
        else
            info_msg "No patches in patches directory"
        fi
    else
        info_msg "No patches directory found"
    fi
    
    # Check for Nook-specific modifications in build script
    if grep -q -i "nook\|nst\|bnrv300" "$KERNEL_BUILD_SCRIPT" 2>/dev/null; then
        pass_test "Nook-specific build detected"
    else
        info_msg "No Nook-specific mentions (using generic OMAP)"
    fi
}

test_size_estimation() {
    echo -e "\n${GREEN}[TEST]${NC} Estimating kernel size..."
    
    # If kernel already built, check actual size
    if [[ -f "$PROJECT_ROOT/platform/nook-touch/boot/uImage" ]]; then
        local size=$(stat -c%s "$PROJECT_ROOT/platform/nook-touch/boot/uImage" 2>/dev/null || stat -f%z "$PROJECT_ROOT/platform/nook-touch/boot/uImage" 2>/dev/null || echo 0)
    elif [[ -f "$PROJECT_ROOT/firmware/boot/uImage" ]]; then
        local size=$(stat -c%s "$PROJECT_ROOT/firmware/boot/uImage" 2>/dev/null || stat -f%z "$PROJECT_ROOT/firmware/boot/uImage" 2>/dev/null || echo 0)
        info_msg "Existing uImage size: $((size / 1024))KB"
        
        if [[ $size -lt $KERNEL_MAX_SIZE ]]; then
            pass_test "Kernel size OK ($((size / 1024))KB < 2MB)"
        else
            fail_test "Kernel too large" "$((size / 1024))KB exceeds 2MB limit"
        fi
    else
        info_msg "Kernel not built yet (typical size: 1.8-1.9MB)"
        
        # Check if size optimizations are configured
        if [[ -f "$KERNEL_CONFIG" ]]; then
            if grep -q "CONFIG_CC_OPTIMIZE_FOR_SIZE=y" "$KERNEL_CONFIG" 2>/dev/null; then
                pass_test "Size optimization enabled"
            else
                info_msg "Consider CONFIG_CC_OPTIMIZE_FOR_SIZE=y"
            fi
        fi
    fi
}

test_parallelization() {
    echo -e "\n${GREEN}[TEST]${NC} Checking build parallelization..."
    
    # Check if script uses parallel make
    if grep -q "make -j\|J_CORES\|nproc" "$KERNEL_BUILD_SCRIPT" 2>/dev/null; then
        pass_test "Parallel compilation configured"
    else
        fail_test "No parallelization" "Use make -j\$(nproc) for faster builds"
    fi
    
    # Check if J_CORES environment variable is used
    if grep -q "J_CORES" "$KERNEL_BUILD_SCRIPT" 2>/dev/null; then
        pass_test "J_CORES variable supported"
        info_msg "Use: J_CORES=\$(nproc) make kernel"
    else
        info_msg "No J_CORES support"
    fi
}

# ===================================================================
# Main Test Execution
# ===================================================================

main() {
    echo "================================"
    echo "    JesterOS Kernel Validation"
    echo "================================"
    
    # Run all tests
    test_environment_files
    test_build_script_exists
    test_docker_environment
    test_cross_compilation_toolchain
    test_kernel_configuration
    test_memory_constraints
    test_uboot_compatibility
    test_kernel_version
    test_build_dependencies
    test_output_paths
    test_android_patches
    test_size_estimation
    test_parallelization
    
    # Summary
    echo ""
    echo "================================"
    echo "Test Summary"
    echo "================================"
    echo -e "${GREEN}Passed:${NC} $TESTS_PASSED"
    echo -e "${RED}Failed:${NC} $TESTS_FAILED"
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "\n${GREEN}✓ All kernel validation tests passed!${NC}"
        echo "The kernel build system is ready. Run: make kernel"
        exit 0
    else
        echo -e "\n${RED}✗ Some tests failed${NC}"
        echo "Please fix the issues before building the kernel."
        echo ""
        echo "Common fixes:"
        echo "  - Ensure Docker is running"
        echo "  - Run: git submodule update --init (if kernel source missing)"
        echo "  - Check build/scripts/build_kernel.sh exists"
        exit 1
    fi
}

# Run main function
main "$@"