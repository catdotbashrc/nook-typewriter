#!/bin/sh
# JesterOS Boot Splash - E-Ink Optimized Version
# Designed for 800x600 6" grayscale display

# Function to center text (approximately)
center_text() {
    printf "%*s\n" $(( (80 + ${#1}) / 2 )) "$1"
}

# Clear and prepare display
if command -v fbink >/dev/null 2>&1; then
    # Full refresh for E-Ink
    fbink -c
fi

clear

# Display the E-Ink optimized jester
cat << 'JESTER_BOOT'


                    =============================
                    |                           |
                    |      J E S T E R O S      |
                    |         v 1 . 0           |
                    |                           |
                    =============================
    
    
                           .===========.
                          /             \
                         |   /\     /\   |
                         |   @@     @@   |
                         |       <       |
                         |    \  _  /    |
                         |     '---'     |
                          \             /
                           '==========='
                            /  /| |\  \
                           /  / | | \  \
                          /__/  | |  \__\
                         <___>  | |  <___>
                               /   \
                              /     \
                             /       \
                            /_       _\
                           (__) | | (__)
                            | | | | | |
                            | | | | | |
                            |_| |_| |_|
                           (___) (___)
    
    
              "By quill and candlelight, we write!"
    
    
    ========================================================
                  Preparing thy writing chamber...
    ========================================================

JESTER_BOOT

# Simple loading indicator for E-Ink
echo ""
echo -n "    Initializing"
for i in 1 2 3 4 5 6 7 8; do
    echo -n "."
    sleep 0.3
done
echo " Ready!"
echo ""

# Add boot messages for medieval flavor
sleep 0.5
echo "    [OK] Summoned the ancient muse"
sleep 0.3
echo "    [OK] Sharpened thy digital quill"
sleep 0.3
echo "    [OK] Unrolled the infinite parchment"
sleep 0.3
echo "    [OK] Lit the candles of inspiration"
sleep 0.3
echo "    [OK] Awakened the jester's spirit"
sleep 0.5

echo ""
echo "    ========================================"
echo "       Welcome, Noble Writer!"
echo "       May thy words flow like honey!"
echo "    ========================================"
echo ""

# Pause to let E-Ink display settle
sleep 3