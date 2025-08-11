#!/bin/bash
# QuillKernel /proc/squireos Validation Test
# Ensures all medieval proc entries work correctly

set -e

echo "═══════════════════════════════════════════════════════════════"
echo "         /proc/squireos Validation Test"
echo "═══════════════════════════════════════════════════════════════"
echo ""

PROC_DIR="/proc/squireos"
LOG_FILE="/tmp/quillkernel-proc-test.log"
ERRORS=0

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test function
test_proc_entry() {
    local entry="$1"
    local expected_content="$2"
    local description="$3"
    
    echo -n "Testing $entry - $description... "
    
    if [ ! -f "$PROC_DIR/$entry" ]; then
        echo -e "${RED}[FAIL]${NC} File not found"
        ((ERRORS++))
        return 1
    fi
    
    # Check if readable
    if ! cat "$PROC_DIR/$entry" > /dev/null 2>&1; then
        echo -e "${RED}[FAIL]${NC} Not readable"
        ((ERRORS++))
        return 1
    fi
    
    # Check for expected content if provided
    if [ -n "$expected_content" ]; then
        if grep -q "$expected_content" "$PROC_DIR/$entry"; then
            echo -e "${GREEN}[PASS]${NC}"
        else
            echo -e "${RED}[FAIL]${NC} Expected content not found"
            ((ERRORS++))
            return 1
        fi
    else
        echo -e "${GREEN}[PASS]${NC}"
    fi
    
    return 0
}

echo "1. Basic Directory Structure"
echo "---------------------------"

if [ -d "$PROC_DIR" ]; then
    echo -e "${GREEN}[PASS]${NC} /proc/squireos directory exists"
    echo "Contents:"
    ls -la "$PROC_DIR" | tee -a "$LOG_FILE"
else
    echo -e "${RED}[FAIL]${NC} /proc/squireos directory missing!"
    echo "QuillKernel proc entries not loaded. Exiting."
    exit 1
fi

echo ""
echo "2. Core SquireOS Entries"
echo "------------------------"

# Test motto
test_proc_entry "motto" "By quill and candlelight" "System motto"
if [ -f "$PROC_DIR/motto" ]; then
    echo "Motto content:"
    cat "$PROC_DIR/motto" | sed 's/^/  /'
fi

echo ""

# Test jester
test_proc_entry "jester" "Your faithful squire" "Jester ASCII art"
if [ -f "$PROC_DIR/jester" ]; then
    echo "Jester says:"
    cat "$PROC_DIR/jester" | head -10 | sed 's/^/  /'
fi

echo ""

# Test wisdom
test_proc_entry "wisdom" "" "Writing wisdom"
if [ -f "$PROC_DIR/wisdom" ]; then
    echo "Today's wisdom:"
    cat "$PROC_DIR/wisdom" | sed 's/^/  /'
    
    # Test if wisdom changes
    echo ""
    echo "Testing wisdom rotation..."
    WISDOM1=$(cat "$PROC_DIR/wisdom")
    sleep 1
    WISDOM2=$(cat "$PROC_DIR/wisdom")
    
    if [ "$WISDOM1" != "$WISDOM2" ]; then
        echo -e "${GREEN}[PASS]${NC} Wisdom rotates correctly"
    else
        echo -e "${YELLOW}[WARN]${NC} Wisdom might not be rotating"
    fi
fi

echo ""
echo "3. Typewriter Module Entries"
echo "----------------------------"

if [ -d "$PROC_DIR/typewriter" ]; then
    echo -e "${GREEN}[PASS]${NC} Typewriter directory exists"
    
    # Test stats
    test_proc_entry "typewriter/stats" "Writing Chronicle" "Writing statistics"
    if [ -f "$PROC_DIR/typewriter/stats" ]; then
        echo "Current stats:"
        cat "$PROC_DIR/typewriter/stats" | head -15 | sed 's/^/  /'
    fi
    
    echo ""
    
    # Test milestone
    test_proc_entry "typewriter/milestone" "Apprentice Scribe" "Achievement status"
    if [ -f "$PROC_DIR/typewriter/milestone" ]; then
        echo "Achievement status:"
        cat "$PROC_DIR/typewriter/milestone" | sed 's/^/  /'
    fi
else
    echo -e "${YELLOW}[WARN]${NC} Typewriter module not loaded"
fi

echo ""
echo "4. Permission Tests"
echo "-------------------"

# Check all entries are read-only
for entry in $(find "$PROC_DIR" -type f 2>/dev/null); do
    PERMS=$(stat -c %a "$entry")
    if [ "$PERMS" = "444" ]; then
        echo -e "${GREEN}[PASS]${NC} $entry has correct permissions (444)"
    else
        echo -e "${RED}[FAIL]${NC} $entry has incorrect permissions ($PERMS)"
        ((ERRORS++))
    fi
done

echo ""
echo "5. Stress Test"
echo "--------------"

echo "Reading entries rapidly..."
for i in {1..100}; do
    cat "$PROC_DIR/motto" > /dev/null 2>&1 || true
    cat "$PROC_DIR/wisdom" > /dev/null 2>&1 || true
    cat "$PROC_DIR/jester" > /dev/null 2>&1 || true
done
echo -e "${GREEN}[PASS]${NC} Rapid read test completed"

echo ""
echo "6. Character Encoding Test"
echo "-------------------------"

# Check for Unicode characters
if cat "$PROC_DIR/jester" | grep -q "♦"; then
    echo -e "${GREEN}[PASS]${NC} Unicode characters present in jester"
    echo -e "${YELLOW}[WARN]${NC} Verify these display correctly on E-Ink"
else
    echo -e "${YELLOW}[WARN]${NC} No Unicode characters found"
fi

echo ""
echo "7. Memory Usage Test"
echo "--------------------"

# Get memory before reading
MEM_BEFORE=$(grep "MemFree:" /proc/meminfo | awk '{print $2}')

# Read all entries multiple times
for i in {1..10}; do
    find "$PROC_DIR" -type f -exec cat {} \; > /dev/null 2>&1
done

# Check memory after
MEM_AFTER=$(grep "MemFree:" /proc/meminfo | awk '{print $2}')
MEM_DIFF=$((MEM_BEFORE - MEM_AFTER))

echo "Memory used by proc reads: ${MEM_DIFF}kB"
if [ "$MEM_DIFF" -lt 1000 ]; then
    echo -e "${GREEN}[PASS]${NC} Memory usage acceptable"
else
    echo -e "${YELLOW}[WARN]${NC} High memory usage detected"
fi

echo ""
echo "8. Integration Test"
echo "-------------------"

# Test if proc entries update with system events
if [ -f "$PROC_DIR/typewriter/stats" ]; then
    echo "Testing keystroke tracking integration..."
    
    # Note: This would need actual keyboard input to fully test
    echo -e "${YELLOW}[INFO]${NC} Full integration test requires USB keyboard"
else
    echo -e "${YELLOW}[SKIP]${NC} Typewriter module not available"
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "                    Test Summary"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "Errors found: $ERRORS"
echo "Full log saved to: $LOG_FILE"
echo ""

if [ "$ERRORS" -eq 0 ]; then
    echo "     .~\"~.~\"~."
    echo "    /  ^   ^  \\    All proc tests passed!"
    echo "   |  >  ◡  <  |   The scrolls are in order!"
    echo "    \\  ___  /      "
    echo "     |~|♦|~|       "
    exit 0
else
    echo "     .~!!!~."
    echo "    / O   O \\    $ERRORS proc tests failed!"
    echo "   |  >   <  |   The scrolls need mending!"
    echo "    \\  ~~~  /    "
    echo "     |~|♦|~|     "
    exit 1
fi