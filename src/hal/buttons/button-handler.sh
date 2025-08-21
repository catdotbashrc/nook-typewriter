#!/bin/bash
# button-handler.sh - Physical button event handler for JesterOS
# Layer 4: Hardware - Button input management
set -euo pipefail

# Input device paths (discovered via reverse engineering)
INPUT_GPIO="/dev/input/event0"     # Power & Home buttons (GPIO)
INPUT_TWL="/dev/input/event1"      # Page turn buttons (TWL4030)
INPUT_TOUCH="/dev/input/event2"    # Touch screen (for reference)

# USB keyboard support (managed by USB keyboard manager)
USB_KEYBOARD_STATUS="/var/jesteros/keyboard"
KEYBOARD_EVENT_DEVICE=""            # Dynamically detected from USB manager

# Key codes from Linux input.h
KEY_POWER=116       # Power button
KEY_HOME=102        # Home/Menu button
KEY_PAGEUP=104      # Left page turn
KEY_PAGEDOWN=109    # Right page turn
KEY_BACK=158        # Back button (if available)

# USB Keyboard key codes (common mappings for GK61)
KEY_ESC=1           # Escape key
KEY_TAB=15          # Tab key
KEY_ENTER=28        # Enter/Return
KEY_SPACE=57        # Space bar
KEY_LEFTCTRL=29     # Left Control
KEY_LEFTSHIFT=42    # Left Shift
KEY_LEFTALT=56      # Left Alt
KEY_BACKSPACE=14    # Backspace
KEY_DELETE=111      # Delete key
KEY_F1=59           # Function keys
KEY_F2=60
KEY_F3=61
KEY_F4=62
KEY_F5=63
KEY_F6=64
KEY_F7=65
KEY_F8=66
KEY_F9=67
KEY_F10=68

# Event types
EV_KEY=1            # Key/button event
EV_SYN=0            # Sync event

# Key states
KEY_RELEASE=0
KEY_PRESS=1
KEY_REPEAT=2

# JesterOS interface paths
BUTTON_STATUS="/var/jesteros/buttons"
BUTTON_LOG="/var/log/jesteros-buttons.log"

# Keyboard status files
KEYBOARD_LOG="/var/log/jesteros-keyboard.log"

# Create directories
mkdir -p "$BUTTON_STATUS" "$(dirname "$BUTTON_LOG")"

# Logging function
log_button() {
    echo "[$(date '+%H:%M:%S')] $1" >> "$BUTTON_LOG"
}

# Keyboard logging function
log_keyboard() {
    echo "[$(date '+%H:%M:%S')] $1" >> "$KEYBOARD_LOG"
}

# Initialize button status files
init_button_status() {
    echo "ready" > "$BUTTON_STATUS/power"
    echo "ready" > "$BUTTON_STATUS/home"
    echo "ready" > "$BUTTON_STATUS/page_left"
    echo "ready" > "$BUTTON_STATUS/page_right"
    echo "0" > "$BUTTON_STATUS/last_event"
    log_button "Button handler initialized"
}

# Check for USB keyboard availability
check_usb_keyboard() {
    if [ -f "$USB_KEYBOARD_STATUS/status" ]; then
        local kb_status=$(cat "$USB_KEYBOARD_STATUS/status" 2>/dev/null || echo "disconnected")
        if [ "$kb_status" = "connected" ]; then
            KEYBOARD_EVENT_DEVICE=$(cat "$USB_KEYBOARD_STATUS/event_device" 2>/dev/null || echo "none")
            if [ "$KEYBOARD_EVENT_DEVICE" != "none" ] && [ -c "$KEYBOARD_EVENT_DEVICE" ]; then
                log_keyboard "USB keyboard detected: $KEYBOARD_EVENT_DEVICE"
                return 0
            fi
        fi
    fi
    KEYBOARD_EVENT_DEVICE=""
    return 1
}

# Handle keyboard events (GK61-specific functionality)
handle_keyboard_event() {
    local keycode="$1"
    local state="$2"
    
    # Only process key press events (avoid repeats)
    if [ "$state" -ne "$KEY_PRESS" ]; then
        return
    fi
    
    log_keyboard "Keyboard event: keycode=$keycode state=$state"
    
    case "$keycode" in
        $KEY_ESC)
            # Escape - Return to main menu
            log_keyboard "ESC pressed - returning to menu"
            if [ -x "/src/services/menu/nook-menu.sh" ]; then
                pkill -f "vim" 2>/dev/null || true
                /src/services/menu/nook-menu.sh &
            fi
            ;;
            
        $KEY_F1)
            # F1 - Show jester mood
            log_keyboard "F1 pressed - show jester"
            if [ -f "/var/jesteros/jester" ]; then
                cat /var/jesteros/jester
            fi
            ;;
            
        $KEY_F2)
            # F2 - Show writing stats
            log_keyboard "F2 pressed - show stats"
            if [ -f "/var/jesteros/typewriter/stats" ]; then
                cat /var/jesteros/typewriter/stats
            fi
            ;;
            
        $KEY_F3)
            # F3 - Save current document
            log_keyboard "F3 pressed - save document"
            if pgrep -x vim > /dev/null; then
                # Send :w command to vim
                echo -e ":w\r" > /proc/$(pgrep -x vim)/fd/0 2>/dev/null || true
            fi
            ;;
            
        $KEY_F4)
            # F4 - Quick exit vim and save
            log_keyboard "F4 pressed - save and exit"
            if pgrep -x vim > /dev/null; then
                # Send :wq command to vim
                echo -e ":wq\r" > /proc/$(pgrep -x vim)/fd/0 2>/dev/null || true
            fi
            ;;
            
        $KEY_F5)
            # F5 - Refresh/reload current file
            log_keyboard "F5 pressed - refresh"
            if pgrep -x vim > /dev/null; then
                # Send :e command to vim
                echo -e ":e\r" > /proc/$(pgrep -x vim)/fd/0 2>/dev/null || true
            fi
            ;;
            
        $KEY_F10)
            # F10 - Toggle USB keyboard mode (return to ADB)
            log_keyboard "F10 pressed - toggle keyboard mode"
            if [ -x "/src/services/system/usb-keyboard-manager.sh" ]; then
                /src/services/system/usb-keyboard-manager.sh restore &
            fi
            ;;
            
        *)
            # Pass through all other keys (typing will work normally in vim)
            log_keyboard "Passthrough key: $keycode"
            ;;
    esac
}

# Handle power button events
handle_power_button() {
    local state="$1"
    
    if [ "$state" -eq "$KEY_PRESS" ]; then
        echo "pressed" > "$BUTTON_STATUS/power"
        log_button "Power button pressed"
        
        # Check for long press (sleep/wake toggle)
        (
            sleep 2
            if [ "$(cat $BUTTON_STATUS/power)" = "pressed" ]; then
                log_button "Power button long press - toggling sleep"
                # Trigger sleep/wake
                echo "mem" > /sys/power/state 2>/dev/null || true
            fi
        ) &
        
    elif [ "$state" -eq "$KEY_RELEASE" ]; then
        echo "released" > "$BUTTON_STATUS/power"
        log_button "Power button released"
        
        # Quick press - show power menu
        if [ -x "/src/services/menu/power-menu.sh" ]; then
            /src/services/menu/power-menu.sh &
        fi
    fi
}

# Handle home button events
handle_home_button() {
    local state="$1"
    
    if [ "$state" -eq "$KEY_PRESS" ]; then
        echo "pressed" > "$BUTTON_STATUS/home"
        log_button "Home button pressed"
        
        # Return to main menu
        if [ -x "/src/services/menu/nook-menu.sh" ]; then
            pkill -f "vim" 2>/dev/null || true  # Exit vim if running
            /src/services/menu/nook-menu.sh &
        fi
        
    elif [ "$state" -eq "$KEY_RELEASE" ]; then
        echo "released" > "$BUTTON_STATUS/home"
    fi
}

# Handle page turn buttons
handle_page_left() {
    local state="$1"
    
    if [ "$state" -eq "$KEY_PRESS" ]; then
        echo "pressed" > "$BUTTON_STATUS/page_left"
        log_button "Left page button pressed"
        
        # Send PageUp to active application
        if pgrep -x vim > /dev/null; then
            # Send Ctrl+B (page up in vim)
            echo -e "\x02" > /proc/$(pgrep -x vim)/fd/0 2>/dev/null || true
        else
            # Generic page up
            xdotool key Page_Up 2>/dev/null || true
        fi
        
    elif [ "$state" -eq "$KEY_RELEASE" ]; then
        echo "released" > "$BUTTON_STATUS/page_left"
    fi
}

handle_page_right() {
    local state="$1"
    
    if [ "$state" -eq "$KEY_PRESS" ]; then
        echo "pressed" > "$BUTTON_STATUS/page_right"
        log_button "Right page button pressed"
        
        # Send PageDown to active application
        if pgrep -x vim > /dev/null; then
            # Send Ctrl+F (page down in vim)
            echo -e "\x06" > /proc/$(pgrep -x vim)/fd/0 2>/dev/null || true
        else
            # Generic page down
            xdotool key Page_Down 2>/dev/null || true
        fi
        
    elif [ "$state" -eq "$KEY_RELEASE" ]; then
        echo "released" > "$BUTTON_STATUS/page_right"
    fi
}

# Check for button combinations
check_combinations() {
    local power=$(cat "$BUTTON_STATUS/power")
    local home=$(cat "$BUTTON_STATUS/home")
    local left=$(cat "$BUTTON_STATUS/page_left")
    local right=$(cat "$BUTTON_STATUS/page_right")
    
    # Power + Home = Screenshot
    if [ "$power" = "pressed" ] && [ "$home" = "pressed" ]; then
        log_button "Screenshot combination detected"
        fbgrab /sdcard/screenshot_$(date +%Y%m%d_%H%M%S).png 2>/dev/null || true
        echo "Screenshot saved" > "$BUTTON_STATUS/last_action"
    fi
    
    # Both page buttons = Toggle writing mode
    if [ "$left" = "pressed" ] && [ "$right" = "pressed" ]; then
        log_button "Writing mode toggle detected"
        if [ -f "$BUTTON_STATUS/writing_mode" ]; then
            rm "$BUTTON_STATUS/writing_mode"
            echo "Writing mode OFF" > "$BUTTON_STATUS/last_action"
        else
            touch "$BUTTON_STATUS/writing_mode"
            echo "Writing mode ON" > "$BUTTON_STATUS/last_action"
        fi
    fi
}

# Monitor input device for button events
monitor_device() {
    local device="$1"
    local device_name="$2"
    
    log_button "Monitoring $device_name on $device"
    
    # Use evtest or custom event reader
    if command -v evtest >/dev/null 2>&1; then
        evtest "$device" 2>/dev/null | while read -r line; do
            # Parse evtest output
            if echo "$line" | grep -q "EV_KEY"; then
                local keycode=$(echo "$line" | grep -oP 'KEY_\w+' | head -1)
                local value=$(echo "$line" | grep -oP 'value \K\d+' | head -1)
                
                case "$keycode" in
                    KEY_POWER)
                        handle_power_button "$value"
                        ;;
                    KEY_HOME)
                        handle_home_button "$value"
                        ;;
                    KEY_PAGEUP)
                        handle_page_left "$value"
                        ;;
                    KEY_PAGEDOWN)
                        handle_page_right "$value"
                        ;;
                    *)
                        # Check if this is from a USB keyboard
                        if [ -n "$KEYBOARD_EVENT_DEVICE" ] && [ "$device" = "$KEYBOARD_EVENT_DEVICE" ]; then
                            handle_keyboard_event "$((0x$code))" "$((0x$value))"
                        fi
                        ;;
                esac
                
                # Only check button combinations for physical buttons
                if [ "$device" != "$KEYBOARD_EVENT_DEVICE" ]; then
                    check_combinations
                fi
            fi
        done
    else
        # Fallback: Read raw events
        hexdump -e '8/2 "%04x " "\n"' "$device" 2>/dev/null | while read -r tv_sec_l tv_sec_h tv_usec_l tv_usec_h type code value pad; do
            if [ "$type" = "0001" ]; then  # EV_KEY
                case "$((0x$code))" in
                    $KEY_POWER)
                        handle_power_button "$((0x$value))"
                        ;;
                    $KEY_HOME)
                        handle_home_button "$((0x$value))"
                        ;;
                    $KEY_PAGEUP)
                        handle_page_left "$((0x$value))"
                        ;;
                    $KEY_PAGEDOWN)
                        handle_page_right "$((0x$value))"
                        ;;
                    *)
                        # Check if this is from a USB keyboard
                        if [ -n "$KEYBOARD_EVENT_DEVICE" ] && [ "$device" = "$KEYBOARD_EVENT_DEVICE" ]; then
                            handle_keyboard_event "$((0x$code))" "$((0x$value))"
                        fi
                        ;;
                esac
                
                # Only check button combinations for physical buttons
                if [ -z "$KEYBOARD_EVENT_DEVICE" ] || [ "$device" != "$KEYBOARD_EVENT_DEVICE" ]; then
                    check_combinations
                fi
                echo "$(date +%s)" > "$BUTTON_STATUS/last_event"
            fi
        done
    fi
}

# Test button functionality
test_buttons() {
    echo "═══════════════════════════════════════════════════════════════"
    echo "                    Button Test Mode"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    echo "Press each button to test. Press Ctrl+C to exit."
    echo ""
    
    # Monitor all button status files
    while true; do
        echo -en "\r"
        echo -n "Power: $(cat $BUTTON_STATUS/power 2>/dev/null || echo 'N/A') | "
        echo -n "Home: $(cat $BUTTON_STATUS/home 2>/dev/null || echo 'N/A') | "
        echo -n "Left: $(cat $BUTTON_STATUS/page_left 2>/dev/null || echo 'N/A') | "
        echo -n "Right: $(cat $BUTTON_STATUS/page_right 2>/dev/null || echo 'N/A')"
        sleep 0.1
    done
}

# List available input devices
list_devices() {
    echo "Available input devices:"
    echo "═══════════════════════════════════════════════════════════════"
    
    for device in /dev/input/event*; do
        if [ -e "$device" ]; then
            echo -n "$device: "
            cat "/sys/class/input/$(basename $device)/device/name" 2>/dev/null || echo "Unknown"
        fi
    done
    
    echo ""
    echo "GPIO information:"
    if [ -d /sys/class/gpio ]; then
        echo "Exported GPIOs:"
        ls /sys/class/gpio/ | grep -E "gpio[0-9]+"
    fi
}

# Main execution
case "${1:-monitor}" in
    monitor)
        init_button_status
        echo "Starting button event monitoring..."
        
        # Check for USB keyboard
        if check_usb_keyboard; then
            echo "USB keyboard detected: $KEYBOARD_EVENT_DEVICE"
            log_keyboard "Starting USB keyboard monitoring"
            
            # Monitor USB keyboard in background
            monitor_device "$KEYBOARD_EVENT_DEVICE" "USB keyboard" &
            KEYBOARD_PID=$!
        else
            echo "No USB keyboard detected"
            KEYBOARD_PID=""
        fi
        
        # Monitor GPIO buttons in background
        monitor_device "$INPUT_GPIO" "GPIO buttons" &
        GPIO_PID=$!
        
        # Monitor TWL4030 buttons
        monitor_device "$INPUT_TWL" "TWL4030 buttons" &
        TWL_PID=$!
        
        # Wait for all monitors
        if [ -n "$KEYBOARD_PID" ]; then
            wait $GPIO_PID $TWL_PID $KEYBOARD_PID
        else
            wait $GPIO_PID $TWL_PID
        fi
        ;;
        
    test)
        init_button_status
        test_buttons
        ;;
        
    list)
        list_devices
        ;;
        
    status)
        echo "═══════════════════════════════════════════════════════════════"
        echo "                    Input Device Status"
        echo "═══════════════════════════════════════════════════════════════"
        echo ""
        echo "Physical Buttons:"
        echo "  Power: $(cat $BUTTON_STATUS/power 2>/dev/null || echo 'unknown')"
        echo "  Home: $(cat $BUTTON_STATUS/home 2>/dev/null || echo 'unknown')"
        echo "  Page Left: $(cat $BUTTON_STATUS/page_left 2>/dev/null || echo 'unknown')"
        echo "  Page Right: $(cat $BUTTON_STATUS/page_right 2>/dev/null || echo 'unknown')"
        echo ""
        echo "USB Keyboard:"
        if check_usb_keyboard; then
            echo "  Status: Connected"
            echo "  Device: $KEYBOARD_EVENT_DEVICE"
            echo "  Name: $(cat $USB_KEYBOARD_STATUS/name 2>/dev/null || echo 'unknown')"
            echo "  ID: $(cat $USB_KEYBOARD_STATUS/vendor_product 2>/dev/null || echo 'unknown')"
        else
            echo "  Status: Disconnected"
        fi
        echo ""
        echo "Last Event: $(cat $BUTTON_STATUS/last_event 2>/dev/null || echo 'never')"
        echo "Last Action: $(cat $BUTTON_STATUS/last_action 2>/dev/null || echo 'none')"
        echo "═══════════════════════════════════════════════════════════════"
        ;;
        
    help|*)
        cat <<EOF
JesterOS Input Handler

Usage: $0 [command]

Commands:
    monitor   - Start monitoring input events (default)
    test      - Interactive button test mode
    list      - List available input devices
    status    - Show current input device status
    help      - Show this help

Physical Button Functions:
    Power (short)    - Power menu
    Power (long)     - Sleep/wake toggle
    Home             - Return to main menu
    Page Left        - Previous page/screen
    Page Right       - Next page/screen

USB Keyboard Functions (GK61):
    ESC              - Return to main menu
    F1               - Show jester mood
    F2               - Show writing statistics
    F3               - Save current document
    F4               - Save and exit vim
    F5               - Refresh/reload current file
    F10              - Toggle keyboard mode (return to ADB)
    
Button Combinations:
    Power + Home     - Screenshot
    Both Page Btns   - Toggle writing mode

USB Keyboard Setup:
    1. Connect OTG cable to Nook
    2. Connect powered USB hub to OTG cable
    3. Connect GK61 keyboard to USB hub
    4. Run: /src/services/system/usb-keyboard-manager.sh setup
    5. Start monitoring: $0 monitor

Files:
    Button Status: $BUTTON_STATUS/
    Button Logs: $BUTTON_LOG
    Keyboard Logs: $KEYBOARD_LOG

Note: USB keyboards are automatically detected when this handler starts.
Use the USB keyboard manager to switch between keyboard and ADB modes.

EOF
        ;;
esac