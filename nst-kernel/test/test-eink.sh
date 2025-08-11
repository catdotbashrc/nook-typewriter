#!/bin/bash
# QuillKernel E-Ink Display Performance Test
# Tests E-Ink specific functionality and performance

set -e

echo "═══════════════════════════════════════════════════════════════"
echo "         QuillKernel E-Ink Performance Test"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "     .~\"~.~\"~."
echo "    /  o   o  \\    Testing thy E-Ink display..."
echo "   |  >  ◡  <  |   (6-inch 800x600 Pearl)"
echo "    \\  ___  /      "
echo "     |~|♦|~|       "
echo ""

LOG_FILE="/tmp/quillkernel-eink-test-$(date +%Y%m%d_%H%M%S).log"
FBINK_AVAILABLE=false
FB_DEVICE="/dev/fb0"

# Check if running on actual hardware
if [ -e "$FB_DEVICE" ]; then
    echo "E-Ink framebuffer detected at $FB_DEVICE" | tee -a "$LOG_FILE"
    HARDWARE=true
else
    echo "[INFO] No framebuffer device - running in simulation mode" | tee -a "$LOG_FILE"
    HARDWARE=false
fi

# Check for FBInk
if command -v fbink > /dev/null 2>&1; then
    echo "FBInk tool available" | tee -a "$LOG_FILE"
    FBINK_AVAILABLE=true
else
    echo "[INFO] FBInk not available - some tests will be skipped" | tee -a "$LOG_FILE"
fi

echo ""

# Test 1: Framebuffer Device Check
echo "Test 1: Framebuffer Device Configuration" | tee -a "$LOG_FILE"
echo "---------------------------------------" | tee -a "$LOG_FILE"

if [ "$HARDWARE" = true ]; then
    # Get framebuffer info
    if [ -f /sys/class/graphics/fb0/name ]; then
        FB_NAME=$(cat /sys/class/graphics/fb0/name)
        echo "Framebuffer driver: $FB_NAME" | tee -a "$LOG_FILE"
        
        # Check for OMAP3 E-Ink driver
        if echo "$FB_NAME" | grep -q "OMAP3EP"; then
            echo "[PASS] Correct E-Ink driver loaded" | tee -a "$LOG_FILE"
        else
            echo "[WARN] Unexpected framebuffer driver" | tee -a "$LOG_FILE"
        fi
    fi
    
    # Get resolution
    if [ -f /sys/class/graphics/fb0/virtual_size ]; then
        FB_SIZE=$(cat /sys/class/graphics/fb0/virtual_size)
        echo "Display resolution: $FB_SIZE" | tee -a "$LOG_FILE"
        
        # Verify Nook Touch resolution
        if [ "$FB_SIZE" = "800,600" ]; then
            echo "[PASS] Correct E-Ink resolution" | tee -a "$LOG_FILE"
        else
            echo "[WARN] Unexpected resolution" | tee -a "$LOG_FILE"
        fi
    fi
    
    # Check bits per pixel (should be 8 for grayscale)
    if [ -f /sys/class/graphics/fb0/bits_per_pixel ]; then
        BPP=$(cat /sys/class/graphics/fb0/bits_per_pixel)
        echo "Bits per pixel: $BPP" | tee -a "$LOG_FILE"
    fi
else
    echo "[SKIP] Hardware tests skipped" | tee -a "$LOG_FILE"
fi

echo ""

# Test 2: Medieval Boot Banner Rendering
echo "Test 2: Medieval Boot Banner Test" | tee -a "$LOG_FILE"
echo "--------------------------------" | tee -a "$LOG_FILE"

if [ "$FBINK_AVAILABLE" = true ] && [ "$HARDWARE" = true ]; then
    echo "Testing jester ASCII art rendering..." | tee -a "$LOG_FILE"
    
    # Clear screen first
    fbink -c 2>&1 | tee -a "$LOG_FILE" || echo "[WARN] Clear screen failed"
    
    # Measure banner display time
    START_TIME=$(date +%s.%N)
    
    # Display jester
    fbink -y 5 "     .~\"~.~\"~." 2>&1 | tee -a "$LOG_FILE" || true
    fbink -y 6 "    /  o   o  \\" 2>&1 | tee -a "$LOG_FILE" || true
    fbink -y 7 "   |  >  ◡  <  |" 2>&1 | tee -a "$LOG_FILE" || true
    fbink -y 8 "    \\  ___  /  " 2>&1 | tee -a "$LOG_FILE" || true
    fbink -y 9 "     |~|♦|~|   " 2>&1 | tee -a "$LOG_FILE" || true
    fbink -y 11 "QuillKernel Ready!" 2>&1 | tee -a "$LOG_FILE" || true
    
    END_TIME=$(date +%s.%N)
    RENDER_TIME=$(echo "$END_TIME - $START_TIME" | bc)
    
    echo "Banner render time: ${RENDER_TIME}s" | tee -a "$LOG_FILE"
    
    # Check for acceptable render time
    if (( $(echo "$RENDER_TIME < 1.0" | bc -l) )); then
        echo "[PASS] Fast banner rendering" | tee -a "$LOG_FILE"
    else
        echo "[WARN] Slow banner rendering" | tee -a "$LOG_FILE"
    fi
else
    echo "[SKIP] FBInk or hardware not available" | tee -a "$LOG_FILE"
fi

echo ""

# Test 3: Refresh Rate Testing
echo "Test 3: E-Ink Refresh Rate Test" | tee -a "$LOG_FILE"
echo "-------------------------------" | tee -a "$LOG_FILE"

if [ "$FBINK_AVAILABLE" = true ] && [ "$HARDWARE" = true ]; then
    echo "Testing refresh rates..." | tee -a "$LOG_FILE"
    
    # Full refresh test
    echo -n "Full refresh: " | tee -a "$LOG_FILE"
    START_TIME=$(date +%s.%N)
    fbink -c 2>&1 > /dev/null || true
    END_TIME=$(date +%s.%N)
    FULL_TIME=$(echo "$END_TIME - $START_TIME" | bc)
    echo "${FULL_TIME}s" | tee -a "$LOG_FILE"
    
    # Partial refresh test (text update)
    echo -n "Partial refresh: " | tee -a "$LOG_FILE"
    START_TIME=$(date +%s.%N)
    fbink -y 20 "Testing partial update..." 2>&1 > /dev/null || true
    END_TIME=$(date +%s.%N)
    PARTIAL_TIME=$(echo "$END_TIME - $START_TIME" | bc)
    echo "${PARTIAL_TIME}s" | tee -a "$LOG_FILE"
    
    # Fast mode test (if available)
    echo -n "Fast mode: " | tee -a "$LOG_FILE"
    START_TIME=$(date +%s.%N)
    fbink -F -y 21 "Fast mode test" 2>&1 > /dev/null || true
    END_TIME=$(date +%s.%N)
    FAST_TIME=$(echo "$END_TIME - $START_TIME" | bc)
    echo "${FAST_TIME}s" | tee -a "$LOG_FILE"
    
    # Validate refresh times
    if (( $(echo "$FULL_TIME < 1.0" | bc -l) )); then
        echo "[PASS] Acceptable full refresh time" | tee -a "$LOG_FILE"
    else
        echo "[WARN] Slow full refresh" | tee -a "$LOG_FILE"
    fi
else
    echo "[SKIP] Refresh rate test skipped" | tee -a "$LOG_FILE"
fi

echo ""

# Test 4: Unicode Character Support
echo "Test 4: Unicode Character Rendering" | tee -a "$LOG_FILE"
echo "----------------------------------" | tee -a "$LOG_FILE"

if [ "$FBINK_AVAILABLE" = true ] && [ "$HARDWARE" = true ]; then
    echo "Testing medieval Unicode characters..." | tee -a "$LOG_FILE"
    
    # Test various Unicode characters
    UNICODE_CHARS=("♦" "◡" "☞" "✎" "📜")
    RENDER_SUCCESS=0
    RENDER_FAIL=0
    
    for char in "${UNICODE_CHARS[@]}"; do
        echo -n "Testing '$char'... " | tee -a "$LOG_FILE"
        if fbink -y 25 "Unicode test: $char" 2>&1 | grep -q "error"; then
            echo "FAILED" | tee -a "$LOG_FILE"
            ((RENDER_FAIL++))
        else
            echo "OK" | tee -a "$LOG_FILE"
            ((RENDER_SUCCESS++))
        fi
    done
    
    echo "Unicode rendering: $RENDER_SUCCESS passed, $RENDER_FAIL failed" | tee -a "$LOG_FILE"
else
    echo "[SKIP] Unicode test skipped" | tee -a "$LOG_FILE"
fi

echo ""

# Test 5: Ghosting Detection
echo "Test 5: E-Ink Ghosting Test" | tee -a "$LOG_FILE"
echo "---------------------------" | tee -a "$LOG_FILE"

if [ "$FBINK_AVAILABLE" = true ] && [ "$HARDWARE" = true ]; then
    echo "Testing for ghosting artifacts..." | tee -a "$LOG_FILE"
    
    # Display pattern
    fbink -c 2>&1 > /dev/null || true
    fbink -y 10 "█████████████████████████" 2>&1 > /dev/null || true
    fbink -y 11 "█████████████████████████" 2>&1 > /dev/null || true
    fbink -y 12 "█████████████████████████" 2>&1 > /dev/null || true
    
    sleep 2
    
    # Clear without full refresh
    fbink -y 10 "                         " 2>&1 > /dev/null || true
    fbink -y 11 "                         " 2>&1 > /dev/null || true
    fbink -y 12 "                         " 2>&1 > /dev/null || true
    
    echo "[INFO] Visual inspection required for ghosting" | tee -a "$LOG_FILE"
    echo "If you see faint blocks, ghosting is present" | tee -a "$LOG_FILE"
    
    sleep 2
    
    # Full refresh to clear
    fbink -c 2>&1 > /dev/null || true
    echo "[INFO] Full refresh performed to clear ghosting" | tee -a "$LOG_FILE"
else
    echo "[SKIP] Ghosting test skipped" | tee -a "$LOG_FILE"
fi

echo ""

# Test 6: Power Consumption During Updates
echo "Test 6: E-Ink Power Consumption" | tee -a "$LOG_FILE"
echo "-------------------------------" | tee -a "$LOG_FILE"

if [ -f /sys/class/power_supply/bq27510-0/current_now ] && [ "$HARDWARE" = true ]; then
    echo "Measuring power during E-Ink operations..." | tee -a "$LOG_FILE"
    
    # Baseline power
    IDLE_CURRENT=$(cat /sys/class/power_supply/bq27510-0/current_now)
    echo "Idle current: ${IDLE_CURRENT}μA" | tee -a "$LOG_FILE"
    
    # Power during refresh
    fbink -c 2>&1 > /dev/null &
    sleep 0.1
    REFRESH_CURRENT=$(cat /sys/class/power_supply/bq27510-0/current_now)
    wait
    echo "Refresh current: ${REFRESH_CURRENT}μA" | tee -a "$LOG_FILE"
    
    # Power during text update
    fbink -y 15 "Power test..." 2>&1 > /dev/null &
    sleep 0.1
    UPDATE_CURRENT=$(cat /sys/class/power_supply/bq27510-0/current_now)
    wait
    echo "Update current: ${UPDATE_CURRENT}μA" | tee -a "$LOG_FILE"
    
    # Calculate differences
    REFRESH_DELTA=$((REFRESH_CURRENT - IDLE_CURRENT))
    UPDATE_DELTA=$((UPDATE_CURRENT - IDLE_CURRENT))
    
    echo "Refresh power delta: ${REFRESH_DELTA}μA" | tee -a "$LOG_FILE"
    echo "Update power delta: ${UPDATE_DELTA}μA" | tee -a "$LOG_FILE"
else
    echo "[SKIP] Power measurement not available" | tee -a "$LOG_FILE"
fi

echo ""

# Test 7: Writing Simulation
echo "Test 7: Typewriter Display Test" | tee -a "$LOG_FILE"
echo "-------------------------------" | tee -a "$LOG_FILE"

if [ "$FBINK_AVAILABLE" = true ] && [ "$HARDWARE" = true ]; then
    echo "Simulating typewriter display..." | tee -a "$LOG_FILE"
    
    # Clear screen
    fbink -c 2>&1 > /dev/null || true
    
    # Simulate typing
    TEXT="By quill and candlelight, the scribe works..."
    Y_POS=15
    
    for (( i=0; i<${#TEXT}; i++ )); do
        PARTIAL="${TEXT:0:i+1}"
        fbink -y $Y_POS "$PARTIAL" 2>&1 > /dev/null || true
        sleep 0.05  # 50ms between characters
    done
    
    echo "[PASS] Typewriter simulation completed" | tee -a "$LOG_FILE"
else
    echo "[SKIP] Typewriter test skipped" | tee -a "$LOG_FILE"
fi

echo ""

# Summary
echo "═══════════════════════════════════════════════════════════════"
echo "E-Ink test complete. Log saved to: $LOG_FILE"
echo ""

# Final assessment
if [ "$HARDWARE" = false ]; then
    echo "     .~\"~.~\"~."
    echo "    /  o   o  \\    Tests limited without"
    echo "   |  >  _  <  |   E-Ink hardware."
    echo "    \\  ___  /      Run on actual Nook!"
    echo "     |~|♦|~|       "
else
    WARNINGS=$(grep -c "WARN" "$LOG_FILE" || echo "0")
    FAILURES=$(grep -c "FAIL" "$LOG_FILE" || echo "0")
    
    if [ $FAILURES -gt 0 ]; then
        echo "     .~!!!~."
        echo "    / O   O \\    $FAILURES failures found!"
        echo "   |  >   <  |   E-Ink needs attention!"
        echo "    \\  ~~~  /    "
        echo "     |~|♦|~|     "
        exit 1
    elif [ $WARNINGS -gt 0 ]; then
        echo "     .~\"~.~\"~."
        echo "    /  o   o  \\    $WARNINGS warnings found."
        echo "   |  >  _  <  |   E-Ink could be better."
        echo "    \\  ___  /      "
        echo "     |~|♦|~|       "
        exit 0
    else
        echo "     .~\"~.~\"~."
        echo "    /  ^   ^  \\    Perfect!"
        echo "   |  >  ◡  <  |   E-Ink performs"
        echo "    \\  ___  /      beautifully!"
        echo "     |~|♦|~|       "
        exit 0
    fi
fi