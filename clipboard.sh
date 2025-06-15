#!/usr/bin/env bash
set -e

CLIPBOARD_DIR="$HOME/.local/share"
CLIPBOARD_FILE="$CLIPBOARD_DIR/clipboard.txt"

# ---- ensure storage exists ----
mkdir -p "$CLIPBOARD_DIR"
touch "$CLIPBOARD_FILE"

# ---- require input ----
if [ "$#" -eq 0 ]; then
  echo "Usage: clipboard.sh <any line of text>"
  exit 1
fi

# ---- append exactly one line ----
printf '%s\n' "$*" >> "$CLIPBOARD_FILE"
