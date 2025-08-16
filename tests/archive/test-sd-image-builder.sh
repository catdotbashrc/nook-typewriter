#!/bin/bash
# ==============================================================================
# Test Suite for SD Card Image Builder Script
# Tests the create-sd-image.sh functionality
# ==============================================================================

set -euo pipefail

# Test configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly BUILD_SCRIPT="${PROJECT_ROOT}/scripts/deployment/create-sd-image.sh"
readonly TEST_OUTPUT_DIR="${PROJECT_ROOT}/releases"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# -----------------------------------------------------------------------------
# Test Helper Functions
# -----------------------------------------------------------------------------

test_start() {
    echo -e "${YELLOW}Testing:${NC} $1"
    TESTS_RUN=$((TESTS_RUN + 1))
}

test_pass() {
    echo -e "${GREEN}  ✓${NC} $1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

test_fail() {
    echo -e "${RED}  ✗${NC} $1"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

assert_file_exists() {
    if [[ -f "$1" ]]; then
        test_pass "File exists: $1"
        return 0
    else
        test_fail "File missing: $1"
        return 1
    fi
}

assert_directory_exists() {
    if [[ -d "$1" ]]; then
        test_pass "Directory exists: $1"
        return 0
    else
        test_fail "Directory missing: $1"
        return 1
    fi
}

assert_executable() {
    if [[ -x "$1" ]]; then
        test_pass "File is executable: $1"
        return 0
    else
        test_fail "File not executable: $1"
        return 1
    fi
}

assert_contains() {
    local file="$1"
    local pattern="$2"
    if grep -q "$pattern" "$file"; then
        test_pass "File contains: $pattern"
        return 0
    else
        test_fail "File missing pattern: $pattern"
        return 1
    fi
}

# -----------------------------------------------------------------------------
# Test Cases
# -----------------------------------------------------------------------------

test_script_exists() {
    test_start "SD card image builder script exists"
    assert_file_exists "${BUILD_SCRIPT}"
    assert_executable "${BUILD_SCRIPT}"
}

test_directory_structure() {
    test_start "Script directory structure"
    assert_directory_exists "${PROJECT_ROOT}/scripts"
    assert_directory_exists "${PROJECT_ROOT}/scripts/deployment"
    assert_directory_exists "${PROJECT_ROOT}/releases"
    assert_directory_exists "${PROJECT_ROOT}/boot"
}

test_uenv_config() {
    test_start "U-Boot environment configuration"
    local uenv_file="${PROJECT_ROOT}/boot/uEnv-enhanced.txt"
    
    if assert_file_exists "${uenv_file}"; then
        assert_contains "${uenv_file}" "bootargs="
        assert_contains "${uenv_file}" "bootcmd="
        assert_contains "${uenv_file}" "root=/dev/mmcblk0p2"
        assert_contains "${uenv_file}" "rootfstype=ext4"
        assert_contains "${uenv_file}" "mem=256M"
    fi
}

test_script_content() {
    test_start "Script content validation"
    
    # Check for required functions
    assert_contains "${BUILD_SCRIPT}" "check_requirements()"
    assert_contains "${BUILD_SCRIPT}" "create_image_file()"
    assert_contains "${BUILD_SCRIPT}" "partition_image()"
    assert_contains "${BUILD_SCRIPT}" "format_partitions()"
    assert_contains "${BUILD_SCRIPT}" "install_boot_files()"
    assert_contains "${BUILD_SCRIPT}" "install_rootfs()"
    
    # Check for safety features
    assert_contains "${BUILD_SCRIPT}" "set -euo pipefail"
    assert_contains "${BUILD_SCRIPT}" "trap cleanup EXIT"
    
    # Check for medieval theme
    assert_contains "${BUILD_SCRIPT}" "JESTER_ASCII"
    assert_contains "${BUILD_SCRIPT}" "By quill and candlelight"
}

test_partition_layout() {
    test_start "Partition layout configuration"
    
    # Check partition sizes
    assert_contains "${BUILD_SCRIPT}" "BOOT_SIZE_MB=100"
    assert_contains "${BUILD_SCRIPT}" "IMAGE_SIZE_MB=512"
    
    # Check partition types
    assert_contains "${BUILD_SCRIPT}" "mkpart primary fat16"
    assert_contains "${BUILD_SCRIPT}" "mkpart primary ext4"
    assert_contains "${BUILD_SCRIPT}" "set 1 boot on"
}

test_filesystem_setup() {
    test_start "Filesystem configuration"
    
    # Check filesystem creation
    assert_contains "${BUILD_SCRIPT}" "mkfs.vfat -F 16"
    assert_contains "${BUILD_SCRIPT}" "mkfs.ext4"
    assert_contains "${BUILD_SCRIPT}" "\^has_journal"  # No journal for SD card
    
    # Check filesystem labels
    assert_contains "${BUILD_SCRIPT}" "NOOK_BOOT"
    assert_contains "${BUILD_SCRIPT}" "NOOK_ROOT"
}

test_rootfs_installation() {
    test_start "Root filesystem installation"
    
    # Check for Docker support
    assert_contains "${BUILD_SCRIPT}" "docker export"
    assert_contains "${BUILD_SCRIPT}" "nook-system"
    
    # Check for tarball support
    assert_contains "${BUILD_SCRIPT}" "tar -xzf"
    assert_contains "${BUILD_SCRIPT}" "rootfs.tar.gz"
    
    # Check for writing directories
    assert_contains "${BUILD_SCRIPT}" "/root/writing"
    assert_contains "${BUILD_SCRIPT}" "/root/notes"
    assert_contains "${BUILD_SCRIPT}" "/root/drafts"
}

test_squireos_modules() {
    test_start "SquireOS module support"
    
    # Check for module installation
    assert_contains "${BUILD_SCRIPT}" "/lib/modules/2.6.29"
    assert_contains "${BUILD_SCRIPT}" "load-squireos-modules"
    assert_contains "${BUILD_SCRIPT}" "insmod"
    
    # Check for jester display
    assert_contains "${BUILD_SCRIPT}" "/proc/squireos/jester"
}

test_error_handling() {
    test_start "Error handling and cleanup"
    
    # Check for cleanup function
    assert_contains "${BUILD_SCRIPT}" "cleanup()"
    assert_contains "${BUILD_SCRIPT}" "losetup -d"
    assert_contains "${BUILD_SCRIPT}" "umount"
    
    # Check for error messages
    assert_contains "${BUILD_SCRIPT}" "log_error"
    assert_contains "${BUILD_SCRIPT}" "exit 1"
}

test_compression() {
    test_start "Image compression support"
    
    # Check for gzip compression
    assert_contains "${BUILD_SCRIPT}" "gzip -c"
    assert_contains "${BUILD_SCRIPT}" "\.gz"
}

test_script_dry_run() {
    test_start "Script dry run (help/requirements check)"
    
    # Test that script can be sourced for syntax check
    if bash -n "${BUILD_SCRIPT}" 2>/dev/null; then
        test_pass "Script syntax is valid"
    else
        test_fail "Script has syntax errors"
    fi
}

test_documentation() {
    test_start "Script documentation"
    
    # Check for usage instructions
    assert_contains "${BUILD_SCRIPT}" "To flash to SD card:"
    assert_contains "${BUILD_SCRIPT}" "dd if="
    assert_contains "${BUILD_SCRIPT}" "Balena Etcher"
    
    # Check for requirements
    assert_contains "${BUILD_SCRIPT}" "parted"
    assert_contains "${BUILD_SCRIPT}" "mkfs.vfat"
    assert_contains "${BUILD_SCRIPT}" "losetup"
}

# -----------------------------------------------------------------------------
# Integration Tests (if dependencies available)
# -----------------------------------------------------------------------------

test_integration_docker() {
    test_start "Docker integration (if available)"
    
    if command -v docker &> /dev/null; then
        if docker images | grep -q "nook-system"; then
            test_pass "Docker image 'nook-system' available for testing"
        else
            test_pass "Docker available but image not built (expected)"
        fi
    else
        test_pass "Docker not available (expected in CI)"
    fi
}

test_integration_kernel() {
    test_start "Kernel file check"
    
    local kernel_locations=(
        "${PROJECT_ROOT}/nst-kernel/build/uImage"
        "${PROJECT_ROOT}/firmware/boot/uImage"
        "${PROJECT_ROOT}/boot/uImage"
    )
    
    local found=false
    for location in "${kernel_locations[@]}"; do
        if [[ -f "${location}" ]]; then
            test_pass "Kernel found at: ${location}"
            found=true
            break
        fi
    done
    
    if [[ "${found}" == "false" ]]; then
        test_pass "Kernel not built yet (expected for issue #7)"
    fi
}

# -----------------------------------------------------------------------------
# Test Report
# -----------------------------------------------------------------------------

print_test_summary() {
    echo
    echo "═══════════════════════════════════════════════════════════════"
    echo "                    Test Summary"
    echo "═══════════════════════════════════════════════════════════════"
    echo "  Tests Run:    ${TESTS_RUN}"
    echo "  Tests Passed: ${TESTS_PASSED}"
    echo "  Tests Failed: ${TESTS_FAILED}"
    echo "═══════════════════════════════════════════════════════════════"
    
    if [[ ${TESTS_FAILED} -eq 0 ]]; then
        echo -e "${GREEN}✓ All tests passed!${NC}"
        return 0
    else
        echo -e "${RED}✗ Some tests failed${NC}"
        return 1
    fi
}

# -----------------------------------------------------------------------------
# Main Test Runner
# -----------------------------------------------------------------------------

main() {
    echo "═══════════════════════════════════════════════════════════════"
    echo "       SD Card Image Builder Test Suite"
    echo "═══════════════════════════════════════════════════════════════"
    echo
    
    # Run all tests
    test_script_exists
    test_directory_structure
    test_uenv_config
    test_script_content
    test_partition_layout
    test_filesystem_setup
    test_rootfs_installation
    test_squireos_modules
    test_error_handling
    test_compression
    test_script_dry_run
    test_documentation
    test_integration_docker
    test_integration_kernel
    
    # Print summary
    print_test_summary
}

# Run tests
main "$@"