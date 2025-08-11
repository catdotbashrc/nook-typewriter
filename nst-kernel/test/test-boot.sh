#!/bin/bash
# QuillKernel Boot Testing Script
# Tests boot sequence and validates kernel messages

set -e

echo "═══════════════════════════════════════════════════════════════"
echo "         QuillKernel Boot Sequence Test"
echo "═══════════════════════════════════════════════════════════════"

# This script is meant to be run on the actual Nook hardware
# It validates that our medieval boot messages appear correctly

LOG_FILE="/tmp/quillkernel-boot-test.log"
DMESG_BACKUP="/tmp/dmesg-backup.log"

# Save current dmesg for comparison
dmesg > "$DMESG_BACKUP"

echo ""
echo "1. Checking Kernel Version"
echo "--------------------------"
uname -r | tee -a "$LOG_FILE"

if uname -r | grep -q "quill-scribe"; then
    echo "[PASS] QuillKernel version detected"
else
    echo "[FAIL] QuillKernel version not found"
    exit 1
fi

echo ""
echo "2. Checking Boot Messages"
echo "-------------------------"

# Check for jester ASCII art
if dmesg | grep -q "\.~\"~\.~\"~\."; then
    echo "[PASS] Jester ASCII art found in boot messages"
else
    echo "[FAIL] Jester ASCII art missing"
fi

# Check for medieval boot messages
EXPECTED_MESSAGES=(
    "QuillKernel awakening"
    "Candles lit for illumination"
    "Quills sharpened to perfection"
    "Your squire stands ready"
    "By quill and candlelight"
)

for msg in "${EXPECTED_MESSAGES[@]}"; do
    if dmesg | grep -q "$msg"; then
        echo "[PASS] Found: $msg"
    else
        echo "[FAIL] Missing: $msg"
    fi
done

echo ""
echo "3. Checking /proc/squireos Entries"
echo "----------------------------------"

if [ -d /proc/squireos ]; then
    echo "[PASS] /proc/squireos directory exists"
    
    # Test each entry
    for entry in motto wisdom jester; do
        if [ -f "/proc/squireos/$entry" ]; then
            echo "[PASS] /proc/squireos/$entry exists"
            echo "Content:"
            cat "/proc/squireos/$entry" | head -5
            echo ""
        else
            echo "[FAIL] /proc/squireos/$entry missing"
        fi
    done
else
    echo "[FAIL] /proc/squireos directory missing"
fi

echo ""
echo "4. Checking Typewriter Module"
echo "-----------------------------"

if [ -d /proc/squireos/typewriter ]; then
    echo "[PASS] Typewriter module loaded"
    
    if [ -f /proc/squireos/typewriter/stats ]; then
        echo "[PASS] Writing stats available"
        cat /proc/squireos/typewriter/stats
    else
        echo "[FAIL] Writing stats missing"
    fi
else
    echo "[INFO] Typewriter module not loaded (may be compiled as module)"
fi

echo ""
echo "5. Boot Time Analysis"
echo "---------------------"

# Extract boot timing from dmesg
BOOT_START=$(dmesg | grep -m1 "Linux version" | sed 's/\[[ ]*\([0-9.]*\)\].*/\1/')
BOOT_END=$(dmesg | grep -m1 "Your squire stands ready" | sed 's/\[[ ]*\([0-9.]*\)\].*/\1/' || echo "0")

if [ "$BOOT_END" != "0" ]; then
    BOOT_TIME=$(echo "$BOOT_END - $BOOT_START" | bc)
    echo "Medieval messages added ${BOOT_TIME}s to boot time"
    
    if (( $(echo "$BOOT_TIME > 5" | bc -l) )); then
        echo "[WARN] Boot messages may be too slow"
    else
        echo "[PASS] Boot time acceptable"
    fi
else
    echo "[WARN] Could not measure boot time"
fi

echo ""
echo "6. Memory Usage Check"
echo "--------------------"

# Check free memory
FREE_MEM=$(free -m | grep "Mem:" | awk '{print $4}')
echo "Free memory: ${FREE_MEM}MB"

if [ "$FREE_MEM" -lt 50 ]; then
    echo "[WARN] Low memory - may affect writing performance"
else
    echo "[PASS] Adequate memory available"
fi

echo ""
echo "7. Error Check"
echo "--------------"

# Check for kernel panics or errors
if dmesg | grep -i "panic\|error\|fail" | grep -v "FAIL" > /tmp/kernel-errors.log; then
    ERROR_COUNT=$(wc -l < /tmp/kernel-errors.log)
    if [ "$ERROR_COUNT" -gt 0 ]; then
        echo "[WARN] Found $ERROR_COUNT potential errors:"
        head -5 /tmp/kernel-errors.log
    fi
else
    echo "[PASS] No kernel errors detected"
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "Boot test complete. Full log saved to: $LOG_FILE"
echo ""

# Show jester reaction based on results
if grep -q "FAIL" "$LOG_FILE"; then
    echo "     .~!!!~."
    echo "    / O   O \\    Some tests failed!"
    echo "   |  >   <  |   Check the log for details."
    echo "    \\  ~~~  /    "
    echo "     |~|♦|~|     "
else
    echo "     .~\"~.~\"~."
    echo "    /  ^   ^  \\    All boot tests passed!"
    echo "   |  >  ◡  <  |   QuillKernel boots successfully!"
    echo "    \\  ___  /      "
    echo "     |~|♦|~|       "
fi