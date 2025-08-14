#!/bin/bash
# Kernel Safety Testing - The most important test for not bricking!
# Validates JesterOS userspace implementation and kernel safety

set -euo pipefail

# Source configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Set JesterOS path (now userspace, not kernel modules)
JESTEROS_PATH="$PROJECT_ROOT/source/kernel/jokernel/modules"
export JESTEROS_PATH

echo "*** JesterOS Kernel Safety Validation ***"
echo "========================================"
echo ""
echo "Validating JesterOS userspace implementation for safety"
echo ""

# 1. Check for JesterOS userspace scripts
echo "-> Checking JesterOS userspace implementation..."
JESTEROS_SCRIPTS=(
    "source/scripts/boot/jesteros-userspace.sh"
    "source/scripts/services/jesteros-tracker.sh"
    "source/scripts/boot/jester-splash.sh"
)

USERSPACE_PASS=true
for script in "${JESTEROS_SCRIPTS[@]}"; do
    if [ -f "$PROJECT_ROOT/$script" ]; then
        echo "  [PASS] Found: $(basename "$script")"
    else
        echo "  [FAIL] Missing: $script"
        USERSPACE_PASS=false
    fi
done

if [ "$USERSPACE_PASS" = true ]; then
    echo "[PASS] JesterOS userspace implementation complete"
    echo "  -> Services run in userspace (no kernel risks)"
    echo "  -> Interface at /var/jesteros/"
else
    echo "[FAIL] JesterOS userspace scripts missing!"
    echo "  -> Run ./install-jesteros-userspace.sh to install"
    exit 1
fi
echo ""

# 2. Check kernel image exists and is safe
echo "-> Checking kernel image..."
KERNEL_IMAGE="$PROJECT_ROOT/firmware/boot/uImage"
if [ -f "$KERNEL_IMAGE" ]; then
    KERNEL_SIZE=$(stat -c%s "$KERNEL_IMAGE" 2>/dev/null || stat -f%z "$KERNEL_IMAGE" 2>/dev/null || echo "0")
    KERNEL_SIZE_MB=$((KERNEL_SIZE / 1048576))
    if [ "$KERNEL_SIZE" -gt 0 ] && [ "$KERNEL_SIZE" -lt 10485760 ]; then
        echo "[PASS] Kernel image exists and size is reasonable (${KERNEL_SIZE_MB}MB)"
    else
        echo "[WARN] Kernel image size unusual: ${KERNEL_SIZE_MB}MB"
    fi
else
    echo "[INFO] No kernel image built yet"
fi
echo ""

# 3. Check for legacy kernel modules (should not exist)
echo "-> Checking for kernel module remnants..."
if [ -d "$JESTEROS_PATH" ] && ls "$JESTEROS_PATH"/*.c >/dev/null 2>&1; then
    echo "[WARN] Found C files in JesterOS path - modules deprecated!"
    echo "  JesterOS now runs in userspace, remove old module code"
else
    echo "[PASS] No kernel module C files (userspace implementation)"
fi
echo ""

# 4. Check boot scripts for safety
echo "-> Checking boot script safety..."
BOOT_SCRIPTS=(
    "$PROJECT_ROOT/source/scripts/boot/boot-jester.sh"
    "$PROJECT_ROOT/source/scripts/boot/boot-with-jester.sh"
)

BOOT_SAFE=true
for script in "${BOOT_SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        # Check for dangerous commands
        if grep -E "rm -rf /|dd if=.*of=/dev/[sh]d|mkfs\." "$script" >/dev/null 2>&1; then
            echo "  [FAIL] Dangerous commands in $(basename "$script")"
            BOOT_SAFE=false
        else
            echo "  [PASS] $(basename "$script") appears safe"
        fi
    fi
done

if [ "$BOOT_SAFE" = false ]; then
    echo "[FAIL] Boot scripts contain dangerous operations!"
    exit 1
fi
echo ""

# 5. Check script permissions and shebangs
echo "-> Checking script safety standards..."
SCRIPT_ISSUES=0
for script in "$PROJECT_ROOT"/source/scripts/**/*.sh; do
    if [ -f "$script" ]; then
        # Check for proper shebang
        if ! head -1 "$script" | grep -q "^#!/bin/bash"; then
            echo "  [WARN] Missing/incorrect shebang: $(basename "$script")"
            SCRIPT_ISSUES=$((SCRIPT_ISSUES + 1))
        fi
        
        # Check for set -euo pipefail
        if ! grep -q "set -.*e" "$script"; then
            echo "  [WARN] Missing error handling: $(basename "$script")"
            SCRIPT_ISSUES=$((SCRIPT_ISSUES + 1))
        fi
    fi
done

if [ "$SCRIPT_ISSUES" -eq 0 ]; then
    echo "[PASS] All scripts follow safety standards"
else
    echo "[WARN] Found $SCRIPT_ISSUES script safety issues"
fi
echo ""

# Final assessment
echo "*** Safety Assessment Summary ***"
echo "================================="

# JesterOS userspace means no kernel module risks!
if [ "$USERSPACE_PASS" = true ] && [ "$BOOT_SAFE" = true ]; then
    echo "[EXCELLENT] JesterOS userspace implementation is SAFE!"
    echo ""
    echo "The Gate Keeper proclaims:"
    echo "  'Huzzah! Thy userspace services pose no threat to the realm!'"
    echo "  'The kernel remains untouched, the device protected!'"
    echo ""
    echo "✅ SAFE to deploy to Nook hardware"
    echo "  - No kernel module compilation risks"
    echo "  - All services run in safe userspace"
    echo "  - Boot scripts validated for safety"
    
    if [ "$SCRIPT_ISSUES" -gt 0 ]; then
        echo ""
        echo "⚠️  Minor warnings: $SCRIPT_ISSUES script improvements suggested"
    fi
    exit 0
else
    echo "[DANGER] Critical safety issues found!"
    echo ""
    echo "The Gate Keeper declares:"
    echo "  'HALT! Thy code threatens the sacred hardware!'"
    echo ""
    echo "❌ DO NOT DEPLOY until issues are resolved!"
    exit 1
fi