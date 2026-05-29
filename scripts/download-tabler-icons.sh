#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ICON_DIR="$ROOT_DIR/assets/icons/tabler"
BASE_URL="https://raw.githubusercontent.com/tabler/tabler-icons/main"

mkdir -p "$ICON_DIR"

download() {
  local icon="$1"
  curl --fail --location --silent --show-error \
    --output "$ICON_DIR/$icon.svg" \
    "$BASE_URL/icons/outline/$icon.svg"
}

download brand-github-copilot
download robot
download file-diff
download status-change
download timeline-event
download schema
download route
download plug-connected

curl --fail --location --silent --show-error \
  --output "$ICON_DIR/LICENSE" \
  "$BASE_URL/LICENSE"

cat > "$ICON_DIR/manifest.json" <<'JSON'
{
  "library": "Tabler Icons",
  "source": "https://github.com/tabler/tabler-icons",
  "usage": "Fallback UI icons only when Lucide lacks the needed concept. Do not mix with Lucide in the same screen unless necessary.",
  "icons": [
    { "name": "brand-github-copilot", "purpose": "Copilot-specific integration fallback" },
    { "name": "robot", "purpose": "Alternate automation or agent fallback" },
    { "name": "file-diff", "purpose": "Diff or patch fallback" },
    { "name": "status-change", "purpose": "State transition fallback" },
    { "name": "timeline-event", "purpose": "Timeline event fallback" },
    { "name": "schema", "purpose": "Schema or structured data fallback" },
    { "name": "route", "purpose": "Workflow route fallback" },
    { "name": "plug-connected", "purpose": "Connector or integration fallback" }
  ]
}
JSON

echo "Downloaded Tabler fallback icons to: $ICON_DIR"
