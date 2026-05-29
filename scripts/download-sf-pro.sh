#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FONT_DIR="$ROOT_DIR/assets/fonts/vendor"
DMG_PATH="$FONT_DIR/SF-Pro.dmg"
URL="https://devimages-cdn.apple.com/design/resources/download/SF-Pro.dmg"

mkdir -p "$FONT_DIR"

if [[ -f "$DMG_PATH" ]]; then
  echo "SF Pro installer already exists: $DMG_PATH"
  exit 0
fi

curl --fail --location --output "$DMG_PATH" "$URL"
echo "Downloaded Apple's official SF Pro installer to: $DMG_PATH"
echo "Review Apple's font license before extracting, installing, committing, or redistributing font files."
