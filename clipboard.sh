#!/usr/bin/env bash
set -e

CLIPBOARD_DIR="$HOME/.local/share"
CLIPBOARD_FILE="$CLIPBOARD_DIR/clipboard.txt"

mkdir -p "$CLIPBOARD_DIR"
touch "$CLIPBOARD_FILE"

# -------------------------
# Append mode
# -------------------------
if [ "$#" -gt 0 ]; then
  printf '%s\n' "$*" >> "$CLIPBOARD_FILE"
  exit 0
fi

# -------------------------
# Interactive mode
# -------------------------
mapfile -t LINES < "$CLIPBOARD_FILE"
COUNT="${#LINES[@]}"

[ "$COUNT" -eq 0 ] && exit 0

SELECTED=$((COUNT - 1))

# terminal setup
stty -echo -icanon time 0 min 0
tput civis
cleanup() {
  stty sane
  tput cnorm
  clear
}
trap cleanup EXIT

draw() {
  clear
  rows=$(tput lines)
  cols=$(tput cols)

  start=0
  if [ "$SELECTED" -ge "$rows" ]; then
    start=$((SELECTED - rows + 1))
  fi

  for ((i=start; i<COUNT && i<start+rows; i++)); do
    line="${LINES[i]}"
    truncated="${line:0:cols-4}"

    if [ "$i" -eq "$SELECTED" ]; then
      printf "> %s\n" "$truncated"
    else
      printf "  %s\n" "$truncated"
    fi
  done
}

draw

while true; do
  IFS= read -rsn1 key

  case "$key" in
    $'\x1b') # escape or arrow
      read -rsn2 rest || true
      case "$rest" in
        "[A") ((SELECTED > 0)) && SELECTED=$((SELECTED - 1)) ;;
        "[B") ((SELECTED < COUNT - 1)) && SELECTED=$((SELECTED + 1)) ;;
        "") exit 0 ;; # Esc
      esac
      ;;
    "") # Enter
      echo "${LINES[SELECTED]}"
      exit 0
      ;;
    $'\x7f'|$'\b') # Backspace / Delete
      unset 'LINES[SELECTED]'
      LINES=("${LINES[@]}")
      COUNT="${#LINES[@]}"

      printf '%s\n' "${LINES[@]}" > "$CLIPBOARD_FILE"

      ((SELECTED >= COUNT)) && SELECTED=$((COUNT - 1))
      [ "$COUNT" -eq 0 ] && exit 0
      ;;
  esac

  draw
done
