#!/bin/bash
# Plugin: System Health Monitor
# Shows memory, disk, and CPU status

health_monitor_handler() {
    /usr/local/bin/health-check.sh
}

# Register the menu item
register_menu_item "h" "[H] Health Check" "health_monitor_handler"

# Optional: Add to startup checks
on_menu_start() {
    # Check if memory is critically low
    if [ -f /proc/meminfo ]; then
        free_mem=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
        if [ "$free_mem" -lt 20480 ]; then  # Less than 20MB
            echo "⚠ WARNING: Very low memory!" | fbink -y 30 2>/dev/null || echo "⚠ WARNING: Very low memory!"
            sleep 2
        fi
    fi
}