#!/bin/sh
# JesterOS Service Management Functions
# Shared utilities for service lifecycle management
# "A well-managed court is a happy court!" - Jester's Wisdom

set -e

# Service directories
SERVICE_CONFIG_DIR="/etc/jesteros/services"
SERVICE_PID_DIR="/var/run/jesteros"
SERVICE_LOG_DIR="/var/log/jesteros"
SERVICE_STATUS_DIR="/var/jesteros/services"

# Create necessary directories
init_service_dirs() {
    mkdir -p "$SERVICE_CONFIG_DIR"
    mkdir -p "$SERVICE_PID_DIR"
    mkdir -p "$SERVICE_LOG_DIR"
    mkdir -p "$SERVICE_STATUS_DIR"
}

# Load service configuration
load_service_config() {
    local service_name="$1"
    local config_file="$SERVICE_CONFIG_DIR/${service_name}.conf"
    
    if [ ! -f "$config_file" ]; then
        echo "Alas! The scroll for service '$service_name' is missing!"
        return 1
    fi
    
    . "$config_file"
}

# Check if service is running
is_service_running() {
    local pidfile="$1"
    
    if [ ! -f "$pidfile" ]; then
        return 1
    fi
    
    local pid=$(cat "$pidfile" 2>/dev/null)
    if [ -z "$pid" ]; then
        return 1
    fi
    
    # Check if process exists
    if kill -0 "$pid" 2>/dev/null; then
        return 0
    else
        # Stale PID file - clean it up
        rm -f "$pidfile"
        return 1
    fi
}

# Start a service
start_service() {
    local service_name="$1"
    
    # Load configuration
    load_service_config "$service_name" || return 1
    
    # Check if already running
    if is_service_running "$SERVICE_PIDFILE"; then
        echo "The ${SERVICE_NAME} already performs its duties!"
        return 0
    fi
    
    # Start the service
    echo "${SERVICE_START_MSG:-Starting $SERVICE_NAME...}"
    
    # Use start-stop-daemon if available
    if command -v start-stop-daemon >/dev/null 2>&1; then
        start-stop-daemon --start --quiet \
            --pidfile "$SERVICE_PIDFILE" \
            --make-pidfile --background \
            --exec "$SERVICE_EXEC" -- $SERVICE_ARGS
    else
        # Fallback to manual daemonization
        nohup "$SERVICE_EXEC" $SERVICE_ARGS > "$SERVICE_LOG_DIR/${service_name}.log" 2>&1 &
        echo $! > "$SERVICE_PIDFILE"
    fi
    
    # Update status
    update_service_status "$service_name" "running"
    
    return 0
}

# Stop a service
stop_service() {
    local service_name="$1"
    
    # Load configuration
    load_service_config "$service_name" || return 1
    
    # Check if running
    if ! is_service_running "$SERVICE_PIDFILE"; then
        echo "The ${SERVICE_NAME} already slumbers!"
        return 0
    fi
    
    echo "${SERVICE_STOP_MSG:-Stopping $SERVICE_NAME...}"
    
    # Stop the service
    if command -v start-stop-daemon >/dev/null 2>&1; then
        start-stop-daemon --stop --quiet \
            --pidfile "$SERVICE_PIDFILE" \
            --retry TERM/5/KILL/5
    else
        # Manual stop
        local pid=$(cat "$SERVICE_PIDFILE" 2>/dev/null)
        if [ -n "$pid" ]; then
            kill "$pid" 2>/dev/null || true
            sleep 2
            # Force kill if still running
            kill -9 "$pid" 2>/dev/null || true
        fi
    fi
    
    # Clean up PID file
    rm -f "$SERVICE_PIDFILE"
    
    # Update status
    update_service_status "$service_name" "stopped"
    
    return 0
}

# Restart a service
restart_service() {
    local service_name="$1"
    
    stop_service "$service_name"
    sleep 1
    start_service "$service_name"
}

# Get service status
service_status() {
    local service_name="$1"
    
    # Load configuration
    load_service_config "$service_name" || return 1
    
    if is_service_running "$SERVICE_PIDFILE"; then
        local pid=$(cat "$SERVICE_PIDFILE")
        echo "⚔️  ${SERVICE_NAME} is valiantly serving (PID: $pid)"
        
        # Show memory usage if available
        if [ -f "/proc/$pid/status" ]; then
            local mem_kb=$(grep VmRSS /proc/$pid/status | awk '{print $2}')
            if [ -n "$mem_kb" ]; then
                echo "   Memory: ${mem_kb}KB"
            fi
        fi
        
        return 0
    else
        echo "💤 ${SERVICE_NAME} rests in the chambers"
        return 1
    fi
}

# Update service status file
update_service_status() {
    local service_name="$1"
    local status="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Create status file
    cat > "$SERVICE_STATUS_DIR/${service_name}.status" << EOF
SERVICE=${service_name}
STATUS=${status}
TIMESTAMP=${timestamp}
EOF
    
    # Update global status
    update_global_status
}

# Update global service status
update_global_status() {
    local status_file="$SERVICE_STATUS_DIR/status"
    
    echo "=== JesterOS Service Status ===" > "$status_file"
    echo "Updated: $(date '+%Y-%m-%d %H:%M:%S')" >> "$status_file"
    echo "" >> "$status_file"
    
    # List all services
    for conf in "$SERVICE_CONFIG_DIR"/*.conf; do
        [ -f "$conf" ] || continue
        
        local service_name=$(basename "$conf" .conf)
        load_service_config "$service_name"
        
        if is_service_running "$SERVICE_PIDFILE"; then
            local pid=$(cat "$SERVICE_PIDFILE")
            echo "✓ ${SERVICE_NAME}: Running (PID $pid)" >> "$status_file"
        else
            echo "✗ ${SERVICE_NAME}: Stopped" >> "$status_file"
        fi
    done
}

# Health check for a service
health_check_service() {
    local service_name="$1"
    
    # Load configuration
    load_service_config "$service_name" || return 1
    
    # Basic check - is it running?
    if ! is_service_running "$SERVICE_PIDFILE"; then
        return 1
    fi
    
    # Custom health check if defined
    if [ -n "$SERVICE_HEALTH_CHECK" ]; then
        eval "$SERVICE_HEALTH_CHECK"
        return $?
    fi
    
    return 0
}

# Auto-restart service with backoff
auto_restart_service() {
    local service_name="$1"
    local max_attempts=3
    local attempt=0
    local backoff=1
    
    while [ $attempt -lt $max_attempts ]; do
        attempt=$((attempt + 1))
        
        echo "Attempting to revive ${service_name} (attempt $attempt/$max_attempts)..."
        
        if start_service "$service_name"; then
            echo "Huzzah! ${service_name} has returned to service!"
            return 0
        fi
        
        # Exponential backoff
        echo "The ${service_name} needs $backoff seconds to recover..."
        sleep $backoff
        backoff=$((backoff * 2))
    done
    
    echo "Alas! The ${service_name} could not be revived after $max_attempts attempts."
    update_service_status "$service_name" "failed"
    return 1
}

# Resolve service dependencies
resolve_dependencies() {
    local service_name="$1"
    local resolved=""
    local visiting=""
    
    _resolve_deps_recursive "$service_name"
    echo "$resolved"
}

# Recursive dependency resolution
_resolve_deps_recursive() {
    local service="$1"
    
    # Check for circular dependency
    if echo "$visiting" | grep -q "\\b$service\\b"; then
        echo "Circular dependency detected for $service!" >&2
        return 1
    fi
    
    # Mark as visiting
    visiting="$visiting $service"
    
    # Load service config
    load_service_config "$service" || return 1
    
    # Resolve dependencies first
    if [ -n "$SERVICE_DEPS" ]; then
        for dep in $SERVICE_DEPS; do
            if ! echo "$resolved" | grep -q "\\b$dep\\b"; then
                _resolve_deps_recursive "$dep"
            fi
        done
    fi
    
    # Add to resolved if not already there
    if ! echo "$resolved" | grep -q "\\b$service\\b"; then
        resolved="$resolved $service"
    fi
    
    # Remove from visiting
    visiting=$(echo "$visiting" | sed "s/\\b$service\\b//")
}

# Initialize service management
init_service_management() {
    init_service_dirs
    update_global_status
    echo "JesterOS Service Management initialized!"
}