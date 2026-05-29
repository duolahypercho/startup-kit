#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ICON_DIR="$ROOT_DIR/assets/icons/lucide"
BASE_URL="https://raw.githubusercontent.com/lucide-icons/lucide/main"

mkdir -p "$ICON_DIR"

download() {
  local icon="$1"
  curl --fail --location --silent --show-error \
    --output "$ICON_DIR/$icon.svg" \
    "$BASE_URL/icons/$icon.svg"
}

download play
download settings
download terminal
download file
download circle-check
download triangle-alert
download loader-circle
download download
download bot
download panel-left
download search
download plus
download x
download command
download database

curl --fail --location --silent --show-error \
  --output "$ICON_DIR/LICENSE" \
  "$BASE_URL/LICENSE"

cat > "$ICON_DIR/manifest.json" <<'JSON'
{
  "library": "Lucide",
  "source": "https://github.com/lucide-icons/lucide",
  "license": "ISC, with some Feather-derived icons under MIT as noted in LICENSE",
  "icons": [
    { "name": "play", "purpose": "Run or start action" },
    { "name": "settings", "purpose": "Settings or configuration" },
    { "name": "terminal", "purpose": "Terminal or command output" },
    { "name": "file", "purpose": "File or artifact" },
    { "name": "circle-check", "purpose": "Success state" },
    { "name": "triangle-alert", "purpose": "Warning or validation issue" },
    { "name": "loader-circle", "purpose": "Loading or in-progress state" },
    { "name": "download", "purpose": "Download action" },
    { "name": "bot", "purpose": "Agent or automation" },
    { "name": "panel-left", "purpose": "Sidebar or navigation panel" },
    { "name": "search", "purpose": "Search" },
    { "name": "plus", "purpose": "Add or create" },
    { "name": "x", "purpose": "Close or remove" },
    { "name": "command", "purpose": "Command palette or shortcuts" },
    { "name": "database", "purpose": "Data source or storage" }
  ]
}
JSON

echo "Downloaded Lucide starter icons to: $ICON_DIR"
