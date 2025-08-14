#!/bin/sh
# JesterOS Userspace Implementation
# Creates /proc-like entries without kernel modules
# "Work smarter, not harder" - Ancient Jester Proverb

set -e

JESTER_DIR="/var/jesteros"
PROC_LINK="/proc/jesteros"

# Create JesterOS directory structure
create_jesteros_dirs() {
    mkdir -p "$JESTER_DIR"
    mkdir -p "$JESTER_DIR/typewriter"
    
    # Create symlink in /proc if possible (may fail, that's ok)
    ln -sf "$JESTER_DIR" "$PROC_LINK" 2>/dev/null || true
}

# Initialize the ASCII jester
init_jester() {
    cat > "$JESTER_DIR/jester" << 'EOF'
     ___
    /o o\   JesterOS v1.0
   | > < |  "By quill and wit!"  
   |  ~  |  
    \___/   Status: Jesting
     | |    Mood: Whimsical
    /   \   
   d     b  
EOF
}

# Initialize typewriter statistics
init_typewriter() {
    cat > "$JESTER_DIR/typewriter/stats" << 'EOF'
=== Typewriter Statistics ===
Words Written: 0
Characters Typed: 0
Writing Sessions: 1
Jests Delivered: 42
Wisdom Dispensed: ∞
Writing Streak: 0 days
Last Session: Just started!
EOF
}

# Initialize wisdom quotes
init_wisdom() {
    # Create a simple wisdom rotation
    cat > "$JESTER_DIR/wisdom" << 'EOF'
"The pen is mightier than the sword, but the jester's wit cuts deepest."
    - Ancient Nook Proverb
EOF
    
    # Store additional wisdom for rotation
    cat > "$JESTER_DIR/.wisdom_pool" << 'EOF'
"Write first, edit later. Perfect is the enemy of done."
"A writer's block is just a jester taking a nap."
"Every great story begins with a single keystroke."
"Words are magic spells that transport minds."
"The blank page is not your enemy, but your dance floor."
"Write like nobody's reading, edit like everybody is."
"A day without writing is like a knight without armor."
"The muse visits those who show up to write."
"First drafts are meant to exist, not to be perfect."
"Your worst writing is better than your best intention."
EOF
}

# Rotate wisdom quotes (call periodically)
rotate_wisdom() {
    if [ -f "$JESTER_DIR/.wisdom_pool" ]; then
        # Get a random line from wisdom pool
        WISDOM=$(awk 'BEGIN{srand()} {lines[NR]=$0} END{print lines[int(rand()*NR)+1]}' "$JESTER_DIR/.wisdom_pool")
        echo "$WISDOM" > "$JESTER_DIR/wisdom"
    fi
}

# Update jester mood based on system state
update_jester_mood() {
    # Check if actively writing (vim running)
    if pgrep -x vim > /dev/null; then
        MOOD="Writing!"
    else
        MOOD="Idle"
    fi
    
    # Update the jester display
    cat > "$JESTER_DIR/jester" << EOF
     ___
    /o o\   JesterOS v1.0
   | > < |  "By quill and wit!"  
   |  ~  |  
    \___/   Status: Active
     | |    Mood: $MOOD
    /   \   
   d     b  
EOF
}

# Main initialization
main() {
    echo "Starting JesterOS Userspace Service..."
    
    create_jesteros_dirs
    init_jester
    init_typewriter
    init_wisdom
    
    echo "JesterOS initialized at $JESTER_DIR"
    echo "Try: cat $JESTER_DIR/jester"
    echo "     cat $JESTER_DIR/typewriter/stats"
    echo "     cat $JESTER_DIR/wisdom"
    
    # If running as daemon, periodically update
    if [ "$1" = "--daemon" ]; then
        echo "Running as daemon..."
        while true; do
            sleep 60
            update_jester_mood
            rotate_wisdom
        done
    fi
}

# Run main function
main "$@"