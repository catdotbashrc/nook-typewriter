#!/bin/bash
# JesterOS Health Monitor - Court Physician Service
# Monitors system health and provides alerts for critical conditions

# Safety settings
set -euo pipefail
trap 'echo "Error in health-check.sh at line $LINENO" >&2' ERR

# Source common functions
COMMON_PATH="${COMMON_PATH:-/src/services/system/common.sh}"
if [[ -f "$COMMON_PATH" ]]; then
    source "$COMMON_PATH"
else
    # Fallback safety settings
    set -euo pipefail
    trap 'echo "Error at line $LINENO"' ERR
fi

# Health monitoring constants
HEALTH_DIR="/var/jesteros/health"
STATUS_FILE="$HEALTH_DIR/status"
ALERT_FILE="$HEALTH_DIR/alerts"
PIDFILE="${PIDFILE:-/var/run/jesteros/health.pid}"

# Thresholds (can be overridden by config)
MEMORY_WARNING_THRESHOLD="${MEMORY_WARNING_THRESHOLD:-75}"
MEMORY_CRITICAL_THRESHOLD="${MEMORY_CRITICAL_THRESHOLD:-90}"
DISK_WARNING_THRESHOLD="${DISK_WARNING_THRESHOLD:-75}"
DISK_CRITICAL_THRESHOLD="${DISK_CRITICAL_THRESHOLD:-90}"
HEALTH_CHECK_INTERVAL="${HEALTH_CHECK_INTERVAL:-60}"

# Initialize health directories
init_health_dirs() {
    mkdir -p "$HEALTH_DIR"
    mkdir -p "$(dirname "$PIDFILE")"
}

# Get memory usage percentage
get_memory_usage() {
    # Get memory info from /proc/meminfo
    local mem_total=$(grep MemTotal /proc/meminfo | awk '{print $2}' 2>/dev/null || echo "0")
    local mem_available=$(grep MemAvailable /proc/meminfo 2>/dev/null | awk '{print $2}' || grep MemFree /proc/meminfo 2>/dev/null | awk '{print $2}' || echo "0")
    
    # Validate we have numeric values
    if [ -z "$mem_total" ] || [ -z "$mem_available" ]; then
        echo "0"
        return
    fi
    
    if [ "$mem_total" -gt 0 ] && [ "$mem_available" -le "$mem_total" ]; then
        local mem_used=$((mem_total - mem_available))
        echo $((mem_used * 100 / mem_total))
    else
        echo "0"
    fi
}

# Get disk usage percentage for root filesystem
get_disk_usage() {
    df / | awk 'NR==2 {print int($5)}' | sed 's/%//'
}

# Check system temperature (if available)
get_temperature() {
    # Check for OMAP3 temperature sensors
    if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
        local temp_millicelsius=$(cat /sys/class/thermal/thermal_zone0/temp)
        echo $((temp_millicelsius / 1000))
    else
        echo "N/A"
    fi
}

# Generate health status report
generate_health_status() {
    local mem_usage=$(get_memory_usage)
    local disk_usage=$(get_disk_usage)
    local temperature=$(get_temperature)
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Determine overall health status
    local health_status="HEALTHY"
    local alerts=""
    
    # Check memory
    if [ "$mem_usage" -ge "$MEMORY_CRITICAL_THRESHOLD" ]; then
        health_status="CRITICAL"
        alerts="$alerts\n⚠️ CRITICAL: Memory usage $mem_usage% (critical threshold: $MEMORY_CRITICAL_THRESHOLD%)"
    elif [ "$mem_usage" -ge "$MEMORY_WARNING_THRESHOLD" ]; then
        health_status="WARNING"
        alerts="$alerts\n⚠️ WARNING: Memory usage $mem_usage% (warning threshold: $MEMORY_WARNING_THRESHOLD%)"
    fi
    
    # Check disk space
    if [ "$disk_usage" -ge "$DISK_CRITICAL_THRESHOLD" ]; then
        health_status="CRITICAL"
        alerts="$alerts\n⚠️ CRITICAL: Disk usage $disk_usage% (critical threshold: $DISK_CRITICAL_THRESHOLD%)"
    elif [ "$disk_usage" -ge "$DISK_WARNING_THRESHOLD" ]; then
        health_status="WARNING"
        alerts="$alerts\n⚠️ WARNING: Disk usage $disk_usage% (warning threshold: $DISK_WARNING_THRESHOLD%)"
    fi
    
    # Generate status report
    cat > "$STATUS_FILE" << EOF
╔════════════════════════════════════╗
║        COURT PHYSICIAN REPORT      ║
╚════════════════════════════════════╝

🏥 System Vitals (Last Check: $timestamp):
   Overall Status:   $health_status
   Memory Usage:     $mem_usage% (Max: 256MB)
   Disk Usage:       $disk_usage% (Root filesystem)
   Temperature:      $temperature°C
   
📊 JesterOS Services:
   Jester Status:    $(test -f /var/jesteros/jester && echo "Active" || echo "Inactive")
   Tracker Status:   $(test -f /var/jesteros/typewriter/stats && echo "Active" || echo "Inactive")
   
⚡ Performance:
   Load Average:     $(cat /proc/loadavg | cut -d' ' -f1-3)
   Uptime:          $(uptime | awk -F',' '{print $1}' | sed 's/.*up //')

🎭 Court Physician's Wisdom:
   "A healthy system writes better stories!"
   "Memory management is like plot management - 
    both need careful attention to detail."

═══════════════════════════════════
Status: $health_status
═══════════════════════════════════
EOF
    
    # Save alerts if any
    if [ -n "$alerts" ]; then
        echo -e "$alerts" > "$ALERT_FILE"
        
        # Display alert on E-Ink if critical
        if [ "$health_status" = "CRITICAL" ]; then
            if command -v fbink >/dev/null 2>&1; then
                echo "SYSTEM ALERT: $health_status" | fbink -y 1 -
            fi
        fi
    else
        echo "No current alerts. System operating normally." > "$ALERT_FILE"
    fi
}

# Continuous health monitoring
monitor_health() {
    echo "Court Physician starting health monitoring..."
    
    while true; do
        generate_health_status
        sleep "$HEALTH_CHECK_INTERVAL"
    done
}

# Show boot greeting
show_health_greeting() {
    echo "🏥 The Court Physician awakens to tend the digital realm..."
    echo "   Monitoring system vitals for optimal writing conditions."
    sleep 2
}

# Main function
main() {
    init_health_dirs
    generate_health_status
    monitor_health
}

# Handle command line arguments for service manager compatibility  
case "${1:-start}" in
    start|--daemon)
        if [ "${1:-}" = "--daemon" ] || [ "${DAEMON_MODE:-}" = "1" ]; then
            # Run in foreground for service manager
            echo "Starting JesterOS Health Monitor (daemon mode)..."
            exec main
        else
            # Traditional background start
            show_health_greeting
            echo "Starting JesterOS Health Monitor..."
            main &
            echo $! > "$PIDFILE"
        fi
        ;;
    stop)
        if [ -f "$PIDFILE" ]; then
            pid=$(cat "$PIDFILE")
            if kill -0 "$pid" 2>/dev/null; then
                kill "$pid"
                rm -f "$PIDFILE"
                echo "Health Monitor stopped."
            else
                echo "Health Monitor not running (stale PID file)"
                rm -f "$PIDFILE"
            fi
        else
            echo "Health Monitor not running."
        fi
        ;;
    status)
        if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
            echo "Health Monitor is running (PID: $(cat "$PIDFILE"))"
            if [ -f "$STATUS_FILE" ]; then
                echo ""
                cat "$STATUS_FILE"
            fi
        else
            echo "Health Monitor is not running."
        fi
        ;;
    check)
        # One-time health check
        init_health_dirs
        generate_health_status
        cat "$STATUS_FILE"
        ;;
    *)
        echo "Usage: $0 {start|stop|status|check|--daemon}"
        exit 1
        ;;
esac