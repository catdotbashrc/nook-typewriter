#!/bin/bash
# battery-monitor.sh - Battery monitoring for JesterOS
# Layer 4: Hardware - Power management interface
set -euo pipefail

# Battery sysfs paths (TWL4030 PMIC + BQ27510)
BATTERY_PATH="/sys/class/power_supply/battery"
USB_PATH="/sys/class/power_supply/usb"
JESTER_POWER="/var/jesteros/power"

# Create JesterOS power interface
mkdir -p "$JESTER_POWER"

# Battery thresholds for writer alerts
CRITICAL_BATTERY=10  # Critical - save work immediately
LOW_BATTERY=20       # Low - gentle reminder
GOOD_BATTERY=50      # Good for extended writing

# Get battery status
get_battery_info() {
    local capacity voltage current temp health status
    
    # Read battery metrics
    [ -f "$BATTERY_PATH/capacity" ] && capacity=$(cat "$BATTERY_PATH/capacity") || capacity="unknown"
    [ -f "$BATTERY_PATH/voltage_now" ] && voltage=$(cat "$BATTERY_PATH/voltage_now") || voltage="0"
    [ -f "$BATTERY_PATH/current_now" ] && current=$(cat "$BATTERY_PATH/current_now") || current="0"
    [ -f "$BATTERY_PATH/temp" ] && temp=$(cat "$BATTERY_PATH/temp") || temp="0"
    [ -f "$BATTERY_PATH/health" ] && health=$(cat "$BATTERY_PATH/health") || health="unknown"
    [ -f "$BATTERY_PATH/status" ] && status=$(cat "$BATTERY_PATH/status") || status="unknown"
    
    # Convert units
    voltage_v=$(echo "scale=2; $voltage / 1000000" | bc 2>/dev/null || echo "0")
    current_ma=$(echo "scale=1; $current / 1000" | bc 2>/dev/null || echo "0")
    temp_c=$(echo "scale=1; $temp / 10" | bc 2>/dev/null || echo "0")
    
    # Write to JesterOS interface
    cat > "$JESTER_POWER/status" <<EOF
Battery: ${capacity}%
Voltage: ${voltage_v}V
Current: ${current_ma}mA
Temperature: ${temp_c}°C
Health: $health
Status: $status
EOF
    
    # Return capacity for scripts
    echo "$capacity"
}

# Calculate estimated writing time remaining
calculate_writing_time() {
    local capacity="$1"
    local current="$2"
    
    # Battery capacity: 1530mAh
    local battery_mah=1530
    
    # Calculate remaining mAh
    local remaining_mah=$(echo "scale=1; $battery_mah * $capacity / 100" | bc)
    
    # Estimate hours remaining (negative current = discharge)
    if [ "$current" -lt 0 ]; then
        current=${current#-}  # Remove negative sign
        local hours=$(echo "scale=1; $remaining_mah / $current" | bc 2>/dev/null || echo "0")
        echo "$hours"
    else
        echo "charging"
    fi
}

# Get power optimization mode
get_power_mode() {
    local governor=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo "unknown")
    local max_freq=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq 2>/dev/null || echo "0")
    
    # Determine mode based on settings
    if [ "$governor" = "powersave" ]; then
        echo "maximum_battery"
    elif [ "$governor" = "conservative" ] && [ "$max_freq" -le 600000 ]; then
        echo "balanced"
    elif [ "$governor" = "performance" ]; then
        echo "performance"
    else
        echo "standard"
    fi
}

# Generate battery warning for writers
generate_battery_warning() {
    local capacity="$1"
    local status="$2"
    
    if [ "$status" = "Charging" ]; then
        echo "⚡ Charging: ${capacity}% - Your words gain power!"
        return 0
    fi
    
    if [ "$capacity" -le "$CRITICAL_BATTERY" ]; then
        cat <<'EOF'
═══════════════════════════════════════════════════
⚠️  CRITICAL BATTERY - SAVE YOUR WORK NOW! ⚠️
═══════════════════════════════════════════════════
    The candle burns low, brave writer!
    Save thy manuscript before darkness falls!
    
    Battery: XXX%
    Time remaining: ~YYY minutes
    
    Press Ctrl+S in Vim to save immediately!
═══════════════════════════════════════════════════
EOF
    elif [ "$capacity" -le "$LOW_BATTERY" ]; then
        cat <<'EOF'
───────────────────────────────────────────────────
📝 Low Battery Notice
───────────────────────────────────────────────────
    "The quill grows heavy, the ink runs thin..."
    
    Battery: XXX%
    Consider saving your work soon.
    
    Tip: Use :w in Vim to save progress
───────────────────────────────────────────────────
EOF
    fi | sed "s/XXX/$capacity/g"
}

# Monitor battery and alert writer
monitor_battery() {
    local last_warning_level=100
    
    while true; do
        # Get current battery info
        local capacity=$(get_battery_info)
        local status=$(cat "$BATTERY_PATH/status" 2>/dev/null || echo "unknown")
        local current=$(cat "$BATTERY_PATH/current_now" 2>/dev/null || echo "0")
        
        # Calculate time remaining
        local time_remaining=$(calculate_writing_time "$capacity" "$current")
        
        # Update JesterOS interface
        echo "$capacity" > "$JESTER_POWER/level"
        echo "$time_remaining" > "$JESTER_POWER/time_remaining"
        echo "$(get_power_mode)" > "$JESTER_POWER/mode"
        
        # Generate warnings at thresholds
        if [ "$capacity" -le "$CRITICAL_BATTERY" ] && [ "$last_warning_level" -gt "$CRITICAL_BATTERY" ]; then
            generate_battery_warning "$capacity" "$status" > "$JESTER_POWER/warning"
            # Could trigger E-Ink alert here
            last_warning_level="$CRITICAL_BATTERY"
        elif [ "$capacity" -le "$LOW_BATTERY" ] && [ "$last_warning_level" -gt "$LOW_BATTERY" ]; then
            generate_battery_warning "$capacity" "$status" > "$JESTER_POWER/warning"
            last_warning_level="$LOW_BATTERY"
        elif [ "$capacity" -gt "$LOW_BATTERY" ]; then
            last_warning_level=100
            > "$JESTER_POWER/warning"  # Clear warning
        fi
        
        # Update Jester mood based on battery
        update_jester_mood "$capacity"
        
        # Sleep for 60 seconds between checks
        sleep 60
    done
}

# Update Jester mood based on battery level
update_jester_mood() {
    local capacity="$1"
    
    if [ "$capacity" -le "$CRITICAL_BATTERY" ]; then
        # Panicked Jester
        cat > "$JESTER_POWER/jester_mood" <<'EOF'
     .~"~.
    / o o \
   |  ___  |   "Save now!"
    \ --- /    "SAVE NOW!!"
     |♦|♦|
    /|   |\
EOF
    elif [ "$capacity" -le "$LOW_BATTERY" ]; then
        # Worried Jester
        cat > "$JESTER_POWER/jester_mood" <<'EOF'
     .~"~.
    /  -  \
   |  ._. |    "Perhaps a
    \ --- /     quick save?"
     |♦|♦|
    /|   |\
EOF
    else
        # Happy Jester
        cat > "$JESTER_POWER/jester_mood" <<'EOF'
     .~"~.
    /  ^  \
   |  ◡  <|    "Write on,
    \ ___ /     brave scribe!"
     |♦|♦|
    /|   |\
EOF
    fi
}

# Main execution
case "${1:-monitor}" in
    status)
        get_battery_info
        ;;
    mode)
        get_power_mode
        ;;
    monitor)
        echo "Starting battery monitor..."
        monitor_battery
        ;;
    test)
        echo "Testing battery interface..."
        get_battery_info
        echo "Power mode: $(get_power_mode)"
        ;;
    *)
        echo "Usage: $0 {status|mode|monitor|test}"
        exit 1
        ;;
esac