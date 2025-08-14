#!/bin/sh
# JesterOS Boot Splash Screen
# "A grand entrance for our noble fool!"

# Clear screen for dramatic effect
clear

# Display the magnificent jester!
cat << 'JESTER_SPLASH'

    ═══════════════════════════════════════════════════════════════
    
                         ╔═══════════════════╗
                         ║   JESTEROS v1.0   ║
                         ╚═══════════════════╝
    
                              ___...___ 
                            .:::::::::::.
                           /:::::::::::::\
                          |::====::====::|
                          |  ┌─┐  ┌─┐  |
                          C  │●│  │●│  D
                          |  └─┘  └─┘  |
                          |      <      |
                          |    \___/    |
                           \   '---'   /
                            '--_____--'
                             /|/|\|/|\
                            / |/|\|/| \
                           /  |===|  \
                          /__/     \__\
                         (___\     /___)
                        /     )   (     \
                       /     /     \     \
                      /     /       \     \
                     (____)           (____)
                     |  |               |  |
                     |  |               |  |
                     |  |               |  |
                     |__|               |__|
                    /____\             /____\
    
            "By bells and baubles, thy Nook awakens!"
    
         Loading the ancient scrolls of writerly wisdom...
    
    ═══════════════════════════════════════════════════════════════

JESTER_SPLASH

# Show loading animation
echo -n "    Summoning the muse:    "
for i in 1 2 3 4 5; do
    echo -n "🎭 "
    sleep 0.5
done
echo " Ready!"

# Brief pause to admire our jester
sleep 2