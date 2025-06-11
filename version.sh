#!/usr/bin/env bash
set -e

VERSION_FILE=".version"

# ---- ensure version file exists ----
if [ ! -f "$VERSION_FILE" ]; then
  echo "0.0.0" > "$VERSION_FILE"
fi

CURRENT_VERSION=$(cat "$VERSION_FILE")
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

# ---- helper ----
increment_patch() {
  PATCH=$((PATCH + 1))
}

increment_minor() {
  MINOR=$1
  PATCH=$2
}

increment_major() {
  MAJOR=$1
  MINOR=$2
  PATCH=$3
}

# ---- parse arguments ----
if [ "$#" -eq 0 ]; then
  # no args → increment patch
  increment_patch
elif [ "$#" -eq 1 ]; then
  # 1 arg → minor increment with new patch
  IFS='.' read -ra PARTS <<< "$1"
  if [ "${#PARTS[@]}" -eq 1 ]; then
    # e.g., "0" → increment minor, set patch to given number
    MINOR="${PARTS[0]}"
    PATCH=0
  elif [ "${#PARTS[@]}" -eq 2 ]; then
    # e.g., "0.5" → increment minor, set patch
    MINOR="${PARTS[0]}"
    PATCH="${PARTS[1]}"
  else
    echo "Invalid argument format: $1"
    exit 1
  fi
elif [ "$#" -eq 2 ]; then
  # 2 args → increment major
  IFS='.' read -ra PARTS <<< "$1.$2"
  MAJOR="${PARTS[0]}"
  MINOR="${PARTS[1]}"
  PATCH="$2"
else
  echo "Usage:"
  echo "  ./version.sh        → increment patch"
  echo "  ./version.sh i.#     → increment minor, set patch"
  echo "  ./version.sh i.#.#   → increment major, set minor and patch"
  exit 1
fi

# ---- save new version ----
NEW_VERSION="$MAJOR.$MINOR.$PATCH"
echo "$NEW_VERSION" > "$VERSION_FILE"
echo "$NEW_VERSION"
