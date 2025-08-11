# Writing Tests for QuillKernel

This guide explains how to write new tests that fit with QuillKernel's medieval theme and testing philosophy.

## Test Writing Principles

### 1. Graceful Degradation
Tests should work everywhere:
```bash
# Good: Handle missing hardware
if [ -e /dev/fb0 ]; then
    echo "Testing E-Ink display..."
    # E-Ink tests
else
    echo "[SKIP] No E-Ink hardware detected"
fi

# Bad: Assume hardware exists
fbink -c  # Will fail in Docker!
```

### 2. Clear Status Messages
Use consistent status indicators:
```bash
echo "[PASS] Test succeeded"
echo "[FAIL] Test failed: reason"
echo "[WARN] Warning: explanation"
echo "[SKIP] Skipped: missing requirement"
echo "[INFO] Information message"
```

### 3. Medieval Theme Integration
Include the jester for personality:
```bash
# Success message
echo "     .~\"~.~\"~."
echo "    /  ^   ^  \\    Test passed!"
echo "   |  >  ◡  <  |   Well done!"
echo "    \\  ___  /      "
echo "     |~|♦|~|       "

# Failure message
echo "     .~!!!~."
echo "    / O   O \\    Test failed!"
echo "   |  >   <  |   Fix required!"
echo "    \\  ~~~  /    "
echo "     |~|♦|~|     "
```

## Test Structure Template

```bash
#!/bin/bash
# QuillKernel [Component] Test
# [Brief description]

set -e

echo "═══════════════════════════════════════════════════════════════"
echo "         QuillKernel [Component] Test"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "     .~\"~.~\"~."
echo "    /  o   o  \\    Testing thy [component]..."
echo "   |  >  ◡  <  |   "
echo "    \\  ___  /      "
echo "     |~|♦|~|       "
echo ""

LOG_FILE="/tmp/quillkernel-[component]-test-$(date +%Y%m%d_%H%M%S).log"
ERRORS=0
WARNINGS=0

# Test functions here...

# Summary
echo "═══════════════════════════════════════════════════════════════"
echo "Test complete. Log saved to: $LOG_FILE"

# Exit with appropriate code
if [ $ERRORS -gt 0 ]; then
    # Failure jester
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    # Warning jester
    exit 0
else
    # Success jester
    exit 0
fi
```

## Writing Specific Test Types

### Hardware Detection Tests
```bash
# Check for hardware presence
check_hardware() {
    if [ -e /sys/class/[hardware] ]; then
        echo "[PASS] Hardware detected"
        return 0
    else
        echo "[SKIP] Hardware not present"
        return 1
    fi
}

# Only run hardware tests if available
if check_hardware; then
    run_hardware_tests
else
    echo "[INFO] Skipping hardware-specific tests"
fi
```

### Performance Tests
```bash
# Measure operation time
measure_performance() {
    local operation=$1
    local threshold=$2
    
    START_TIME=$(date +%s.%N)
    $operation
    END_TIME=$(date +%s.%N)
    
    DURATION=$(echo "$END_TIME - $START_TIME" | bc)
    
    if (( $(echo "$DURATION < $threshold" | bc -l) )); then
        echo "[PASS] Operation completed in ${DURATION}s"
    else
        echo "[WARN] Operation slow: ${DURATION}s (threshold: ${threshold}s)"
    fi
}
```

### Memory Tests
```bash
# Check for memory leaks
check_memory_leak() {
    local operation=$1
    
    MEM_BEFORE=$(grep "MemFree:" /proc/meminfo | awk '{print $2}')
    
    # Run operation multiple times
    for i in {1..1000}; do
        $operation > /dev/null 2>&1
    done
    
    MEM_AFTER=$(grep "MemFree:" /proc/meminfo | awk '{print $2}')
    LEAK=$((MEM_BEFORE - MEM_AFTER))
    
    if [ $LEAK -lt 1000 ]; then  # Less than 1MB
        echo "[PASS] No significant memory leak"
    else
        echo "[FAIL] Possible memory leak: ${LEAK}kB"
    fi
}
```

### File System Tests
```bash
# Test proc file operations
test_proc_file() {
    local file=$1
    local expected=$2
    
    if [ ! -f "$file" ]; then
        echo "[FAIL] File not found: $file"
        return 1
    fi
    
    # Check permissions
    PERMS=$(stat -c %a "$file")
    if [ "$PERMS" != "444" ]; then
        echo "[WARN] Incorrect permissions: $PERMS (expected 444)"
    fi
    
    # Check content
    CONTENT=$(cat "$file")
    if [[ "$CONTENT" == *"$expected"* ]]; then
        echo "[PASS] Content verified"
    else
        echo "[FAIL] Expected content not found"
    fi
}
```

## Adding Tests to the Suite

### 1. Create Test Script
```bash
cd nst-kernel/test
vim test-newfeature.sh
chmod +x test-newfeature.sh
```

### 2. Update run-all-tests.sh
```bash
# Add to TESTS array
["test-newfeature"]="New Feature Test"

# Add to TEST_ORDER
TEST_ORDER=(...existing... "test-newfeature" ...)
```

### 3. Document the Test
Add entry to `docs/test-documentation.md`:
- Purpose
- Requirements
- What it tests
- Expected results
- Troubleshooting

## Test Best Practices

### DO:
- ✅ Log all operations with timestamps
- ✅ Provide clear error messages
- ✅ Handle missing dependencies gracefully
- ✅ Clean up temporary files
- ✅ Use meaningful exit codes
- ✅ Include medieval humor appropriately

### DON'T:
- ❌ Assume hardware is present
- ❌ Modify system configuration
- ❌ Leave processes running
- ❌ Use absolute paths without checking
- ❌ Ignore error conditions
- ❌ Make tests too long (>5 minutes)

## Example: Writing a New Module Test

Let's write a test for a hypothetical "scroll" module:

```bash
#!/bin/bash
# QuillKernel Scroll Module Test
# Tests the medieval scroll reading functionality

set -e

echo "═══════════════════════════════════════════════════════════════"
echo "         QuillKernel Scroll Module Test"
echo "═══════════════════════════════════════════════════════════════"
echo ""

LOG_FILE="/tmp/quillkernel-scroll-test-$(date +%Y%m%d_%H%M%S).log"
ERRORS=0

# Check if module is loaded
echo -n "Checking scroll module... "
if [ -d /proc/squireos/scrolls ]; then
    echo "[PASS]"
else
    echo "[SKIP] Module not loaded"
    exit 0
fi

# Test scroll reading
echo -n "Testing scroll access... "
if timeout 1 cat /proc/squireos/scrolls/wisdom > /dev/null 2>&1; then
    echo "[PASS]"
else
    echo "[FAIL]"
    ((ERRORS++))
fi

# Test scroll rotation
echo -n "Testing scroll rotation... "
SCROLL1=$(cat /proc/squireos/scrolls/current)
sleep 1
SCROLL2=$(cat /proc/squireos/scrolls/current)

if [ "$SCROLL1" != "$SCROLL2" ]; then
    echo "[PASS]"
else
    echo "[WARN] Scrolls not rotating"
fi

# Summary
echo ""
if [ $ERRORS -eq 0 ]; then
    echo "     .~\"~.~\"~."
    echo "    /  ^   ^  \\    Scroll tests passed!"
    echo "   |  >  ◡  <  |   Thy scrolls are ready!"
    echo "    \\  ___  /      "
    echo "     |~|♦|~|       "
    exit 0
else
    echo "     .~!!!~."
    echo "    / O   O \\    Scroll tests failed!"
    echo "   |  >   <  |   The scrolls are torn!"
    echo "    \\  ~~~  /    "
    echo "     |~|♦|~|     "
    exit 1
fi
```

## Testing Your Tests

Before adding a test to the suite:

1. **Run in Docker** (no hardware)
   ```bash
   docker run -it --rm -v $(pwd):/test ubuntu:20.04 /test/test-newfeature.sh
   ```

2. **Run on Nook** (with hardware)
   ```bash
   ./test-newfeature.sh
   ```

3. **Check output format**
   - Clear status messages
   - Proper skip handling
   - Meaningful error messages

4. **Verify logging**
   - Check log file creation
   - Ensure useful debugging info

5. **Test edge cases**
   - Missing files
   - Permission issues
   - Hardware failures

Remember: A good test helps developers fix problems quickly!