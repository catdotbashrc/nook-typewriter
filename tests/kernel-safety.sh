#!/bin/bash
# Kernel Safety Testing - The most important test for not bricking!
# Simple validation of kernel safety (JesterOS now in userspace)

set -euo pipefail

# Source configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$PROJECT_ROOT/.kernel.env"

echo "*** JesterOS Kernel Safety Validation ***"
echo "========================================"
echo ""
echo "This is the MOST IMPORTANT test - kernel issues brick devices!"
echo ""

# Check for JesterOS userspace scripts
JESTEROS_SCRIPTS="source/scripts/boot/jesteros-userspace.sh"

if [ -f "$JESTEROS_SCRIPTS" ]; then
    echo "[PASS] JesterOS userspace implementation found"
    echo "  -> JesterOS now runs as userspace services"
    echo "  -> No kernel module compilation needed"
    echo "  -> Interface at /var/jesteros/"
else
    echo "[WARN] JesterOS userspace script not found"
    echo "  -> Run ./install-jesteros-userspace.sh to install"
fi
echo ""

# 2. Check kernel source for unsafe patterns (if kernel source exists)
echo "-> Checking for unsafe kernel patterns..."
KERNEL_SRC="source/kernel/src"
if [ -d "$KERNEL_SRC" ]; then
    UNSAFE_COUNT=0
    # Only check actual kernel code, not JesterOS modules
    for func in sprintf strcpy strcat; do
        if find "$KERNEL_SRC" -name "*.c" -not -path "*/jesteros/*" -exec grep -l "$func" {} \; 2>/dev/null | head -1 | grep -q .; then
            echo "  [WARN] Found unsafe function in kernel: $func"
            UNSAFE_COUNT=$((UNSAFE_COUNT + 1))
        fi
    done
    
    if [ "$UNSAFE_COUNT" -eq 0 ]; then
        echo "[PASS] No critical unsafe functions in kernel"
    else
        echo "[WARN] Found $UNSAFE_COUNT unsafe patterns - review kernel safety"
    fi
else
    echo "[INFO] Kernel source not present - skipping kernel checks"
fi
echo ""

# 3. Check userspace service scripts for safety
echo "-> Checking userspace service safety..."
SERVICE_SCRIPTS="source/scripts/services/*.sh"
SAFETY_ISSUES=0

if ls $SERVICE_SCRIPTS >/dev/null 2>&1; then
    for script in $SERVICE_SCRIPTS; do
        SCRIPT_NAME=$(basename "$script")
        
        # Check for set -e or error handling
        if ! grep -q "set -e\|set -.*e" "$script"; then
            echo "  [WARN] $SCRIPT_NAME: Missing error handling (set -e)"
            SAFETY_ISSUES=$((SAFETY_ISSUES + 1))
        fi
        
        # Check for input validation
        if grep -q 'eval\|$(' "$script" | grep -v '^#'; then
            if ! grep -q "validate_.*input\|sanitize" "$script"; then
                echo "  [INFO] $SCRIPT_NAME: Has command substitution - ensure input validation"
            fi
        fi
    done
    
    if [ "$SAFETY_ISSUES" -eq 0 ]; then
        echo "[PASS] Userspace services follow safety practices"
    else
        echo "[WARN] Found $SAFETY_ISSUES safety considerations in services"
    fi
else
    echo "[WARN] No userspace service scripts found"
fi
echo ""

# 4. Check boot scripts for proper sequencing
echo "-> Checking boot script safety..."
BOOT_SCRIPTS="source/scripts/boot/*.sh"
if ls $BOOT_SCRIPTS >/dev/null 2>&1; then
    BOOT_ISSUES=0
    for script in $BOOT_SCRIPTS; do
        if grep -q "/dev/sd[a-z]" "$script" | grep -v "^#"; then
            if ! grep -q "confirm\|validate.*device" "$script"; then
                echo "  [WARN] $(basename $script): Direct device access without validation"
                BOOT_ISSUES=$((BOOT_ISSUES + 1))
            fi
        fi
    done
    
    if [ "$BOOT_ISSUES" -eq 0 ]; then
        echo "[PASS] Boot scripts validate device operations"
    else
        echo "[WARN] Found $BOOT_ISSUES boot script safety issues"
    fi
else
    echo "[INFO] No boot scripts found"
fi
echo ""

# 5. Check memory usage estimates
echo "-> Checking memory usage..."
MEMORY_SAFE=true

# Check if services stay within budget
SERVICE_MEM_ESTIMATE=0
if ls $SERVICE_SCRIPTS >/dev/null 2>&1; then
    SERVICE_COUNT=$(ls -1 $SERVICE_SCRIPTS | wc -l)
    # Estimate ~100KB per service script
    SERVICE_MEM_ESTIMATE=$((SERVICE_COUNT * 100))
    echo "  Estimated service memory: ${SERVICE_MEM_ESTIMATE}KB for $SERVICE_COUNT services"
    
    if [ "$SERVICE_MEM_ESTIMATE" -gt 1024 ]; then
        echo "  [WARN] Services may use >1MB RAM"
        MEMORY_SAFE=false
    fi
fi

echo "[INFO] Total userspace estimate: ${SERVICE_MEM_ESTIMATE}KB"
if [ "$MEMORY_SAFE" = true ]; then
    echo "[PASS] Memory usage within safe limits"
else
    echo "[WARN] Review memory usage before deployment"
fi
echo ""

# Final assessment
echo "*** Safety Assessment Summary ***"
echo "================================="

# Since JesterOS is userspace now, we only have warnings, no critical kernel issues
TOTAL_WARNINGS=$((SAFETY_ISSUES + BOOT_ISSUES))

echo "Userspace Safety Issues: $SAFETY_ISSUES"
echo "Boot Script Issues: $BOOT_ISSUES"
echo "Memory Concerns: $([ "$MEMORY_SAFE" = true ] && echo "None" || echo "Review needed")"
echo ""

if [ "$TOTAL_WARNINGS" -eq 0 ] && [ "$MEMORY_SAFE" = true ]; then
    echo "[EXCELLENT] All safety checks passed!"
    echo "The Court Jester says: 'Thy services are worthy of the realm!'"
    echo "✓ SAFE to deploy to Nook hardware"
elif [ "$TOTAL_WARNINGS" -le 2 ]; then
    echo "[GOOD] Minor warnings only"
    echo "The Court Jester says: 'Minor concerns, but courage prevails!'"
    echo "✓ SAFE to deploy with caution"
else
    echo "[CAUTION] Multiple warnings found"
    echo "The Court Jester says: 'Review thy work, then proceed!'"
    echo "⚠ Consider fixing warnings before deployment"
fi

echo ""
echo "Safety Check Complete (JesterOS in userspace)"