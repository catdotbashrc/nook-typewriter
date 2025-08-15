#!/bin/bash
# The Court Jester - A whimsical companion for writers
# Lives in userspace, no kernel rebuild needed!

# Source common functions and safety settings
COMMON_PATH="${COMMON_PATH:-/usr/local/bin/common.sh}"
if [[ -f "$COMMON_PATH" ]]; then
    source "$COMMON_PATH"
else
    # Fallback safety settings
    set -euo pipefail
    trap 'echo "Error at line $LINENO"' ERR
fi

# Use common constants or define locally
JESTER_DIR="${JESTER_DIR:-/var/lib/jester}"
JESTER_PROC="/proc/jester"
JESTER_STATE="$JESTER_DIR/state"
JESTER_WISDOM="$JESTER_DIR/wisdom"
ACHIEVEMENT_FILE="$JESTER_DIR/achievements"

# Create jester's home
[[ -d "$JESTER_DIR" ]] || mkdir -p "$JESTER_DIR"

# Jester ASCII art collection
show_jester_happy() {
    cat << 'EOF'
     ___
    /^ ^\   
   | ◉ ◉ |  
   |  ‿  |  
    \___/   
     | |    
    /||\   
   d | |b   
  *jingle*
EOF
}

show_jester_confused() {
    cat << 'EOF'
     ___
    /? ?\   
   | ∘ ∘ |  
   |  ~  |  
    \___/   
     | |    
    /||\   
   d | |b   
     ???
EOF
}

show_jester_sleepy() {
    cat << 'EOF'
     ___
    /z z\   
   | - - |  
   |  _  |  
    \___/   
     | |    
    /||\   
   d | |b   
    Zzz...
EOF
}

show_jester_writing() {
    cat << 'EOF'
     ___
    /^ ^\   
   | · · |  
   |  ‿  |  
    \___/   
     |✍|    
    /||\   
   d | |b   
 *scribble*
EOF
}

# Writing wisdom from the jester
WISDOMS=(
    "Do not force yourself to write when you have nothing to say."
    "Writers are engineers of human souls."
    "The method borrowed from the Chinese pharmacy is most crude."
    "Pay close attention to all manner of things; observe more."
    "Read it over twice and strike out non-essential words."
    "Literature must become a cog in one great mechanism."
    "A writer's block is just the jester taking a nap."
    "Every word you write makes the kingdom brighter."
    "The best stories are told by candlelight."
    "Your quill is mightier than any sword."
    "Write first, edit later - the jester insists!"
    "Even jesters need their morning coffee... er, ink."
)

# Achievement system
declare -A ACHIEVEMENTS=(
    ["apprentice"]="100:Apprentice Scribe:Your first 100 words!"
    ["journeyman"]="1000:Journeyman Writer:1000 words of wisdom"
    ["master"]="5000:Master Wordsmith:5000 words crafted"
    ["chronicler"]="10000:Court Chronicler:10,000 words penned"
    ["sage"]="25000:Sage of Stories:25,000 words woven"
    ["legend"]="50000:Legendary Author:50,000 words - a novel!"
)

# Initialize word count
WORD_COUNT=0
[ -f "$JESTER_DIR/wordcount" ] && WORD_COUNT=$(cat "$JESTER_DIR/wordcount")

# Get random wisdom
get_wisdom() {
    echo "${WISDOMS[$RANDOM % ${#WISDOMS[@]}]}"
}

# Update jester state based on writing activity
update_jester_state() {
    local vim_pids=$(pgrep -c vim)
    
    if [ "$vim_pids" -gt 0 ]; then
        echo "writing" > "$JESTER_STATE"
        show_jester_writing > "$JESTER_DIR/ascii"
    else
        local hour=$(date +%H)
        if [ "$hour" -ge 22 ] || [ "$hour" -le 6 ]; then
            echo "sleepy" > "$JESTER_STATE"
            show_jester_sleepy > "$JESTER_DIR/ascii"
        else
            echo "happy" > "$JESTER_STATE"
            show_jester_happy > "$JESTER_DIR/ascii"
        fi
    fi
}

# Check achievements
check_achievements() {
    for achievement in "${!ACHIEVEMENTS[@]}"; do
        IFS=':' read -r threshold name desc <<< "${ACHIEVEMENTS[$achievement]}"
        if [ "$WORD_COUNT" -ge "$threshold" ]; then
            if ! grep -q "$name" "$ACHIEVEMENT_FILE" 2>/dev/null; then
                echo "$(date): $name - $desc" >> "$ACHIEVEMENT_FILE"
                # Display achievement on E-Ink
                fbink -y 20 "🎉 Achievement Unlocked: $name!" 2>/dev/null || \
                    echo "🎉 Achievement Unlocked: $name!"
            fi
        fi
    done
}

# Create pseudo-proc entries (using regular files)
create_proc_entries() {
    # Symlink to make it feel like /proc
    [ ! -L "$JESTER_PROC" ] && ln -sf "$JESTER_DIR" "$JESTER_PROC" 2>/dev/null
    
    # Update entries
    update_jester_state
    get_wisdom > "$JESTER_WISDOM"
    echo "$WORD_COUNT" > "$JESTER_DIR/wordcount"
    check_achievements
    
    # Create motto file
    echo "By quill and candlelight, we write!" > "$JESTER_DIR/motto"
}

# Monitor writing activity
monitor_writing() {
    while true; do
        # Count words in writing directory
        if [ -d /root/writing ]; then
            NEW_COUNT=$(find /root/writing -name "*.txt" -o -name "*.md" | \
                       xargs wc -w 2>/dev/null | tail -1 | awk '{print $1}')
            [ -z "$NEW_COUNT" ] && NEW_COUNT=0
            
            if [ "$NEW_COUNT" -gt "$WORD_COUNT" ]; then
                WORD_COUNT=$NEW_COUNT
                echo "$WORD_COUNT" > "$JESTER_DIR/wordcount"
                check_achievements
            fi
        fi
        
        create_proc_entries
        sleep 30
    done
}

# Boot greeting
show_boot_greeting() {
    clear
    echo "═══════════════════════════════════════════════════════════════"
    show_jester_happy
    echo ""
    echo "   'By quill and candlelight, we begin our tale!'"
    echo ""
    echo "   Your Court Jester awakens to serve you, dear writer."
    echo "   Today's wisdom: $(get_wisdom)"
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    sleep 3
}

# PID file location (can be overridden by service manager)
PIDFILE="${PIDFILE:-/var/run/jesteros/jester.pid}"

# Ensure PID directory exists
mkdir -p "$(dirname "$PIDFILE")"

# Main daemon
case "${1:-start}" in
    start|--daemon)
        # For service manager compatibility
        if [ "${1:-}" = "--daemon" ] || [ "${DAEMON_MODE:-}" = "1" ]; then
            # Run in foreground for service manager
            create_proc_entries
            exec monitor_writing
        else
            # Traditional background start
            show_boot_greeting
            echo "Starting Court Jester daemon..."
            monitor_writing &
            echo $! > "$PIDFILE"
        fi
        ;;
    stop)
        if [ -f "$PIDFILE" ]; then
            pid=$(cat "$PIDFILE")
            if kill -0 "$pid" 2>/dev/null; then
                kill "$pid"
                rm -f "$PIDFILE"
                echo "Court Jester daemon stopped."
            else
                echo "Court Jester daemon not running (stale PID file)"
                rm -f "$PIDFILE"
            fi
        else
            echo "Court Jester daemon not running."
        fi
        ;;
    status)
        if [ -f "$JESTER_DIR/ascii" ]; then
            cat "$JESTER_DIR/ascii"
            echo ""
            echo "State: $(cat $JESTER_STATE 2>/dev/null || echo 'unknown')"
            echo "Words: $(cat $JESTER_DIR/wordcount 2>/dev/null || echo '0')"
            echo "Wisdom: $(cat $JESTER_WISDOM 2>/dev/null)"
        else
            echo "The jester is sleeping..."
        fi
        ;;
    *)
        echo "Usage: $0 {start|stop|status|--daemon}"
        ;;
esac