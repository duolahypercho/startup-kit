#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ICON_DIR="$ROOT_DIR/assets/icons/simple-icons"
BASE_URL="https://raw.githubusercontent.com/simple-icons/simple-icons/develop"

mkdir -p "$ICON_DIR"

download() {
  local icon="$1"
  curl --fail --location --silent --show-error \
    --output "$ICON_DIR/$icon.svg" \
    "$BASE_URL/icons/$icon.svg"
}

download github
download google
download vercel
download nextdotjs
download react
download tailwindcss
download typescript
download npm

curl --fail --location --silent --show-error \
  --output "$ICON_DIR/LICENSE" \
  "$BASE_URL/LICENSE.md"

curl --fail --location --silent --show-error \
  --output "$ICON_DIR/DISCLAIMER.md" \
  "$BASE_URL/DISCLAIMER.md"

cat > "$ICON_DIR/manifest.json" <<'JSON'
{
  "library": "Simple Icons",
  "source": "https://github.com/simple-icons/simple-icons",
  "usage": "Brand logos only. Check the bundled DISCLAIMER.md and each brand's trademark rules before use.",
  "icons": [
    { "name": "github", "purpose": "GitHub brand logo" },
    { "name": "google", "purpose": "Google brand logo" },
    { "name": "vercel", "purpose": "Vercel brand logo" },
    { "name": "nextdotjs", "purpose": "Next.js brand logo" },
    { "name": "react", "purpose": "React brand logo" },
    { "name": "tailwindcss", "purpose": "Tailwind CSS brand logo" },
    { "name": "typescript", "purpose": "TypeScript brand logo" },
    { "name": "npm", "purpose": "npm brand logo" }
  ]
}
JSON

echo "Downloaded Simple Icons starter logos to: $ICON_DIR"
