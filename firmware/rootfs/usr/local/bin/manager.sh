#!/bin/sh
# JesterOS Service Manager
# Central management for all JesterOS services
# "Order in the court, jest in the heart!" - Ancient Proverb

set -e

# Source the service functions
SCRIPT_DIR=$(dirname "$0")
SERVICE_FUNCTIONS="$SCRIPT_DIR/../../3-system/common/service-functions.sh"

# Try multiple paths for service functions
if [ -f "$SERVICE_FUNCTIONS" ]; then
    . "$SERVICE_FUNCTIONS"
elif [ -f "/runtime/3-system/common/service-functions.sh" ]; then
    . "/runtime/3-system/common/service-functions.sh"
else
    echo "Error: Cannot find service-functions.sh" >&2
    echo "Searched:" >&2
    echo "  - $SERVICE_FUNCTIONS" >&2
    echo "  - /runtime/3-system/common/service-functions.sh" >&2
    exit 1
fi

# Display usage
usage() {
    cat << EOF
JesterOS Service Manager - Keeper of the Digital Court

Usage: $0 {start|stop|restart|status|health|monitor} [service|all]

Commands:
  start   [service]  - Awaken a service (or all services)
  stop    [service]  - Send a service to rest (or all services)
  restart [service]  - Refresh a service's vigor (or all services)
  status  [service]  - Check a service's well-being (or all services)
  health  [service]  - Perform health check (or all services)
  monitor            - Continuous monitoring with auto-restart
  init               - Initialize service management system

Services:
  jester   - The Court Jester (mood and ASCII art)
  tracker  - The Royal Scribe (writing statistics)
  health   - The Court Physician (system health)
  all      - All services of the realm

Examples:
  $0 start all          # Start all services
  $0 status jester      # Check jester service status
  $0 monitor            # Start monitoring daemon

By quill and jest, we serve!
EOF
}

# Start all services in dependency order
start_all_services() {
    echo "════════════════════════════════════════"
    echo "  Awakening the JesterOS Court..."
    echo "════════════════════════════════════════"
    
    # Get all services
    local services=""
    for conf in "$SERVICE_CONFIG_DIR"/*.conf; do
        [ -f "$conf" ] || continue
        services="$services $(basename "$conf" .conf)"
    done
    
    # Start services in dependency order
    for service in $services; do
        local deps=$(resolve_dependencies "$service")
        for dep in $deps; do
            start_service "$dep"
        done
    done
    
    echo ""
    echo "The court is now in session!"
}

# Stop all services in reverse dependency order
stop_all_services() {
    echo "════════════════════════════════════════"
    echo "  Dismissing the JesterOS Court..."
    echo "════════════════════════════════════════"
    
    # Get all services in reverse order
    local services=""
    for conf in "$SERVICE_CONFIG_DIR"/*.conf; do
        [ -f "$conf" ] || continue
        services="$(basename "$conf" .conf) $services"
    done
    
    # Stop services
    for service in $services; do
        stop_service "$service"
    done
    
    echo ""
    echo "The court retires for the evening."
}

# Restart all services
restart_all_services() {
    stop_all_services
    echo ""
    sleep 2
    start_all_services
}

# Show status of all services
status_all_services() {
    echo "════════════════════════════════════════"
    echo "  JesterOS Service Status Report"
    echo "════════════════════════════════════════"
    echo ""
    
    local all_running=true
    
    for conf in "$SERVICE_CONFIG_DIR"/*.conf; do
        [ -f "$conf" ] || continue
        
        local service=$(basename "$conf" .conf)
        if ! service_status "$service"; then
            all_running=false
        fi
    done
    
    echo ""
    echo "────────────────────────────────────────"
    
    # Show memory summary
    local total_mem=0
    for conf in "$SERVICE_CONFIG_DIR"/*.conf; do
        [ -f "$conf" ] || continue
        
        local service=$(basename "$conf" .conf)
        load_service_config "$service"
        
        if is_service_running "$SERVICE_PIDFILE"; then
            local pid=$(cat "$SERVICE_PIDFILE")
            if [ -f "/proc/$pid/status" ]; then
                local mem_kb=$(grep VmRSS /proc/$pid/status 2>/dev/null | awk '{print $2}')
                if [ -n "$mem_kb" ]; then
                    total_mem=$((total_mem + mem_kb))
                fi
            fi
        fi
    done
    
    if [ $total_mem -gt 0 ]; then
        echo "Total service memory: ${total_mem}KB"
        
        # Check if under 1MB limit
        if [ $total_mem -lt 1024 ]; then
            echo "✓ Memory budget maintained (< 1MB)"
        else
            echo "⚠️  Warning: Exceeding 1MB memory budget!"
        fi
    fi
    
    echo ""
    
    if $all_running; then
        echo "🎭 All services are performing splendidly!"
    else
        echo "⚠️  Some services need attention!"
    fi
}

# Health check for all services
health_check_all() {
    echo "════════════════════════════════════════"
    echo "  Court Physician's Health Report"
    echo "════════════════════════════════════════"
    echo ""
    
    local all_healthy=true
    
    for conf in "$SERVICE_CONFIG_DIR"/*.conf; do
        [ -f "$conf" ] || continue
        
        local service=$(basename "$conf" .conf)
        load_service_config "$service"
        
        echo -n "Examining ${SERVICE_NAME}... "
        
        if health_check_service "$service"; then
            echo "✓ Healthy!"
        else
            echo "✗ Needs attention!"
            all_healthy=false
            
            # Auto-restart if not running
            if ! is_service_running "$SERVICE_PIDFILE"; then
                echo "  Attempting resuscitation..."
                auto_restart_service "$service"
            fi
        fi
    done
    
    echo ""
    if $all_healthy; then
        echo "🏥 The court is in excellent health!"
    else
        echo "⚠️  Some services require healing!"
    fi
}

# Monitoring daemon
monitor_services() {
    echo "════════════════════════════════════════"
    echo "  JesterOS Service Monitor"
    echo "  Press Ctrl+C to stop monitoring"
    echo "════════════════════════════════════════"
    
    # Create monitor PID file
    local monitor_pid="/var/run/jesteros/monitor.pid"
    echo $$ > "$monitor_pid"
    
    # Trap for clean shutdown
    trap "rm -f $monitor_pid; echo 'Monitor retiring...'; exit 0" INT TERM
    
    while true; do
        # Check each service
        for conf in "$SERVICE_CONFIG_DIR"/*.conf; do
            [ -f "$conf" ] || continue
            
            local service=$(basename "$conf" .conf)
            
            if ! health_check_service "$service"; then
                echo "[$(date '+%H:%M:%S')] Service $service is unwell!"
                
                # Try to restart
                if ! is_service_running "$SERVICE_PIDFILE"; then
                    echo "[$(date '+%H:%M:%S')] Attempting to revive $service..."
                    auto_restart_service "$service"
                fi
            fi
        done
        
        # Update global status
        update_global_status
        
        # Sleep before next check (30 seconds)
        sleep 30
    done
}

# Initialize service management
initialize_services() {
    echo "Initializing JesterOS Service Management..."
    
    # Initialize directories
    init_service_management
    
    # Create default service configurations if they don't exist
    if [ ! -f "$SERVICE_CONFIG_DIR/jester.conf" ]; then
        mkdir -p "$SERVICE_CONFIG_DIR"
        create_default_configs
    fi
    
    echo "Service management initialized!"
}

# Create default service configurations
create_default_configs() {
    echo "Creating default service configurations..."
    
    # Jester service
    cat > "$SERVICE_CONFIG_DIR/jester.conf" << 'EOF'
SERVICE_NAME="Court Jester"
SERVICE_DESC="ASCII art and mood daemon"
SERVICE_EXEC="/usr/local/bin/jester-daemon.sh"
SERVICE_PIDFILE="/var/run/jesteros/jester.pid"
SERVICE_ARGS=""
SERVICE_DEPS=""
SERVICE_START_MSG="🎭 The Jester awakens with bells jingling!"
SERVICE_STOP_MSG="🎭 The Jester retires to chambers..."
SERVICE_HEALTH_CHECK="test -f /var/jesteros/jester"
EOF
    
    # Tracker service
    cat > "$SERVICE_CONFIG_DIR/tracker.conf" << 'EOF'
SERVICE_NAME="Royal Scribe"
SERVICE_DESC="Writing statistics tracker"
SERVICE_EXEC="/usr/local/bin/jesteros-tracker.sh"
SERVICE_PIDFILE="/var/run/jesteros/tracker.pid"
SERVICE_ARGS=""
SERVICE_DEPS="jester"
SERVICE_START_MSG="📜 The Royal Scribe takes up the quill!"
SERVICE_STOP_MSG="📜 The Royal Scribe sets down the quill..."
SERVICE_HEALTH_CHECK="test -f /var/jesteros/typewriter/stats"
EOF
    
    # Health service
    cat > "$SERVICE_CONFIG_DIR/health.conf" << 'EOF'
SERVICE_NAME="Court Physician"
SERVICE_DESC="System health monitor"
SERVICE_EXEC="/usr/local/bin/health-check.sh"
SERVICE_PIDFILE="/var/run/jesteros/health.pid"
SERVICE_ARGS="--daemon"
SERVICE_DEPS="jester"
SERVICE_START_MSG="🏥 The Court Physician begins rounds!"
SERVICE_STOP_MSG="🏥 The Court Physician retires..."
SERVICE_HEALTH_CHECK="test -f /var/jesteros/health/status"
EOF
}

# Main command processing
case "${1:-}" in
    start)
        if [ "${2:-}" = "all" ] || [ -z "${2:-}" ]; then
            start_all_services
        else
            start_service "$2"
        fi
        ;;
    
    stop)
        if [ "${2:-}" = "all" ] || [ -z "${2:-}" ]; then
            stop_all_services
        else
            stop_service "$2"
        fi
        ;;
    
    restart)
        if [ "${2:-}" = "all" ] || [ -z "${2:-}" ]; then
            restart_all_services
        else
            restart_service "$2"
        fi
        ;;
    
    status)
        if [ "${2:-}" = "all" ] || [ -z "${2:-}" ]; then
            status_all_services
        else
            service_status "$2"
        fi
        ;;
    
    health)
        if [ "${2:-}" = "all" ] || [ -z "${2:-}" ]; then
            health_check_all
        else
            if health_check_service "$2"; then
                echo "✓ Service $2 is healthy!"
            else
                echo "✗ Service $2 needs attention!"
                exit 1
            fi
        fi
        ;;
    
    monitor)
        monitor_services
        ;;
    
    init)
        initialize_services
        ;;
    
    *)
        usage
        exit 1
        ;;
esac

exit 0