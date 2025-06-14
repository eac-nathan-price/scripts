#!/usr/bin/env bash
set -e

VERSION_TXT=".version"
VERSION_JSON="version.json"

# -------------------------
# Detect version source
# -------------------------
if [ -f "$VERSION_JSON" ]; then
  SOURCE="json"
elif [ -f "$VERSION_TXT" ]; then
  SOURCE="txt"
else
  SOURCE="txt"
  echo "0.0.0" > "$VERSION_TXT"
fi

# -------------------------
# Load version
# -------------------------
if [ "$SOURCE" = "json" ]; then
  read -r MAJOR MINOR PATCH < <(
    sed -E 's/[{}"]//g' "$VERSION_JSON" \
    | tr ',' '\n' \
    | sed -E 's/.*major *: *//;t; s/.*minor *: *//;t; s/.*patch *: *//;t; d'
  )
else
  read -r MAJOR MINOR PATCH < <(tr '.' ' ' < "$VERSION_TXT")
fi

# normalize to numbers if strings
MAJOR=${MAJOR:-0}
MINOR=${MINOR:-0}
PATCH=${PATCH:-0}

# -------------------------
# No args → print version
# -------------------------
if [ "$#" -eq 0 ]; then
  echo "$MAJOR.$MINOR.$PATCH"
  exit 0
fi

# -------------------------
# Normalize argument
# -------------------------
IFS='.' read -ra PARTS <<< "$1"
while [ "${#PARTS[@]}" -lt 3 ]; do
  PARTS=( "x" "${PARTS[@]}" )
done

# -------------------------
# Apply rule
# -------------------------
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

# -------------------------
# Save version
# -------------------------
if [ "$SOURCE" = "json" ]; then
  cat > "$VERSION_JSON" <<EOF
{
  "major": $NEW_MAJOR,
  "minor": $NEW_MINOR,
  "patch": $NEW_PATCH
}
EOF
else
  echo "$NEW_MAJOR.$NEW_MINOR.$NEW_PATCH" > "$VERSION_TXT"
fi

echo "$NEW_MAJOR.$NEW_MINOR.$NEW_PATCH"
