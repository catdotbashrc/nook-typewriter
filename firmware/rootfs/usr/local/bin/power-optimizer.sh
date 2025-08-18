#!/bin/bash
# power-optimizer.sh - Power optimization for extended writing sessions
# Layer 4: Hardware - CPU and peripheral power management
set -euo pipefail

# Power management paths
CPU_PATH="/sys/devices/system/cpu/cpu0/cpufreq"
WIFI_PATH="/sys/class/net/wlan0"
BLOCK_PATH="/sys/block"
POWER_CTRL="/sys/power"
WAKE_LOCK="/sys/power/wake_lock"
WAKE_UNLOCK="/sys/power/wake_unlock"

# Power profiles
PROFILE_MAX_BATTERY="powersave"    # 15-18 hours
PROFILE_BALANCED="conservative"     # 10-12 hours  
PROFILE_PERFORMANCE="ondemand"      # 6-8 hours
PROFILE_PLUGGED="performance"       # When charging

# Frequency limits (OMAP3621: 300-800MHz)
FREQ_POWERSAVE=300000    # 300MHz
FREQ_BALANCED=600000     # 600MHz
FREQ_PERFORMANCE=800000  # 800MHz

# Log function
log_power() {
    echo "[$(date '+%H:%M:%S')] $1" >> /var/log/power-optimizer.log
}

# Check if we're charging
is_charging() {
    local status=$(cat /sys/class/power_supply/battery/status 2>/dev/null || echo "Unknown")
    [ "$status" = "Charging" ] || [ "$status" = "Full" ]
}

# Set CPU governor and frequency
set_cpu_profile() {
    local profile="$1"
    local max_freq="$2"
    
    # Set governor
    if [ -w "$CPU_PATH/scaling_governor" ]; then
        echo "$profile" > "$CPU_PATH/scaling_governor"
        log_power "CPU governor set to: $profile"
    fi
    
    # Set frequency limits
    if [ -w "$CPU_PATH/scaling_max_freq" ]; then
        echo "$max_freq" > "$CPU_PATH/scaling_max_freq"
        log_power "CPU max frequency: $max_freq Hz"
    fi
    
    # Set minimum frequency for power saving
    if [ -w "$CPU_PATH/scaling_min_freq" ]; then
        echo "$FREQ_POWERSAVE" > "$CPU_PATH/scaling_min_freq"
    fi
}

# Control WiFi power
set_wifi_power() {
    local mode="$1"  # on/off/powersave
    
    case "$mode" in
        off)
            # Disable WiFi completely
            if [ -d "$WIFI_PATH" ]; then
                ifconfig wlan0 down 2>/dev/null || true
                echo 1 > "$WIFI_PATH/device/rfkill/state" 2>/dev/null || true
                log_power "WiFi disabled for power saving"
            fi
            ;;
        powersave)
            # Enable WiFi power saving mode
            if [ -w "$WIFI_PATH/device/power/control" ]; then
                echo auto > "$WIFI_PATH/device/power/control"
                iwconfig wlan0 power on 2>/dev/null || true
                log_power "WiFi power saving enabled"
            fi
            ;;
        on)
            # Normal WiFi operation
            if [ -d "$WIFI_PATH" ]; then
                echo 0 > "$WIFI_PATH/device/rfkill/state" 2>/dev/null || true
                ifconfig wlan0 up 2>/dev/null || true
                log_power "WiFi enabled"
            fi
            ;;
    esac
}

# Optimize block device power
optimize_storage_power() {
    # Enable runtime PM for MMC/SD
    for device in mmcblk0 mmcblk1; do
        if [ -w "$BLOCK_PATH/$device/device/power/control" ]; then
            echo auto > "$BLOCK_PATH/$device/device/power/control"
            log_power "Runtime PM enabled for $device"
        fi
    done
    
    # Set I/O scheduler to noop for flash storage
    for device in mmcblk0 mmcblk1; do
        if [ -w "$BLOCK_PATH/$device/queue/scheduler" ]; then
            echo noop > "$BLOCK_PATH/$device/queue/scheduler" 2>/dev/null || true
            log_power "I/O scheduler set to noop for $device"
        fi
    done
    
    # Reduce writeback time for less disk activity
    echo 1500 > /proc/sys/vm/dirty_writeback_centisecs 2>/dev/null || true
}

# Configure wake locks for writing mode
configure_wake_locks() {
    local mode="$1"  # writing/reading/idle
    
    case "$mode" in
        writing)
            # Keep CPU awake but allow display to sleep
            echo "jesteros_writing" > "$WAKE_LOCK" 2>/dev/null || true
            log_power "Wake lock set for writing mode"
            ;;
        reading)
            # Allow aggressive sleep
            echo "jesteros_writing" > "$WAKE_UNLOCK" 2>/dev/null || true
            log_power "Wake lock released for reading mode"
            ;;
        idle)
            # Release all custom wake locks
            echo "jesteros_writing" > "$WAKE_UNLOCK" 2>/dev/null || true
            log_power "All wake locks released"
            ;;
    esac
}

# Apply power profile
apply_power_profile() {
    local profile="$1"
    
    echo "Applying power profile: $profile"
    
    case "$profile" in
        max-battery)
            # Maximum battery life (15-18 hours)
            set_cpu_profile "$PROFILE_MAX_BATTERY" "$FREQ_POWERSAVE"
            set_wifi_power "off"
            optimize_storage_power
            configure_wake_locks "idle"
            
            # Disable unnecessary services
            pkill -f "sync-notes" 2>/dev/null || true
            
            # Set aggressive power saving
            echo 1 > /sys/module/pm_debug/parameters/enable_off_mode 2>/dev/null || true
            echo 5 > /proc/sys/vm/laptop_mode 2>/dev/null || true
            
            log_power "Maximum battery profile applied"
            ;;
            
        balanced)
            # Balanced mode (10-12 hours)
            set_cpu_profile "$PROFILE_BALANCED" "$FREQ_BALANCED"
            set_wifi_power "powersave"
            optimize_storage_power
            configure_wake_locks "writing"
            
            # Moderate power saving
            echo 1 > /sys/module/pm_debug/parameters/enable_off_mode 2>/dev/null || true
            echo 2 > /proc/sys/vm/laptop_mode 2>/dev/null || true
            
            log_power "Balanced profile applied"
            ;;
            
        performance)
            # Performance mode (6-8 hours)
            set_cpu_profile "$PROFILE_PERFORMANCE" "$FREQ_PERFORMANCE"
            set_wifi_power "on"
            configure_wake_locks "writing"
            
            # Minimal power saving
            echo 0 > /sys/module/pm_debug/parameters/enable_off_mode 2>/dev/null || true
            echo 0 > /proc/sys/vm/laptop_mode 2>/dev/null || true
            
            log_power "Performance profile applied"
            ;;
            
        auto)
            # Auto-select based on battery and charging status
            if is_charging; then
                apply_power_profile "performance"
            else
                local battery=$(cat /sys/class/power_supply/battery/capacity 2>/dev/null || echo 50)
                if [ "$battery" -le 20 ]; then
                    apply_power_profile "max-battery"
                elif [ "$battery" -le 50 ]; then
                    apply_power_profile "balanced"
                else
                    apply_power_profile "performance"
                fi
            fi
            ;;
            
        *)
            echo "Unknown profile: $profile"
            echo "Available: max-battery, balanced, performance, auto"
            exit 1
            ;;
    esac
    
    # Update JesterOS power interface
    echo "$profile" > /var/jesteros/power/profile 2>/dev/null || true
}

# Get current power stats
show_power_stats() {
    echo "═══════════════════════════════════════════════════"
    echo "              Power Optimization Status"
    echo "═══════════════════════════════════════════════════"
    
    # CPU info
    echo "CPU Governor: $(cat $CPU_PATH/scaling_governor 2>/dev/null || echo 'unknown')"
    echo "CPU Frequency: $(cat $CPU_PATH/scaling_cur_freq 2>/dev/null || echo '0') Hz"
    echo "CPU Max Freq: $(cat $CPU_PATH/scaling_max_freq 2>/dev/null || echo '0') Hz"
    
    # Battery info
    echo ""
    echo "Battery: $(cat /sys/class/power_supply/battery/capacity 2>/dev/null || echo '?')%"
    echo "Status: $(cat /sys/class/power_supply/battery/status 2>/dev/null || echo 'unknown')"
    
    # WiFi status
    echo ""
    if ifconfig wlan0 2>/dev/null | grep -q "UP"; then
        echo "WiFi: Enabled"
    else
        echo "WiFi: Disabled (saving power)"
    fi
    
    # Estimate battery life
    echo ""
    local governor=$(cat $CPU_PATH/scaling_governor 2>/dev/null || echo 'unknown')
    case "$governor" in
        powersave)
            echo "Estimated battery life: 15-18 hours"
            ;;
        conservative)
            echo "Estimated battery life: 10-12 hours"
            ;;
        ondemand|performance)
            echo "Estimated battery life: 6-8 hours"
            ;;
        *)
            echo "Estimated battery life: Unknown"
            ;;
    esac
    
    echo "═══════════════════════════════════════════════════"
}

# Main execution
case "${1:-help}" in
    max-battery|balanced|performance|auto)
        apply_power_profile "$1"
        show_power_stats
        ;;
    status)
        show_power_stats
        ;;
    monitor)
        # Continuous monitoring mode
        while true; do
            apply_power_profile "auto"
            sleep 300  # Re-evaluate every 5 minutes
        done
        ;;
    test)
        echo "Testing power management interfaces..."
        echo "CPU governor: $(cat $CPU_PATH/scaling_governor 2>/dev/null || echo 'not accessible')"
        echo "Battery path: $(ls /sys/class/power_supply/battery/ 2>/dev/null | head -1 || echo 'not found')"
        echo "WiFi device: $(ls $WIFI_PATH 2>/dev/null | head -1 || echo 'not found')"
        ;;
    help|*)
        cat <<EOF
Power Optimizer for JesterOS Writing Mode

Usage: $0 [command]

Commands:
    max-battery   - Maximum battery life (15-18 hours)
                   300MHz CPU, WiFi off, aggressive PM
                   
    balanced      - Balanced mode (10-12 hours)
                   600MHz CPU, WiFi powersave, moderate PM
                   
    performance   - Performance mode (6-8 hours)
                   800MHz CPU, WiFi on, minimal PM
                   
    auto          - Auto-select based on battery level
    status        - Show current power configuration
    monitor       - Continuous auto-adjustment mode
    test          - Test power management interfaces
    help          - Show this help

Examples:
    $0 max-battery    # For long writing sessions
    $0 auto          # Let system decide
    $0 status        # Check current settings

EOF
        ;;
esac