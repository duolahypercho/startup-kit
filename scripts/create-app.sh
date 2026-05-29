#!/usr/bin/env bash
set -euo pipefail

# Bootstraps a Next.js + Tailwind + shadcn/ui app wired to the startup-kit theme.
# Usage: scripts/create-app.sh <app-name>

APP_NAME="${1:-startup-app}"
KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v npx >/dev/null 2>&1; then
  echo "npx is required."
  exit 1
fi

npx create-next-app@latest "$APP_NAME" \
  --typescript --tailwind --eslint --app --src-dir --import-alias "@/*" --no-turbopack

cd "$APP_NAME"

# Theme: replace the generated global stylesheet with the kit baseline.
cp "$KIT_DIR/assets/tailwind/globals.css" "src/app/globals.css"
mkdir -p src/styles
cp "$KIT_DIR/assets/theme/default-theme.css" "src/styles/default-theme.css"
cp "$KIT_DIR/assets/theme/dark-theme.css" "src/styles/dark-theme.css"

# shadcn/ui init using the kit config.
cp "$KIT_DIR/assets/shadcn/components.tailwind-v3.json" "components.json"
npx shadcn@latest add button input label select textarea checkbox switch tabs \
  dialog dropdown-menu popover tooltip sheet table form card alert skeleton sonner

# Theme provider for dark mode.
npm install next-themes react-hook-form zod @hookform/resolvers lucide-react

echo ""
echo "Created $APP_NAME."
echo "Next: review references/theming.md, layout.md, and forms.md, then run 'npm run dev'."
