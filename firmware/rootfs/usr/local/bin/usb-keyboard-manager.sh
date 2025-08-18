#!/bin/bash
# usb-keyboard-manager.sh - USB OTG keyboard management for JesterOS
# Layer 3: System - USB mode switching and keyboard detection
set -euo pipefail

# USB OTG paths (MUSB controller)
USB_MODE_PATH="/sys/devices/platform/musb_hdrc/mode"
USB_VBUS_PATH="/sys/devices/platform/musb_hdrc/vbus"
USB_DEVICES_PATH="/sys/devices/platform/musb_hdrc/usb1"

# JesterOS status paths
USB_STATUS="/var/jesteros/usb"
KEYBOARD_STATUS="/var/jesteros/keyboard"
USB_LOG="/var/log/jesteros-usb.log"

# USB modes
MODE_DEVICE="b_idle"    # ADB/device mode (default)
MODE_HOST="host"        # USB host mode for keyboards
MODE_AUTO="otg"         # Auto-detect mode (if supported)

# Keyboard detection patterns
KEYBOARD_VENDORS="0416:1b96|1a2c:3013"  # Skyloong GK61 vendor:product IDs
KEYBOARD_NAMES="GK61|Skyloong"           # Device name patterns

# Create status directories
mkdir -p "$USB_STATUS" "$KEYBOARD_STATUS" "$(dirname "$USB_LOG")"

# Logging function with timestamp
log_usb() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$USB_LOG"
}

# Error handling with automatic recovery
error_handler() {
    local exit_code=$?
    local line_num=$1
    log_usb "ERROR: Line $line_num failed with exit code $exit_code"
    
    # Attempt safe recovery to device mode
    if [ -w "$USB_MODE_PATH" ]; then
        echo "$MODE_DEVICE" > "$USB_MODE_PATH" 2>/dev/null || true
        log_usb "Attempted recovery to device mode"
    fi
    
    exit $exit_code
}

trap 'error_handler $LINENO' ERR

# Initialize USB status
init_usb_status() {
    local current_mode
    current_mode=$(cat "$USB_MODE_PATH" 2>/dev/null || echo "unknown")
    
    echo "$current_mode" > "$USB_STATUS/mode"
    echo "disconnected" > "$KEYBOARD_STATUS/status"
    echo "none" > "$KEYBOARD_STATUS/device"
    echo "0" > "$KEYBOARD_STATUS/last_event"
    
    log_usb "USB keyboard manager initialized - current mode: $current_mode"
}

# Check if USB OTG is available and functional
check_usb_otg() {
    if [ ! -f "$USB_MODE_PATH" ]; then
        log_usb "ERROR: USB OTG not available - missing $USB_MODE_PATH"
        return 1
    fi
    
    if [ ! -w "$USB_MODE_PATH" ]; then
        log_usb "WARNING: USB OTG not writable - may need root permissions"
        return 1
    fi
    
    log_usb "USB OTG controller available and writable"
    return 0
}

# Get current USB mode
get_usb_mode() {
    cat "$USB_MODE_PATH" 2>/dev/null || echo "unknown"
}

# Switch USB to host mode for keyboards
switch_to_host_mode() {
    local current_mode
    current_mode=$(get_usb_mode)
    
    log_usb "Switching from $current_mode to host mode..."
    
    # Store original mode for recovery
    echo "$current_mode" > "$USB_STATUS/original_mode"
    
    # Switch to host mode
    echo "$MODE_HOST" > "$USB_MODE_PATH"
    
    # Wait for mode change to take effect
    sleep 2
    
    # Verify mode change
    local new_mode
    new_mode=$(get_usb_mode)
    if [ "$new_mode" = "$MODE_HOST" ]; then
        echo "$MODE_HOST" > "$USB_STATUS/mode"
        log_usb "Successfully switched to host mode"
        return 0
    else
        log_usb "ERROR: Mode switch failed - current mode: $new_mode"
        return 1
    fi
}

# Switch USB back to device mode (for ADB)
switch_to_device_mode() {
    local current_mode
    current_mode=$(get_usb_mode)
    
    log_usb "Switching from $current_mode to device mode..."
    
    # Switch to device mode
    echo "$MODE_DEVICE" > "$USB_MODE_PATH"
    
    # Wait for mode change
    sleep 2
    
    # Verify mode change
    local new_mode
    new_mode=$(get_usb_mode)
    if [ "$new_mode" = "$MODE_DEVICE" ]; then
        echo "$MODE_DEVICE" > "$USB_STATUS/mode"
        log_usb "Successfully switched to device mode"
        return 0
    else
        log_usb "ERROR: Mode switch failed - current mode: $new_mode"
        return 1
    fi
}

# Detect connected USB keyboards
detect_keyboards() {
    local keyboards_found=0
    
    # Check if USB host devices directory exists
    if [ ! -d "$USB_DEVICES_PATH" ]; then
        echo "disconnected" > "$KEYBOARD_STATUS/status"
        return 0
    fi
    
    # Scan for keyboard devices
    for device in "$USB_DEVICES_PATH"/*; do
        if [ -d "$device" ]; then
            # Check device descriptor files
            local vendor_id=""
            local product_id=""
            local product_name=""
            
            if [ -f "$device/idVendor" ]; then
                vendor_id=$(cat "$device/idVendor")
            fi
            
            if [ -f "$device/idProduct" ]; then
                product_id=$(cat "$device/idProduct")
            fi
            
            if [ -f "$device/product" ]; then
                product_name=$(cat "$device/product")
            fi
            
            # Check if this matches keyboard patterns
            local device_id="${vendor_id}:${product_id}"
            if echo "$device_id" | grep -qE "$KEYBOARD_VENDORS" || \
               echo "$product_name" | grep -qE "$KEYBOARD_NAMES"; then
                
                echo "connected" > "$KEYBOARD_STATUS/status"
                echo "$device_id" > "$KEYBOARD_STATUS/vendor_product"
                echo "$product_name" > "$KEYBOARD_STATUS/name"
                echo "$(basename "$device")" > "$KEYBOARD_STATUS/device"
                
                log_usb "Keyboard detected: $product_name ($device_id)"
                keyboards_found=1
                break
            fi
        fi
    done
    
    if [ $keyboards_found -eq 0 ]; then
        echo "disconnected" > "$KEYBOARD_STATUS/status"
        echo "none" > "$KEYBOARD_STATUS/device"
    fi
    
    return $keyboards_found
}

# Find keyboard input device (event file)
find_keyboard_event_device() {
    local keyboard_event=""
    
    # Look for new input devices that match HID keyboard pattern
    for event_device in /dev/input/event*; do
        if [ -c "$event_device" ]; then
            # Get device info from /proc/bus/input/devices
            local event_num
            event_num=$(basename "$event_device" | sed 's/event//')
            
            # Check if this is a keyboard device
            if grep -A 5 -B 5 "event$event_num" /proc/bus/input/devices 2>/dev/null | \
               grep -q "Handlers.*kbd"; then
                
                # Verify it's not one of our existing devices (event0, event1, event2)
                if [ "$event_num" -gt 2 ]; then
                    keyboard_event="$event_device"
                    echo "$keyboard_event" > "$KEYBOARD_STATUS/event_device"
                    log_usb "Keyboard input device: $keyboard_event"
                    break
                fi
            fi
        fi
    done
    
    if [ -n "$keyboard_event" ]; then
        return 0
    else
        echo "none" > "$KEYBOARD_STATUS/event_device"
        return 1
    fi
}

# Setup keyboard for writing (enable host mode and detect)
setup_keyboard() {
    log_usb "Setting up USB keyboard..."
    
    # Check OTG availability
    if ! check_usb_otg; then
        log_usb "ERROR: USB OTG not available"
        return 1
    fi
    
    # Switch to host mode
    if ! switch_to_host_mode; then
        log_usb "ERROR: Failed to switch to host mode"
        return 1
    fi
    
    # Wait for device enumeration
    log_usb "Waiting for keyboard detection..."
    sleep 3
    
    # Detect keyboards
    if detect_keyboards; then
        log_usb "Keyboard detection successful"
        
        # Find input event device
        if find_keyboard_event_device; then
            echo "$(date +%s)" > "$KEYBOARD_STATUS/last_event"
            log_usb "Keyboard setup complete - ready for input"
            return 0
        else
            log_usb "WARNING: Keyboard detected but no input device found"
            return 1
        fi
    else
        log_usb "WARNING: No keyboards detected"
        return 1
    fi
}

# Restore ADB connectivity (switch back to device mode)
restore_adb() {
    log_usb "Restoring ADB connectivity..."
    
    # Switch back to device mode
    if switch_to_device_mode; then
        echo "disconnected" > "$KEYBOARD_STATUS/status"
        echo "none" > "$KEYBOARD_STATUS/event_device"
        log_usb "ADB connectivity restored"
        return 0
    else
        log_usb "ERROR: Failed to restore device mode"
        return 1
    fi
}

# Monitor for keyboard connection/disconnection
monitor_keyboard() {
    log_usb "Starting keyboard monitoring..."
    
    while true; do
        local current_mode
        current_mode=$(get_usb_mode)
        
        if [ "$current_mode" = "$MODE_HOST" ]; then
            # Check if keyboard is still connected
            if ! detect_keyboards; then
                log_usb "Keyboard disconnected"
                echo "disconnected" > "$KEYBOARD_STATUS/status"
            fi
        fi
        
        sleep 5
    done
}

# Status reporting
show_status() {
    echo "═══════════════════════════════════════════════════════════════"
    echo "                   USB Keyboard Status"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    echo "USB Mode: $(cat "$USB_STATUS/mode" 2>/dev/null || echo 'unknown')"
    echo "Keyboard: $(cat "$KEYBOARD_STATUS/status" 2>/dev/null || echo 'unknown')"
    
    if [ "$(cat "$KEYBOARD_STATUS/status" 2>/dev/null)" = "connected" ]; then
        echo "Device: $(cat "$KEYBOARD_STATUS/name" 2>/dev/null || echo 'unknown')"
        echo "ID: $(cat "$KEYBOARD_STATUS/vendor_product" 2>/dev/null || echo 'unknown')"
        echo "Event: $(cat "$KEYBOARD_STATUS/event_device" 2>/dev/null || echo 'none')"
    fi
    
    echo ""
    echo "Last update: $(date)"
    echo "═══════════════════════════════════════════════════════════════"
}

# Test keyboard functionality
test_keyboard() {
    echo "═══════════════════════════════════════════════════════════════"
    echo "                   Keyboard Test Mode"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    
    local keyboard_device
    keyboard_device=$(cat "$KEYBOARD_STATUS/event_device" 2>/dev/null || echo "none")
    
    if [ "$keyboard_device" = "none" ] || [ ! -c "$keyboard_device" ]; then
        echo "ERROR: No keyboard device available for testing"
        echo "Run 'setup' command first to configure keyboard"
        return 1
    fi
    
    echo "Testing keyboard: $keyboard_device"
    echo "Type on your keyboard - events will be displayed below"
    echo "Press Ctrl+C to exit test mode"
    echo ""
    
    # Monitor keyboard events
    if command -v evtest >/dev/null 2>&1; then
        evtest "$keyboard_device"
    else
        # Fallback to hexdump
        hexdump -C "$keyboard_device"
    fi
}

# Main command handling
main() {
    case "${1:-status}" in
        setup|start)
            init_usb_status
            setup_keyboard
            ;;
            
        restore|adb)
            restore_adb
            ;;
            
        monitor)
            init_usb_status
            monitor_keyboard
            ;;
            
        detect)
            detect_keyboards
            find_keyboard_event_device
            ;;
            
        status)
            show_status
            ;;
            
        test)
            test_keyboard
            ;;
            
        host)
            switch_to_host_mode
            ;;
            
        device)
            switch_to_device_mode
            ;;
            
        check)
            check_usb_otg
            echo "USB OTG controller: $([ $? -eq 0 ] && echo 'Available' || echo 'Not available')"
            ;;
            
        help|*)
            cat <<EOF
JesterOS USB Keyboard Manager

Usage: $0 [command]

Commands:
    setup     - Setup USB keyboard (switch to host mode and detect)
    restore   - Restore ADB connectivity (switch to device mode)
    monitor   - Monitor keyboard connection status
    detect    - Detect connected keyboards and input devices
    status    - Show current keyboard and USB status
    test      - Test keyboard input (interactive mode)
    host      - Switch to USB host mode
    device    - Switch to USB device mode
    check     - Check USB OTG controller availability
    help      - Show this help

Hardware Setup:
    1. Connect: Nook → micro USB OTG cable → powered USB hub
    2. Connect: USB hub → USB-C cable → Skyloong GK61 keyboard
    3. Run: $0 setup
    4. Verify: $0 status

Files:
    Status: $USB_STATUS/ and $KEYBOARD_STATUS/
    Logs: $USB_LOG

Examples:
    $0 setup     # Enable keyboard mode
    $0 test      # Test keyboard input
    $0 restore   # Return to ADB mode
    $0 status    # Check current status

EOF
            ;;
    esac
}

# Execute main function with all arguments
main "$@"