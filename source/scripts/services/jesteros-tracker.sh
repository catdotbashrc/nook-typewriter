#!/bin/sh
# JesterOS Writing Tracker
# Monitors actual writing activity and updates statistics

JESTER_DIR="/var/jesteros"
STATS_FILE="$JESTER_DIR/typewriter/stats"
STATS_DATA="$JESTER_DIR/.stats_data"
WATCH_DIR="/root/manuscripts"

# Initialize statistics data file
init_stats_data() {
    if [ ! -f "$STATS_DATA" ]; then
        cat > "$STATS_DATA" << EOF
TOTAL_WORDS=0
TOTAL_CHARS=0
SESSIONS=1
STREAK_DAYS=0
LAST_WRITE=$(date)
SESSION_START=$(date +%s)
EOF
    fi
}

# Load current statistics
load_stats() {
    if [ -f "$STATS_DATA" ]; then
        . "$STATS_DATA"
    fi
}

# Count words in a file
count_words() {
    wc -w < "$1" 2>/dev/null || echo 0
}

# Count characters in a file
count_chars() {
    wc -c < "$1" 2>/dev/null || echo 0
}

# Update writing statistics
update_stats() {
    load_stats
    
    # Count current words and characters in manuscripts
    CURRENT_WORDS=0
    CURRENT_CHARS=0
    
    if [ -d "$WATCH_DIR" ]; then
        for file in "$WATCH_DIR"/*.txt "$WATCH_DIR"/*.md; do
            if [ -f "$file" ]; then
                FILE_WORDS=$(count_words "$file")
                FILE_CHARS=$(count_chars "$file")
                CURRENT_WORDS=$((CURRENT_WORDS + FILE_WORDS))
                CURRENT_CHARS=$((CURRENT_CHARS + FILE_CHARS))
            fi
        done
    fi
    
    # Calculate session time
    CURRENT_TIME=$(date +%s)
    SESSION_MINS=$(( (CURRENT_TIME - SESSION_START) / 60 ))
    
    # Update the visible stats file
    cat > "$STATS_FILE" << EOF
╔════════════════════════════════════╗
║     TYPEWRITER STATISTICS          ║
╚════════════════════════════════════╝

📜 Writing Progress:
   Words Written:    $CURRENT_WORDS
   Characters Typed: $CURRENT_CHARS
   
⏰ Session Info:
   Current Session:  $SESSION_MINS minutes
   Writing Streak:   $STREAK_DAYS days
   Last Activity:    $LAST_WRITE

🎭 Jester's Tally:
   Jests Delivered:  42
   Wisdom Shared:    ∞
   Inspiration:      Overflowing!

═══════════════════════════════════
"Keep thy quill moving, brave writer!"
═══════════════════════════════════
EOF
    
    # Save the data
    cat > "$STATS_DATA" << EOF
TOTAL_WORDS=$CURRENT_WORDS
TOTAL_CHARS=$CURRENT_CHARS
SESSIONS=$SESSIONS
STREAK_DAYS=$STREAK_DAYS
LAST_WRITE="$(date)"
SESSION_START=$SESSION_START
EOF
}

# Monitor for vim activity and update jester mood
monitor_writing() {
    while true; do
        if pgrep -x vim > /dev/null; then
            # Vim is running - writer is active!
            cat > "$JESTER_DIR/jester" << 'EOF'
     ___
    /^ ^\   JesterOS v1.0
   | > < |  "Thy words flow like wine!"  
   |  ⌣  |  
    \___/   Status: WRITING!
     | |    Mood: Ecstatic! 
    /||\   
   d | |b   *scribbles frantically*
EOF
            update_stats
        else
            # No vim - writer is resting
            cat > "$JESTER_DIR/jester" << 'EOF'
     ___
    /- -\   JesterOS v1.0
   | > < |  "Rest thy quill, then write again!"  
   |  ~  |  
    \___/   Status: Idle
     | |    Mood: Patient
    / \    
   d   b   *waiting for inspiration*
EOF
        fi
        
        sleep 30
    done
}

# PID file location (can be overridden by service manager)
PIDFILE="${PIDFILE:-/var/run/jesteros/tracker.pid}"

# Ensure PID directory exists
mkdir -p "$(dirname "$PIDFILE")"

# Main function
main() {
    # Ensure directories exist
    mkdir -p "$JESTER_DIR/typewriter"
    mkdir -p "$WATCH_DIR"
    
    init_stats_data
    update_stats
    
    # Start monitoring
    monitor_writing
}

# Handle command line arguments for service manager compatibility
case "${1:-start}" in
    start|--daemon)
        if [ "${1:-}" = "--daemon" ] || [ "${DAEMON_MODE:-}" = "1" ]; then
            # Run in foreground for service manager
            echo "Starting JesterOS Writing Tracker (daemon mode)..."
            exec main
        else
            # Traditional background start
            echo "Starting JesterOS Writing Tracker..."
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
                echo "Writing Tracker stopped."
            else
                echo "Writing Tracker not running (stale PID file)"
                rm -f "$PIDFILE"
            fi
        else
            echo "Writing Tracker not running."
        fi
        ;;
    status)
        if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
            echo "Writing Tracker is running (PID: $(cat "$PIDFILE"))"
            if [ -f "$STATS_FILE" ]; then
                echo ""
                cat "$STATS_FILE"
            fi
        else
            echo "Writing Tracker is not running."
        fi
        ;;
    *)
        echo "Usage: $0 {start|stop|status|--daemon}"
        exit 1
        ;;
esac