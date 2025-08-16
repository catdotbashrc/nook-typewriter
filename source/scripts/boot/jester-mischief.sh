#!/bin/sh
# Jester Mischief Animations
# Boot-time animations and mischievous displays for E-Ink
# "The jester's bells jingle with glee!"

# Safety settings for reliable animation
set -eu
trap 'echo "Error in jester-mischief.sh at line $LINENO" >&2' ERR

# Boot logging
BOOT_LOG="${BOOT_LOG:-/var/log/jesteros-boot.log}"
log_animation() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [jester-mischief] $1" >> "$BOOT_LOG" 2>/dev/null || true
}

# Display function with E-Ink support
display_animation() {
    if command -v fbink >/dev/null 2>&1; then
        # E-Ink display mode
        fbink -c 2>/dev/null
        fbink -y 10 "$1" 2>/dev/null || echo "$1"
    else
        # Terminal fallback
        echo "$1"
    fi
}

# ASCII art animations
show_jester_dance() {
    cat << 'JESTER1'
       .~"~.~"~.
      /  ^   ^  \
     |  >  ◡  <  |    *jingle*
      \  ___  /           *jingle*
       |~|♦|~|
      d|     |b
JESTER1
    sleep 1
    
    cat << 'JESTER2'
       .~"~.~"~.
      /  -   -  \
     |  >  ~  <  |        *jingle*
      \  ___  /       *jingle*
       |~|♦|~|
      b|     |d
JESTER2
    sleep 1
}

# Main animation sequence
main() {
    local mode="${1:-boot}"
    
    log_animation "Starting $mode animations"
    
    case "$mode" in
        boot)
            display_animation "The jester awakens with mischievous glee!"
            sleep 1
            show_jester_dance
            display_animation "*jingle jingle* The bells do ring!"
            sleep 1
            display_animation "Ready to serve thy writing quest!"
            ;;
        menu)
            display_animation "The jester juggles menu options..."
            ;;
        shutdown)
            display_animation "The jester bows and retires..."
            sleep 1
            display_animation "Until next time, noble writer!"
            ;;
        *)
            display_animation "The jester performs a merry jig!"
            ;;
    esac
    
    log_animation "Animation sequence complete"
}

# Run animation
main "$@"