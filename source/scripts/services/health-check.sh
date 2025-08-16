#!/bin/bash
# Health Check Script for Nook Typewriter
# Provides system health monitoring and writing statistics

set -eu

# PID file location (can be overridden by service manager)
PIDFILE="${PIDFILE:-/var/run/jesteros/health.pid}"
HEALTH_DIR="/var/jesteros/health"

# Ensure directories exist
mkdir -p "$(dirname "$PIDFILE")"
mkdir -p "$HEALTH_DIR"

# Colors for terminal output (fallback if no E-Ink)
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to display on E-Ink or terminal
display_line() {
    local y_pos=$1
    local text=$2
    if command -v fbink >/dev/null 2>&1; then
        fbink -y "$y_pos" "$text" 2>/dev/null || echo "$text"
    else
        echo "$text"
    fi
}

# Function to format bytes to human readable
format_bytes() {
    local bytes=$1
    if [ $bytes -lt 1024 ]; then
        echo "${bytes}B"
    elif [ $bytes -lt 1048576 ]; then
        echo "$((bytes / 1024))KB"
    elif [ $bytes -lt 1073741824 ]; then
        echo "$((bytes / 1048576))MB"
    else
        echo "$((bytes / 1073741824))GB"
    fi
}

# Clear display
if command -v fbink >/dev/null 2>&1; then
    fbink -c 2>/dev/null || clear
else
    clear
fi

# Header
display_line 1 "═══════════════════════════════"
display_line 2 "   SYSTEM HEALTH CHECK"
display_line 3 "═══════════════════════════════"

# Memory Status
display_line 5 "MEMORY STATUS:"
if [ -f /proc/meminfo ]; then
    total_mem=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    free_mem=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
    used_mem=$((total_mem - free_mem))
    mem_percent=$((used_mem * 100 / total_mem))
    
    display_line 6 "  Total: $(format_bytes $((total_mem * 1024)))"
    display_line 7 "  Used:  $(format_bytes $((used_mem * 1024))) ($mem_percent%)"
    display_line 8 "  Free:  $(format_bytes $((free_mem * 1024)))"
    
    # Memory warning
    if [ $mem_percent -gt 90 ]; then
        display_line 9 "  ⚠ WARNING: Low memory!"
    elif [ $mem_percent -gt 75 ]; then
        display_line 9 "  ⚠ Memory usage high"
    else
        display_line 9 "  ✓ Memory healthy"
    fi
else
    display_line 6 "  Unable to read memory info"
fi

# Disk Status
display_line 11 "DISK STATUS:"
root_usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
root_free=$(df -h / | tail -1 | awk '{print $4}')
root_total=$(df -h / | tail -1 | awk '{print $2}')

display_line 12 "  Root: $root_usage% used"
display_line 13 "  Free: $root_free / $root_total"

if [ "$root_usage" -gt 90 ]; then
    display_line 14 "  ⚠ WARNING: Disk almost full!"
elif [ "$root_usage" -gt 75 ]; then
    display_line 14 "  ⚠ Disk usage high"
else
    display_line 14 "  ✓ Disk healthy"
fi

# CPU Status
display_line 16 "CPU STATUS:"
if [ -f /proc/loadavg ]; then
    load=$(cat /proc/loadavg | awk '{print $1}')
    display_line 17 "  Load: $load"
    
    # Check if load is high (>1.0 for single core)
    if (( $(echo "$load > 1.0" | bc -l 2>/dev/null || echo 0) )); then
        display_line 18 "  ⚠ High CPU load"
    else
        display_line 18 "  ✓ CPU healthy"
    fi
else
    display_line 17 "  Unable to read CPU info"
fi

# Uptime
display_line 20 "UPTIME:"
if command -v uptime >/dev/null 2>&1; then
    uptime_str=$(uptime -p 2>/dev/null || uptime | awk -F'up' '{print $2}' | awk -F',' '{print $1}')
    display_line 21 "  $uptime_str"
else
    display_line 21 "  Unknown"
fi

# Writing Statistics (if available)
if [ -f /var/jesteros/typewriter/stats ]; then
    display_line 23 "WRITING STATS:"
    words_today=$(grep "Words today:" /var/jesteros/typewriter/stats 2>/dev/null | awk '{print $3}' || echo "0")
    total_words=$(grep "Total words:" /var/jesteros/typewriter/stats 2>/dev/null | awk '{print $3}' || echo "0")
    display_line 24 "  Today: $words_today words"
    display_line 25 "  Total: $total_words words"
elif [ -d ~/notes ] || [ -d ~/writing ] || [ -d ~/drafts ]; then
    display_line 23 "WRITING FILES:"
    # Count markdown files
    md_count=$(find ~/notes ~/writing ~/drafts -name "*.md" 2>/dev/null | wc -l || echo 0)
    txt_count=$(find ~/notes ~/writing ~/drafts -name "*.txt" 2>/dev/null | wc -l || echo 0)
    display_line 24 "  Markdown: $md_count files"
    display_line 25 "  Text: $txt_count files"
fi

# Battery Status (if available)
if [ -f /sys/class/power_supply/battery/capacity ]; then
    display_line 27 "BATTERY:"
    battery=$(cat /sys/class/power_supply/battery/capacity)
    status=$(cat /sys/class/power_supply/battery/status 2>/dev/null || echo "Unknown")
    display_line 28 "  Level: $battery%"
    display_line 29 "  Status: $status"
fi

# Footer
display_line 31 "═══════════════════════════════"
display_line 32 "Press any key to continue..."

# Main health check function wrapper
health_check_main() {
    # Clear display
    if command -v fbink >/dev/null 2>&1; then
        fbink -c 2>/dev/null || clear
    else
        clear
    fi
    
    # Header
    display_line 1 "═══════════════════════════════════"
    display_line 2 "   SYSTEM HEALTH CHECK"
    display_line 3 "═══════════════════════════════"
    
    # Memory Status
    display_line 5 "MEMORY STATUS:"
    if [ -f /proc/meminfo ]; then
        total_mem=$(grep MemTotal /proc/meminfo | awk '{print $2}')
        free_mem=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
        used_mem=$((total_mem - free_mem))
        mem_percent=$((used_mem * 100 / total_mem))
        
        display_line 6 "  Total: $(format_bytes $((total_mem * 1024)))"
        display_line 7 "  Used:  $(format_bytes $((used_mem * 1024))) ($mem_percent%)"
        display_line 8 "  Free:  $(format_bytes $((free_mem * 1024)))"
        
        # Memory warning
        if [ $mem_percent -gt 90 ]; then
            display_line 9 "  ⚠ WARNING: Low memory!"
        elif [ $mem_percent -gt 75 ]; then
            display_line 9 "  ⚠ Memory usage high"
        else
            display_line 9 "  ✓ Memory healthy"
        fi
    else
        display_line 6 "  Unable to read memory info"
    fi
    
    # Disk Status
    display_line 11 "DISK STATUS:"
    root_usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    root_free=$(df -h / | tail -1 | awk '{print $4}')
    root_total=$(df -h / | tail -1 | awk '{print $2}')
    
    display_line 12 "  Root: $root_usage% used"
    display_line 13 "  Free: $root_free / $root_total"
    
    if [ "$root_usage" -gt 90 ]; then
        display_line 14 "  ⚠ WARNING: Disk almost full!"
    elif [ "$root_usage" -gt 75 ]; then
        display_line 14 "  ⚠ Disk usage high"
    else
        display_line 14 "  ✓ Disk healthy"
    fi
    
    # CPU Status
    display_line 16 "CPU STATUS:"
    if [ -f /proc/loadavg ]; then
        load=$(cat /proc/loadavg | awk '{print $1}')
        display_line 17 "  Load: $load"
        
        # Check if load is high (>1.0 for single core)
        if (( $(echo "$load > 1.0" | bc -l 2>/dev/null || echo 0) )); then
            display_line 18 "  ⚠ High CPU load"
        else
            display_line 18 "  ✓ CPU healthy"
        fi
    else
        display_line 17 "  Unable to read CPU info"
    fi
    
    # Uptime
    display_line 20 "UPTIME:"
    if command -v uptime >/dev/null 2>&1; then
        uptime_str=$(uptime -p 2>/dev/null || uptime | awk -F'up' '{print $2}' | awk -F',' '{print $1}')
        display_line 21 "  $uptime_str"
    else
        display_line 21 "  Unknown"
    fi
    
    # Writing Statistics (if available)
    if [ -f /var/jesteros/typewriter/stats ]; then
        display_line 23 "WRITING STATS:"
        words_today=$(grep "Words Written:" /var/jesteros/typewriter/stats 2>/dev/null | awk '{print $3}' || echo "0")
        display_line 24 "  Words: $words_today"
    elif [ -d ~/notes ] || [ -d ~/writing ] || [ -d ~/drafts ]; then
        display_line 23 "WRITING FILES:"
        # Count markdown files
        md_count=$(find ~/notes ~/writing ~/drafts -name "*.md" 2>/dev/null | wc -l || echo 0)
        txt_count=$(find ~/notes ~/writing ~/drafts -name "*.txt" 2>/dev/null | wc -l || echo 0)
        display_line 24 "  Markdown: $md_count files"
        display_line 25 "  Text: $txt_count files"
    fi
    
    # Battery Status (if available)
    if [ -f /sys/class/power_supply/battery/capacity ]; then
        display_line 27 "BATTERY:"
        battery=$(cat /sys/class/power_supply/battery/capacity)
        status=$(cat /sys/class/power_supply/battery/status 2>/dev/null || echo "Unknown")
        display_line 28 "  Level: $battery%"
        display_line 29 "  Status: $status"
    fi
    
    # Footer
    display_line 31 "═══════════════════════════════════"
    display_line 32 "Press any key to continue..."
    
    # Wait for input if interactive
    if [ -t 0 ]; then
        read -n 1 -s
    fi
    
    # Save status
    save_health_status
}

# Save health status to file
save_health_status() {
    local status_file="$HEALTH_DIR/status"
    
    {
        echo "TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')"
        
        # Memory check
        if [ -f /proc/meminfo ]; then
            total_mem=$(grep MemTotal /proc/meminfo | awk '{print $2}')
            free_mem=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
            used_mem=$((total_mem - free_mem))
            mem_percent=$((used_mem * 100 / total_mem))
            echo "MEMORY_PERCENT=$mem_percent"
            echo "MEMORY_FREE=$free_mem"
        fi
        
        # Disk check
        root_usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
        echo "DISK_PERCENT=$root_usage"
        
        # Load average
        if [ -f /proc/loadavg ]; then
            load=$(cat /proc/loadavg | awk '{print $1}')
            echo "CPU_LOAD=$load"
        fi
        
        # Overall health
        if [ "${mem_percent:-0}" -gt 90 ] || [ "${root_usage:-0}" -gt 90 ]; then
            echo "HEALTH=critical"
        elif [ "${mem_percent:-0}" -gt 75 ] || [ "${root_usage:-0}" -gt 75 ]; then
            echo "HEALTH=warning"
        else
            echo "HEALTH=healthy"
        fi
    } > "$status_file"
}

# Monitor health in daemon mode
monitor_health() {
    while true; do
        save_health_status
        
        # Check for critical conditions
        if [ -f "$HEALTH_DIR/status" ]; then
            . "$HEALTH_DIR/status"
            
            if [ "${HEALTH:-healthy}" = "critical" ]; then
                # Log critical health
                echo "[$(date)] CRITICAL: System health degraded!" >> /var/log/jesteros/health.log
            fi
        fi
        
        sleep 60  # Check every minute
    done
}

# Handle command line arguments
case "${1:-check}" in
    check)
        health_check_main
        ;;
    
    --daemon|daemon)
        echo "Starting Health Monitor daemon..."
        monitor_health
        ;;
    
    start)
        echo "Starting Health Monitor daemon..."
        monitor_health &
        echo $! > "$PIDFILE"
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
            if [ -f "$HEALTH_DIR/status" ]; then
                echo ""
                echo "Last health check:"
                cat "$HEALTH_DIR/status"
            fi
        else
            echo "Health Monitor is not running."
        fi
        ;;
    
    *)
        echo "Usage: $0 {check|start|stop|status|--daemon}"
        exit 1
        ;;
esac