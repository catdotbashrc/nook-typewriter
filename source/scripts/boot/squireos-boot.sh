#!/bin/bash
# SquireOS Boot Sequence with E-Ink Friendly Animations
# Shows branded startup sequence with jester mascot

# Safety settings for reliable boot
set -euo pipefail
trap 'echo "Error in squireos-boot.sh at line $LINENO" >&2' ERR

# Boot logging configuration
BOOT_LOG="${BOOT_LOG:-/var/log/jesteros-boot.log}"
boot_log() {
    local level="${1:-INFO}"
    local message="${2:-}"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] [squireos-boot] $message" >> "$BOOT_LOG" 2>/dev/null || true
    [ "$level" = "ERROR" ] && echo "[squireos-boot] ERROR: $message" >&2
}

boot_log "INFO" "Starting SquireOS boot sequence"

# Source common functions and safety settings
COMMON_PATH="${COMMON_PATH:-/usr/local/bin/common.sh}"
if [[ -f "$COMMON_PATH" ]]; then
    source "$COMMON_PATH"
    # Override e_sleep if needed for boot sequence
    BOOT_PHASE_DELAY="${BOOT_PHASE_DELAY:-0.5}"
    BOOT_ITEM_DELAY="${BOOT_ITEM_DELAY:-0.2}"
else
    # Common.sh not found, but safety already set at top
    boot_log "WARN" "Common library not found at $COMMON_PATH"
    BOOT_PHASE_DELAY=0.5
    BOOT_ITEM_DELAY=0.2
fi

# Function to display with FBInk or fallback to echo
display() {
    local y_pos="${1:-0}"
    shift
    local text="$*"
    if [[ "${SQUIREOS_COMMON_LOADED:-0}" == "1" ]] && has_eink; then
        fbink -y "$y_pos" "$text" 2>/dev/null || boot_log "WARN" "Failed to display text at y=$y_pos"
    else
        echo "$text"
    fi
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

# Function to sleep with E-Ink consideration (if not from common.sh)
if ! declare -f e_sleep >/dev/null 2>&1; then
    e_sleep() {
        sleep "${1:-0.3}"
    }
fi

# Start boot sequence
boot_log "INFO" "Initializing display for boot sequence"
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
e_sleep "$BOOT_PHASE_DELAY"

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
e_sleep "$BOOT_PHASE_DELAY"

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
e_sleep "$BOOT_PHASE_DELAY"

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
e_sleep "${LONG_DELAY:-1.5}"

# Phase 5: Loading sequence
clear_screen
display 2 "SquireOS Parchment (1.0.0)"
display 3 "=========================="
display 5 "Preparing thy digital scriptorium..."
e_sleep "$BOOT_ITEM_DELAY"

display 7 "[✓] Candles lit"
e_sleep "$BOOT_ITEM_DELAY"

display 8 "[✓] Quills sharpened"
e_sleep "$BOOT_ITEM_DELAY"

display 9 "[✓] Inkwells filled"
e_sleep "$BOOT_ITEM_DELAY"

display 10 "[✓] Parchment unfurled"
e_sleep "$BOOT_ITEM_DELAY"

display 11 "[✓] Ancient wisdom loaded"
e_sleep "$BOOT_ITEM_DELAY"

display 12 "[✓] Revolutionary writing methods initialized"
e_sleep "$BOOT_ITEM_DELAY"

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
e_sleep "$BOOT_PHASE_DELAY"

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
e_sleep "$BOOT_PHASE_DELAY"

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
e_sleep "${LONG_DELAY:-1.5}"

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
e_sleep "$BOOT_PHASE_DELAY"

display_centered "Starting literary workshop in 2..."
e_sleep "$BOOT_PHASE_DELAY"

display_centered "Starting literary workshop in 1..."
e_sleep "$BOOT_PHASE_DELAY"

# Clear for menu
clear_screen

# If this is the actual boot script, start the menu
# Otherwise just exit (for testing)
if [ "${1:-}" == "--start-menu" ]; then
    boot_log "INFO" "Starting squire menu"
    if [ -x /usr/local/bin/squire-menu.sh ]; then
        exec /usr/local/bin/squire-menu.sh
    else
        boot_log "ERROR" "Squire menu not found or not executable"
        echo "ERROR: Cannot start squire menu!" >&2
        exit 1
    fi
else
    boot_log "INFO" "Boot sequence complete (test mode)"
fi