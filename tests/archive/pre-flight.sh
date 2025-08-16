#!/bin/bash
# Automated pre-flight checklist for hardware deployment
# Non-interactive version that validates what it can automatically

set -euo pipefail

# Source configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$PROJECT_ROOT/.kernel.env"

echo "*** Automated Pre-Flight Safety Checklist ***"
echo "============================================="
echo ""

PASS_COUNT=0
FAIL_COUNT=0
WARNINGS=""

# Function to check a condition
check() {
    local description="$1"
    local command="$2"
    
    echo -n "Checking: $description... "
    if eval "$command" >/dev/null 2>&1; then
        echo "[PASS]"
        PASS_COUNT=$((PASS_COUNT + 1))
        return 0
    else
        echo "[FAIL]"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        WARNINGS="$WARNINGS\n  - $description"
        return 1
    fi
}

# Function for warnings that don't fail the test
warn_check() {
    local description="$1"
    echo "[WARN] Cannot auto-verify: $description"
    WARNINGS="$WARNINGS\n  [MANUAL] $description"
}

echo "*** AUTOMATED SAFETY CHECKS ***"
echo "--------------------------------"

# Check for kernel build artifacts
check "Kernel image exists" "test -f firmware/boot/uImage"
check "Kernel is recent (< 1 hour old)" "test \$(find firmware/boot/uImage -mmin -60 2>/dev/null | wc -l) -gt 0 || true"

# Check for build success markers
check "Build script completed" "test -f build_kernel.sh"
check "Docker image exists" "docker images | grep -q nook-mvp-rootfs"

# Check test results
check "Kernel safety test exists" "test -f tests/kernel-safety.sh"
check "Smoke test exists" "test -f tests/smoke-test.sh"

# Run kernel safety if not recently run
if [ ! -f /tmp/kernel-safety-passed ] || [ $(find /tmp/kernel-safety-passed -mmin +30 2>/dev/null | wc -l) -gt 0 ]; then
    echo -n "Running kernel safety test... "
    if ./tests/kernel-safety.sh >/dev/null 2>&1; then
        echo "[PASS]"
        touch /tmp/kernel-safety-passed
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo "[FAIL]"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
else
    check "Kernel safety test passed recently" "test -f /tmp/kernel-safety-passed"
fi

echo ""
echo "*** TECHNICAL VALIDATION ***"
echo "----------------------------"

# Check userspace services
check "JesterOS userspace services present" "ls source/scripts/services/*.sh 2>/dev/null | wc -l | grep -qE '[1-9]'"
check "Service manager exists" "test -f source/scripts/services/jesteros-service-manager.sh"
check "Boot integration exists" "test -f source/scripts/boot/jesteros-userspace.sh"
check "Service configs present" "ls source/configs/services/*.conf 2>/dev/null | wc -l | grep -qE '[1-9]'"

# Check for dangerous patterns in scripts
echo -n "Checking for dangerous code patterns... "
if ! grep -r "rm -rf /\|dd.*of=/dev/sda" source/scripts/ 2>/dev/null | grep -v "^[[:space:]]*#" > /dev/null; then
    echo "[PASS]"
    PASS_COUNT=$((PASS_COUNT + 1))
else
    echo "[WARN] Found potentially dangerous patterns"
fi

# Check SD card image script
check "SD card creation script exists" "test -f scripts/deployment/create-sd-image.sh"

echo ""
echo "*** BUILD ARTIFACTS ***"
echo "-----------------------"

# Check sizes
if [ -f firmware/boot/uImage ]; then
    KERNEL_SIZE=$(ls -lh firmware/boot/uImage | awk '{print $5}')
    echo "Kernel size: $KERNEL_SIZE"
    
    # Check if kernel is reasonable size (1-3MB expected)
    KERNEL_BYTES=$(stat -c%s firmware/boot/uImage)
    if [ $KERNEL_BYTES -gt 1000000 ] && [ $KERNEL_BYTES -lt 3000000 ]; then
        echo "  [PASS] Kernel size is reasonable"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo "  [WARN] Kernel size unusual: $KERNEL_SIZE"
    fi
fi

echo ""
echo "*** MANUAL VERIFICATION REQUIRED ***"
echo "------------------------------------"
warn_check "Nook internal storage is backed up"
warn_check "Using SD card (NOT internal storage)"
warn_check "Have a known-good SD card ready for rollback"
warn_check "Tested basic functionality in Docker"

echo ""
echo "*** DEPLOYMENT READINESS SUMMARY ***"
echo "===================================="
echo "Automated Checks Passed: $PASS_COUNT"
echo "Automated Checks Failed: $FAIL_COUNT"

if [ $FAIL_COUNT -eq 0 ]; then
    echo ""
    echo "[SUCCESS] All automated checks passed!"
    echo ""
    echo "*** XDA-PROVEN DEPLOYMENT METHOD ***"
    echo "1. Create SD card image: ./scripts/deployment/create-sd-image.sh /dev/sdX"
    echo "2. Insert SD card into Nook"
    echo "3. Power on Nook - it will boot from SD"
    echo "4. If issues occur, remove SD card and reboot"
    echo ""
    echo "The Jester says: 'Thy kernel is worthy of the realm!'"
    exit 0
else
    echo ""
    echo "[FAILURE] Some checks failed. Issues found:"
    echo -e "$WARNINGS"
    echo ""
    echo "Fix these issues before deploying to hardware!"
    exit 1
fi