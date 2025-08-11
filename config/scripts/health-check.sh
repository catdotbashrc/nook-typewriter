#!/bin/bash
# Health Check Script for Nook Typewriter
# Provides system health monitoring and writing statistics

set -eu

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
if [ -f /proc/squireos/typewriter/stats ]; then
    display_line 23 "WRITING STATS:"
    words_today=$(grep "Words today:" /proc/squireos/typewriter/stats 2>/dev/null | awk '{print $3}' || echo "0")
    total_words=$(grep "Total words:" /proc/squireos/typewriter/stats 2>/dev/null | awk '{print $3}' || echo "0")
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

# Wait for input if interactive
if [ -t 0 ]; then
    read -n 1 -s
fi