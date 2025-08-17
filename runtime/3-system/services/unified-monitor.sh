#!/bin/bash
# unified-monitor.sh - Consolidated monitoring service for JesterOS
# Phase 2: Replaces separate monitor daemons with unified service
# Reduces memory usage and subprocess spawning

set -euo pipefail
trap 'echo "Error in unified-monitor.sh at line $LINENO"' ERR

# Source configuration
JESTEROS_CONFIG="${JESTEROS_CONFIG:-/runtime/config/jesteros.conf}"
[ -f "$JESTEROS_CONFIG" ] && source "$JESTEROS_CONFIG"

# Source consolidated functions
CONSOLIDATED_FUNCTIONS="${CONSOLIDATED_FUNCTIONS:-/runtime/3-system/common/consolidated-functions.sh}"
[ -f "$CONSOLIDATED_FUNCTIONS" ] && source "$CONSOLIDATED_FUNCTIONS"

# Source memory configuration
MEMORY_CONFIG="${MEMORY_CONFIG:-/runtime/config/memory.conf}"
[ -f "$MEMORY_CONFIG" ] && source "$MEMORY_CONFIG"

# =============================================================================
# UNIFIED MONITORING STATE
# =============================================================================

# PID and status files
PID_FILE="${JESTEROS_VAR}/unified-monitor.pid"
STATUS_FILE="${JESTEROS_VAR}/monitor-status"
LAST_CHECK_FILE="${JESTEROS_VAR}/last-check"

# Monitoring intervals (seconds)
MEMORY_INTERVAL=60
TEMP_INTERVAL=30
BATTERY_INTERVAL=120
JESTER_INTERVAL=30

# Last check timestamps
LAST_MEMORY_CHECK=0
LAST_TEMP_CHECK=0
LAST_BATTERY_CHECK=0
LAST_JESTER_CHECK=0

# Cache files
TEMP_CACHE="/tmp/jesteros_temp_cache"
BATTERY_CACHE="/tmp/jesteros_battery_cache"
MEMORY_CACHE="/tmp/jesteros_memory_cache"

# =============================================================================
# MONITORING FUNCTIONS
# =============================================================================

# Check memory status (from memory.conf)
check_memory() {
    local free_kb=$(get_free_memory)
    local status=$(check_memory_status)
    
    # Cache result
    cat > "$MEMORY_CACHE" << EOF
FREE_KB=$free_kb
STATUS=$status
TIMESTAMP=$(date +%s)
EOF
    
    # Take action if needed
    case "$status" in
        CRITICAL)
            log_sensor "CRITICAL: Memory at ${free_kb}KB" "CRITICAL"
            emergency_cleanup 3
            update_jester_mood "stressed"
            ;;
        WARNING)
            log_sensor "WARNING: Memory at ${free_kb}KB" "WARN"
            emergency_cleanup 2
            update_jester_mood "stressed"
            ;;
        LOW)
            log_sensor "LOW: Memory at ${free_kb}KB" "INFO"
            emergency_cleanup 1
            ;;
        OK)
            # All good
            ;;
    esac
    
    echo "$status"
}

# Check temperature (optimized from Phase 1)
check_temperature() {
    # Read all temps efficiently (cached)
    local eink_temp=20
    local battery_temp=25
    local cpu_temp=40
    
    if [ -f "/sys/class/hwmon/hwmon0/temp1_input" ]; then
        read -r temp_raw < /sys/class/hwmon/hwmon0/temp1_input
        eink_temp=$((temp_raw / 1000))
    fi
    
    if [ -f "/sys/class/power_supply/battery/temp" ]; then
        read -r temp_raw < /sys/class/power_supply/battery/temp
        battery_temp=$((temp_raw / 10))
    fi
    
    if [ -f "/sys/class/thermal/thermal_zone0/temp" ]; then
        read -r temp_raw < /sys/class/thermal/thermal_zone0/temp
        cpu_temp=$((temp_raw / 1000))
    fi
    
    # Cache results
    cat > "$TEMP_CACHE" << EOF
EINK_TEMP=$eink_temp
BATTERY_TEMP=$battery_temp
CPU_TEMP=$cpu_temp
TIMESTAMP=$(date +%s)
EOF
    
    # Determine status
    local status="optimal"
    
    if [ "$battery_temp" -gt "${BATTERY_CRITICAL:-50}" ]; then
        status="critical"
        log_sensor "CRITICAL: Battery temp ${battery_temp}°C" "CRITICAL"
        update_jester_mood "stressed"
    elif [ "$cpu_temp" -gt "${CPU_CRITICAL:-85}" ]; then
        status="critical"
        log_sensor "CRITICAL: CPU temp ${cpu_temp}°C" "CRITICAL"
        update_jester_mood "stressed"
    elif [ "$eink_temp" -lt "${EINK_MIN_TEMP:-5}" ] || [ "$eink_temp" -gt "${EINK_MAX_TEMP:-40}" ]; then
        status="suboptimal"
        update_jester_mood "uncomfortable"
    fi
    
    echo "$status"
}

# Check battery status
check_battery() {
    local capacity=50
    local status="Unknown"
    local voltage=0
    
    if [ -f "/sys/class/power_supply/battery/capacity" ]; then
        capacity=$(cat /sys/class/power_supply/battery/capacity)
    fi
    
    if [ -f "/sys/class/power_supply/battery/status" ]; then
        status=$(cat /sys/class/power_supply/battery/status)
    fi
    
    if [ -f "/sys/class/power_supply/battery/voltage_now" ]; then
        voltage=$(cat /sys/class/power_supply/battery/voltage_now)
    fi
    
    # Cache results
    cat > "$BATTERY_CACHE" << EOF
CAPACITY=$capacity
STATUS=$status
VOLTAGE=$voltage
TIMESTAMP=$(date +%s)
EOF
    
    # Check thresholds
    if [ "$capacity" -lt "${BATTERY_SHUTDOWN:-5}" ]; then
        log_sensor "CRITICAL: Battery at ${capacity}% - Shutdown imminent!" "CRITICAL"
        update_jester_mood "dying"
        echo "critical"
    elif [ "$capacity" -lt "${BATTERY_CRITICAL_PCT:-10}" ]; then
        log_sensor "CRITICAL: Battery at ${capacity}%" "CRITICAL"
        update_jester_mood "stressed"
        echo "critical"
    elif [ "$capacity" -lt "${BATTERY_LOW:-20}" ]; then
        log_sensor "WARNING: Battery at ${capacity}%" "WARN"
        update_jester_mood "tired"
        echo "low"
    else
        echo "ok"
    fi
}

# Update jester based on system state
update_jester_state() {
    # Check if writing is active
    local writing_active=false
    if pgrep -x vim >/dev/null 2>&1; then
        writing_active=true
        echo "active" > "${JESTEROS_VAR}/typewriter/status"
    else
        echo "idle" > "${JESTEROS_VAR}/typewriter/status"
    fi
    
    # Determine mood based on all factors
    local mood="happy"
    
    # Check cached states
    if [ -f "$MEMORY_CACHE" ]; then
        source "$MEMORY_CACHE"
        [ "$STATUS" = "CRITICAL" ] && mood="stressed"
        [ "$STATUS" = "WARNING" ] && mood="worried"
    fi
    
    if [ -f "$TEMP_CACHE" ]; then
        source "$TEMP_CACHE"
        [ "$CPU_TEMP" -gt 70 ] && mood="hot"
        [ "$BATTERY_TEMP" -gt 45 ] && mood="hot"
    fi
    
    if [ -f "$BATTERY_CACHE" ]; then
        source "$BATTERY_CACHE"
        [ "$CAPACITY" -lt 20 ] && mood="tired"
        [ "$CAPACITY" -lt 10 ] && mood="dying"
    fi
    
    [ "$writing_active" = true ] && mood="busy"
    
    update_jester_mood "$mood"
}

# =============================================================================
# MAIN MONITORING LOOP
# =============================================================================

monitor_loop() {
    log_sensor "Unified monitor starting" "INFO"
    
    # Initialize
    mkdir -p "${JESTEROS_VAR}" "${JESTEROS_VAR}/typewriter" 2>/dev/null || true
    echo $$ > "$PID_FILE"
    
    # Main loop
    while true; do
        local now=$(date +%s)
        local any_check=false
        
        # Memory check
        if [ $((now - LAST_MEMORY_CHECK)) -ge $MEMORY_INTERVAL ]; then
            check_memory > "${STATUS_FILE}.memory"
            LAST_MEMORY_CHECK=$now
            any_check=true
        fi
        
        # Temperature check
        if [ $((now - LAST_TEMP_CHECK)) -ge $TEMP_INTERVAL ]; then
            check_temperature > "${STATUS_FILE}.temp"
            LAST_TEMP_CHECK=$now
            any_check=true
        fi
        
        # Battery check
        if [ $((now - LAST_BATTERY_CHECK)) -ge $BATTERY_INTERVAL ]; then
            check_battery > "${STATUS_FILE}.battery"
            LAST_BATTERY_CHECK=$now
            any_check=true
        fi
        
        # Jester update
        if [ $((now - LAST_JESTER_CHECK)) -ge $JESTER_INTERVAL ]; then
            update_jester_state
            LAST_JESTER_CHECK=$now
            any_check=true
        fi
        
        # Update last check time
        if [ "$any_check" = true ]; then
            echo "$now" > "$LAST_CHECK_FILE"
        fi
        
        # Sleep until next check needed
        sleep 5
    done
}

# =============================================================================
# SERVICE MANAGEMENT
# =============================================================================

start_monitor() {
    if [ -f "$PID_FILE" ]; then
        local old_pid=$(cat "$PID_FILE" 2>/dev/null || echo "")
        if [ -n "$old_pid" ] && kill -0 "$old_pid" 2>/dev/null; then
            echo "Unified monitor already running (PID: $old_pid)"
            return 0
        fi
    fi
    
    echo "Starting JesterOS Unified Monitor..."
    monitor_loop &
    local monitor_pid=$!
    echo $monitor_pid > "$PID_FILE"
    
    sleep 1
    if kill -0 $monitor_pid 2>/dev/null; then
        echo "Unified monitor started (PID: $monitor_pid)"
        log_sensor "Unified monitor started" "INFO"
    else
        echo "Failed to start unified monitor"
        rm -f "$PID_FILE"
        return 1
    fi
}

stop_monitor() {
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE" 2>/dev/null || echo "")
        if [ -n "$pid" ]; then
            echo "Stopping unified monitor (PID: $pid)..."
            kill -TERM "$pid" 2>/dev/null || true
            sleep 1
            kill -KILL "$pid" 2>/dev/null || true
            rm -f "$PID_FILE"
            echo "Unified monitor stopped"
            log_sensor "Unified monitor stopped" "INFO"
        fi
    else
        echo "Unified monitor not running"
    fi
}

status_monitor() {
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE" 2>/dev/null || echo "")
        if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
            echo "Unified Monitor: RUNNING (PID: $pid)"
            echo ""
            echo "Component Status:"
            [ -f "${STATUS_FILE}.memory" ] && echo "  Memory:      $(cat ${STATUS_FILE}.memory)"
            [ -f "${STATUS_FILE}.temp" ] && echo "  Temperature: $(cat ${STATUS_FILE}.temp)"
            [ -f "${STATUS_FILE}.battery" ] && echo "  Battery:     $(cat ${STATUS_FILE}.battery)"
            echo ""
            echo "Last check: $(date -d @$(cat $LAST_CHECK_FILE 2>/dev/null || echo 0))"
        else
            echo "Unified Monitor: NOT RUNNING (stale PID)"
            rm -f "$PID_FILE"
        fi
    else
        echo "Unified Monitor: NOT RUNNING"
    fi
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

case "${1:-status}" in
    start)
        start_monitor
        ;;
    stop)
        stop_monitor
        ;;
    restart)
        stop_monitor
        sleep 1
        start_monitor
        ;;
    status)
        status_monitor
        ;;
    test)
        echo "Testing monitoring functions..."
        echo "Memory: $(check_memory)"
        echo "Temperature: $(check_temperature)"
        echo "Battery: $(check_battery)"
        echo "Test complete!"
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|test}"
        exit 1
        ;;
esac