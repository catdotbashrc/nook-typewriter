#!/bin/bash
# button-handler.sh - Physical button event handler for JesterOS
# Layer 4: Hardware - Button input management
set -euo pipefail

# Input device paths (discovered via reverse engineering)
INPUT_GPIO="/dev/input/event0"     # Power & Home buttons (GPIO)
INPUT_TWL="/dev/input/event1"      # Page turn buttons (TWL4030)
INPUT_TOUCH="/dev/input/event2"    # Touch screen (for reference)

# Key codes from Linux input.h
KEY_POWER=116       # Power button
KEY_HOME=102        # Home/Menu button
KEY_PAGEUP=104      # Left page turn
KEY_PAGEDOWN=109    # Right page turn
KEY_BACK=158        # Back button (if available)

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

# Create directories
mkdir -p "$BUTTON_STATUS" "$(dirname "$BUTTON_LOG")"

# Logging function
log_button() {
    echo "[$(date '+%H:%M:%S')] $1" >> "$BUTTON_LOG"
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
        if [ -x "/runtime/1-ui/menu/power-menu.sh" ]; then
            /runtime/1-ui/menu/power-menu.sh &
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
        if [ -x "/runtime/1-ui/menu/nook-menu.sh" ]; then
            pkill -f "vim" 2>/dev/null || true  # Exit vim if running
            /runtime/1-ui/menu/nook-menu.sh &
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
                esac
                
                check_combinations
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
                esac
                
                check_combinations
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
        
        # Monitor GPIO buttons in background
        monitor_device "$INPUT_GPIO" "GPIO buttons" &
        GPIO_PID=$!
        
        # Monitor TWL4030 buttons
        monitor_device "$INPUT_TWL" "TWL4030 buttons" &
        TWL_PID=$!
        
        # Wait for both monitors
        wait $GPIO_PID $TWL_PID
        ;;
        
    test)
        init_button_status
        test_buttons
        ;;
        
    list)
        list_devices
        ;;
        
    status)
        echo "Button Status:"
        echo "Power: $(cat $BUTTON_STATUS/power 2>/dev/null || echo 'unknown')"
        echo "Home: $(cat $BUTTON_STATUS/home 2>/dev/null || echo 'unknown')"
        echo "Page Left: $(cat $BUTTON_STATUS/page_left 2>/dev/null || echo 'unknown')"
        echo "Page Right: $(cat $BUTTON_STATUS/page_right 2>/dev/null || echo 'unknown')"
        echo "Last Event: $(cat $BUTTON_STATUS/last_event 2>/dev/null || echo 'never')"
        echo "Last Action: $(cat $BUTTON_STATUS/last_action 2>/dev/null || echo 'none')"
        ;;
        
    help|*)
        cat <<EOF
JesterOS Button Handler

Usage: $0 [command]

Commands:
    monitor   - Start monitoring button events (default)
    test      - Interactive button test mode
    list      - List available input devices
    status    - Show current button status
    help      - Show this help

Button Functions:
    Power (short)    - Power menu
    Power (long)     - Sleep/wake toggle
    Home             - Return to main menu
    Page Left        - Previous page/screen
    Page Right       - Next page/screen
    
Combinations:
    Power + Home     - Screenshot
    Both Page Btns   - Toggle writing mode

Files:
    Status: $BUTTON_STATUS/
    Logs: $BUTTON_LOG

EOF
        ;;
esac