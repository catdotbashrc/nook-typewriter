#!/bin/bash
# Memory Profiler - Collect detailed memory data for optimization
# Run this to gather real memory usage data and optimize our targets

set -euo pipefail

# Create data directory
PROFILE_DIR="tests/memory-profiles"
mkdir -p "$PROFILE_DIR"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
PROFILE_FILE="$PROFILE_DIR/memory_profile_$TIMESTAMP.txt"

echo "*** Memory Profiler - Data Collection ***"
echo "=========================================="
echo ""
echo "Collecting detailed memory data for optimization..."
echo "Profile will be saved to: $PROFILE_FILE"
echo ""

# Start profile file
cat > "$PROFILE_FILE" << EOF
Memory Profile Report
Generated: $(date)
Purpose: Collect real memory usage data to optimize 96MB target

=== ENVIRONMENT ===
EOF

# Add environment info
echo "Hardware: $(uname -m)" >> "$PROFILE_FILE"
echo "Kernel: $(uname -r)" >> "$PROFILE_FILE"
echo "OS: $(cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d'"' -f2 || echo 'Unknown')" >> "$PROFILE_FILE"
echo "" >> "$PROFILE_FILE"

echo "-> Collecting baseline memory data..."

# 1. System memory baseline
cat >> "$PROFILE_FILE" << EOF
=== BASELINE MEMORY STATE ===
EOF

if [ -f "/proc/meminfo" ]; then
    echo "Full /proc/meminfo:" >> "$PROFILE_FILE"
    cat /proc/meminfo >> "$PROFILE_FILE"
    echo "" >> "$PROFILE_FILE"
    
    # Extract key metrics
    TOTAL_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    FREE_KB=$(grep MemFree /proc/meminfo | awk '{print $2}')
    AVAILABLE_KB=$(grep MemAvailable /proc/meminfo | awk '{print $2}' 2>/dev/null || echo "$FREE_KB")
    BUFFERS_KB=$(grep Buffers /proc/meminfo | awk '{print $2}')
    CACHED_KB=$(grep "^Cached:" /proc/meminfo | awk '{print $2}')
    
    TOTAL_MB=$((TOTAL_KB / 1024))
    FREE_MB=$((FREE_KB / 1024))
    AVAILABLE_MB=$((AVAILABLE_KB / 1024))
    USED_MB=$((TOTAL_MB - FREE_MB))
    BUFFERS_MB=$((BUFFERS_KB / 1024))
    CACHED_MB=$((CACHED_KB / 1024))
    
    cat >> "$PROFILE_FILE" << EOF

Memory Summary (MB):
  Total RAM:           $TOTAL_MB
  Used:                $USED_MB
  Free:                $FREE_MB  
  Available:           $AVAILABLE_MB
  Buffers:             $BUFFERS_MB
  Cached:              $CACHED_MB
  
Current vs Targets:
  OS Usage:            $USED_MB MB (target: <96MB)
  Available for writing: $AVAILABLE_MB MB (target: >160MB)
  
EOF

    echo "  Baseline: ${USED_MB}MB used, ${AVAILABLE_MB}MB available"
else
    echo "ERROR: Cannot access /proc/meminfo" >> "$PROFILE_FILE"
fi

# 2. Detailed process analysis
echo "-> Analyzing individual process memory usage..."

cat >> "$PROFILE_FILE" << EOF
=== PROCESS MEMORY BREAKDOWN ===

Top 20 processes by memory usage:
EOF

# Get detailed process memory info
ps aux --sort=-%mem | head -21 >> "$PROFILE_FILE"

echo "" >> "$PROFILE_FILE"
echo "Process categories and usage:" >> "$PROFILE_FILE"

# Categorize processes and sum memory
SYSTEM_TOTAL=0
USER_TOTAL=0
KERNEL_TOTAL=0

ps aux --sort=-%mem --no-headers | while read user pid cpu mem vsz rss tty stat start time command; do
    MEM_KB=$(echo "$rss" | tr -d ' ')
    MEM_MB=$((MEM_KB / 1024))
    
    # Categorize by process type
    case "$command" in
        *kernel*|*kthread*|*migration*|*rcu*|*watchdog*|*irq*)
            CATEGORY="KERNEL"
            ;;
        *init*|*systemd*|*dbus*|*cron*|*syslog*)
            CATEGORY="SYSTEM"
            ;;
        *vim*|*bash*|*sh*)
            CATEGORY="USER"
            ;;
        *)
            CATEGORY="OTHER"
            ;;
    esac
    
    if [ "$MEM_MB" -gt 0 ]; then
        printf "  %-8s %6dMB  %s\n" "$CATEGORY" "$MEM_MB" "$command" >> "$PROFILE_FILE"
    fi
done

# 3. Kernel module memory analysis
echo "-> Profiling kernel module memory..."

cat >> "$PROFILE_FILE" << EOF

=== KERNEL MODULE MEMORY ===
EOF

if [ -f "/proc/modules" ]; then
    echo "Loaded modules:" >> "$PROFILE_FILE"
    printf "  %-20s %8s %8s %s\n" "Module" "Size(KB)" "Used" "Dependencies" >> "$PROFILE_FILE"
    
    TOTAL_MODULE_KB=0
    while read name size used deps state addr; do
        SIZE_KB=$((size / 1024))
        TOTAL_MODULE_KB=$((TOTAL_MODULE_KB + SIZE_KB))
        printf "  %-20s %8d %8s %s\n" "$name" "$SIZE_KB" "$used" "$deps" >> "$PROFILE_FILE"
    done < /proc/modules
    
    TOTAL_MODULE_MB=$((TOTAL_MODULE_KB / 1024))
    echo "" >> "$PROFILE_FILE"
    echo "Total kernel modules: ${TOTAL_MODULE_MB}MB (${TOTAL_MODULE_KB}KB)" >> "$PROFILE_FILE"
    
    echo "  Kernel modules: ${TOTAL_MODULE_MB}MB total"
else
    echo "ERROR: Cannot access /proc/modules" >> "$PROFILE_FILE"
fi

# 4. JokerOS specific analysis
echo "-> Analyzing JokerOS components..."

cat >> "$PROFILE_FILE" << EOF

=== JOKEROS COMPONENT ANALYSIS ===
EOF

# Check JokerOS modules specifically
JOKEROS_TOTAL_KB=0
for module in jokeros_core jester typewriter wisdom; do
    if grep -q "^$module " /proc/modules 2>/dev/null; then
        SIZE=$(grep "^$module " /proc/modules | awk '{print $2}')
        SIZE_KB=$((SIZE / 1024))
        JOKEROS_TOTAL_KB=$((JOKEROS_TOTAL_KB + SIZE_KB))
        echo "  $module: ${SIZE_KB}KB" >> "$PROFILE_FILE"
    else
        echo "  $module: NOT LOADED" >> "$PROFILE_FILE"
    fi
done

JOKEROS_TOTAL_MB=$((JOKEROS_TOTAL_KB / 1024))
echo "  Total JokerOS modules: ${JOKEROS_TOTAL_MB}MB (${JOKEROS_TOTAL_KB}KB)" >> "$PROFILE_FILE"

echo "  JokerOS modules: ${JOKEROS_TOTAL_MB}MB"

# 5. Vim memory profiling
echo "-> Profiling vim memory usage..."

cat >> "$PROFILE_FILE" << EOF

=== VIM MEMORY PROFILING ===
EOF

if command -v vim >/dev/null 2>&1; then
    # Test vim memory with different scenarios
    
    # Small file test
    echo "Testing small file (1KB)..." >> "$PROFILE_FILE"
    echo "test content" > /tmp/small_test.txt
    
    # Start vim and measure
    vim /tmp/small_test.txt -c ":q!" &
    VIM_PID=$!
    sleep 1
    
    if kill -0 $VIM_PID 2>/dev/null; then
        VIM_MEM_KB=$(ps -p $VIM_PID -o rss= 2>/dev/null || echo "0")
        VIM_MEM_MB=$((VIM_MEM_KB / 1024))
        echo "  Small file: ${VIM_MEM_MB}MB (${VIM_MEM_KB}KB)" >> "$PROFILE_FILE"
        kill $VIM_PID 2>/dev/null || true
    fi
    
    # Medium file test  
    echo "Testing medium file (100KB)..." >> "$PROFILE_FILE"
    dd if=/dev/zero of=/tmp/medium_test.txt bs=1024 count=100 2>/dev/null
    
    vim /tmp/medium_test.txt -c ":q!" &
    VIM_PID=$!
    sleep 1
    
    if kill -0 $VIM_PID 2>/dev/null; then
        VIM_MEM_KB=$(ps -p $VIM_PID -o rss= 2>/dev/null || echo "0")
        VIM_MEM_MB=$((VIM_MEM_KB / 1024))
        echo "  Medium file: ${VIM_MEM_MB}MB (${VIM_MEM_KB}KB)" >> "$PROFILE_FILE"
        kill $VIM_PID 2>/dev/null || true
    fi
    
    # Cleanup
    rm -f /tmp/small_test.txt /tmp/medium_test.txt
    
    echo "  Vim memory tests completed"
else
    echo "  Vim not available for testing" >> "$PROFILE_FILE"
fi

# 6. Generate optimization recommendations
echo "-> Generating optimization recommendations..."

cat >> "$PROFILE_FILE" << EOF

=== OPTIMIZATION ANALYSIS ===

Current Memory Allocation:
  OS Base Usage:       $USED_MB MB
  Available for Apps:  $AVAILABLE_MB MB
  Target OS Budget:    96 MB
  Target Writing Space: 160 MB

EOF

# Calculate recommendations
if [ "$USED_MB" -lt 80 ]; then
    cat >> "$PROFILE_FILE" << EOF
RECOMMENDATIONS:
  [OPPORTUNITY] OS using only $USED_MB MB - well under 96MB target!
  [ACTION] Could add more features or optimize less aggressively
  [SAFE MARGIN] ${AVAILABLE_MB}MB available for writing (target: 160MB)
EOF
elif [ "$USED_MB" -lt 96 ]; then
    MARGIN=$((96 - USED_MB))
    cat >> "$PROFILE_FILE" << EOF
RECOMMENDATIONS:
  [GOOD] OS within 96MB budget with ${MARGIN}MB margin
  [STATUS] Current allocation is well-tuned
  [AVAILABLE] ${AVAILABLE_MB}MB for writing
EOF
else
    OVERAGE=$((USED_MB - 96))
    cat >> "$PROFILE_FILE" << EOF
RECOMMENDATIONS:
  [CRITICAL] OS over budget by ${OVERAGE}MB!
  [ACTION] Need to reduce OS memory usage
  [PRIORITY] Optimize kernel modules, remove services, use minimal builds
EOF
fi

# 7. Historical comparison (if previous profiles exist)
echo "-> Checking for historical data..."

cat >> "$PROFILE_FILE" << EOF

=== HISTORICAL COMPARISON ===
EOF

PREV_PROFILES=$(ls "$PROFILE_DIR"/memory_profile_*.txt 2>/dev/null | grep -v "$PROFILE_FILE" | tail -1 || echo "")

if [ -n "$PREV_PROFILES" ]; then
    echo "Comparing to previous profile: $(basename "$PREV_PROFILES")" >> "$PROFILE_FILE"
    
    PREV_USED=$(grep "Used:" "$PREV_PROFILES" | head -1 | awk '{print $2}')
    PREV_AVAILABLE=$(grep "Available:" "$PREV_PROFILES" | head -1 | awk '{print $2}')
    
    if [ -n "$PREV_USED" ] && [ -n "$PREV_AVAILABLE" ]; then
        USED_DIFF=$((USED_MB - PREV_USED))
        AVAIL_DIFF=$((AVAILABLE_MB - PREV_AVAILABLE))
        
        echo "Memory usage change: ${USED_DIFF:+$USED_DIFF}MB (was ${PREV_USED}MB)" >> "$PROFILE_FILE"
        echo "Available change: ${AVAIL_DIFF:+$AVAIL_DIFF}MB (was ${PREV_AVAILABLE}MB)" >> "$PROFILE_FILE"
    fi
else
    echo "No previous profiles found - this is the baseline" >> "$PROFILE_FILE"
fi

echo "" >> "$PROFILE_FILE"
echo "Profile completed: $(date)" >> "$PROFILE_FILE"

# 8. Display summary
echo ""
echo "*** Memory Profiling Complete ***"
echo "=================================="
echo ""
echo "Key Findings:"
echo "  OS Memory Usage:     ${USED_MB}MB / 96MB target"
echo "  Available for Apps:  ${AVAILABLE_MB}MB / 160MB target"
echo "  JokerOS Modules:     ${JOKEROS_TOTAL_MB}MB"
echo ""

if [ "$USED_MB" -lt 80 ]; then
    echo "[OPPORTUNITY] Memory usage well under target - room for improvements!"
elif [ "$USED_MB" -lt 96 ]; then
    echo "[GOOD] Memory usage within target with good margin"
else
    echo "[CRITICAL] Memory usage over target - optimization needed!"
fi

echo ""
echo "Detailed profile saved to: $PROFILE_FILE"
echo ""
echo "The Profiler Jester says:"
if [ "$USED_MB" -lt 80 ]; then
    echo "'Thy memory usage is most conservative! Room for enhancement!'"
else
    echo "'Measure twice, optimize once - data guides the way!'"
fi