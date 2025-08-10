#!/bin/bash
set -eu

REMOTE="${RCLONE_REMOTE:-remote}"
PATH_REMOTE="${RCLONE_PATH:-nook-notes}"
SRC="${NOTES_DIR:-$HOME/notes}"

if ! command -v rclone >/dev/null 2>&1; then
  echo "rclone not installed" >&2
  exit 1
fi

if [ ! -f "$HOME/.config/rclone/rclone.conf" ]; then
  echo "Missing rclone config at $HOME/.config/rclone/rclone.conf" >&2
  echo "Run 'rclone config' to set up cloud storage" >&2
  exit 1
fi

mkdir -p "$SRC"
echo "Syncing $SRC to ${REMOTE}:${PATH_REMOTE}..."
rclone sync "$SRC" "${REMOTE}:${PATH_REMOTE}" -v
echo "Sync complete"
