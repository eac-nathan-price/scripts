#!/usr/bin/env bash
set -e

# ---- config ----
BIN_DIR="$HOME/.local/bin"
BASHRC="$HOME/.bashrc"

# ---- args ----
if [ "$#" -ne 2 ]; then
  echo "Usage: ./install.sh <script_path> <alias_name>"
  exit 1
fi

SCRIPT_PATH="$1"
ALIAS_NAME="$2"

# ---- resolve absolute path ----
if [ ! -f "$SCRIPT_PATH" ]; then
  echo "Error: script '$SCRIPT_PATH' does not exist"
  exit 1
fi

SCRIPT_PATH="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)/$(basename "$SCRIPT_PATH")"

# ---- ensure executable ----
chmod +x "$SCRIPT_PATH"

# ---- ensure bin dir ----
mkdir -p "$BIN_DIR"

TARGET="$BIN_DIR/$ALIAS_NAME"

# ---- overwrite existing alias ----
if [ -e "$TARGET" ]; then
  echo "Warning: overwriting existing '$TARGET'"
  rm -f "$TARGET"
fi

ln -s "$SCRIPT_PATH" "$TARGET"

# ---- ensure PATH ----
if ! grep -q "$BIN_DIR" "$BASHRC"; then
  echo "" >> "$BASHRC"
  echo "# Added by install.sh" >> "$BASHRC"
  echo "export PATH=\"\$PATH:$BIN_DIR\"" >> "$BASHRC"
fi

echo "Installed '$ALIAS_NAME' → $SCRIPT_PATH"

# ---- attempt immediate refresh ----
if [ -n "$BASH_VERSION" ]; then
  echo "Reloading shell configuration..."
  source "$BASHRC" || true
fi

echo "Done."
echo "You can now run '$ALIAS_NAME' from any directory."
