#!/bin/sh
# Animated Dancing Jester Boot Sequence
# "The fool doth dance at dawn!"

# Safety settings for reliable animation
set -eu
trap 'echo "Error in jester-dance.sh at line $LINENO" >&2' ERR

# Frame delay for animation
DELAY=0.3

# Function to clear and draw frame
draw_frame() {
    clear
    echo "$1"
    sleep "$DELAY"
}

# Jester animation frames
FRAME1='
                     JESTEROS BOOT SEQUENCE
    
                           ___...___ 
                         .:::::::::::.
                        /:::::::::::::\
                       |::====::====::|
                       |  o      o   |
                       C      <      D
                       |    \___/    |
                        \   `---`   /
                         `--.___,--`
                           /|/|\
                          / |/| \
                         /  ===  \
                        /__/   \__\
                       (___\   /___)
                           |   |
                           |   |
                           |___|
                          /     \
'

FRAME2='
                     JESTEROS BOOT SEQUENCE
    
                           ___...___ 
                         .:::::::::::.
                        /:::::::::::::\
                       |::====::====::|
                       |  -      -   |
                       C      <      D
                       |    \___/    |
                        \   `---`   /
                         `--.___,--`
                          \|/|\|/
                         \ |/| /
                        \  ===  /
                       __\     /__
                      (___/   \___) 
                          |   |
                          |   |
                          |___|
                         /     \
'

FRAME3='
                     JESTEROS BOOT SEQUENCE
    
                           ___...___ 
                         .:::::::::::.
                        /:::::::::::::\
                       |::====::====::|
                       |  ^      ^   |
                       C      <      D
                       |    \___/    |
                        \   `---`   /
                         `--.___,--`
                           /|\\|\\
                          / | \\ \\
                         /  ===  \\
                        /       \\
                       /         \\
                      |           |
                      |           |
                      |___________|
                     (_____) (_____)
'

FRAME4='
                     JESTEROS BOOT SEQUENCE
    
                           ___...___ 
                         .:::::::::::.
                        /:::::::::::::\
                       |::====::====::|
                       |  o      o   |
                       C      <      D
                       |    \\___/    |
                        \\   `---`   /
                         `--.___,--`
                          /|/|\\|\\
                         //|/| \\\\
                        // === \\\\
                       //       \\\\
                      //         \\\\
                     |             |
                     |             |
                     |_____________|
                    /               \\
'

# Play the animation
echo "Summoning the Jester..."
sleep 1

draw_frame "$FRAME1"
draw_frame "$FRAME2"
draw_frame "$FRAME3"
draw_frame "$FRAME4"
draw_frame "$FRAME3"
draw_frame "$FRAME2"
draw_frame "$FRAME1"

# Final pose with message
clear
cat << 'FINAL_JESTER'

                     =======================
                      JESTEROS INITIALIZED!
                     =======================
    
                           ___...___ 
                         .:::::::::::.
                        /:::::::::::::\
                       |::====::====::|
                       |  *      *   |
                       C      <      D
                       |    \___/    |
                        \   `---`   /
                         `--.___,--`
                          //|/|\\\\
                         // |/| \\\\
                        //  ===  \\\\
                       //_/     \\_\\\\
                      (___\\   //___)
                          ||   ||
                          ||   ||
                          ||___||
                         /_______\\
    
            "The stage is set for thy words!"
    
    ================================================

FINAL_JESTER

sleep 2