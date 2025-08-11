#!/bin/bash
set -eu

# Clear screen and show menu
fbink -c || true
fbink -y 3 "NOOK WRITING SYSTEM" || true
fbink -y 5 "[Z] Zettelkasten Mode" || true
fbink -y 6 "[D] Draft Mode" || true
fbink -y 7 "[R] Resume Session" || true
fbink -y 8 "[S] Sync Notes" || true
fbink -y 9 "[Q] Shutdown" || true
fbink -y 11 "Select: " || true

# Read single character with timeout
read -r -n 1 -t 30 choice || true

case "${choice:-}" in
  z|Z)
    mkdir -p ~/notes
    vim ~/notes/"$(date +%Y%m%d%H%M%S)".md
    ;;
  d|D)
    mkdir -p ~/drafts
    vim ~/drafts/draft.txt
    ;;
  r|R)
    if [ -f ~/drafts/draft.txt ]; then
      vim ~/drafts/draft.txt
    else
      vim ~/notes/latest.md
    fi
    ;;
  s|S)
    /usr/local/bin/sync-notes.sh || echo "Sync failed"
    ;;
  q|Q)
    /sbin/poweroff || poweroff
    ;;
  *)
    exec "$0"
    ;;
esac

# Return to menu after editing
exec "$0"