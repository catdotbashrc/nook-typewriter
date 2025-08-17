#!/bin/bash
# memory-guardian.sh - JesterOS Memory Guardian Service
# Monitors and protects system memory to prevent OOM kills
# Part of Phase 1 critical safety fixes

set -euo pipefail
trap 'echo "Error in memory-guardian.sh at line $LINENO"' ERR

# Source memory configuration
MEMORY_CONFIG="/runtime/config/memory.conf"
if [ -f "$MEMORY_CONFIG" ]; then
    source "$MEMORY_CONFIG"
else
    echo "ERROR: Memory configuration not found at $MEMORY_CONFIG"
    exit 1
fi

# PID file for daemon
PID_FILE="/var/run/jesteros/memory-guardian.pid"
LOG_FILE="/var/log/jesteros/memory-guardian.log"

# Ensure directories exist
mkdir -p "$(dirname "$PID_FILE")" "$(dirname "$LOG_FILE")" 2>/dev/null || true

# Logging function
log_guardian() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Start memory guardian daemon
start_guardian() {
    if [ -f "$PID_FILE" ]; then
        local old_pid=$(cat "$PID_FILE" 2>/dev/null || echo "")
        if [ -n "$old_pid" ] && kill -0 "$old_pid" 2>/dev/null; then
            echo "Memory guardian already running (PID: $old_pid)"
            return 0
        fi
    fi
    
    echo "Starting JesterOS Memory Guardian..."
    log_guardian "Memory guardian starting..."
    
    # Run monitoring in background
    {
        # Write PID
        echo $$ > "$PID_FILE"
        
        # Main monitoring loop
        while true; do
            local free_kb=$(get_free_memory)
            local status=$(check_memory_status)
            
            # Take action based on status
            case $status in
                CRITICAL)
                    log_guardian "CRITICAL: Only ${free_kb}KB free! Emergency cleanup level 3"
                    emergency_cleanup 3
                    # Alert user if possible
                    echo "MEMORY CRITICAL!" > /var/jesteros/jester 2>/dev/null || true
                    ;;
                WARNING)
                    log_guardian "WARNING: Only ${free_kb}KB free. Cleanup level 2"
                    emergency_cleanup 2
                    ;;
                LOW)
                    log_guardian "LOW: ${free_kb}KB free. Cleanup level 1"
                    emergency_cleanup 1
                    ;;
                OK)
                    # All good, just log periodically
                    if [ $(($(date +%s) % 300)) -eq 0 ]; then
                        log_guardian "OK: ${free_kb}KB free"
                    fi
                    ;;
            esac
            
            # Adjust check interval based on status
            local interval=$CHECK_INTERVAL_NORMAL
            [ "$status" = "CRITICAL" ] && interval=$CHECK_INTERVAL_CRITICAL
            [ "$status" = "WARNING" ] && interval=$CHECK_INTERVAL_WARNING
            
            sleep $interval
        done
    } &
    
    local guardian_pid=$!
    echo $guardian_pid > "$PID_FILE"
    
    # Verify it started
    sleep 1
    if kill -0 $guardian_pid 2>/dev/null; then
        echo "Memory guardian started successfully (PID: $guardian_pid)"
        log_guardian "Memory guardian started (PID: $guardian_pid)"
    else
        echo "Failed to start memory guardian"
        rm -f "$PID_FILE"
        return 1
    fi
}

# Stop memory guardian daemon
stop_guardian() {
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE" 2>/dev/null || echo "")
        if [ -n "$pid" ]; then
            echo "Stopping memory guardian (PID: $pid)..."
            kill -TERM "$pid" 2>/dev/null || true
            sleep 1
            kill -KILL "$pid" 2>/dev/null || true
            rm -f "$PID_FILE"
            log_guardian "Memory guardian stopped"
            echo "Memory guardian stopped"
        else
            echo "Memory guardian not running"
        fi
    else
        echo "Memory guardian not running"
    fi
}

# Check guardian status
status_guardian() {
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE" 2>/dev/null || echo "")
        if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
            local free_kb=$(get_free_memory)
            local status=$(check_memory_status)
            echo "Memory Guardian: RUNNING (PID: $pid)"
            echo "Memory Status: $status (${free_kb}KB free)"
            
            # Show last few log entries
            echo ""
            echo "Recent activity:"
            tail -5 "$LOG_FILE" 2>/dev/null || echo "No log entries"
        else
            echo "Memory Guardian: NOT RUNNING (stale PID file)"
            rm -f "$PID_FILE"
        fi
    else
        echo "Memory Guardian: NOT RUNNING"
    fi
}

# Manual memory check
check_memory() {
    local free_kb=$(get_free_memory)
    local status=$(check_memory_status)
    
    echo "Memory Check Results:"
    echo "====================="
    echo "Free Memory: ${free_kb}KB"
    echo "Status: $status"
    echo ""
    echo "Thresholds:"
    echo "  Critical: <${MEMORY_CRITICAL}KB"
    echo "  Warning:  <${MEMORY_WARNING}KB"
    echo "  Comfortable: >${MEMORY_COMFORTABLE}KB"
    echo ""
    
    if [ "$status" != "OK" ]; then
        echo "Recommended action: Run 'emergency_cleanup' or restart guardian"
    fi
}

# Handle commands
case "${1:-status}" in
    start)
        start_guardian
        ;;
    stop)
        stop_guardian
        ;;
    restart)
        stop_guardian
        sleep 1
        start_guardian
        ;;
    status)
        status_guardian
        ;;
    check)
        check_memory
        ;;
    cleanup)
        level="${2:-1}"
        emergency_cleanup "$level"
        ;;
    test)
        echo "Testing memory functions..."
        free_kb=$(get_free_memory)
        status=$(check_memory_status)
        echo "Free memory: ${free_kb}KB"
        echo "Status: $status"
        echo "Test complete!"
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|check|cleanup [1-3]|test}"
        echo ""
        echo "Commands:"
        echo "  start    - Start memory guardian daemon"
        echo "  stop     - Stop memory guardian daemon"
        echo "  restart  - Restart memory guardian daemon"
        echo "  status   - Show guardian and memory status"
        echo "  check    - Manual memory check"
        echo "  cleanup  - Run emergency cleanup (level 1-3)"
        echo "  test     - Test memory functions"
        exit 1
        ;;
esac