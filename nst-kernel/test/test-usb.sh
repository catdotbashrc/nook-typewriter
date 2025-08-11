#!/bin/bash
# QuillKernel USB Testing Script
# Tests USB keyboard detection and medieval messages

set -e

echo "═══════════════════════════════════════════════════════════════"
echo "         QuillKernel USB Keyboard Test"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "This test requires a USB keyboard and OTG adapter"
echo ""

LOG_FILE="/tmp/quillkernel-usb-test.log"
DMESG_BEFORE="/tmp/dmesg-before-usb.log"
DMESG_AFTER="/tmp/dmesg-after-usb.log"

# Function to wait for user action
wait_for_user() {
    echo "$1"
    echo "Press Enter when ready..."
    read -r
}

echo "1. Initial USB State Check"
echo "--------------------------"

# Check USB subsystem
if lsusb > /dev/null 2>&1; then
    echo "[PASS] USB subsystem accessible"
    echo "Current USB devices:"
    lsusb | tee -a "$LOG_FILE"
else
    echo "[FAIL] Cannot access USB subsystem"
    exit 1
fi

# Check for USB HID support
if grep -q "CONFIG_USB_HID=y" /proc/config.gz 2>/dev/null || \
   zcat /proc/config.gz 2>/dev/null | grep -q "CONFIG_USB_HID=y"; then
    echo "[PASS] USB HID support compiled in kernel"
else
    echo "[WARN] Cannot verify USB HID support"
fi

echo ""
echo "2. USB Keyboard Connection Test"
echo "-------------------------------"

# Save current dmesg
dmesg > "$DMESG_BEFORE"

wait_for_user "Please disconnect any USB devices and press Enter"

# Get baseline USB device count
DEVICES_BEFORE=$(lsusb | wc -l)

wait_for_user "Now connect your USB keyboard via OTG adapter and press Enter"

# Get new device count
DEVICES_AFTER=$(lsusb | wc -l)

if [ "$DEVICES_AFTER" -gt "$DEVICES_BEFORE" ]; then
    echo "[PASS] USB device detected"
    
    # Show new device
    echo "New USB device:"
    lsusb | tail -1
else
    echo "[FAIL] No new USB device detected"
    echo "Check your OTG adapter and keyboard"
fi

# Capture new dmesg
sleep 2  # Give kernel time to print messages
dmesg > "$DMESG_AFTER"

echo ""
echo "3. Medieval Message Check"
echo "------------------------"

# Check for our custom USB messages
if diff "$DMESG_BEFORE" "$DMESG_AFTER" | grep -q "A new quill has been provided"; then
    echo "[PASS] Custom USB connection message found!"
    echo ""
    diff "$DMESG_BEFORE" "$DMESG_AFTER" | grep -A5 -B5 "quill" || true
else
    echo "[FAIL] Custom USB message not found"
    echo "Standard messages:"
    diff "$DMESG_BEFORE" "$DMESG_AFTER" | grep -i "usb" | head -10 || true
fi

echo ""
echo "4. Keyboard Functionality Test"
echo "------------------------------"

# Check if keyboard is recognized as input device
if ls /dev/input/by-id/*kbd* > /dev/null 2>&1; then
    echo "[PASS] Keyboard device node created"
    ls -la /dev/input/by-id/*kbd* | tee -a "$LOG_FILE"
else
    echo "[WARN] No keyboard device nodes found"
fi

# Test keyboard input
echo ""
echo "Keyboard input test:"
echo "Type 'squire' and press Enter to test keyboard:"
read -r TEST_INPUT

if [ "$TEST_INPUT" = "squire" ]; then
    echo "[PASS] Keyboard input working correctly!"
else
    echo "[FAIL] Keyboard input not working as expected"
    echo "You typed: '$TEST_INPUT'"
fi

echo ""
echo "5. USB Disconnection Test"
echo "-------------------------"

# Save current dmesg
dmesg > "$DMESG_BEFORE"

wait_for_user "Please disconnect the USB keyboard and press Enter"

# Capture new dmesg
sleep 2
dmesg > "$DMESG_AFTER"

# Check for disconnect message
if diff "$DMESG_BEFORE" "$DMESG_AFTER" | grep -q "The quill has been withdrawn"; then
    echo "[PASS] Custom USB disconnection message found!"
else
    echo "[FAIL] Custom USB disconnection message not found"
fi

echo ""
echo "6. Power Draw Test"
echo "------------------"

# Check battery status before and after USB
if [ -f /sys/class/power_supply/bq27510-0/current_now ]; then
    echo "Checking power consumption..."
    
    wait_for_user "Disconnect all USB devices for baseline reading"
    CURRENT_IDLE=$(cat /sys/class/power_supply/bq27510-0/current_now)
    echo "Idle current: ${CURRENT_IDLE}uA"
    
    wait_for_user "Connect USB keyboard"
    sleep 5
    CURRENT_USB=$(cat /sys/class/power_supply/bq27510-0/current_now)
    echo "With USB keyboard: ${CURRENT_USB}uA"
    
    INCREASE=$((CURRENT_USB - CURRENT_IDLE))
    echo "Power increase: ${INCREASE}uA"
    
    if [ "$INCREASE" -gt 100000 ]; then
        echo "[WARN] High power draw - may need powered hub"
    else
        echo "[PASS] Power draw acceptable"
    fi
else
    echo "[SKIP] Battery monitoring not available"
fi

echo ""
echo "7. Typewriter Integration Test"
echo "------------------------------"

if [ -f /proc/squireos/typewriter/stats ]; then
    echo "Checking if keystrokes are tracked..."
    
    # Get initial stats
    KEYS_BEFORE=$(grep "Keystrokes:" /proc/squireos/typewriter/stats | awk '{print $2}')
    
    echo "Type some text and press Enter:"
    read -r DUMMY_INPUT
    
    # Check new stats
    KEYS_AFTER=$(grep "Keystrokes:" /proc/squireos/typewriter/stats | awk '{print $2}')
    
    if [ "$KEYS_AFTER" -gt "$KEYS_BEFORE" ]; then
        echo "[PASS] Typewriter module tracking keystrokes!"
        echo "Keystrokes recorded: $((KEYS_AFTER - KEYS_BEFORE))"
    else
        echo "[FAIL] Typewriter module not tracking keystrokes"
    fi
else
    echo "[SKIP] Typewriter module not loaded"
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "USB test complete. Full log saved to: $LOG_FILE"
echo ""

# Final jester message
if grep -q "FAIL" "$LOG_FILE"; then
    echo "     .~???~."
    echo "    / o   o \\    Some USB tests failed!"
    echo "   |   >.<   |   Check connections and try again."
    echo "   |  ___    |   "
    echo "    \\ \\  / ? /   "
    echo "     |♦|♦|?      "
else
    echo "     .~\"~.~\"~."
    echo "    /  ^   ^  \\    USB tests successful!"
    echo "   |  >  ◡  <  |   Thy quill is ready!"
    echo "    \\  ___  /      "
    echo "     |~|♦|~|       "
fi