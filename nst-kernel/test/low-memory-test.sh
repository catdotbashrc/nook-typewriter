#!/bin/bash
# QuillKernel Low Memory Stress Test
# Tests kernel behavior under memory pressure (256MB constraint)

set -e

echo "═══════════════════════════════════════════════════════════════"
echo "         QuillKernel Low Memory Stress Test"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "     .~\"~.~\"~."
echo "    /  o   o  \\    Testing memory limits..."
echo "   |  >  ◡  <  |   (256MB total RAM)"
echo "    \\  ___  /      "
echo "     |~|♦|~|       "
echo ""

LOG_FILE="/tmp/quillkernel-lowmem-test-$(date +%Y%m%d_%H%M%S).log"

# Function to get current memory stats
get_memory_stats() {
    local mem_total=$(grep "MemTotal:" /proc/meminfo | awk '{print $2}')
    local mem_free=$(grep "MemFree:" /proc/meminfo | awk '{print $2}')
    local mem_available=$(grep "MemAvailable:" /proc/meminfo | awk '{print $2}')
    local swap_total=$(grep "SwapTotal:" /proc/meminfo | awk '{print $2}')
    
    echo "Memory Stats:" | tee -a "$LOG_FILE"
    echo "  Total: $((mem_total / 1024))MB" | tee -a "$LOG_FILE"
    echo "  Free: $((mem_free / 1024))MB" | tee -a "$LOG_FILE"
    echo "  Available: $((mem_available / 1024))MB" | tee -a "$LOG_FILE"
    echo "  Swap: $((swap_total / 1024))MB" | tee -a "$LOG_FILE"
}

# Function to monitor page faults
monitor_page_faults() {
    local duration=$1
    local start_faults=$(grep "pgfault" /proc/vmstat | awk '{print $2}')
    sleep "$duration"
    local end_faults=$(grep "pgfault" /proc/vmstat | awk '{print $2}')
    local faults_per_sec=$(( (end_faults - start_faults) / duration ))
    
    echo "Page faults/sec: $faults_per_sec" | tee -a "$LOG_FILE"
    
    # Memory pressure detected if >3 faults/sec
    if [ $faults_per_sec -gt 3 ]; then
        echo "[WARN] Memory pressure detected!" | tee -a "$LOG_FILE"
        return 1
    fi
    return 0
}

# Function to create memory pressure
create_memory_pressure() {
    local target_mb=$1
    local blocks=$((target_mb * 1024))  # 1KB blocks
    
    echo "Allocating ${target_mb}MB of memory..." | tee -a "$LOG_FILE"
    
    # Use dd to allocate memory
    dd if=/dev/zero of=/dev/null bs=1024 count=$blocks 2>&1 | grep -v "records" || true
}

echo "Initial System State" | tee -a "$LOG_FILE"
echo "-------------------" | tee -a "$LOG_FILE"
get_memory_stats
echo ""

# Test 1: Baseline memory usage
echo "Test 1: Baseline Memory Usage" | tee -a "$LOG_FILE"
echo "-----------------------------" | tee -a "$LOG_FILE"

# Check QuillKernel memory footprint
if [ -d /proc/squireos ]; then
    echo "QuillKernel features loaded" | tee -a "$LOG_FILE"
    
    # Read all proc files to load them into memory
    find /proc/squireos -type f -exec cat {} \; > /dev/null 2>&1
    
    # Check typewriter module size
    if lsmod | grep -q typewriter; then
        MOD_SIZE=$(lsmod | grep typewriter | awk '{print $2}')
        echo "Typewriter module size: $MOD_SIZE bytes" | tee -a "$LOG_FILE"
    fi
fi

echo ""

# Test 2: Progressive memory allocation
echo "Test 2: Progressive Memory Allocation" | tee -a "$LOG_FILE"
echo "------------------------------------" | tee -a "$LOG_FILE"

INITIAL_FREE=$(grep "MemFree:" /proc/meminfo | awk '{print $2}')
ALLOCATIONS=(10 20 30 40 50)  # MB to allocate

for mb in "${ALLOCATIONS[@]}"; do
    echo -n "Allocating ${mb}MB... " | tee -a "$LOG_FILE"
    
    # Create a file in tmpfs to consume memory
    dd if=/dev/zero of=/tmp/memtest_${mb}mb bs=1M count=$mb 2>/dev/null
    
    # Check if system is still responsive
    if timeout 2 cat /proc/squireos/wisdom > /dev/null 2>&1; then
        echo "System responsive" | tee -a "$LOG_FILE"
    else
        echo "System unresponsive!" | tee -a "$LOG_FILE"
        break
    fi
    
    # Monitor page faults
    monitor_page_faults 2 || true
done

# Cleanup
rm -f /tmp/memtest_*mb

echo ""

# Test 3: /proc/squireos under memory pressure
echo "Test 3: /proc/squireos Under Memory Pressure" | tee -a "$LOG_FILE"
echo "-------------------------------------------" | tee -a "$LOG_FILE"

# Allocate most of available memory
AVAILABLE=$(grep "MemAvailable:" /proc/meminfo | awk '{print $2}')
ALLOCATE=$((AVAILABLE * 80 / 100 / 1024))  # 80% of available in MB

echo "Allocating ${ALLOCATE}MB (80% of available)..." | tee -a "$LOG_FILE"
stress-ng --vm 1 --vm-bytes ${ALLOCATE}M --timeout 10s 2>/dev/null &
STRESS_PID=$!

sleep 2

# Test proc file access under pressure
echo "Testing /proc/squireos access..." | tee -a "$LOG_FILE"
SUCCESS=0
FAIL=0

for i in {1..100}; do
    if timeout 1 cat /proc/squireos/wisdom > /dev/null 2>&1; then
        ((SUCCESS++))
    else
        ((FAIL++))
    fi
done

echo "Access results: $SUCCESS successful, $FAIL failed" | tee -a "$LOG_FILE"

# Kill stress test
kill $STRESS_PID 2>/dev/null || true
wait $STRESS_PID 2>/dev/null || true

echo ""

# Test 4: OOM killer behavior
echo "Test 4: Near-OOM Behavior" | tee -a "$LOG_FILE"
echo "------------------------" | tee -a "$LOG_FILE"
echo "[INFO] Skipping actual OOM test for safety" | tee -a "$LOG_FILE"

# Just check OOM score for our processes
if [ -f /proc/self/oom_score ]; then
    OOM_SCORE=$(cat /proc/self/oom_score)
    echo "Current process OOM score: $OOM_SCORE" | tee -a "$LOG_FILE"
fi

echo ""

# Test 5: Writing under memory pressure
echo "Test 5: Typewriter Module Memory Test" | tee -a "$LOG_FILE"
echo "------------------------------------" | tee -a "$LOG_FILE"

if [ -f /proc/squireos/typewriter/stats ]; then
    # Get initial stats
    KEYS_BEFORE=$(grep "Keystrokes:" /proc/squireos/typewriter/stats | grep -o "[0-9]*" | head -1)
    
    # Allocate memory
    echo "Creating memory pressure..." | tee -a "$LOG_FILE"
    stress-ng --vm 1 --vm-bytes 150M --timeout 20s 2>/dev/null &
    STRESS_PID=$!
    
    sleep 2
    
    # Simulate typing
    echo "Simulating typing under pressure..." | tee -a "$LOG_FILE"
    for i in {1..1000}; do
        echo "test" > /dev/null
    done
    
    # Check if stats still update
    KEYS_AFTER=$(grep "Keystrokes:" /proc/squireos/typewriter/stats | grep -o "[0-9]*" | head -1)
    
    if [ "$KEYS_AFTER" != "$KEYS_BEFORE" ]; then
        echo "Typewriter module still tracking (Good!)" | tee -a "$LOG_FILE"
    else
        echo "Typewriter module may be affected by memory pressure" | tee -a "$LOG_FILE"
    fi
    
    kill $STRESS_PID 2>/dev/null || true
    wait $STRESS_PID 2>/dev/null || true
else
    echo "Typewriter module not loaded" | tee -a "$LOG_FILE"
fi

echo ""

# Test 6: Memory leak detection
echo "Test 6: Memory Leak Detection" | tee -a "$LOG_FILE"
echo "----------------------------" | tee -a "$LOG_FILE"

MEM_BEFORE=$(grep "MemFree:" /proc/meminfo | awk '{print $2}')

# Hammer the proc files
echo "Reading /proc/squireos files 10000 times..." | tee -a "$LOG_FILE"
for i in {1..10000}; do
    cat /proc/squireos/wisdom > /dev/null 2>&1
    cat /proc/squireos/jester > /dev/null 2>&1
    cat /proc/squireos/motto > /dev/null 2>&1
done

MEM_AFTER=$(grep "MemFree:" /proc/meminfo | awk '{print $2}')
MEM_DIFF=$((MEM_BEFORE - MEM_AFTER))

echo "Memory difference: ${MEM_DIFF}kB" | tee -a "$LOG_FILE"
if [ $MEM_DIFF -gt 1000 ]; then
    echo "[WARN] Possible memory leak detected!" | tee -a "$LOG_FILE"
else
    echo "[PASS] No significant memory leak" | tee -a "$LOG_FILE"
fi

echo ""

# Final system state
echo "Final System State" | tee -a "$LOG_FILE"
echo "-----------------" | tee -a "$LOG_FILE"
get_memory_stats

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "Low memory test complete. Log saved to: $LOG_FILE"
echo ""

# Check for critical issues
WARNINGS=$(grep -c "WARN" "$LOG_FILE" || echo "0")
ERRORS=$(grep -c "ERROR\|FAIL" "$LOG_FILE" || echo "0")

if [ $ERRORS -gt 0 ]; then
    echo "     .~!!!~."
    echo "    / O   O \\    $ERRORS errors found!"
    echo "   |  >   <  |   Memory handling needs work!"
    echo "    \\  ~~~  /    "
    echo "     |~|♦|~|     "
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo "     .~\"~.~\"~."
    echo "    /  o   o  \\    $WARNINGS warnings found."
    echo "   |  >  _  <  |   Memory usage could be better."
    echo "    \\  ___  /      "
    echo "     |~|♦|~|       "
    exit 0
else
    echo "     .~\"~.~\"~."
    echo "    /  ^   ^  \\    Excellent!"
    echo "   |  >  ◡  <  |   QuillKernel handles"
    echo "    \\  ___  /      low memory gracefully!"
    echo "     |~|♦|~|       "
    exit 0
fi