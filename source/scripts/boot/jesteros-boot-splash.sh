#!/bin/sh
# JesterOS Boot Splash
# Displays the glorious JesterOS logo at boot

# Function to display on E-Ink or terminal
display() {
    if command -v fbink >/dev/null 2>&1; then
        fbink -c 2>/dev/null  # Clear screen
        fbink -y 5 "$1" 2>/dev/null || echo "$1"
    else
        clear
        echo "$1"
    fi
}

# Show the amazing JesterOS logo!
show_logo() {
    cat << 'EOF'

   88                                                    
   ""                        ,d                          
                             88                          
   88  ,adPPYba, ,adPPYba, MM88MMM ,adPPYba, 8b,dPPYba,  
   88 a8P_____88 I8[    ""   88   a8P_____88 88P'   "Y8  
   88 8PP"""""""  `"Y8ba,    88   8PP""""""" 88          
   88 "8b,   ,aa aa    ]8I   88,  "8b,   ,aa 88          
   88  `"Ybbd8"' `"YbbdP"'   "Y888 `"Ybbd8"' 88          
  ,88                                                    
888P"                            OS                       


        ═══════════════════════════════════════
             Medieval Writing Companion v1.0
        ═══════════════════════════════════════

                "By quill and jest!"

     ___
    /^ ^\   Your Court Jester awakens...
   | > < |  Ready to assist thy writing!
   |  ⌣  |  
    \___/   
     | |    
    /||\   
   d | |b   

        ═══════════════════════════════════════
EOF
}

# Main
display "$(show_logo)"

# Show for 3 seconds if not in daemon mode
if [ "${1:-}" != "--quick" ]; then
    sleep 3
fi