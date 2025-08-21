#!/bin/bash
# power-menu.sh - Power management menu for JesterOS
# Layer 1: UI - Power settings interface
set -euo pipefail

# Source common functions
COMMON_PATH="${COMMON_PATH:-/src/services/system/common.sh}"
if [[ -f "$COMMON_PATH" ]]; then
    source "$COMMON_PATH"
fi

# Power management scripts
BATTERY_MONITOR="/src/hal/power/battery-monitor.sh"
POWER_OPTIMIZER="/src/hal/power/power-optimizer.sh"
POWER_STATUS="/var/jesteros/power"

# Display power menu header
display_power_header() {
    clear
    cat << 'EOF'
    ═══════════════════════════════════════════════════════════════
                      ⚡ Power Management ⚡
    ═══════════════════════════════════════════════════════════════
    
         .~"~.         "By candle's light,
        /  ⚡  \         or battery bright,
       |  ◡  <|         thy words take flight!"
        \ ___ /        
         |♦|♦|         - The Energy Jester
        /|   |\
    
    ═══════════════════════════════════════════════════════════════
EOF
}

# Get current battery info
get_battery_status() {
    local capacity=$(cat /sys/class/power_supply/battery/capacity 2>/dev/null || echo "?")
    local status=$(cat /sys/class/power_supply/battery/status 2>/dev/null || echo "Unknown")
    local voltage=$(cat /sys/class/power_supply/battery/voltage_now 2>/dev/null || echo "0")
    
    # Convert voltage to volts
    voltage_v=$(echo "scale=2; $voltage / 1000000" | bc 2>/dev/null || echo "?.?")
    
    echo "    Battery Level: ${capacity}% | Status: $status | Voltage: ${voltage_v}V"
}

# Get current power profile
get_power_profile() {
    local governor=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo "unknown")
    local freq=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq 2>/dev/null || echo "0")
    local freq_mhz=$(echo "scale=0; $freq / 1000" | bc 2>/dev/null || echo "?")
    
    # Determine profile from governor
    local profile="Unknown"
    case "$governor" in
        powersave)
            profile="Maximum Battery (15-18 hours)"
            ;;
        conservative)
            profile="Balanced (10-12 hours)"
            ;;
        ondemand|performance)
            profile="Performance (6-8 hours)"
            ;;
    esac
    
    echo "    Current Profile: $profile"
    echo "    CPU: ${freq_mhz}MHz ($governor governor)"
}

# Display main power menu
display_power_menu() {
    display_power_header
    
    echo ""
    get_battery_status
    echo ""
    get_power_profile
    echo ""
    
    # Show WiFi status
    if ifconfig wlan0 2>/dev/null | grep -q "UP"; then
        echo "    WiFi: Enabled (consuming power)"
    else
        echo "    WiFi: Disabled (saving power)"
    fi
    
    echo ""
    echo "    ═══════════════════════════════════════════════════════════════"
    echo ""
    echo "    === Power Profiles ==="
    echo ""
    echo "    [M] Maximum Battery Mode (15-18 hours)"
    echo "        300MHz CPU, WiFi Off, Aggressive PM"
    echo ""
    echo "    [B] Balanced Mode (10-12 hours)"
    echo "        600MHz CPU, WiFi Power Save, Standard PM"
    echo ""
    echo "    [P] Performance Mode (6-8 hours)"
    echo "        800MHz CPU, WiFi On, Minimal PM"
    echo ""
    echo "    [A] Auto Mode (Adjust by battery level)"
    echo ""
    echo "    === Controls ==="
    echo ""
    echo "    [W] Toggle WiFi"
    echo "    [S] Show Detailed Stats"
    echo "    [T] Test Battery Monitor"
    echo "    [R] Return to Main Menu"
    echo ""
    echo -n "    Choose: "
}

# Show detailed power statistics
show_detailed_stats() {
    clear
    echo "    ═══════════════════════════════════════════════════════════════"
    echo "                    Detailed Power Statistics"
    echo "    ═══════════════════════════════════════════════════════════════"
    echo ""
    
    # Battery details
    echo "    === Battery Information ==="
    for stat in capacity voltage_now current_now temp health status; do
        if [ -f "/sys/class/power_supply/battery/$stat" ]; then
            value=$(cat "/sys/class/power_supply/battery/$stat")
            printf "    %-15s: %s\n" "$stat" "$value"
        fi
    done
    
    echo ""
    echo "    === CPU Information ==="
    echo "    Governor: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null)"
    echo "    Current Freq: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq 2>/dev/null) Hz"
    echo "    Min Freq: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq 2>/dev/null) Hz"
    echo "    Max Freq: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq 2>/dev/null) Hz"
    
    echo ""
    echo "    === Power Consumption Estimate ==="
    local governor=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null)
    case "$governor" in
        powersave)
            echo "    CPU: ~50-100mW"
            echo "    System Total: ~80-130mW"
            echo "    Battery Life: 15-18 hours"
            ;;
        conservative)
            echo "    CPU: ~100-200mW"
            echo "    System Total: ~150-250mW"
            echo "    Battery Life: 10-12 hours"
            ;;
        ondemand|performance)
            echo "    CPU: ~200-400mW"
            echo "    System Total: ~250-450mW"
            echo "    Battery Life: 6-8 hours"
            ;;
    esac
    
    echo ""
    echo "    Press any key to return..."
    read -n 1
}

# Toggle WiFi
toggle_wifi() {
    echo ""
    if ifconfig wlan0 2>/dev/null | grep -q "UP"; then
        echo "    Disabling WiFi to save power..."
        ifconfig wlan0 down 2>/dev/null || true
        echo 1 > /sys/class/net/wlan0/device/rfkill/state 2>/dev/null || true
        echo "    WiFi disabled"
    else
        echo "    Enabling WiFi..."
        echo 0 > /sys/class/net/wlan0/device/rfkill/state 2>/dev/null || true
        ifconfig wlan0 up 2>/dev/null || true
        echo "    WiFi enabled"
    fi
    echo "    Press any key to continue..."
    read -n 1
}

# Test battery monitor
test_battery_monitor() {
    echo ""
    echo "    Testing battery monitor..."
    echo ""
    
    if [ -x "$BATTERY_MONITOR" ]; then
        $BATTERY_MONITOR test
    else
        echo "    Battery monitor not found at $BATTERY_MONITOR"
    fi
    
    echo ""
    echo "    Press any key to continue..."
    read -n 1
}

# Apply power profile
apply_profile() {
    local profile="$1"
    echo ""
    echo "    Applying $profile profile..."
    
    if [ -x "$POWER_OPTIMIZER" ]; then
        $POWER_OPTIMIZER "$profile"
        echo ""
        echo "    Profile applied successfully!"
    else
        echo "    Power optimizer not found at $POWER_OPTIMIZER"
    fi
    
    echo ""
    echo "    Press any key to continue..."
    read -n 1
}

# Main power menu loop
power_menu_loop() {
    while true; do
        display_power_menu
        read -r choice
        
        case "${choice,,}" in
            m)
                apply_profile "max-battery"
                ;;
            b)
                apply_profile "balanced"
                ;;
            p)
                apply_profile "performance"
                ;;
            a)
                apply_profile "auto"
                ;;
            w)
                toggle_wifi
                ;;
            s)
                show_detailed_stats
                ;;
            t)
                test_battery_monitor
                ;;
            r)
                return 0
                ;;
            *)
                ;;
        esac
    done
}

# Main entry point
if [ "${1:-}" = "standalone" ]; then
    # Running standalone
    power_menu_loop
else
    # Called from main menu - run once
    power_menu_loop
fi