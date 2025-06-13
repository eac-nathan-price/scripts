#!/usr/bin/env bash
set -e

VERSION_FILE=".version"

# ---- ensure version file exists ----
if [ ! -f "$VERSION_FILE" ]; then
  echo "0.0.0" > "$VERSION_FILE"
fi

CURRENT_VERSION=$(cat "$VERSION_FILE")
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

# ---- no args → just print version ----
if [ "$#" -eq 0 ]; then
  echo "$CURRENT_VERSION"
  exit 0
fi

# ---- parse increment argument ----
ARG="$1"

if [[ "$ARG" == "i" ]]; then
  # increment patch
  PATCH=$((PATCH + 1))
elif [[ "$ARG" =~ ^i\.([0-9]+)$ ]]; then
  # i.# → increment minor, set patch
  NEW_MINOR="${BASH_REMATCH[1]}"
  MINOR=$((MINOR + 1))
  PATCH="$NEW_MINOR"
elif [[ "$ARG" =~ ^i\.([0-9]+)\.([0-9]+)$ ]]; then
  # i.#.# → increment major, set minor and patch
  NEW_MAJOR="${BASH_REMATCH[1]}"
  NEW_MINOR="${BASH_REMATCH[2]}"
  MAJOR=$((MAJOR + 1))
  MINOR="$NEW_MAJOR"
  PATCH="$NEW_MINOR"
else
  echo "Invalid argument: $ARG"
  echo "Usage:"
  echo "  ./version.sh          → print version"
  echo "  ./version.sh i        → increment patch"
  echo "  ./version.sh i.#      → increment minor, set patch"
  echo "  ./version.sh i.#.#    → increment major, set minor and patch"
  exit 1
fi

# ---- save new version if incremented ----
echo "$MAJOR.$MINOR.$PATCH" > "$VERSION_FILE"
echo "$MAJOR.$MINOR.$PATCH"
