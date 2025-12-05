#!/usr/bin/env bash

set -e

SCRIPT_NAME="zoneless"
INSTALL_DIR="$HOME/.local/bin"
BASHRC="$HOME/.bashrc"

remove_zone_identifiers() {
    TARGET="${1:-.}"

    echo "Removing Zone.Identifier streams under: $TARGET"
    find "$TARGET" -type f -print0 2>/dev/null | while IFS= read -r -d '' FILE; do
        if [ -e "${FILE}:Zone.Identifier" ]; then
            rm -f "${FILE}:Zone.Identifier"
            echo "Removed: $FILE"
        fi
    done
    echo "Done."
}

install_script() {
    echo "Installing $SCRIPT_NAME ..."

    mkdir -p "$INSTALL_DIR"

    # Copy this script into ~/.local/bin/zoneless
    # Resolve full path of this script
    THIS_SCRIPT="$(realpath "$0")"
    cp "$THIS_SCRIPT" "$INSTALL_DIR/$SCRIPT_NAME"
    chmod +x "$INSTALL_DIR/$SCRIPT_NAME"

    # Ensure ~/.local/bin is in PATH
    if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
        if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$BASHRC" 2>/dev/null; then
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$BASHRC"
            echo "Added ~/.local/bin to PATH in $BASHRC"
        fi
    fi

    echo "Installed! Open a new terminal or run:"
    echo "    source ~/.bashrc"
    echo ""
    echo "Now you can run:"
    echo "    zoneless [directory]"
}

# --- main ---
if [[ "$1" == "--install" ]]; then
    install_script
    exit 0
fi

remove_zone_identifiers "$1"
