#!/usr/bin/env bash
set -euo pipefail

# Bootstraps a Next.js + Tailwind + shadcn/ui app wired to the startup-kit theme.
# Usage: scripts/create-app.sh <app-name>

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=/dev/null
. "$KIT_DIR/scripts/lib/workspace.sh"
# shellcheck source=/dev/null
. "$KIT_DIR/scripts/lib/onboarding-gate.sh"
# shellcheck source=/dev/null
. "$KIT_DIR/scripts/lib/versions.sh"

# Refuse to scaffold until onboarding has produced .startup-kit/intake.md
# (override with --skip-onboarding or STARTUP_KIT_SKIP_ONBOARDING=1).
og_parse_and_require "$@" || exit 1
set -- ${OG_ARGS[@]+"${OG_ARGS[@]}"}

APP_NAME="${1:-startup-app}"

if ! command -v npx >/dev/null 2>&1; then
  echo "npx is required."
  exit 1
fi

npx --yes "create-next-app@${SK_NEXT_MAJOR}" "$APP_NAME" \
  --typescript --tailwind --eslint --app --src-dir --import-alias "@/*" \
  --no-turbopack --use-npm

# Apply the kit theme and pin Tailwind to v3 to match the kit assets.
ws_apply_web_theme_v3 "$KIT_DIR" "$APP_NAME" "npm"

cd "$APP_NAME"

# shadcn/ui primitives using the kit config.
npx --yes "shadcn@${SK_SHADCN_MAJOR}" add --yes --overwrite \
  button input label select textarea checkbox switch tabs \
  dialog dropdown-menu popover tooltip sheet table form card alert skeleton sonner

# Theme provider for dark mode + common product deps.
npm install next-themes react-hook-form zod @hookform/resolvers lucide-react

# Bundle the animated/3D background catalog + reusable wrapper, and install the
# common WebGL runtimes so a background can be dropped onto any marketing/hero
# surface. (cd into the app for this; the helper expects the app path.)
cd ..
ws_add_backgrounds "$KIT_DIR" "$APP_NAME" "npm"
cd "$APP_NAME"

echo ""
echo "Created $APP_NAME."
echo "Backgrounds bundled in src/components/backgrounds (three + ogl installed)."
echo "Add a heavier one anytime: scripts/add-background.sh <Name> $APP_NAME"
echo "Next: review references/theming.md, layout.md, backgrounds.md, then run 'npm run dev'."
