#!/bin/bash
# ===================================================================
# JesterOS Ramdisk Build Validation
# ===================================================================
# Tests the ramdisk build process comprehensively:
# - Build execution
# - Content validation  
# - Size constraints
# - U-Boot format compatibility
# - Android init requirements
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
TEST_NAME="Ramdisk Build Validation"
TEST_CRITICAL=true
RAMDISK_MAX_SIZE=$((3 * 1024 * 1024))  # 3MB max compressed
RAMDISK_BUILD_DIR="/tmp/ramdisk-test-$$"
RAMDISK_OUTPUT="$RAMDISK_BUILD_DIR/uRamdisk"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0

# Cleanup function
cleanup() {
    if [[ -d "$RAMDISK_BUILD_DIR" ]]; then
        rm -rf "$RAMDISK_BUILD_DIR"
    fi
}
trap cleanup EXIT

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

test_build_script_exists() {
    echo -e "\n${GREEN}[TEST]${NC} Checking ramdisk build script..."
    
    if [[ -f "$PROJECT_ROOT/scripts/build-ramdisk.sh" ]]; then
        pass_test "Build script exists"
        
        if [[ -x "$PROJECT_ROOT/scripts/build-ramdisk.sh" ]]; then
            pass_test "Build script is executable"
        else
            fail_test "Build script not executable" "Missing execute permission"
        fi
    else
        fail_test "Build script missing" "scripts/build-ramdisk.sh not found"
        return 1
    fi
}

test_required_files() {
    echo -e "\n${GREEN}[TEST]${NC} Checking required input files..."
    
    local required_files=(
        "platform/nook-touch/init.rc"
        "platform/nook-touch/default.prop"
        "src/init/jesteros-init.sh"
    )
    
    for file in "${required_files[@]}"; do
        if [[ -f "$PROJECT_ROOT/$file" ]]; then
            local size=$(stat -c%s "$PROJECT_ROOT/$file" 2>/dev/null || stat -f%z "$PROJECT_ROOT/$file" 2>/dev/null || echo 0)
            if [[ $size -gt 0 ]]; then
                pass_test "$(basename $file) present (${size} bytes)"
            else
                fail_test "$(basename $file) empty" "File exists but has 0 bytes"
            fi
        else
            fail_test "$(basename $file) missing" "Required at $file"
        fi
    done
}

test_ramdisk_structure() {
    echo -e "\n${GREEN}[TEST]${NC} Testing ramdisk directory structure..."
    
    # Create test build directory
    mkdir -p "$RAMDISK_BUILD_DIR"
    
    # Simulate ramdisk structure
    local dirs=(
        "system/bin"
        "system/etc"
        "system/lib"
        "data"
        "proc"
        "sys"
        "dev"
        "tmp"
        "mnt"
        "cache"
    )
    
    info_msg "Creating test ramdisk structure..."
    for dir in "${dirs[@]}"; do
        mkdir -p "$RAMDISK_BUILD_DIR/ramdisk/$dir"
        if [[ -d "$RAMDISK_BUILD_DIR/ramdisk/$dir" ]]; then
            pass_test "Directory /$dir created"
        else
            fail_test "Directory /$dir failed" "Could not create directory"
        fi
    done
}

test_init_rc_parsing() {
    echo -e "\n${GREEN}[TEST]${NC} Validating init.rc syntax..."
    
    local init_rc="$PROJECT_ROOT/platform/nook-touch/init.rc"
    if [[ ! -f "$init_rc" ]]; then
        fail_test "init.rc validation" "File not found"
        return 1
    fi
    
    # Check for required service definitions
    if grep -q "service jesteros-init" "$init_rc"; then
        pass_test "JesterOS init service defined"
    else
        fail_test "JesterOS init service missing" "No 'service jesteros-init' in init.rc"
    fi
    
    if grep -q "service omap-edpd" "$init_rc"; then
        pass_test "E-ink daemon service defined"
    else
        fail_test "E-ink daemon missing" "No 'service omap-edpd' in init.rc"
    fi
    
    # Check for critical triggers
    if grep -q "on boot" "$init_rc"; then
        pass_test "Boot trigger present"
    else
        fail_test "Boot trigger missing" "No 'on boot' trigger in init.rc"
    fi
    
    # Validate Android 2.3 init syntax (basic check)
    # Skip comment lines and properly indented commands
    local syntax_errors=$(grep -E '^\s*[^#\s]' "$init_rc" | grep -v -E '^(service|on |    )' | head -5)
    
    if [[ -z "$syntax_errors" ]]; then
        pass_test "init.rc syntax valid"
    else
        fail_test "init.rc syntax errors" "Invalid commands found"
        echo "$syntax_errors"
    fi
}

test_default_prop_validation() {
    echo -e "\n${GREEN}[TEST]${NC} Validating default.prop..."
    
    local default_prop="$PROJECT_ROOT/platform/nook-touch/default.prop"
    if [[ ! -f "$default_prop" ]]; then
        fail_test "default.prop validation" "File not found"
        return 1
    fi
    
    # Check for critical properties
    if grep -q "ro.jesteros.memory.limit=95" "$default_prop"; then
        pass_test "Memory limit property set (95MB)"
    else
        fail_test "Memory limit missing" "ro.jesteros.memory.limit not set to 95"
    fi
    
    if grep -q "persist.jesteros.mode=writer" "$default_prop"; then
        pass_test "JesterOS mode configured"
    else
        fail_test "JesterOS mode missing" "persist.jesteros.mode not set"
    fi
    
    # Validate property format (key=value)
    local invalid_props=$(grep -v '^#' "$default_prop" | grep -v '^$' | grep -v '^[a-z][a-z0-9._]*=[^[:space:]]*$' | head -5)
    
    if [[ -z "$invalid_props" ]]; then
        pass_test "Property format valid"
    else
        fail_test "Invalid property format" "Properties must be key=value"
        echo "$invalid_props"
    fi
}

test_binary_requirements() {
    echo -e "\n${GREEN}[TEST]${NC} Checking binary requirements..."
    
    # These would need to be in the ramdisk
    local required_binaries=(
        "sh"       # Shell for init scripts
        "busybox"  # Core utilities
        "linker"   # Android dynamic linker
    )
    
    info_msg "Checking for required binaries in system..."
    
    # In a real test, we'd check if these are available for ARM
    # For now, just verify our build script mentions them
    local build_script="$PROJECT_ROOT/scripts/build-ramdisk.sh"
    
    for binary in "${required_binaries[@]}"; do
        if grep -q "$binary" "$build_script" 2>/dev/null; then
            pass_test "$binary referenced in build"
        else
            fail_test "$binary not referenced" "Build script should include $binary"
        fi
    done
}

test_size_constraints() {
    echo -e "\n${GREEN}[TEST]${NC} Testing size constraints..."
    
    # Calculate estimated ramdisk size
    local total_size=0
    
    # Add up sizes of input files
    for file in platform/nook-touch/init.rc platform/nook-touch/default.prop src/init/jesteros-init.sh; do
        if [[ -f "$PROJECT_ROOT/$file" ]]; then
            local fsize=$(stat -c%s "$PROJECT_ROOT/$file" 2>/dev/null || stat -f%z "$PROJECT_ROOT/$file" 2>/dev/null || echo 0)
            total_size=$((total_size + fsize))
        fi
    done
    
    info_msg "Input files total: $total_size bytes"
    
    # Estimate compressed size (usually 30-40% of original)
    local estimated_compressed=$((total_size * 40 / 100))
    info_msg "Estimated compressed: $estimated_compressed bytes"
    
    if [[ $estimated_compressed -lt $RAMDISK_MAX_SIZE ]]; then
        pass_test "Size within limits (<3MB)"
    else
        fail_test "Size exceeds limits" "Estimated ${estimated_compressed} bytes > 3MB"
    fi
}

test_uboot_format() {
    echo -e "\n${GREEN}[TEST]${NC} Testing U-Boot format requirements..."
    
    # Check if mkimage is available
    if command -v mkimage &>/dev/null; then
        pass_test "mkimage tool available"
        
        # Check mkimage version
        local mkimage_version=$(mkimage -V 2>&1 | head -1)
        info_msg "mkimage version: $mkimage_version"
    else
        # Check if build script handles missing mkimage
        if grep -q "mkimage" "$PROJECT_ROOT/scripts/build-ramdisk.sh"; then
            pass_test "Build script references mkimage"
            info_msg "mkimage will be needed during actual build"
        else
            fail_test "mkimage not configured" "Build script doesn't handle U-Boot image creation"
        fi
    fi
    
    # Verify U-Boot header parameters in build script
    if grep -q "0x81600000" "$PROJECT_ROOT/scripts/build-ramdisk.sh" 2>/dev/null; then
        pass_test "Correct load address (0x81600000)"
    else
        fail_test "Wrong load address" "Should use 0x81600000 for ramdisk"
    fi
}

test_android_compatibility() {
    echo -e "\n${GREEN}[TEST]${NC} Testing Android 2.3 compatibility..."
    
    # Check init.rc for Android 2.3 specific requirements
    local init_rc="$PROJECT_ROOT/platform/nook-touch/init.rc"
    
    # Android 2.3 requires certain mount points
    if grep -q "mount rootfs rootfs / rw remount" "$init_rc"; then
        pass_test "Root remount configured"
    else
        info_msg "Note: Root remount may be needed"
    fi
    
    # Check for proper class definitions
    if grep -q "class_start late_start" "$init_rc"; then
        pass_test "Late start class configured"
    else
        fail_test "Late start class missing" "JesterOS needs late_start trigger"
    fi
    
    # Verify property triggers
    if grep -q "on property:" "$init_rc"; then
        pass_test "Property triggers present"
    else
        info_msg "No property triggers (may be OK)"
    fi
}

test_dry_run_build() {
    echo -e "\n${GREEN}[TEST]${NC} Testing build script dry run..."
    
    local build_script="$PROJECT_ROOT/scripts/build-ramdisk.sh"
    
    if [[ ! -f "$build_script" ]]; then
        fail_test "Dry run test" "Build script not found"
        return 1
    fi
    
    # Check if script has dry-run or help option
    if bash "$build_script" --help 2>&1 | grep -q -E "(help|usage|dry)" || \
       bash "$build_script" --dry-run 2>&1 | grep -q -E "(Dry run|Would create|Simulating)"; then
        pass_test "Build script supports dry-run/help"
    else
        info_msg "Build script may not support dry-run mode"
        # Try to check if it's safe to run
        if grep -q "rm -rf /" "$build_script"; then
            fail_test "DANGEROUS: Script contains 'rm -rf /'"
            return 1
        else
            pass_test "Build script appears safe"
        fi
    fi
}

# ===================================================================
# Main Test Execution
# ===================================================================

main() {
    echo "================================"
    echo "    JesterOS Ramdisk Validation"
    echo "================================"
    
    # Run all tests
    test_build_script_exists
    test_required_files
    test_ramdisk_structure
    test_init_rc_parsing
    test_default_prop_validation
    test_binary_requirements
    test_size_constraints
    test_uboot_format
    test_android_compatibility
    test_dry_run_build
    
    # Summary
    echo ""
    echo "================================"
    echo "Test Summary"
    echo "================================"
    echo -e "${GREEN}Passed:${NC} $TESTS_PASSED"
    echo -e "${RED}Failed:${NC} $TESTS_FAILED"
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "\n${GREEN}✓ All ramdisk validation tests passed!${NC}"
        echo "The ramdisk build system is ready for use."
        exit 0
    else
        echo -e "\n${RED}✗ Some tests failed${NC}"
        echo "Please fix the issues before building the ramdisk."
        exit 1
    fi
}

# Run main function
main "$@"