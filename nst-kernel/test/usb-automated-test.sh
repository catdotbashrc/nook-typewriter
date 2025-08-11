#!/bin/bash
# QuillKernel USB Host Mode Automated Test
# Comprehensive USB keyboard testing for Nook Simple Touch

set -e

echo "═══════════════════════════════════════════════════════════════"
echo "         QuillKernel USB Automated Test"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "     .~\"~.~\"~."
echo "    /  o   o  \\    Testing USB host mode..."
echo "   |  >  ◡  <  |   (OTG + Keyboard support)"
echo "    \\  ___  /      "
echo "     |~|♦|~|       "
echo ""

LOG_FILE="/tmp/quillkernel-usb-test-$(date +%Y%m%d_%H%M%S).log"
ERRORS=0
WARNINGS=0

# Function to log with timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Function to check USB subsystem
check_usb_subsystem() {
    log "Checking USB subsystem..."
    
    # Check if USB core is loaded
    if [ -d /sys/bus/usb ]; then
        log "[PASS] USB subsystem present"
    else
        log "[FAIL] USB subsystem not found"
        ((ERRORS++))
        return 1
    fi
    
    # Check for MUSB controller (Nook uses MUSB)
    if ls /sys/bus/platform/drivers/musb* > /dev/null 2>&1; then
        log "[PASS] MUSB controller driver loaded"
    else
        log "[WARN] MUSB controller not found"
        ((WARNINGS++))
    fi
    
    # Check USB mode (should be host or OTG)
    if [ -f /sys/devices/platform/musb*/mode ]; then
        USB_MODE=$(cat /sys/devices/platform/musb*/mode 2>/dev/null || echo "unknown")
        log "USB mode: $USB_MODE"
        
        if [[ "$USB_MODE" == *"host"* ]] || [[ "$USB_MODE" == *"otg"* ]]; then
            log "[PASS] USB in correct mode"
        else
            log "[WARN] USB not in host/OTG mode"
            ((WARNINGS++))
        fi
    fi
    
    return 0
}

# Function to check power budget
check_usb_power() {
    log ""
    log "Checking USB power configuration..."
    
    # Check max power settings
    if [ -f /sys/bus/usb/devices/usb1/bMaxPower ]; then
        MAX_POWER=$(cat /sys/bus/usb/devices/usb1/bMaxPower 2>/dev/null || echo "0")
        log "USB max power: ${MAX_POWER}mA"
        
        # Nook provides limited power
        if [ "$MAX_POWER" -le 100 ]; then
            log "[PASS] Power budget appropriate for Nook"
        else
            log "[WARN] Power budget may be too high"
            ((WARNINGS++))
        fi
    fi
    
    # Check for overcurrent protection
    if ls /sys/bus/usb/devices/*/overcurrent 2>/dev/null; then
        log "[PASS] Overcurrent protection available"
    fi
}

# Function to detect keyboards
detect_keyboards() {
    log ""
    log "Detecting USB keyboards..."
    
    KEYBOARD_COUNT=0
    
    # Method 1: Check /dev/input/by-id/
    if [ -d /dev/input/by-id ]; then
        KEYBOARDS=$(ls /dev/input/by-id/*kbd* 2>/dev/null | wc -l)
        if [ "$KEYBOARDS" -gt 0 ]; then
            log "[PASS] Found $KEYBOARDS keyboard device(s) in /dev/input/by-id/"
            ls -la /dev/input/by-id/*kbd* 2>/dev/null | tee -a "$LOG_FILE"
            KEYBOARD_COUNT=$KEYBOARDS
        fi
    fi
    
    # Method 2: Check lsusb for HID devices
    if command -v lsusb > /dev/null 2>&1; then
        log ""
        log "USB devices detected:"
        lsusb | tee -a "$LOG_FILE"
        
        # Look for keyboard devices
        if lsusb | grep -i "keyboard\|HID" > /dev/null; then
            log "[PASS] HID device detected via lsusb"
            ((KEYBOARD_COUNT++))
        fi
    fi
    
    # Method 3: Check /proc/bus/input/devices
    if [ -f /proc/bus/input/devices ]; then
        if grep -i "keyboard" /proc/bus/input/devices > /dev/null; then
            log "[PASS] Keyboard found in /proc/bus/input/devices"
            grep -A5 -i "keyboard" /proc/bus/input/devices | head -20 | tee -a "$LOG_FILE"
        fi
    fi
    
    # Method 4: Check event devices
    for event in /dev/input/event*; do
        if [ -e "$event" ]; then
            # Try to get device info
            if timeout 1 evtest --query "$event" EV_KEY 2>/dev/null | grep -q "KEY_A"; then
                log "[PASS] Keyboard-capable device at $event"
                ((KEYBOARD_COUNT++))
            fi
        fi
    done
    
    if [ "$KEYBOARD_COUNT" -eq 0 ]; then
        log "[WARN] No USB keyboards detected"
        ((WARNINGS++))
        return 1
    fi
    
    return 0
}

# Function to test medieval USB messages
check_medieval_messages() {
    log ""
    log "Checking for QuillKernel USB messages..."
    
    # Check kernel log for custom messages
    DMESG_LINES=$(dmesg | tail -100)
    
    # Look for QuillKernel USB messages
    if echo "$DMESG_LINES" | grep -i "quill\|scribe\|squire" | grep -i "usb\|keyboard"; then
        log "[PASS] Found QuillKernel USB messages:"
        echo "$DMESG_LINES" | grep -i "quill\|scribe\|squire" | grep -i "usb\|keyboard" | tail -5 | tee -a "$LOG_FILE"
    else
        log "[INFO] No QuillKernel USB messages in recent dmesg"
    fi
    
    # Check for "new quill" message specifically
    if echo "$DMESG_LINES" | grep -i "new quill"; then
        log "[PASS] 'New quill' message found!"
    fi
}

# Function to measure keyboard latency
test_keyboard_latency() {
    log ""
    log "Testing keyboard input latency..."
    
    # Find first keyboard event device
    KEYBOARD_DEV=""
    for event in /dev/input/event*; do
        if [ -e "$event" ] && timeout 1 evtest --query "$event" EV_KEY 2>/dev/null | grep -q "KEY_A"; then
            KEYBOARD_DEV="$event"
            break
        fi
    done
    
    if [ -z "$KEYBOARD_DEV" ]; then
        log "[SKIP] No keyboard device found for latency test"
        return
    fi
    
    log "Using device: $KEYBOARD_DEV"
    
    # Monitor events for a short time
    log "Monitoring keyboard events for 5 seconds..."
    log "Press some keys to test latency..."
    
    timeout 5 evtest "$KEYBOARD_DEV" 2>&1 | grep -E "EV_KEY|time" | head -20 | tee -a "$LOG_FILE" || true
    
    log "[INFO] Manual verification needed for actual latency"
}

# Function to test USB power consumption
test_power_consumption() {
    log ""
    log "Testing USB power consumption..."
    
    # Check if power monitoring is available
    if [ -f /sys/class/power_supply/bq27510-0/current_now ]; then
        # Get baseline current
        CURRENT_BEFORE=$(cat /sys/class/power_supply/bq27510-0/current_now 2>/dev/null || echo "0")
        log "Current draw with USB: ${CURRENT_BEFORE}μA"
        
        # Calculate power
        if [ -f /sys/class/power_supply/bq27510-0/voltage_now ]; then
            VOLTAGE=$(cat /sys/class/power_supply/bq27510-0/voltage_now)
            POWER=$((CURRENT_BEFORE * VOLTAGE / 1000000))
            log "Power consumption: ${POWER}mW"
            
            # Check if within Nook limits
            if [ "$CURRENT_BEFORE" -lt 100000 ]; then  # 100mA
                log "[PASS] USB power within Nook limits"
            else
                log "[WARN] USB power may exceed Nook limits"
                ((WARNINGS++))
            fi
        fi
    else
        log "[SKIP] Power monitoring not available"
    fi
}

# Function to test disconnect/reconnect
test_hotplug() {
    log ""
    log "Testing USB hot-plug functionality..."
    
    # Monitor USB events
    log "Monitoring for USB events for 10 seconds..."
    log "Try disconnecting and reconnecting your keyboard..."
    
    # Start monitoring in background
    udevadm monitor --subsystem-match=usb --property 2>&1 | head -20 > /tmp/usb-events.log &
    MONITOR_PID=$!
    
    sleep 10
    
    # Stop monitoring
    kill $MONITOR_PID 2>/dev/null || true
    
    # Check for events
    if [ -s /tmp/usb-events.log ]; then
        log "[INFO] USB events detected:"
        cat /tmp/usb-events.log | grep -E "add|remove|bind|unbind" | tee -a "$LOG_FILE"
    else
        log "[INFO] No USB events captured"
    fi
    
    rm -f /tmp/usb-events.log
}

# Function to test typewriter integration
test_typewriter_integration() {
    log ""
    log "Testing typewriter module integration..."
    
    if [ -f /proc/squireos/typewriter/stats ]; then
        # Get initial keystroke count
        KEYS_BEFORE=$(grep "Keystrokes:" /proc/squireos/typewriter/stats | grep -o "[0-9]*" | head -1)
        log "Initial keystrokes: $KEYS_BEFORE"
        
        log "Type 'test' on USB keyboard and press Enter..."
        read -r USER_INPUT
        
        # Get new count
        KEYS_AFTER=$(grep "Keystrokes:" /proc/squireos/typewriter/stats | grep -o "[0-9]*" | head -1)
        log "Keystrokes after typing: $KEYS_AFTER"
        
        if [ "$KEYS_AFTER" -gt "$KEYS_BEFORE" ]; then
            log "[PASS] Typewriter tracking USB keyboard input"
        else
            log "[FAIL] Typewriter not tracking USB input"
            ((ERRORS++))
        fi
    else
        log "[SKIP] Typewriter module not loaded"
    fi
}

# Function to stress test USB
stress_test_usb() {
    log ""
    log "Running USB stress test..."
    
    # Find keyboard device
    KEYBOARD_DEV=""
    for event in /dev/input/event*; do
        if [ -e "$event" ] && timeout 1 evtest --query "$event" EV_KEY 2>/dev/null | grep -q "KEY_A"; then
            KEYBOARD_DEV="$event"
            break
        fi
    done
    
    if [ -z "$KEYBOARD_DEV" ]; then
        log "[SKIP] No keyboard for stress test"
        return
    fi
    
    log "Monitoring rapid input for 10 seconds..."
    log "Type as fast as possible!"
    
    # Count events
    EVENT_COUNT=$(timeout 10 evtest "$KEYBOARD_DEV" 2>&1 | grep -c "EV_KEY" || echo "0")
    
    log "Captured $EVENT_COUNT key events"
    
    if [ "$EVENT_COUNT" -gt 0 ]; then
        log "[PASS] USB handling rapid input"
    else
        log "[WARN] No events captured during stress test"
        ((WARNINGS++))
    fi
}

# Main test execution
log "Starting USB automated test at $(date)"
log "============================================"

# Run all tests
check_usb_subsystem
check_usb_power
detect_keyboards

if [ $? -eq 0 ]; then
    # Only run keyboard tests if one is detected
    check_medieval_messages
    test_keyboard_latency
    test_power_consumption
    test_hotplug
    test_typewriter_integration
    stress_test_usb
else
    log ""
    log "[INFO] Skipping keyboard-specific tests"
fi

# Summary
log ""
log "============================================"
log "USB Test Summary:"
log "  Errors: $ERRORS"
log "  Warnings: $WARNINGS"
log "============================================"

# Final assessment
echo ""
if [ "$ERRORS" -gt 0 ]; then
    echo "     .~!!!~."
    echo "    / O   O \\    $ERRORS errors found!"
    echo "   |  >   <  |   USB support needs fixing!"
    echo "    \\  ~~~  /    "
    echo "     |~|♦|~|     "
    exit 1
elif [ "$WARNINGS" -gt 2 ]; then
    echo "     .~\"~.~\"~."
    echo "    /  o   o  \\    Multiple warnings found."
    echo "   |  >  _  <  |   USB could work better."
    echo "    \\  ___  /      "
    echo "     |~|♦|~|       "
    exit 0
else
    echo "     .~\"~.~\"~."
    echo "    /  ^   ^  \\    USB tests passed!"
    echo "   |  >  ◡  <  |   Thy keyboard shall"
    echo "    \\  ___  /      work splendidly!"
    echo "     |~|♦|~|       "
    exit 0
fi