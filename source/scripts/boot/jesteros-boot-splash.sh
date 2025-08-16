#!/bin/sh
# JesterOS Boot Splash
# Displays the glorious JesterOS logo at boot

# Safety settings for reliable boot display
set -eu
trap 'echo "Error in jesteros-boot-splash.sh at line $LINENO" >&2' ERR

# Boot logging configuration
BOOT_LOG="${BOOT_LOG:-/var/log/jesteros-boot.log}"
boot_log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [jesteros-boot-splash] $1" >> "$BOOT_LOG" 2>/dev/null || true
}

boot_log "Starting JesterOS boot splash"

# Function to display on E-Ink or terminal
display() {
    local content="${1:-}"
    if command -v fbink >/dev/null 2>&1; then
        boot_log "Using E-Ink display via fbink"
        fbink -c 2>/dev/null  # Clear screen
        fbink -y 5 "$content" 2>/dev/null || echo "$content"
    else
        boot_log "Using terminal display (fbink not available)"
        clear
        echo "$content"
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

                          @ @ @@ @ @                         
                        @@@ @@@@@@ @@@                       
                       @@@@  @@@@  @@@@                      
                      @@  @@@◉  ◉@@@  @@                     
                     @@ @@    ⌣    @@ @@                     
      @@@@@@@@@@@@@@@@ `@@@@@    @@@@@  @@@@@@@@@@@@@@@     
    @@@@               @@aa$@@@@@@@ao@@               @@@@   
   @@                 @@oa#oooaaaooooo@@                 @@  
  @@    @@@@@@@@@@@@@ @@@@ooooooooo@@@@@@@@@@@@@@@@@@     @@ 
   @@@@@@$aao@@@@o*@@@@@@$@@@ooooo@@@ @@@@@@*$@@ @aao@@@@@@  
    
         Your Court Jester awakens to serve!
       Ready to assist thy noble writing quest!
         *jingle jingle* The bells do ring!   

        ═══════════════════════════════════════
EOF
}

# Main
boot_log "Displaying JesterOS logo"
display "$(show_logo)"

# Show for 3 seconds if not in daemon mode
if [ "${1:-}" != "--quick" ]; then
    boot_log "Holding splash screen for 3 seconds"
    sleep 3
else
    boot_log "Quick mode - skipping splash delay"
fi

boot_log "Boot splash complete"