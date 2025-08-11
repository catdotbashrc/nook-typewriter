#!/bin/bash
# Mischievous Jester Animations for E-Ink
# Random silly antics to delight writers!

# Array of mischievous animations
declare -a MISCHIEF

# Jester hiding behind text
MISCHIEF[0]=$(cat << 'EOF'
    Loading your writing environment...
                                    .~"~.
                                   /  o o\
    ████████████████████          |  >.<| 
    ████████████████████           \___/  
    ████████████████████            |~|   
                                    d| |b  
        "Psst! Found me!"
EOF
)

# Jester upside down
MISCHIEF[1]=$(cat << 'EOF'
                    ^^^^       
                  b |   | d    
                   \|   |/     
                    |   |      
                   q|~|~|p     
                   / --- \     
                  |  <◡> |    
                   \ o o /
                    '~"~'
                    
        "Oops! Wrong way up!"
EOF
)

# Jester stealing a letter
MISCHIEF[2]=$(cat << 'EOF'
    W R I T I N G   S Y S T E M
              ^
              |
         .~"~.|
        /  ^ ^ \
       |  >◡<  |  "I'll take this 'T'!"
        \ --- /
         |~|~|
        d| T |b
         |   |
        /|   |\
       d |   | b
         ^^^^
EOF
)

# Jester riding a quill
MISCHIEF[3]=$(cat << 'EOF'
                    .~"~.
                   /  ^ ^ \
                  |  >◡<  |  "Wheee!"
                   \ --- /
                    |~|~|
                   d|   |b
            _____|_____|_____
           /                 \
          (  ~~~~~~~~~~~~~~~  )
           \_______________,/
                  |||
                  |||  <- Giant Quill
                  |||
                   V
EOF
)

# Jester playing with punctuation
MISCHIEF[4]=$(cat << 'EOF'
        . . . ! ! ! ? ? ?
           \  |  /
            \ | /
           .~"~.
          /  * * \
         |  >◡<  |  *juggling punctuation*
          \ --- /
           |~|~|
          d| ; |b
           | : |
          /| , |\
         d |   | b
           ^^^^
EOF
)

# Jester peeking from side
MISCHIEF[5]=$(cat << 'EOF'
|                                           
|                                           
|  B                                        
|  O          .~.                           
|  O         / o \                          
|  T        | >◡< |  "Ready to write?"      
|  I         \__/                           
|  N          ||                            
|  G...      d||b                           
|             ||                            
|            ^^^^                           
|                                           
EOF
)

# Jester doing cartwheels
MISCHIEF[6]=$(cat << 'EOF'
     .~"~.        d^^^^b         '~"~'
    /  ^ ^ \       |  |          \ o o /
   |  >◡<  |       |  |           |<◡> |
    \ --- /       q|--|p          / --- \
     |~|~|         |  |            |~|~|
    d|   |b       /    \          d|   |b
     ^^^^        / o  o \          ^^^^
                |  <◡>  |
                 \ -- /
                  '~~'
    
         *cartwheel* *cartwheel* *cartwheel*
EOF
)

# Jester with scroll
MISCHIEF[7]=$(cat << 'EOF'
           .~"~.
          /  ^ ^ \
         |  >◡<  |
          \ --- /
           |~|~|     ╔════════════════╗
          d|   |b    ║ Today's Quest: ║
           |   |     ║ Write 500 words║
          /|   |\    ║ Reward: Joy!   ║
         d |   | b   ╚════════════════╝
           ^^^^
           
    "A quest from the kingdom!"
EOF
)

# Jester with candlelight
MISCHIEF[8]=$(cat << 'EOF'
             *
            |||
            |||      .~"~.
           |||||    /  ^ ^ \
          |||||||  |  >◡<  |  "By candlelight..."
           |||||    \ --- /
            |||      |~|~|
            |||     d|   |b
          [====]     |   |
                    /|   |\
                   d |   | b
                     ^^^^
EOF
)

# Jester sleeping (for night writing)
MISCHIEF[9]=$(cat << 'EOF'
                    .~"~.
                   /  - - \     z
                  |  > _< |    z
                   \ --- /    z
                    |~|~|
                   d|   |b
                    |   |
                   /|   |\
                  d |   | b
                    ^^^^
                    
        "Even jesters need beauty sleep..."
EOF
)

# Function to show random mischief
show_random_mischief() {
    local rand=$((RANDOM % ${#MISCHIEF[@]}))
    if command -v fbink >/dev/null 2>&1; then
        fbink -c
        fbink -y 5 "${MISCHIEF[$rand]}" 2>/dev/null
    else
        clear
        echo "${MISCHIEF[$rand]}"
    fi
    sleep 2
}

# Boot sequence with multiple mischiefs
mischievous_boot() {
    # Show 3 random mischievous animations
    for i in {1..3}; do
        show_random_mischief
    done
    
    # Final greeting
    if command -v fbink >/dev/null 2>&1; then
        fbink -c
        fbink -y 8 "$(cat << 'EOF'
                    .~"~.~"~.
                   /  ^   ^  \
                  |  >  ◡  <  |  ✨
                   \  ___  /
                    |~|♦|~|
                   d|     |b
                    
    "The Court Jester is ready to inspire!"
    
         Press any key to begin writing...
EOF
)" 2>/dev/null
    else
        clear
        cat << 'EOF'
                    .~"~.~"~.
                   /  ^   ^  \
                  |  >  ◡  <  |  ✨
                   \  ___  /
                    |~|♦|~|
                   d|     |b
                    
    "The Court Jester is ready to inspire!"
    
         Press any key to begin writing...
EOF
    fi
    
    read -n 1 -t 5 || true
}

# Easter egg animations for special occasions
show_easter_egg() {
    local hour=$(date +%H)
    
    # Late night writing easter egg
    if [ "$hour" -ge 23 ] || [ "$hour" -le 4 ]; then
        echo "${MISCHIEF[9]}"  # Sleepy jester
    # Morning greeting
    elif [ "$hour" -ge 5 ] && [ "$hour" -le 9 ]; then
        echo "${MISCHIEF[8]}"  # Candlelight jester
    else
        show_random_mischief
    fi
}

# Main execution
case "${1:-boot}" in
    boot)
        mischievous_boot
        ;;
    random)
        show_random_mischief
        ;;
    easter)
        show_easter_egg
        ;;
    all)
        # Show all animations (for testing)
        for i in "${!MISCHIEF[@]}"; do
            echo "Animation $i:"
            echo "${MISCHIEF[$i]}"
            echo ""
            sleep 2
        done
        ;;
    *)
        echo "Usage: $0 {boot|random|easter|all}"
        ;;
esac