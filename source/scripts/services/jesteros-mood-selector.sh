#!/bin/sh
# JesterOS Mood Selector
# Selects appropriate jester ASCII art based on system state

set -euo pipefail

# Mood detection based on system state
get_jester_mood() {
    # Check memory usage
    MEM_PERCENT=$(free | grep Mem | awk '{print int($3/$2 * 100)}')
    
    # Check if writing is active (vim process)
    if pgrep -x vim >/dev/null 2>&1; then
        echo "WRITING"
        return
    fi
    
    # Check system uptime (in minutes)
    UPTIME_MINS=$(awk '{print int($1/60)}' /proc/uptime 2>/dev/null || echo "0")
    
    # Determine mood based on conditions
    if [ "$MEM_PERCENT" -gt 90 ]; then
        echo "STRESSED"
    elif [ "$MEM_PERCENT" -gt 75 ]; then
        echo "THINKING"
    elif [ "$UPTIME_MINS" -lt 5 ]; then
        echo "EXCITED"
    elif [ "$UPTIME_MINS" -gt 180 ]; then
        echo "SLEEPING"
    else
        echo "HAPPY"
    fi
}

# Get appropriate ASCII art for mood
get_jester_art() {
    local mood="${1:-HAPPY}"
    
    case "$mood" in
        WRITING)
            cat << 'EOF'
     ___
    /^ ^\   *scribble scribble*
   | · · |  Thy words flow like honey!
   |  ‿  |  
    \___/   
     |✍|    
    /||\   
   d | |b   
EOF
            ;;
        EXCITED)
            cat << 'EOF'
     ___
    /! !\   Huzzah! A new quest begins!
   | ★ ★ |  
   |  O  |  
    \___/   
    \| |/   
    /||\   
   d | |b   
  !!!!!!!!
EOF
            ;;
        THINKING)
            cat << 'EOF'
     ___
    /- -\   Hmm... pondering thy request...
   | ∘ ∘ |  
   |  ~  |  
    \___/   
     | |    
    /||\   
   d | |b   
     ...
EOF
            ;;
        SLEEPING)
            cat << 'EOF'
     ___
    /z z\   The realm rests peacefully...
   | - - |  
   |  _  |  
    \___/   
     | |    
    /||\   
   d | |b   
    Zzz...
EOF
            ;;
        STRESSED)
            cat << 'EOF'
     ___
    /@_@\   Memory grows tight, m'lord!
   | > < |  
   |  ︵  |  
    \___/   
     | |    
    /||\   
   d | |b   
   *wheeze*
EOF
            ;;
        HAPPY|*)
            cat << 'EOF'
     ___
    /^ ^\   At thy service, noble scribe!
   | ◉ ◉ |  
   |  ‿  |  
    \___/   
     | |    
    /||\   
   d | |b   
  *jingle*
EOF
            ;;
    esac
}

# Main execution
main() {
    MOOD=$(get_jester_mood)
    get_jester_art "$MOOD"
    
    # Log mood for statistics
    if [ -d "/var/jesteros" ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Mood: $MOOD" >> /var/jesteros/mood.log 2>/dev/null || true
    fi
}

# Run if executed directly
if [ "${0##*/}" = "jesteros-mood-selector.sh" ]; then
    main "$@"
fi