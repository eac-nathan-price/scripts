#!/usr/bin/env bash
set -e

VERSION_FILE=".version"

# ---- ensure version file exists ----
if [ ! -f "$VERSION_FILE" ]; then
  echo "0.0.0" > "$VERSION_FILE"
fi

read -r MAJOR MINOR PATCH < <(tr '.' ' ' < "$VERSION_FILE")

# ---- no args → print version ----
if [ "$#" -eq 0 ]; then
  echo "$MAJOR.$MINOR.$PATCH"
  exit 0
fi

ARG="$1"

# ---- split and normalize to 3 parts ----
IFS='.' read -ra PARTS <<< "$ARG"

while [ "${#PARTS[@]}" -lt 3 ]; do
  PARTS=( "x" "${PARTS[@]}" )
done

# ---- apply rules positionally ----
apply_part() {
  local current="$1"
  local rule="$2"

  if [[ "$rule" == "x" ]]; then
    echo "$current"
  elif [[ "$rule" == "i" ]]; then
    echo $((current + 1))
  elif [[ "$rule" =~ ^[0-9]+$ ]]; then
    echo "$rule"
  else
    echo "Invalid token: $rule"
    exit 1
  fi
}

NEW_MAJOR=$(apply_part "$MAJOR" "${PARTS[0]}")
NEW_MINOR=$(apply_part "$MINOR" "${PARTS[1]}")
NEW_PATCH=$(apply_part "$PATCH" "${PARTS[2]}")

NEW_VERSION="$NEW_MAJOR.$NEW_MINOR.$NEW_PATCH"

echo "$NEW_VERSION" > "$VERSION_FILE"
echo "$NEW_VERSION"
