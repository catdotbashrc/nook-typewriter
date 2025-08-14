#!/bin/bash
# Hardware Memory Testing - Run this ON the actual Nook device
# Real memory usage validation against our 96MB budget

set -euo pipefail

echo "*** Real Hardware Memory Test ***"
echo "=================================="
echo ""
echo "Running on actual Nook hardware to validate memory usage"
echo "Target: OS <96MB, Writing space >160MB available"
echo ""

# 1. System memory overview
echo "-> System memory overview..."
echo ""
echo "=== /proc/meminfo Analysis ==="
if [ -f "/proc/meminfo" ]; then
    cat /proc/meminfo | grep -E "(MemTotal|MemFree|MemAvailable|Buffers|Cached|SwapTotal|SwapFree)"
    echo ""
    
    # Extract key values
    TOTAL_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    FREE_KB=$(grep MemFree /proc/meminfo | awk '{print $2}')
    AVAILABLE_KB=$(grep MemAvailable /proc/meminfo | awk '{print $2}' 2>/dev/null || echo "$FREE_KB")
    
    TOTAL_MB=$((TOTAL_KB / 1024))
    FREE_MB=$((FREE_KB / 1024))
    AVAILABLE_MB=$((AVAILABLE_KB / 1024))
    USED_MB=$((TOTAL_MB - FREE_MB))
    
    echo "Memory Summary:"
    echo "  Total RAM:                     ${TOTAL_MB}MB"
    echo "  Used:                          ${USED_MB}MB"
    echo "  Free:                          ${FREE_MB}MB"
    echo "  Available for apps:            ${AVAILABLE_MB}MB"
    
    if [ "$USED_MB" -le 96 ]; then
        echo "  [PASS] OS memory usage within 96MB budget"
        REMAINING=$((256 - USED_MB))
        echo "  [PASS] ${REMAINING}MB remaining for writing"
    else
        echo "  [FAIL] OS using ${USED_MB}MB - over 96MB budget!"
        OVERAGE=$((USED_MB - 96))
        echo "  [CRITICAL] Over budget by ${OVERAGE}MB"
    fi
else
    echo "[FAIL] Cannot access /proc/meminfo"
    exit 1
fi
echo ""

# 2. Process memory usage
echo "-> Process memory usage..."
echo ""
echo "=== Top Memory Consumers ==="
echo "Process memory usage (top 10 by memory):"
ps aux --sort=-%mem | head -11 | awk '{printf "  %-15s %6s %6s %s\n", $1, $4"%", $6"KB", $11}'
echo ""

# Check for memory hogs
MEMORY_HOGS=$(ps aux --sort=-%mem | awk 'NR>1 && $4 > 5 {print $11 " (" $4 "%)"}' | head -5)
if [ -n "$MEMORY_HOGS" ]; then
    echo "Processes using >5% memory:"
    echo "$MEMORY_HOGS" | while read line; do echo "  $line"; done
else
    echo "[PASS] No processes using excessive memory"
fi
echo ""

# 3. Kernel module memory
echo "-> Kernel module memory usage..."
echo ""
echo "=== Kernel Modules ==="
if [ -f "/proc/modules" ]; then
    echo "Loaded kernel modules:"
    printf "  %-20s %8s %s\n" "Module" "Size" "Used"
    cat /proc/modules | while read name size used deps state addr; do
        SIZE_KB=$((size / 1024))
        printf "  %-20s %6dKB %s\n" "$name" "$SIZE_KB" "$used"
    done
    
    # Check for JokerOS modules specifically
    echo ""
    echo "JokerOS modules status:"
    for module in jokeros_core jester typewriter wisdom; do
        if grep -q "^$module " /proc/modules; then
            SIZE=$(grep "^$module " /proc/modules | awk '{print $2}')
            SIZE_KB=$((SIZE / 1024))
            echo "  [PASS] $module loaded (${SIZE_KB}KB)"
        else
            echo "  [FAIL] $module not loaded"
        fi
    done
else
    echo "[FAIL] Cannot access /proc/modules"
fi
echo ""

# 4. JokerOS interface test
echo "-> JokerOS interface memory test..."
echo ""
echo "=== /var/jesteros Interface ==="
if [ -d "/var/jesteros" ]; then
    echo "[PASS] /var/jesteros directory exists"
    
    # Test each interface
    for interface in jester typewriter/stats wisdom; do
        if [ -r "/var/jesteros/$interface" ]; then
            echo "  [PASS] $interface readable"
            # Read a small amount to test
            head -3 "/var/jesteros/$interface" 2>/dev/null | while read line; do
                echo "    $line"
            done
        else
            echo "  [FAIL] $interface not readable"
        fi
    done
else
    echo "[FAIL] /var/jesteros not found - JesterOS userspace services not running"
fi
echo ""

# 5. Vim memory test
echo "-> Vim memory usage test..."
echo ""
echo "=== Vim Memory Test ==="

# Get memory before vim
BEFORE_USED_KB=$(grep MemFree /proc/meminfo | awk '{print $2}')

# Test vim startup (in background, then kill)
echo "Testing vim memory usage..."
if command -v vim >/dev/null 2>&1; then
    # Start vim with a test file
    echo "test content for memory measurement" > /tmp/memtest.txt
    
    # Start vim in background
    vim /tmp/memtest.txt -c ":q!" &
    VIM_PID=$!
    sleep 2
    
    # Check vim memory usage
    if kill -0 $VIM_PID 2>/dev/null; then
        VIM_MEM=$(ps -p $VIM_PID -o rss= 2>/dev/null || echo "0")
        VIM_MB=$((VIM_MEM / 1024))
        echo "  Vim memory usage: ${VIM_MB}MB (${VIM_MEM}KB)"
        
        if [ "$VIM_MB" -le 10 ]; then
            echo "  [PASS] Vim within 10MB target"
        else
            echo "  [WARN] Vim using more than 10MB"
        fi
        
        kill $VIM_PID 2>/dev/null || true
    else
        echo "  [INFO] Vim started and exited quickly"
    fi
    
    rm -f /tmp/memtest.txt
else
    echo "  [FAIL] Vim not available"
fi
echo ""

# 6. Available memory for writing
echo "-> Available memory for writing..."
echo ""
echo "=== Writing Memory Analysis ==="

CURRENT_FREE_KB=$(grep MemFree /proc/meminfo | awk '{print $2}')
CURRENT_AVAILABLE_KB=$(grep MemAvailable /proc/meminfo | awk '{print $2}' 2>/dev/null || echo "$CURRENT_FREE_KB")
CURRENT_FREE_MB=$((CURRENT_FREE_KB / 1024))
CURRENT_AVAILABLE_MB=$((CURRENT_AVAILABLE_KB / 1024))

echo "Memory available for writing:"
echo "  Free memory:                   ${CURRENT_FREE_MB}MB"
echo "  Available memory:              ${CURRENT_AVAILABLE_MB}MB"

if [ "$CURRENT_AVAILABLE_MB" -ge 160 ]; then
    echo "  [PASS] Sufficient memory for writing (>160MB)"
else
    echo "  [WARN] Less than 160MB available for writing"
    echo "  [ACTION] Consider memory optimization"
fi
echo ""

# 7. Final assessment
echo "*** Hardware Memory Test Summary ***"
echo "====================================="
echo ""
echo "Memory Budget Validation:"
echo "  OS Memory Usage:               ${USED_MB}MB / 96MB budget"
echo "  Available for Writing:         ${CURRENT_AVAILABLE_MB}MB / 160MB target"
echo ""

if [ "$USED_MB" -le 96 ] && [ "$CURRENT_AVAILABLE_MB" -ge 160 ]; then
    echo "[PASS] Memory usage within all targets!"
    echo "[PASS] Safe to proceed with writing tasks"
elif [ "$USED_MB" -le 96 ]; then
    echo "[CAUTION] OS within budget but low writing memory"
    echo "[ACTION] Monitor memory during writing sessions"
else
    echo "[FAIL] OS memory over budget - optimization needed"
    echo "[ACTION] Reduce OS memory usage before heavy writing"
fi

echo ""
echo "The Hardware Memory Jester says:"
if [ "$USED_MB" -le 96 ] && [ "$CURRENT_AVAILABLE_MB" -ge 160 ]; then
    echo "'Thy memory management is most excellent, scribe!'"
else
    echo "'Mind thy memory usage, for precious RAM must be preserved!'"
fi