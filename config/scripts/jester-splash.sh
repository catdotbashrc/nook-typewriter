#!/bin/bash
# Animated Jester Splash Screen for E-Ink Display
# A mischievous jester greets writers on boot!

# Use FBInk for E-Ink display or terminal fallback
display() {
    if command -v fbink >/dev/null 2>&1; then
        fbink -c  # Clear screen
        fbink -y 10 "$1" 2>/dev/null
    else
        clear
        echo "$1"
    fi
}

# Jester animation frames
frame1() {
    cat << 'EOF'
                    .~"~.
                   /  o o \
                  |  >  < |    
                   \ --- /     
                    |~|~|      
                   d|   |b     
                    |   |      
                   /|   |\     
                  d |   | b    
                    ^^^^       
        "Hark! A writer approaches!"
EOF
}

frame2() {
    cat << 'EOF'
                    .~"~.
                   /  ^ ^ \
                  |  > ◡< |    *jingle*
                   \ --- /     
                 ~~~|~|~|~~~   
                   d|   |b     
                    | \ |      
                   /|  \|\     
                  d |   | b    
                    ^^^^       
          "Time to tickle the keys!"
EOF
}

frame3() {
    cat << 'EOF'
                    .~"~.
                   /  - - \
                  |  > o< |     
                   \ --- /      ♪♫
              ~~~~~ |~|~| ~~~~~
                  / |   | \    
                 /  |   |  \   
                d   |   |   b  
                    |   |      
                    ^^^^       
            *does a little dance*
EOF
}

frame4() {
    cat << 'EOF'
                    .~"~.
                   /  * * \
                  |  > ◡< |    ✨
                   \ --- /     
                    |~|~|      
                   d| ♦ |b     
                    |   |      
                    |\  |      
                   d| \ |b     
                    ^^^^       
         "Your muse has arrived!"
EOF
}

frame5() {
    cat << 'EOF'
                     ___
                    .~"~.
                   /  ^ ^ \    
                  |  > ◡< |   ✎
                   \ --- /     
                    |~|~|      
                   d|   |b     
                    |   |      
                   /|   |\     
                  d |   | b    
                    ^^^^       
    "By quill and candlelight, we write!"
EOF
}

# Juggling animation sequence
juggle1() {
    cat << 'EOF'
                    .~"~.      o
                   /  ^ ^ \    
                  |  > ◡< |    
                   \ --- /     
                    |~|~|      
                   d| • |b     
                    |   |      
                   /|\  |      
                  d | \ |b     
                    ^^^^       
EOF
}

juggle2() {
    cat << 'EOF'
                    .~"~.    o   o
                   /  * * \    
                  |  > ◡< |    
                   \ --- /     
                    |~|~|      
                   d|   |b     
                    | • |      
                    |  \|      
                   d|   |b     
                    ^^^^       
EOF
}

juggle3() {
    cat << 'EOF'
                    .~"~.  o   o   o
                   /  ^ ^ \    
                  |  > ◡< |    
                   \ --- /     
                    |~|~|      
                   d|   |b     
                    |   |      
                   /| • |\     
                  d |   | b    
                    ^^^^       
EOF
}

# Play the animation
play_animation() {
    # Opening sequence
    display "$(frame1)"
    sleep 0.8
    
    display "$(frame2)"
    sleep 0.8
    
    display "$(frame3)"
    sleep 0.8
    
    # Juggling sequence (mischievous!)
    for i in {1..3}; do
        display "$(juggle1)"
        sleep 0.3
        display "$(juggle2)"
        sleep 0.3
        display "$(juggle3)"
        sleep 0.3
    done
    
    # Finale
    display "$(frame4)"
    sleep 1
    
    display "$(frame5)"
    sleep 2
}

# Boot greeting with animation
show_boot_greeting() {
    # Play the animation
    play_animation
    
    # Final message
    display "$(cat << 'EOF'

═══════════════════════════════════════════════════════════════

           N O O K   T Y P E W R I T E R
           
              QuillKernel Edition
           
     "Your Court Jester awaits your command!"

═══════════════════════════════════════════════════════════════

            Press any key to begin...

EOF
)"
    
    # Wait for keypress or timeout
    read -n 1 -t 5 || true
}

# Main execution
case "${1:-boot}" in
    boot)
        show_boot_greeting
        ;;
    test)
        # Test mode - run all animations
        echo "Testing jester animations..."
        play_animation
        ;;
    *)
        echo "Usage: $0 {boot|test}"
        ;;
esac