#!/usr/bin/env bash
set -e

CLIPBOARD_DIR="$HOME/.local/share"
CLIPBOARD_FILE="$CLIPBOARD_DIR/clipboard.txt"

mkdir -p "$CLIPBOARD_DIR"
touch "$CLIPBOARD_FILE"

# -------------------------
# Clear clipboard
# -------------------------
if [ "$#" -eq 1 ]; then
  case "$1" in
    -c|--clear)
      : > "$CLIPBOARD_FILE"
      exit 0
      ;;
  esac
fi

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
    $'\x1b') # escape / arrows / paging
      read -rsn1 k1 || true
      if [[ "$k1" == "[" ]]; then
        read -rsn1 k2 || true
        case "$k2" in
          A) ((SELECTED > 0)) && SELECTED=$((SELECTED - 1)) ;; # Up
          B) ((SELECTED < COUNT - 1)) && SELECTED=$((SELECTED + 1)) ;; # Down
          5) # Page Up
            read -rsn1 _ || true # consume '~'
            rows=$(tput lines)
            SELECTED=$((SELECTED - rows + 1))
            ((SELECTED < 0)) && SELECTED=0
            ;;
          6) # Page Down
            read -rsn1 _ || true # consume '~'
            rows=$(tput lines)
            SELECTED=$((SELECTED + rows - 1))
            ((SELECTED >= COUNT)) && SELECTED=$((COUNT - 1))
            ;;
        esac
      else
        exit 0 # plain Esc
      fi
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
