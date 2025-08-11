#!/bin/bash
# QuillKernel Typewriter Module Test
# Tests writing statistics and achievement tracking

set -e

echo "═══════════════════════════════════════════════════════════════"
echo "         QuillKernel Typewriter Module Test"
echo "═══════════════════════════════════════════════════════════════"
echo ""

MODULE_DIR="/proc/squireos/typewriter"
LOG_FILE="/tmp/quillkernel-typewriter-test.log"
TEST_FILE="/tmp/typewriter-test.txt"

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if module is loaded
echo "1. Module Status Check"
echo "---------------------"

if [ -d "$MODULE_DIR" ]; then
    echo -e "${GREEN}[PASS]${NC} Typewriter module loaded"
    echo "Module entries:"
    ls -la "$MODULE_DIR" | tee -a "$LOG_FILE"
else
    echo -e "${RED}[FAIL]${NC} Typewriter module not found"
    
    # Try to load module
    echo "Attempting to load typewriter module..."
    if modprobe typewriter 2>/dev/null; then
        echo -e "${GREEN}[PASS]${NC} Module loaded successfully"
    else
        echo -e "${RED}[FAIL]${NC} Could not load module"
        echo "Module may be compiled into kernel or not available"
        exit 1
    fi
fi

echo ""
echo "2. Initial Statistics"
echo "--------------------"

if [ -f "$MODULE_DIR/stats" ]; then
    echo "Current writing statistics:"
    cat "$MODULE_DIR/stats" | tee -a "$LOG_FILE"
    
    # Parse initial values
    KEYS_BEFORE=$(grep "Keystrokes:" "$MODULE_DIR/stats" | grep -o "[0-9]*" | head -1 || echo "0")
    WORDS_BEFORE=$(grep "Words:" "$MODULE_DIR/stats" | grep -o "[0-9]*" | head -1 || echo "0")
    
    echo ""
    echo "Initial keystrokes: $KEYS_BEFORE"
    echo "Initial words: $WORDS_BEFORE"
else
    echo -e "${RED}[FAIL]${NC} Stats file not found"
    exit 1
fi

echo ""
echo "3. Keystroke Tracking Test"
echo "-------------------------"

echo "Testing keystroke detection..."
echo "Please type exactly: 'The quick brown fox jumps over the lazy dog'"
echo "Then press Enter:"
read -r TEST_INPUT

# Expected: 44 characters (including spaces)
EXPECTED_CHARS=44

# Check new stats
sleep 1  # Give module time to update
KEYS_AFTER=$(grep "Keystrokes:" "$MODULE_DIR/stats" | grep -o "[0-9]*" | head -1 || echo "0")
KEYS_ADDED=$((KEYS_AFTER - KEYS_BEFORE))

echo "Keystrokes detected: $KEYS_ADDED"
echo "Expected (approximately): $EXPECTED_CHARS"

# Allow some variance for Enter key and timing
if [ "$KEYS_ADDED" -gt 40 ] && [ "$KEYS_ADDED" -lt 50 ]; then
    echo -e "${GREEN}[PASS]${NC} Keystroke tracking accurate"
else
    echo -e "${YELLOW}[WARN]${NC} Keystroke count differs from expected"
fi

echo ""
echo "4. Word Count Test"
echo "-----------------"

# Check word count update
WORDS_AFTER=$(grep "Words:" "$MODULE_DIR/stats" | grep -o "[0-9]*" | head -1 || echo "0")
WORDS_ADDED=$((WORDS_AFTER - WORDS_BEFORE))

echo "Words counted: $WORDS_ADDED"
echo "Expected: ~9 words"

if [ "$WORDS_ADDED" -ge 7 ] && [ "$WORDS_ADDED" -le 11 ]; then
    echo -e "${GREEN}[PASS]${NC} Word counting working"
else
    echo -e "${YELLOW}[WARN]${NC} Word count differs from expected"
fi

echo ""
echo "5. Session Tracking Test"
echo "-----------------------"

# Check if session is active
if grep -q "Current Session:" "$MODULE_DIR/stats"; then
    SESSION_TIME=$(grep "Current Session:" "$MODULE_DIR/stats" | grep -o "[0-9]*" || echo "0")
    echo "Current session time: $SESSION_TIME minutes"
    echo -e "${GREEN}[PASS]${NC} Session tracking active"
else
    echo -e "${YELLOW}[WARN]${NC} Session information not found"
fi

echo ""
echo "6. Achievement System Test"
echo "-------------------------"

if [ -f "$MODULE_DIR/milestone" ]; then
    echo "Current achievement status:"
    cat "$MODULE_DIR/milestone" | tee -a "$LOG_FILE"
    
    # Check milestone calculation
    TOTAL_WORDS=$(grep "Total Words:" "$MODULE_DIR/stats" | grep -o "[0-9]*" | tail -1 || echo "0")
    
    if [ "$TOTAL_WORDS" -lt 1000 ]; then
        EXPECTED_TITLE="Apprentice Scribe"
    elif [ "$TOTAL_WORDS" -lt 10000 ]; then
        EXPECTED_TITLE="Apprentice Scribe"  # 1000+ words
    elif [ "$TOTAL_WORDS" -lt 50000 ]; then
        EXPECTED_TITLE="Journeyman Wordsmith"
    elif [ "$TOTAL_WORDS" -lt 100000 ]; then
        EXPECTED_TITLE="Master Illuminator"
    else
        EXPECTED_TITLE="Grand Chronicler"
    fi
    
    if grep -q "$EXPECTED_TITLE" "$MODULE_DIR/milestone"; then
        echo -e "${GREEN}[PASS]${NC} Achievement title correct for word count"
    else
        echo -e "${YELLOW}[WARN]${NC} Achievement title may be incorrect"
    fi
else
    echo -e "${RED}[FAIL]${NC} Milestone file not found"
fi

echo ""
echo "7. Rapid Input Test"
echo "-------------------"

echo "Testing rapid keystroke handling..."
echo "Type as fast as you can for 5 seconds after pressing Enter!"
echo "Press Enter to start:"
read -r

KEYS_START=$(grep "Keystrokes:" "$MODULE_DIR/stats" | grep -o "[0-9]*" | head -1 || echo "0")
START_TIME=$(date +%s)

echo "GO! Type now!"
# Read for 5 seconds
timeout 5 cat > /dev/null || true

END_TIME=$(date +%s)
KEYS_END=$(grep "Keystrokes:" "$MODULE_DIR/stats" | grep -o "[0-9]*" | head -1 || echo "0")

DURATION=$((END_TIME - START_TIME))
KEYS_TYPED=$((KEYS_END - KEYS_START))
KEYS_PER_SEC=$((KEYS_TYPED / DURATION))

echo ""
echo "Rapid typing results:"
echo "Duration: ${DURATION}s"
echo "Keystrokes: $KEYS_TYPED"
echo "Speed: ~$KEYS_PER_SEC keys/second"

if [ "$KEYS_TYPED" -gt 0 ]; then
    echo -e "${GREEN}[PASS]${NC} Rapid input handling works"
else
    echo -e "${RED}[FAIL]${NC} No keystrokes detected during rapid test"
fi

echo ""
echo "8. Daily Reset Test"
echo "-------------------"

echo "Checking daily statistics..."
TODAY_KEYS=$(grep "Keystrokes:" "$MODULE_DIR/stats" | tail -1 | grep -o "[0-9]*" || echo "0")
echo "Today's keystrokes: $TODAY_KEYS"

# Note: Full test would require changing system date
echo -e "${YELLOW}[INFO]${NC} Daily reset requires 24 hours to fully test"

echo ""
echo "9. Memory Leak Test"
echo "-------------------"

# Get initial memory
MEM_BEFORE=$(grep "MemFree:" /proc/meminfo | awk '{print $2}')

# Hammer the module
echo "Stress testing module..."
for i in {1..1000}; do
    cat "$MODULE_DIR/stats" > /dev/null 2>&1
    cat "$MODULE_DIR/milestone" > /dev/null 2>&1
done

# Check memory after
MEM_AFTER=$(grep "MemFree:" /proc/meminfo | awk '{print $2}')
MEM_LEAK=$((MEM_BEFORE - MEM_AFTER))

echo "Memory difference: ${MEM_LEAK}kB"
if [ "$MEM_LEAK" -lt 100 ]; then
    echo -e "${GREEN}[PASS]${NC} No significant memory leak detected"
else
    echo -e "${YELLOW}[WARN]${NC} Possible memory leak"
fi

echo ""
echo "10. Kernel Message Check"
echo "-----------------------"

# Check for milestone messages in dmesg
echo "Checking for jester messages..."
if dmesg | tail -20 | grep -q "Jester"; then
    echo -e "${GREEN}[PASS]${NC} Jester messages found in kernel log"
    dmesg | tail -20 | grep "Jester" | head -3
else
    echo -e "${YELLOW}[INFO]${NC} No recent jester messages"
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "Typewriter module test complete. Log saved to: $LOG_FILE"
echo ""

# Show summary with jester
TOTAL_WORDS_FINAL=$(grep "Total Words:" "$MODULE_DIR/stats" | grep -o "[0-9]*" | tail -1 || echo "0")

if [ "$TOTAL_WORDS_FINAL" -gt "$WORDS_BEFORE" ]; then
    echo "     .~\"~.~\"~."
    echo "    /  ^   ^  \\    Excellent testing session!"
    echo "   |  >  ◡  <  |   You wrote $((TOTAL_WORDS_FINAL - WORDS_BEFORE)) words!"
    echo "    \\  ___  /      "
    echo "     |~|♦|~|       Keep up the good work!"
else
    echo "     .~\"~.~\"~."
    echo "    /  o   o  \\    Testing complete!"
    echo "   |  >  ◡  <  |   The typewriter module"
    echo "    \\  ___  /      stands ready!"
    echo "     |~|♦|~|       "
fi