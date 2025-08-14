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

# 2. Check for unsafe string functions (buffer overflows)
echo "-> Checking for unsafe string functions..."
UNSAFE_COUNT=0
for func in sprintf strcpy strcat; do
    if grep -q "$func" $JESTEROS_PATH/*.c; then
        echo "  [DANGER] Found unsafe function: $func"
        grep -n "$func" $JESTEROS_PATH/*.c | head -3
        UNSAFE_COUNT=$((UNSAFE_COUNT + 1))
    fi
done

if [ "$UNSAFE_COUNT" -eq 0 ]; then
    echo "[PASS] No unsafe string functions found"
else
    echo "[FAIL] Found $UNSAFE_COUNT unsafe string functions - WILL cause buffer overflows!"
    exit 1
fi
echo ""

# 3. Check for hardware register access (bricking risk)
echo "-> Checking for dangerous hardware access..."
HARDWARE_FUNCS="ioremap __raw_write outb inb writeb readb"
HARDWARE_COUNT=0
for func in $HARDWARE_FUNCS; do
    if grep -q "$func" $JESTEROS_PATH/*.c; then
        echo "  [DANGER] Found hardware access: $func"
        HARDWARE_COUNT=$((HARDWARE_COUNT + 1))
    fi
done

if [ "$HARDWARE_COUNT" -eq 0 ]; then
    echo "[PASS] No direct hardware access found"
else
    echo "[FAIL] Found hardware register access - WILL brick device!"
    exit 1
fi
echo ""

# 4. Check for division by zero (kernel panic)
echo "-> Checking for division by zero risks..."
# Look for modulo with variables (not constants), excluding known safe cases
if grep -n " % [a-zA-Z]" $JESTEROS_PATH/*.c | grep -v "wisdom_count\|% 60\|% 100" | grep -q .; then
    echo "[FAIL] Found modulo operations with variables without zero checks!"
    grep -n " % [a-zA-Z]" $JESTEROS_PATH/*.c | grep -v "wisdom_count\|% 60\|% 100"
    echo "STOP: Division by zero causes immediate kernel panic!"
    exit 1
else
    echo "[PASS] No division by zero risks found"
fi
echo ""

# 5. Check for proper module structure
echo "-> Checking module structure..."
STRUCTURE_ERRORS=0

# Check each module has required functions
for module in $JESTEROS_PATH/*.c; do
    MODULE_NAME=$(basename "$module" .c)
    echo "  Checking $MODULE_NAME..."
    
    # Check for MODULE_LICENSE
    if ! grep -q "MODULE_LICENSE" "$module"; then
        echo "    [WARN] Missing MODULE_LICENSE"
        STRUCTURE_ERRORS=$((STRUCTURE_ERRORS + 1))
    fi
    
    # Check for init function
    if ! grep -q "_init\|module_init" "$module"; then
        echo "    [WARN] Missing init function"
        STRUCTURE_ERRORS=$((STRUCTURE_ERRORS + 1))
    fi
    
    # Check for exit function  
    if ! grep -q "_exit\|module_exit" "$module"; then
        echo "    [WARN] Missing exit function"
        STRUCTURE_ERRORS=$((STRUCTURE_ERRORS + 1))
    fi
done

if [ "$STRUCTURE_ERRORS" -eq 0 ]; then
    echo "[PASS] All modules have proper structure"
else
    echo "[WARN] Found $STRUCTURE_ERRORS structure issues"
fi
echo ""

# 6. Check for memory leaks
echo "-> Checking for potential memory leaks..."
LEAK_WARNINGS=0

# Check malloc/free balance in our modules
MALLOC_COUNT=$(cat $JESTEROS_PATH/*.c | grep -c "kmalloc\|kzalloc" 2>/dev/null || echo "0")
FREE_COUNT=$(cat $JESTEROS_PATH/*.c | grep -c "kfree" 2>/dev/null || echo "0")

if [ "$MALLOC_COUNT" -gt 0 ] && [ "$FREE_COUNT" -eq 0 ]; then
    echo "[WARN] Found memory allocations but no kfree calls"
    LEAK_WARNINGS=$((LEAK_WARNINGS + 1))
fi

# Check proc entry cleanup
PROC_CREATE_COUNT=$(cat $JESTEROS_PATH/*.c 2>/dev/null | grep -c "proc_create\|create_proc" || echo "0")
PROC_REMOVE_COUNT=$(cat $JESTEROS_PATH/*.c 2>/dev/null | grep -c "remove_proc_entry" || echo "0")

if [ "$PROC_CREATE_COUNT" -gt 0 ] && [ "$PROC_REMOVE_COUNT" -eq 0 ]; then
    echo "[WARN] Creating proc entries but no cleanup found"
    LEAK_WARNINGS=$((LEAK_WARNINGS + 1))
fi

if [ "$LEAK_WARNINGS" -eq 0 ]; then
    echo "[PASS] No obvious memory leak patterns"
else
    echo "[WARN] Found $LEAK_WARNINGS potential leak patterns"
fi
echo ""

# 7. Check file sizes (memory usage)
echo "-> Checking module sizes..."
LARGE_MODULES=0
for module in $JESTEROS_PATH/*.c; do
    SIZE=$(wc -c < "$module")
    SIZE_KB=$((SIZE / 1024))
    MODULE_NAME=$(basename "$module")
    
    if [ "$SIZE_KB" -gt 10 ]; then  # >10KB is large for embedded
        echo "  [WARN] Large module: $MODULE_NAME (${SIZE_KB}KB)"
        LARGE_MODULES=$((LARGE_MODULES + 1))
    else
        echo "  [GOOD] $MODULE_NAME (${SIZE_KB}KB)"
    fi
done

if [ "$LARGE_MODULES" -eq 0 ]; then
    echo "[PASS] All modules are reasonably sized"
else
    echo "[WARN] Found $LARGE_MODULES large modules"
fi
echo ""

# Final assessment
echo "*** Safety Assessment Summary ***"
echo "================================="

CRITICAL_ISSUES=$((UNSAFE_COUNT + HARDWARE_COUNT))
TOTAL_WARNINGS=$((STRUCTURE_ERRORS + LEAK_WARNINGS + LARGE_MODULES))

echo "Critical Issues: $CRITICAL_ISSUES"
echo "Warnings: $TOTAL_WARNINGS"
echo ""

if [ "$CRITICAL_ISSUES" -eq 0 ]; then
    if [ "$TOTAL_WARNINGS" -eq 0 ]; then
        echo "[EXCELLENT] All kernel safety checks passed!"
        echo "The Kernel Jester says: 'Thy modules are worthy of the realm!'"
        echo "✓ SAFE to deploy to Nook hardware"
    elif [ "$TOTAL_WARNINGS" -le 2 ]; then
        echo "[GOOD] No critical issues, minor warnings only"
        echo "The Kernel Jester says: 'Minor concerns, but courage prevails!'"
        echo "✓ SAFE to deploy with caution"
    else
        echo "[CAUTION] No critical issues but many warnings"
        echo "The Kernel Jester says: 'Review thy work, then proceed!'"
        echo "⚠ Consider fixing warnings before deployment"
    fi
else
    echo "[DANGER] CRITICAL ISSUES FOUND!"
    echo "The Kernel Jester says: 'HALT! Thy code will brick the realm!'"
    echo "❌ DO NOT DEPLOY until critical issues are resolved!"
    exit 1
fi

echo ""
echo "Kernel Safety Check Complete (JesterOS in userspace)"