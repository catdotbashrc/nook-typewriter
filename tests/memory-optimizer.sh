#!/bin/bash
# Memory Optimizer - Analyze profiling data and suggest optimizations
# Use collected memory data to tune targets and suggest improvements

set -euo pipefail

echo "*** Memory Optimization Analysis ***"
echo "====================================="
echo ""

PROFILE_DIR="tests/memory-profiles"

if [ ! -d "$PROFILE_DIR" ]; then
    echo "[ERROR] No memory profiles found!"
    echo "Run ./tests/memory-profiler.sh first to collect data"
    exit 1
fi

# Find latest profile
LATEST_PROFILE=$(ls "$PROFILE_DIR"/memory_profile_*.txt 2>/dev/null | tail -1)

if [ -z "$LATEST_PROFILE" ]; then
    echo "[ERROR] No memory profile files found in $PROFILE_DIR"
    echo "Run ./tests/memory-profiler.sh first"
    exit 1
fi

echo "Analyzing latest profile: $(basename "$LATEST_PROFILE")"
echo ""

# Extract key metrics from latest profile
CURRENT_USED=$(grep "Used:" "$LATEST_PROFILE" | head -1 | awk '{print $2}')
CURRENT_AVAILABLE=$(grep "Available:" "$LATEST_PROFILE" | head -1 | awk '{print $2}')
CURRENT_TOTAL=$(grep "Total RAM:" "$LATEST_PROFILE" | head -1 | awk '{print $3}')

echo "Current Memory State:"
echo "  Total RAM:           ${CURRENT_TOTAL}MB"
echo "  OS Usage:            ${CURRENT_USED}MB"
echo "  Available:           ${CURRENT_AVAILABLE}MB"
echo ""

# Analyze against targets
echo "=== TARGET ANALYSIS ==="
echo ""

CURRENT_TARGET=96
WRITING_TARGET=160

echo "Current targets:"
echo "  OS Budget:           ${CURRENT_TARGET}MB"
echo "  Writing Space:       ${WRITING_TARGET}MB"
echo ""

# Calculate margins and recommendations
if [ "$CURRENT_USED" -lt "$CURRENT_TARGET" ]; then
    MARGIN=$((CURRENT_TARGET - CURRENT_USED))
    echo "[GOOD] OS within budget with ${MARGIN}MB margin"
    
    if [ "$MARGIN" -gt 20 ]; then
        echo ""
        echo "=== OPTIMIZATION OPPORTUNITIES ==="
        echo ""
        echo "Large margin detected! Recommendations:"
        echo ""
        
        echo "1. [FEATURE ENHANCEMENT] Add more writing tools:"
        echo "   - Spell checker (estimated +3-5MB)"
        echo "   - Thesaurus database (estimated +2-4MB)"
        echo "   - Additional vim plugins (estimated +2-3MB)"
        echo "   - Enhanced medieval themes (estimated +1MB)"
        echo ""
        
        echo "2. [PERFORMANCE IMPROVEMENT] Increase buffer sizes:"
        echo "   - Larger vim buffers for better performance"
        echo "   - More system cache for E-Ink optimization"
        echo "   - Pre-load frequently used data"
        echo ""
        
        echo "3. [TARGET ADJUSTMENT] Revise memory targets:"
        NEW_TARGET=$((CURRENT_USED + 10))
        echo "   - OS budget could be ${NEW_TARGET}MB (current: ${CURRENT_USED}MB + 10MB safety)"
        EXTRA_WRITING=$((CURRENT_TARGET - NEW_TARGET))
        echo "   - This frees up ${EXTRA_WRITING}MB more for writing"
        
    elif [ "$MARGIN" -gt 10 ]; then
        echo ""
        echo "[MODERATE OPPORTUNITY] ${MARGIN}MB margin allows small enhancements"
        echo "Consider: Additional vim plugins or small feature additions"
    else
        echo "[WELL TUNED] Margin is appropriate for safety"
    fi
    
else
    OVERAGE=$((CURRENT_USED - CURRENT_TARGET))
    echo "[CRITICAL] OS over budget by ${OVERAGE}MB!"
    echo ""
    echo "=== OPTIMIZATION REQUIRED ==="
    echo ""
    echo "Memory reduction strategies:"
    echo ""
    
    echo "1. [IMMEDIATE] Remove unnecessary services:"
    echo "   - Check for unused daemons"
    echo "   - Disable non-essential system services"
    echo "   - Use minimal init system"
    echo ""
    
    echo "2. [KERNEL] Optimize kernel modules:"
    echo "   - Remove unused kernel modules"
    echo "   - Optimize JesterOS service sizes"
    echo "   - Use minimal kernel configuration"
    echo ""
    
    echo "3. [BUILD] Use minimal build mode:"
    echo "   - Build with BUILD_MODE=minimal instead of writer"
    echo "   - Remove vim plugins if necessary"
    echo "   - Strip debug symbols"
fi

echo ""
echo "=== WRITING SPACE ANALYSIS ==="
echo ""

if [ "$CURRENT_AVAILABLE" -ge "$WRITING_TARGET" ]; then
    EXTRA=$((CURRENT_AVAILABLE - WRITING_TARGET))
    echo "[EXCELLENT] ${EXTRA}MB more than target available for writing"
    
    if [ "$EXTRA" -gt 50 ]; then
        echo ""
        echo "Abundant writing space! Options:"
        echo "  - Support very large documents"
        echo "  - Add in-memory database for notes"
        echo "  - Implement advanced text processing"
    fi
else
    SHORTAGE=$((WRITING_TARGET - CURRENT_AVAILABLE))
    echo "[WARNING] ${SHORTAGE}MB short of writing space target"
    echo ""
    echo "Writing space optimization needed:"
    echo "  - Reduce OS memory usage by ${SHORTAGE}MB minimum"
    echo "  - Consider using swap file for OS, not writing"
fi

echo ""
echo "=== COMPONENT ANALYSIS ==="
echo ""

# Analyze top memory consumers from profile
echo "Top memory consumers analysis:"
if grep -A 10 "Top 20 processes" "$LATEST_PROFILE" | grep -v "USER\|PID" | head -5 | while read line; do
    if echo "$line" | grep -q " [0-9]"; then
        PROCESS=$(echo "$line" | awk '{print $11}')
        MEMORY_PCT=$(echo "$line" | awk '{print $4}' | tr -d '%')
        
        if [ "${MEMORY_PCT%.*}" -gt 5 ]; then  # More than 5%
            echo "  [REVIEW] $PROCESS using ${MEMORY_PCT}% memory"
        fi
    fi
done

echo ""
echo "=== HISTORICAL TRENDS ==="
echo ""

# Compare with previous profiles if available
PREV_PROFILES=$(ls "$PROFILE_DIR"/memory_profile_*.txt 2>/dev/null | grep -v "$(basename "$LATEST_PROFILE")" | tail -3)

if [ -n "$PREV_PROFILES" ]; then
    echo "Memory usage trends:"
    echo ""
    
    for profile in $PREV_PROFILES; do
        PREV_USED=$(grep "Used:" "$profile" | head -1 | awk '{print $2}')
        PREV_DATE=$(basename "$profile" | sed 's/memory_profile_\([0-9_]*\).txt/\1/' | sed 's/_/ /')
        
        if [ -n "$PREV_USED" ]; then
            CHANGE=$((CURRENT_USED - PREV_USED))
            if [ "$CHANGE" -gt 0 ]; then
                echo "  $(echo "$PREV_DATE" | sed 's/\(....\)\(..\)\(..\)_\(..\)\(..\).*/\1-\2-\3 \4:\5/'): ${PREV_USED}MB (+${CHANGE}MB since then)"
            elif [ "$CHANGE" -lt 0 ]; then
                POS_CHANGE=$((-CHANGE))
                echo "  $(echo "$PREV_DATE" | sed 's/\(....\)\(..\)\(..\)_\(..\)\(..\).*/\1-\2-\3 \4:\5/'): ${PREV_USED}MB (-${POS_CHANGE}MB since then)"
            else
                echo "  $(echo "$PREV_DATE" | sed 's/\(....\)\(..\)\(..\)_\(..\)\(..\).*/\1-\2-\3 \4:\5/'): ${PREV_USED}MB (no change)"
            fi
        fi
    done
else
    echo "No historical data yet - run profiler regularly to track trends"
fi

echo ""
echo "=== ACTIONABLE RECOMMENDATIONS ==="
echo ""

# Generate specific action items based on analysis
if [ "$CURRENT_USED" -lt 80 ]; then
    echo "RECOMMENDED ACTIONS (Memory well under budget):"
    echo ""
    echo "1. ADD FEATURES:"
    echo "   - Implement spell checking"
    echo "   - Add thesaurus lookup" 
    echo "   - Include more vim writing plugins"
    echo ""
    echo "2. UPDATE TARGETS:"
    NEW_OS_TARGET=$((CURRENT_USED + 15))
    NEW_WRITING_TARGET=$((256 - NEW_OS_TARGET))
    echo "   - Revise OS budget to ${NEW_OS_TARGET}MB"
    echo "   - Increase writing target to ${NEW_WRITING_TARGET}MB"
    
elif [ "$CURRENT_USED" -lt 96 ]; then
    echo "RECOMMENDED ACTIONS (Memory within budget):"
    echo ""
    echo "1. MAINTAIN current configuration"
    echo "2. MONITOR for memory growth"
    echo "3. CONSIDER small enhancements if needed"
    
else
    echo "CRITICAL ACTIONS (Memory over budget):"
    echo ""
    echo "1. IMMEDIATELY reduce OS memory usage"
    echo "2. DISABLE unnecessary services"
    echo "3. OPTIMIZE kernel configuration"
    echo "4. TEST with minimal build mode"
fi

echo ""
echo "=== MONITORING SETUP ==="
echo ""
echo "Set up regular monitoring:"
echo ""
echo "1. Run memory profiler weekly:"
echo "   ./tests/memory-profiler.sh"
echo ""
echo "2. Check on hardware after major changes:"
echo "   ./tests/hardware-memory-test.sh"
echo ""
echo "3. Track trends over time:"
echo "   ./tests/memory-optimizer.sh"

echo ""
echo "*** Optimization Analysis Complete ***"
echo ""

if [ "$CURRENT_USED" -lt 80 ]; then
    echo "The Optimizer Jester says:"
    echo "'Thy memory management is most conservative!'"
    echo "'Room for grand enhancements awaits!'"
elif [ "$CURRENT_USED" -lt 96 ]; then
    echo "The Optimizer Jester says:"
    echo "'Well balanced, good scribe!'"
    echo "'Steady as she goes!'"
else
    echo "The Optimizer Jester says:"
    echo "'Trim the fat, preserve the feast!'"
    echo "'Every byte counts in this realm!'"
fi