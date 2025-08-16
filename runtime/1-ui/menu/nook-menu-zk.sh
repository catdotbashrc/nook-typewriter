#!/bin/bash
set -eu

# Nook Menu with zk Integration
# Uses zk for powerful note management

# Clear screen and show menu
fbink -c || true
fbink -y 2 "NOOK WRITING SYSTEM" || true
fbink -y 3 "═══════════════════" || true
fbink -y 5 "[N] New Note (zk)" || true
fbink -y 6 "[D] Daily Note" || true
fbink -y 7 "[S] Search Notes" || true
fbink -y 8 "[R] Recent Notes" || true
fbink -y 9 "[I] New Idea" || true
fbink -y 10 "[W] Word Count" || true
fbink -y 11 "[C] Cloud Sync" || true
fbink -y 12 "[Q] Shutdown" || true
fbink -y 14 "Select: " || true

# Read single character with timeout
read -r -n 1 -t 30 choice || true

case "${choice:-}" in
  n|N)
    # Create new note with zk
    echo "Enter note title: "
    read -r title
    cd ~/notes
    zk new --title "$title" --edit
    ;;
  
  d|D)
    # Create daily note
    cd ~/notes
    zk new --group daily --edit
    ;;
  
  s|S)
    # Search notes interactively
    cd ~/notes
    zk edit --interactive
    ;;
  
  r|R)
    # Show recent notes
    cd ~/notes
    zk list --sort created- --limit 10 --interactive --edit
    ;;
  
  i|I)
    # Create new idea
    echo "Enter idea title: "
    read -r title
    cd ~/notes
    zk new --group ideas --title "$title" --edit
    ;;
  
  w|W)
    # Show word count statistics
    fbink -c || true
    fbink -y 2 "WORD COUNT STATISTICS" || true
    fbink -y 3 "═══════════════════" || true
    
    cd ~/notes
    # Get total word count
    total=$(zk list --format "{{word-count}}" | awk '{sum+=$1} END {print sum}')
    fbink -y 5 "Total: $total words" || true
    
    # Get today's count
    today=$(zk list --created today --format "{{word-count}}" | awk '{sum+=$1} END {print sum}')
    fbink -y 6 "Today: $today words" || true
    
    # Show recent notes with word counts
    fbink -y 8 "Recent notes:" || true
    zk list --sort created- --limit 5 --format "{{word-count}}w: {{title}}" | head -5 | while IFS= read -r line; do
      fbink -y $((9 + ${LINENO})) "$line" || true
    done
    
    fbink -y 15 "Press any key..." || true
    read -n 1
    exec "$0"
    ;;
  
  c|C)
    # Sync to cloud
    /usr/local/bin/sync-notes.sh || echo "Sync failed"
    ;;
  
  q|Q)
    # Shutdown
    fbink -c || true
    fbink -y 5 "Fare thee well, scribe!" || true
    fbink -y 7 "Thy words are saved." || true
    sleep 2
    /sbin/poweroff || poweroff
    ;;
  
  *)
    # Invalid choice - restart menu
    exec "$0"
    ;;
esac

# Return to menu after action
exec "$0"