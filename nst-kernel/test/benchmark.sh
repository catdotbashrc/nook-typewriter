#!/bin/bash
# QuillKernel Performance Benchmark
# Measures performance impact of medieval modifications

set -e

echo "═══════════════════════════════════════════════════════════════"
echo "         QuillKernel Performance Benchmark"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "     .~\"~.~\"~."
echo "    /  o   o  \\    Measuring thy kernel's"
echo "   |  >  ◡  <  |   performance..."
echo "    \\  ___  /      "
echo "     |~|♦|~|       "
echo ""

LOG_FILE="/tmp/quillkernel-benchmark-$(date +%Y%m%d_%H%M%S).log"

# Function to log results
log_result() {
    echo "$1" | tee -a "$LOG_FILE"
}

echo "Starting benchmark at $(date)" | tee "$LOG_FILE"
echo "Kernel: $(uname -r)" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# 1. Boot Time Measurement
echo "1. Boot Time Analysis"
echo "--------------------"

if [ -f /proc/uptime ]; then
    UPTIME=$(cat /proc/uptime | awk '{print $1}')
    log_result "System uptime: ${UPTIME}s"
    
    # Extract boot message timings from dmesg
    if dmesg | grep -q "Your squire stands ready"; then
        KERNEL_START=$(dmesg | grep "Linux version" | head -1 | sed 's/\[[ ]*\([0-9.]*\)\].*/\1/')
        SQUIRE_READY=$(dmesg | grep "Your squire stands ready" | head -1 | sed 's/\[[ ]*\([0-9.]*\)\].*/\1/')
        
        if [ -n "$KERNEL_START" ] && [ -n "$SQUIRE_READY" ]; then
            BOOT_MSGS_TIME=$(echo "$SQUIRE_READY - $KERNEL_START" | bc)
            log_result "Medieval messages took: ${BOOT_MSGS_TIME}s"
            
            # Check delays
            DELAY_COUNT=$(grep -c "mdelay" /proc/kallsyms 2>/dev/null || echo "0")
            log_result "Kernel delays in boot path: $DELAY_COUNT"
        fi
    fi
else
    log_result "Boot time measurement not available"
fi

echo ""

# 2. Memory Usage
echo "2. Memory Usage Analysis"
echo "-----------------------"

# Get memory stats
MEM_TOTAL=$(grep "MemTotal:" /proc/meminfo | awk '{print $2}')
MEM_FREE=$(grep "MemFree:" /proc/meminfo | awk '{print $2}')
MEM_AVAILABLE=$(grep "MemAvailable:" /proc/meminfo | awk '{print $2}')
MEM_USED=$((MEM_TOTAL - MEM_FREE))

log_result "Total memory: $((MEM_TOTAL / 1024))MB"
log_result "Used memory: $((MEM_USED / 1024))MB"
log_result "Free memory: $((MEM_FREE / 1024))MB"
log_result "Available memory: $((MEM_AVAILABLE / 1024))MB"

# Check QuillKernel module memory
if lsmod | grep -q "typewriter"; then
    MOD_SIZE=$(lsmod | grep "typewriter" | awk '{print $2}')
    log_result "Typewriter module size: ${MOD_SIZE} bytes"
fi

# Check /proc/squireos memory usage
if [ -d /proc/squireos ]; then
    # Measure memory before and after accessing proc files
    MEM_BEFORE=$(grep "MemFree:" /proc/meminfo | awk '{print $2}')
    
    for i in {1..100}; do
        find /proc/squireos -type f -exec cat {} \; > /dev/null 2>&1
    done
    
    MEM_AFTER=$(grep "MemFree:" /proc/meminfo | awk '{print $2}')
    PROC_MEM=$((MEM_BEFORE - MEM_AFTER))
    log_result "/proc/squireos access memory impact: ${PROC_MEM}kB"
fi

echo ""

# 3. CPU Performance
echo "3. CPU Performance Test"
echo "----------------------"

# Simple CPU benchmark - calculate primes
log_result "Running CPU benchmark (finding primes)..."
START_TIME=$(date +%s.%N)

# Find primes up to 10000
for ((n=2; n<=10000; n++)); do
    for ((i=2; i<=n/2; i++)); do
        if [ $((n%i)) -eq 0 ]; then
            break
        fi
    done
done > /dev/null 2>&1

END_TIME=$(date +%s.%N)
CPU_TIME=$(echo "$END_TIME - $START_TIME" | bc)
log_result "CPU benchmark completed in: ${CPU_TIME}s"

# Check CPU frequency scaling
if [ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq ]; then
    CPU_FREQ=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq)
    log_result "Current CPU frequency: $((CPU_FREQ / 1000))MHz"
fi

echo ""

# 4. I/O Performance
echo "4. I/O Performance Test"
echo "----------------------"

TEST_FILE="/tmp/quillkernel-io-test"
TEST_SIZE="1M"

# Write test
log_result "Testing write performance..."
sync
START_TIME=$(date +%s.%N)
dd if=/dev/zero of="$TEST_FILE" bs="$TEST_SIZE" count=10 2>&1 | grep -o "[0-9.]* MB/s" | tail -1 | tee -a "$LOG_FILE"
sync
END_TIME=$(date +%s.%N)
WRITE_TIME=$(echo "$END_TIME - $START_TIME" | bc)

# Read test
log_result "Testing read performance..."
echo 3 > /proc/sys/vm/drop_caches 2>/dev/null || true
START_TIME=$(date +%s.%N)
dd if="$TEST_FILE" of=/dev/null bs="$TEST_SIZE" 2>&1 | grep -o "[0-9.]* MB/s" | tail -1 | tee -a "$LOG_FILE"
END_TIME=$(date +%s.%N)
READ_TIME=$(echo "$END_TIME - $START_TIME" | bc)

rm -f "$TEST_FILE"

echo ""

# 5. Power Consumption
echo "5. Power Consumption Analysis"
echo "----------------------------"

if [ -f /sys/class/power_supply/bq27510-0/current_now ]; then
    CURRENT=$(cat /sys/class/power_supply/bq27510-0/current_now)
    VOLTAGE=$(cat /sys/class/power_supply/bq27510-0/voltage_now)
    POWER=$((CURRENT * VOLTAGE / 1000000))
    
    log_result "Current draw: ${CURRENT}µA"
    log_result "Voltage: $((VOLTAGE / 1000))mV"
    log_result "Power consumption: ${POWER}mW"
    
    # Test suspend/resume if available
    if [ -f /sys/power/state ]; then
        log_result "Testing suspend current..."
        # Note: This would actually suspend the device
        log_result "[INFO] Suspend test skipped (would suspend device)"
    fi
else
    log_result "Power monitoring not available"
fi

echo ""

# 6. USB Performance
echo "6. USB Keyboard Response Test"
echo "-----------------------------"

if lsusb | grep -qi "keyboard"; then
    log_result "USB keyboard detected"
    
    # Measure input latency (rough estimate)
    echo "Press any key to test response time..."
    read -r -s -n1 -t 5 || true
    
    # Check USB interrupts
    USB_IRQ=$(grep -i "usb" /proc/interrupts | head -1 | awk '{print $2}')
    log_result "USB interrupts: $USB_IRQ"
else
    log_result "No USB keyboard connected"
fi

echo ""

# 7. E-Ink Specific Tests
echo "7. E-Ink Display Performance"
echo "---------------------------"

if command -v fbink > /dev/null 2>&1; then
    log_result "Testing E-Ink refresh rate..."
    
    # Time a full refresh
    START_TIME=$(date +%s.%N)
    fbink -c 2>/dev/null || true
    END_TIME=$(date +%s.%N)
    REFRESH_TIME=$(echo "$END_TIME - $START_TIME" | bc)
    
    log_result "Full refresh time: ${REFRESH_TIME}s"
else
    log_result "FBInk not available - skipping E-Ink tests"
fi

echo ""

# 8. Module Loading Performance
echo "8. Module Loading Test"
echo "---------------------"

if lsmod | grep -q "typewriter"; then
    log_result "Testing module unload/reload..."
    
    START_TIME=$(date +%s.%N)
    rmmod typewriter 2>/dev/null || true
    modprobe typewriter 2>/dev/null || true
    END_TIME=$(date +%s.%N)
    
    MODULE_TIME=$(echo "$END_TIME - $START_TIME" | bc)
    log_result "Module reload time: ${MODULE_TIME}s"
else
    log_result "Typewriter module not loaded as module"
fi

echo ""

# 9. Overall System Load
echo "9. System Load Analysis"
echo "----------------------"

# Get load average
LOAD=$(cat /proc/loadavg)
log_result "Load average: $LOAD"

# Count processes
PROCS=$(ps aux | wc -l)
log_result "Running processes: $PROCS"

# Check for medieval process overhead
SQUIRE_PROCS=$(ps aux | grep -i "squire\|jester\|quill" | grep -v grep | wc -l)
log_result "SquireOS specific processes: $SQUIRE_PROCS"

echo ""

# 10. Summary and Recommendations
echo "═══════════════════════════════════════════════════════════════"
echo "                    Benchmark Summary"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Analyze results
WARNINGS=0

# Check memory
if [ "$MEM_AVAILABLE" -lt 51200 ]; then  # Less than 50MB
    echo "[WARN] Low available memory may affect performance"
    ((WARNINGS++))
fi

# Check boot time
if [ -n "$BOOT_MSGS_TIME" ] && (( $(echo "$BOOT_MSGS_TIME > 3" | bc -l) )); then
    echo "[WARN] Boot messages add significant delay"
    ((WARNINGS++))
fi

# Check CPU
if [ -n "$CPU_TIME" ] && (( $(echo "$CPU_TIME > 10" | bc -l) )); then
    echo "[WARN] CPU performance may be impacted"
    ((WARNINGS++))
fi

echo ""
log_result "Performance warnings: $WARNINGS"
log_result "Full results saved to: $LOG_FILE"

echo ""
# Final jester message
if [ "$WARNINGS" -eq 0 ]; then
    echo "     .~\"~.~\"~."
    echo "    /  ^   ^  \\    Excellent performance!"
    echo "   |  >  ◡  <  |   QuillKernel runs smoothly!"
    echo "    \\  ___  /      "
    echo "     |~|♦|~|       "
else
    echo "     .~\"~.~\"~."
    echo "    /  o   o  \\    Performance could be better..."
    echo "   |  >  _  <  |   Consider the warnings above."
    echo "    \\  ___  /      "
    echo "     |~|♦|~|       "
fi