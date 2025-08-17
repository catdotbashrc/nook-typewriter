#!/bin/bash
# temperature-monitor.sh - Environmental temperature monitoring for JesterOS
# Layer 4: Hardware - Sensor monitoring for optimal writing conditions
set -euo pipefail

# Temperature sensor paths (discovered via reverse engineering)
EINK_TEMP="/sys/class/graphics/fb0/epd_temp"
BATTERY_TEMP="/sys/class/power_supply/battery/temp"
CPU_TEMP="/sys/class/thermal/thermal_zone0/temp"
TWL_TEMP="/sys/class/hwmon/hwmon0/temp1_input"  # TWL4030 if available

# JesterOS interface
SENSOR_STATUS="/var/jesteros/sensors"
SENSOR_LOG="/var/log/jesteros-sensors.log"

# Temperature thresholds (Celsius)
# E-Ink optimal operation range
EINK_MIN_TEMP=5      # Below this, refresh issues
EINK_OPTIMAL_LOW=15  # Ideal lower bound
EINK_OPTIMAL_HIGH=30 # Ideal upper bound  
EINK_MAX_TEMP=40     # Above this, display damage risk

# Battery safety thresholds
BATTERY_CHARGE_MIN=0    # Don't charge below this
BATTERY_CHARGE_MAX=45   # Stop charging above this
BATTERY_CRITICAL=50     # Shutdown threshold

# CPU thermal limits
CPU_THROTTLE=65000      # Start throttling (millidegrees)
CPU_CRITICAL=85000      # Emergency shutdown

# Create directories
mkdir -p "$SENSOR_STATUS" "$(dirname "$SENSOR_LOG")"

# Logging function
log_sensor() {
    echo "[$(date '+%H:%M:%S')] $1" >> "$SENSOR_LOG"
}

# Read E-Ink temperature
get_eink_temp() {
    if [ -f "$EINK_TEMP" ]; then
        cat "$EINK_TEMP" 2>/dev/null || echo "25"
    else
        # Fallback: estimate from battery temp
        local battery_temp=$(get_battery_temp)
        echo "$battery_temp"
    fi
}

# Read battery temperature
get_battery_temp() {
    if [ -f "$BATTERY_TEMP" ]; then
        local temp_raw=$(cat "$BATTERY_TEMP" 2>/dev/null || echo "250")
        # Convert from decidegrees to Celsius
        echo $((temp_raw / 10))
    else
        echo "25"  # Safe default
    fi
}

# Read CPU temperature
get_cpu_temp() {
    if [ -f "$CPU_TEMP" ]; then
        local temp_raw=$(cat "$CPU_TEMP" 2>/dev/null || echo "40000")
        # Convert from millidegrees to Celsius
        echo $((temp_raw / 1000))
    else
        echo "40"  # Safe default
    fi
}

# Check if temperature is safe for writing
check_writing_conditions() {
    local eink_temp=$(get_eink_temp)
    local battery_temp=$(get_battery_temp)
    local cpu_temp=$(get_cpu_temp)
    
    local status="optimal"
    local warnings=""
    
    # Check E-Ink temperature
    if [ "$eink_temp" -lt "$EINK_MIN_TEMP" ]; then
        status="cold"
        warnings="E-Ink too cold for reliable refresh"
        log_sensor "WARNING: E-Ink temperature ${eink_temp}°C below minimum"
    elif [ "$eink_temp" -gt "$EINK_MAX_TEMP" ]; then
        status="hot"
        warnings="E-Ink too hot - risk of damage"
        log_sensor "WARNING: E-Ink temperature ${eink_temp}°C above maximum"
    elif [ "$eink_temp" -lt "$EINK_OPTIMAL_LOW" ] || [ "$eink_temp" -gt "$EINK_OPTIMAL_HIGH" ]; then
        status="suboptimal"
        warnings="E-Ink temperature not ideal for best performance"
    fi
    
    # Check battery temperature
    if [ "$battery_temp" -gt "$BATTERY_CRITICAL" ]; then
        status="critical"
        warnings="Battery dangerously hot!"
        log_sensor "CRITICAL: Battery temperature ${battery_temp}°C"
    elif [ "$battery_temp" -gt "$BATTERY_CHARGE_MAX" ]; then
        # Disable charging if too hot
        echo 0 > /sys/class/power_supply/battery/charge_enabled 2>/dev/null || true
        warnings="$warnings | Charging disabled due to temperature"
    fi
    
    # Check CPU temperature
    if [ "$cpu_temp" -gt "$((CPU_CRITICAL / 1000))" ]; then
        status="critical"
        warnings="CPU overheating!"
        log_sensor "CRITICAL: CPU temperature ${cpu_temp}°C"
    elif [ "$cpu_temp" -gt "$((CPU_THROTTLE / 1000))" ]; then
        # Apply thermal throttling
        /runtime/4-hardware/power/power-optimizer.sh max-battery
        warnings="$warnings | CPU throttled for cooling"
    fi
    
    # Write status
    echo "$status" > "$SENSOR_STATUS/condition"
    echo "$warnings" > "$SENSOR_STATUS/warnings"
    
    echo "$status"
}

# Adjust E-Ink refresh rate based on temperature
adjust_eink_refresh() {
    local temp=$(get_eink_temp)
    local refresh_mode="normal"
    
    if [ "$temp" -lt 10 ]; then
        # Cold - use slower, stronger refresh
        refresh_mode="cold"
        echo 2 > /sys/class/graphics/fb0/epd_refresh_mode 2>/dev/null || true
        echo 500 > /sys/class/graphics/fb0/epd_refresh_delay 2>/dev/null || true
        log_sensor "E-Ink set to cold weather mode"
        
    elif [ "$temp" -gt 35 ]; then
        # Hot - use faster, gentler refresh
        refresh_mode="hot"
        echo 1 > /sys/class/graphics/fb0/epd_refresh_mode 2>/dev/null || true
        echo 100 > /sys/class/graphics/fb0/epd_refresh_delay 2>/dev/null || true
        log_sensor "E-Ink set to hot weather mode"
        
    else
        # Normal temperature range
        refresh_mode="normal"
        echo 0 > /sys/class/graphics/fb0/epd_refresh_mode 2>/dev/null || true
        echo 200 > /sys/class/graphics/fb0/epd_refresh_delay 2>/dev/null || true
    fi
    
    echo "$refresh_mode" > "$SENSOR_STATUS/eink_mode"
}

# Generate temperature report
generate_report() {
    local eink_temp=$(get_eink_temp)
    local battery_temp=$(get_battery_temp)
    local cpu_temp=$(get_cpu_temp)
    local condition=$(check_writing_conditions)
    
    cat > "$SENSOR_STATUS/report" <<EOF
═══════════════════════════════════════════════════════════════
                 Environmental Sensor Report
═══════════════════════════════════════════════════════════════

Temperature Readings:
  E-Ink Display:  ${eink_temp}°C $(get_eink_status $eink_temp)
  Battery:        ${battery_temp}°C $(get_battery_status $battery_temp)
  CPU:            ${cpu_temp}°C $(get_cpu_status $cpu_temp)

Writing Conditions: $(echo $condition | tr '[:lower:]' '[:upper:]')

E-Ink Performance:
  Optimal Range:  ${EINK_OPTIMAL_LOW}-${EINK_OPTIMAL_HIGH}°C
  Current Mode:   $(cat $SENSOR_STATUS/eink_mode 2>/dev/null || echo "normal")
  
Safety Status:
  Battery Charging: $(is_charging_safe && echo "Safe" || echo "Disabled")
  CPU Throttling:   $(is_throttled && echo "Active" || echo "Normal")
  
Recommendations:
$(get_recommendations $eink_temp $battery_temp $cpu_temp)

═══════════════════════════════════════════════════════════════
EOF
    
    cat "$SENSOR_STATUS/report"
}

# Helper functions for status descriptions
get_eink_status() {
    local temp=$1
    if [ "$temp" -lt "$EINK_MIN_TEMP" ]; then
        echo "❄️ Too Cold"
    elif [ "$temp" -lt "$EINK_OPTIMAL_LOW" ]; then
        echo "🌡️ Cool"
    elif [ "$temp" -le "$EINK_OPTIMAL_HIGH" ]; then
        echo "✅ Optimal"
    elif [ "$temp" -le "$EINK_MAX_TEMP" ]; then
        echo "🌡️ Warm"
    else
        echo "🔥 Too Hot"
    fi
}

get_battery_status() {
    local temp=$1
    if [ "$temp" -le "$BATTERY_CHARGE_MAX" ]; then
        echo "✅ Safe"
    elif [ "$temp" -le "$BATTERY_CRITICAL" ]; then
        echo "⚠️ Hot"
    else
        echo "🚨 Critical"
    fi
}

get_cpu_status() {
    local temp=$1
    if [ "$temp" -le 50 ]; then
        echo "✅ Cool"
    elif [ "$temp" -le 65 ]; then
        echo "🌡️ Normal"
    elif [ "$temp" -le 85 ]; then
        echo "⚠️ Hot"
    else
        echo "🚨 Critical"
    fi
}

is_charging_safe() {
    local battery_temp=$(get_battery_temp)
    [ "$battery_temp" -ge "$BATTERY_CHARGE_MIN" ] && [ "$battery_temp" -le "$BATTERY_CHARGE_MAX" ]
}

is_throttled() {
    local cpu_temp=$(get_cpu_temp)
    [ "$cpu_temp" -gt "$((CPU_THROTTLE / 1000))" ]
}

get_recommendations() {
    local eink=$1
    local battery=$2
    local cpu=$3
    local recs=""
    
    if [ "$eink" -lt "$EINK_OPTIMAL_LOW" ]; then
        recs="• Warm device to room temperature before extended writing"
    elif [ "$eink" -gt "$EINK_OPTIMAL_HIGH" ]; then
        recs="• Move to cooler location for optimal display performance"
    fi
    
    if [ "$battery" -gt "$BATTERY_CHARGE_MAX" ]; then
        recs="$recs\n• Let device cool before charging"
    fi
    
    if [ "$cpu" -gt "$((CPU_THROTTLE / 1000))" ]; then
        recs="$recs\n• Consider reducing workload or taking a break"
    fi
    
    [ -z "$recs" ] && recs="• Conditions optimal for writing!"
    echo -e "$recs"
}

# Update Jester mood based on temperature
update_jester_mood() {
    local condition="$1"
    
    case "$condition" in
        optimal)
            cat > "$SENSOR_STATUS/jester_mood" <<'EOF'
     .~"~.
    /  ^  \
   |  ◡  <|    "Perfect weather
    \ ___ /      for writing!"
     |♦|♦|
    /|   |\
EOF
            ;;
        cold)
            cat > "$SENSOR_STATUS/jester_mood" <<'EOF'
     .~"~.
    / ❄️ ❄️\
   | .-. <|    "Brrr! Let's warm
    \ --- /      up first!"
     |♦|♦|
    /|   |\
EOF
            ;;
        hot)
            cat > "$SENSOR_STATUS/jester_mood" <<'EOF'
     .~"~.
    / 🔥🔥\
   |  @@ <|    "Too hot! Find
    \ ___ /      some shade!"
     |♦|♦|
    /|   |\
EOF
            ;;
        critical)
            cat > "$SENSOR_STATUS/jester_mood" <<'EOF'
     .~"~.
    / !! \
   | O O |    "DANGER! Save
    \ --- /     work NOW!"
     |♦|♦|
    /|   |\
EOF
            ;;
        *)
            cat > "$SENSOR_STATUS/jester_mood" <<'EOF'
     .~"~.
    /  -  \
   |  ._. |    "Conditions
    \ --- /     could be better..."
     |♦|♦|
    /|   |\
EOF
            ;;
    esac
}

# Monitor loop
monitor_sensors() {
    log_sensor "Temperature monitoring started"
    
    while true; do
        # Read all temperatures
        local eink_temp=$(get_eink_temp)
        local battery_temp=$(get_battery_temp)
        local cpu_temp=$(get_cpu_temp)
        
        # Update status files
        echo "$eink_temp" > "$SENSOR_STATUS/eink_temp"
        echo "$battery_temp" > "$SENSOR_STATUS/battery_temp"
        echo "$cpu_temp" > "$SENSOR_STATUS/cpu_temp"
        
        # Check conditions
        local condition=$(check_writing_conditions)
        
        # Adjust E-Ink for temperature
        adjust_eink_refresh
        
        # Update Jester mood
        update_jester_mood "$condition"
        
        # Log if conditions change
        if [ -f "$SENSOR_STATUS/last_condition" ]; then
            local last=$(cat "$SENSOR_STATUS/last_condition")
            if [ "$condition" != "$last" ]; then
                log_sensor "Condition changed: $last -> $condition"
            fi
        fi
        echo "$condition" > "$SENSOR_STATUS/last_condition"
        
        # Sleep for 30 seconds
        sleep 30
    done
}

# Main execution
case "${1:-monitor}" in
    monitor)
        echo "Starting temperature monitoring..."
        monitor_sensors
        ;;
    status)
        generate_report
        ;;
    test)
        echo "Testing temperature sensors..."
        echo "E-Ink: $(get_eink_temp)°C"
        echo "Battery: $(get_battery_temp)°C"
        echo "CPU: $(get_cpu_temp)°C"
        echo "Condition: $(check_writing_conditions)"
        ;;
    adjust)
        adjust_eink_refresh
        echo "E-Ink refresh adjusted for temperature"
        ;;
    help|*)
        cat <<EOF
Temperature Monitor for JesterOS

Usage: $0 [command]

Commands:
    monitor   - Start continuous monitoring (default)
    status    - Show current temperature report
    test      - Test sensor readings
    adjust    - Adjust E-Ink for current temperature
    help      - Show this help

Temperature Ranges:
    E-Ink Optimal:    ${EINK_OPTIMAL_LOW}-${EINK_OPTIMAL_HIGH}°C
    Battery Safe:     0-${BATTERY_CHARGE_MAX}°C
    CPU Normal:       <${CPU_THROTTLE}°C

Files:
    Status: $SENSOR_STATUS/
    Logs: $SENSOR_LOG

EOF
        ;;
esac