#!/bin/bash
# SquireOS Boot Sequence with E-Ink Friendly Animations
# Shows branded startup sequence with jester mascot

# Function to display with FBInk or fallback to echo
display() {
    local y_pos=$1
    shift
    local text="$@"
    fbink -y "$y_pos" "$text" 2>/dev/null || echo "$text"
}

# Function to clear screen
clear_screen() {
    fbink -c 2>/dev/null || clear
}

# Function to display centered text
display_centered() {
    local text="$1"
    fbink -C "$text" 2>/dev/null || echo "$text"
}

# Function to sleep with E-Ink consideration
e_sleep() {
    sleep "$1"
}

# Start boot sequence
clear_screen

# Phase 1: Candle lighting
cat << 'EOF' | fbink -S 2>/dev/null || cat
           Medieval Boot Sequence Initiated
          ===================================

                    Lighting candles...

                         .
                         |
                       / |
                      |  |
                      |  |
                     [____]
EOF
e_sleep 1

# Phase 2: Candle lit
clear_screen
cat << 'EOF' | fbink -S 2>/dev/null || cat
                         ,
                        /|
                       / |
                      |  |
                      |  |
                     [____]

                  The scriptorium awakens...
EOF
e_sleep 1

# Phase 3: Jester appears (partial)
clear_screen
cat << 'EOF' | fbink -S 2>/dev/null || cat
                         ,
                        /|
       .~"~.~"~.       / |
      /  -   -  \     |  |
                      |  |
                     [____]

            Your squire stirs from slumber...
EOF
e_sleep 1

# Phase 4: Jester fully appears
clear_screen
cat << 'EOF' | fbink -S 2>/dev/null || cat
                         ,
                        /|
       .~"~.~"~.       / |
      /  o   o  \     |  |
     |  >  ◡  <  |    |  |
      \  ___  /      [____]
       |~|♦|~|
      d|     |b    

         *yawn* "Good morrow, m'lord!"
EOF
e_sleep 2

# Phase 5: Loading sequence
clear_screen
display 2 "SquireOS Parchment (1.0.0)"
display 3 "=========================="
display 5 "Preparing thy digital scriptorium..."
e_sleep 0.5

display 7 "[✓] Candles lit"
e_sleep 0.3

display 8 "[✓] Quills sharpened"
e_sleep 0.3

display 9 "[✓] Inkwells filled"
e_sleep 0.3

display 10 "[✓] Parchment unfurled"
e_sleep 0.3

display 11 "[✓] Ancient wisdom loaded"
e_sleep 0.3

display 12 "[✓] Revolutionary writing methods initialized"
e_sleep 0.5

# Phase 6: Jester juggling
clear_screen
cat << 'EOF' | fbink -S 2>/dev/null || cat
       .~"~.~"~.      S
      /  ^   ^  \    q u
     |  >  ◡  <  |  i   r
      \  ___  /    r     e
       |~|♦|~|      e   O
      d|     |b        S

    "Watch me juggle the letters!"
EOF
e_sleep 1

# Phase 7: Dropped letter
clear_screen
cat << 'EOF' | fbink -S 2>/dev/null || cat
       .~"~.~"~.      S
      /  o   o  \    q u
     |  >  <  |  i   r
      \  ___  /         e
       |~|♦|~|      
      d|     |b     O    S

    "Oops! I dropped one!"
EOF
e_sleep 1

# Phase 8: Final logo
clear_screen
cat << 'EOF' | fbink -S 2>/dev/null || cat
       .~"~.~"~.
      /  @   @  \
     | >  ___  < |
     |  \  ~  /  |
      \  '---'  /
    .~`-._____.-'~.
   /   |~|~|~|   \       ___             _           ___  ___ 
  |  //|  ♦  |\\  |     / __| __ _ _  _ (_)_ _ ___  / _ \/ __|
  |=// |     | \\=|     \__ \/ _` | || || | '_/ -_)| (_) \__ \
  |/   |     |   \|     |___/\__, |\_,_||_|_| \___| \___/|___/
 /|    | ಠ_ಠ |    |\            |_|                            
d |    |_____|    | b     
  |   /|     |\   |      Version 1.0.0 (Parchment)
  |__/ |     | \__|      "By quill and candlelight"
 (_)   |     |   (_)
       (_)   (_)

    "I dropped the quill!"
EOF
e_sleep 2

# Phase 9: Daily wisdom
clear_screen
# Select random wisdom
WISDOMS=(
    "\"Do not force yourself to write when you have nothing to say.\" - An ancient scribe"
    "\"The method borrowed from the Chinese pharmacy is most crude.\" - A wise philosopher"
    "\"Writers are engineers of human souls.\" - A mustachioed poet"
)
wisdom=${WISDOMS[$RANDOM % ${#WISDOMS[@]}]}

cat << EOF | fbink -S 2>/dev/null || cat
       .~"~.~"~.
      /  -   -  \     Today's Ancient Wisdom:
     |  >  ~  <  |    
      \  ___  /       $wisdom
       |~|♦|~|        
      d|     |b       

EOF
e_sleep 3

# Phase 10: Ready message
clear_screen
cat << 'EOF' | fbink -S 2>/dev/null || cat
       .~"~.~"~.
      /  ^   ^  \
     |  >  ◡  <  |    SquireOS Ready!
      \  ___  /       
       |~|♦|~|        "Your faithful squire awaits thy command!"
      d|     |b       

    Starting literary workshop in 3...
EOF
e_sleep 1

display_centered "Starting literary workshop in 2..."
e_sleep 1

display_centered "Starting literary workshop in 1..."
e_sleep 1

# Clear for menu
clear_screen

# If this is the actual boot script, start the menu
# Otherwise just exit (for testing)
if [ "$1" == "--start-menu" ]; then
    exec /usr/local/bin/squire-menu.sh
fi