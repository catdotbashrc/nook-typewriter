#!/bin/bash
set -eu

# SquireOS Main Menu with Jester Mascot
# E-Ink optimized with graceful fallback

# Clear screen
fbink -c || clear

# Display jester header (simplified for E-Ink)
echo "
     .~\"~.~\"~.
    /  o   o  \\     SquireOS Literary Workshop  
   |  >  ◡  <  |    ========================
    \\  ___  /       
     |~|♦|~|        'Avoid the Chinese pharmacy method!'
    d|     |b              - A wise philosopher
" | fbink -S || cat

# Menu options with medieval theme
fbink -y 8 "  [S] Scribe - Begin new manuscript" || echo "[S] Scribe - Begin new manuscript"
fbink -y 9 "  [C] Chronicle - View writing statistics" || echo "[C] Chronicle - View writing statistics"
fbink -y 10 "  [I] Illuminate - Continue last work" || echo "[I] Illuminate - Continue last work"
fbink -y 11 "  [L] Library - Browse thy scrolls" || echo "[L] Library - Browse thy scrolls"
fbink -y 12 "  [M] Messenger - Sync to cloud" || echo "[M] Messenger - Sync to cloud"
fbink -y 13 "  [W] Wisdom - Writing guidance" || echo "[W] Wisdom - Writing guidance"
fbink -y 14 "  [T] Terminal - Command prompt" || echo "[T] Terminal - Command prompt"
fbink -y 15 "  [Q] Quest Complete - Shutdown" || echo "[Q] Quest Complete - Shutdown"

fbink -y 17 "What is thy bidding, m'lord? " || echo -n "What is thy bidding, m'lord? "

# Read single character with timeout
read -r -n 1 -t 60 choice || true

# Process choice
case "${choice:-}" in
  s|S)
    # Scribe mode - new document
    fbink -c || clear
    echo "
       .~\"~.~\"~.
      /  ^   ^  \\    The jester prepares fresh parchment!
     |  >  ‿  <  |   
      \\  ___  /      'Do not force yourself to write 
       |~|♦|~|        when you have nothing to say.'
                           - An ancient scribe
    " | fbink -S || cat
    sleep 2
    
    mkdir -p ~/scrolls
    timestamp=$(date +%Y%m%d_%H%M%S)
    vim ~/scrolls/manuscript_${timestamp}.md
    ;;
    
  c|C)
    # Chronicle - show statistics
    fbink -c || clear
    echo "
       .~\"~.~\"~.
      /  -   -  \\    Thy Writing Chronicle
     |  >  ~  <  |   ==================
      \\  ___  /      
       |~|♦|~|       
    " | fbink -S || cat
    
    if [ -f "$HOME/.squireos/stats" ]; then
      source "$HOME/.squireos/stats"
      echo "Words Written Today: ${WORDS_TODAY:-0}" | fbink -y 8 || echo "Words Written Today: ${WORDS_TODAY:-0}"
      echo "Total Words: ${WORDS_TOTAL:-0}" | fbink -y 9 || echo "Total Words: ${WORDS_TOTAL:-0}"
      echo "Writing Streak: ${STREAK_DAYS:-0} days" | fbink -y 10 || echo "Writing Streak: ${STREAK_DAYS:-0} days"
      echo "Manuscripts: $(find ~/scrolls -name "*.md" 2>/dev/null | wc -l)" | fbink -y 11 || echo "Manuscripts: $(find ~/scrolls -name "*.md" 2>/dev/null | wc -l)"
    else
      echo "No chronicles yet recorded, m'lord!" | fbink -y 8 || echo "No chronicles yet recorded, m'lord!"
    fi
    
    echo "" | fbink -y 13 || echo ""
    echo "Press any key to return..." | fbink -y 14 || echo "Press any key to return..."
    read -n 1 -s -r
    ;;
    
  i|I)
    # Illuminate - continue last work
    fbink -c || clear
    echo "
       .~\"~.~\"~.
      /  @   @  \\    Resuming thy great work...
     |  >  ___  <  |   
      \\  ___  /      'Read it over twice at least
       |~|♦|~|        and strike out non-essential words.'
                           - A meticulous editor
    " | fbink -S || cat
    sleep 2
    
    # Find most recent file
    latest=$(find ~/scrolls -name "*.md" -type f -printf '%T@ %p\n' 2>/dev/null | sort -nr | head -1 | cut -d' ' -f2-)
    if [ -n "$latest" ]; then
      vim "$latest"
    else
      vim ~/scrolls/first_manuscript.md
    fi
    ;;
    
  l|L)
    # Library - browse manuscripts
    fbink -c || clear
    echo "
       .~\"~.~\"~.
      /  o   o  \\    The Grand Library
     |  >  ◡  <  |   ================
      \\  ___  /      
       |~|♦|~|       Thy collected works:
    " | fbink -S || cat
    
    cd ~/scrolls 2>/dev/null || mkdir -p ~/scrolls
    ls -la *.md 2>/dev/null | head -10 | fbink -S || ls -la *.md 2>/dev/null || echo "No manuscripts found!"
    
    echo "" | fbink -y 16 || echo ""
    echo "Press any key to return..." | fbink -y 17 || echo "Press any key to return..."
    read -n 1 -s -r
    ;;
    
  m|M)
    # Messenger - sync
    fbink -c || clear
    echo "
       .~\"~.~\"~.
      /  >   >  \\    The messenger prepares...
     |  >  <  |   
      \\  ___  /      
       |~|♦|~|       
    " | fbink -S || cat
    
    /usr/local/bin/sync-notes.sh || echo "The messenger stumbled! Sync failed."
    sleep 3
    ;;
    
  w|W)
    # Wisdom - show writing advice
    fbink -c || clear
    
    # Random wisdom selector
    WISDOMS=(
      "'Writers are engineers of human souls.' - A mustachioed Georgian poet"
      "'Pay close attention to all manner of things; observe more.' - A mountain sage"
      "'We must learn to talk to the masses in their language.' - A people's teacher"
      "'Investigate and study before writing.' - A methodical researcher"
    )
    
    wisdom=${WISDOMS[$RANDOM % ${#WISDOMS[@]}]}
    
    echo "
       .~\"~.~\"~.
      /  -   -  \\    Ancient Writing Wisdom
     |  >  ~  <  |   ====================
      \\  ___  /      
       |~|♦|~|       $wisdom
    " | fbink -S || cat
    
    echo "" | fbink -y 12 || echo ""
    echo "Press any key for enlightenment..." | fbink -y 13 || echo "Press any key for enlightenment..."
    read -n 1 -s -r
    ;;
    
  t|T)
    # Terminal access
    fbink -c || clear
    echo "
       .~\"~.~\"~.
      /  o   o  \\    Entering the scriptorium basement...
     |  >  □  <  |   (Type 'exit' to return)
      \\  ___  /      
       |~|♦|~|       
    " | fbink -S || cat
    
    /bin/bash
    ;;
    
  q|Q)
    # Shutdown with animation
    fbink -c || clear
    echo "
       .~\"~.~\"~.
      /  -   -  \\    The jester retires for the evening...
     |  >  ~  <  |   
      \\  ___  /      'Til next we meet, m'lord!
       |~|♦|~|       
      d|     |b      
    " | fbink -S || cat
    
    sleep 2
    fbink -c || clear
    echo "
       .~zzZ~.
      ( - - )        Sweet dreams of grand manuscripts...
      |  ~  |   
       \\ _ /      
       |♦|♦|       
    " | fbink -S || cat
    
    sleep 2
    /sbin/poweroff || poweroff
    ;;
    
  *)
    # Invalid choice - show confused jester
    fbink -c || clear
    echo "
       .~???~.
      / o   o \\      M'lord, I know not that command!
     |   >.<   |     
     |  ___    |     
      \\ \\  / ? /     
       |♦|♦|?       
    " | fbink -S || cat
    
    sleep 2
    exec "$0"
    ;;
esac

# Return to menu after action
exec "$0"