#!/usr/bin/env bash
set -euo pipefail

# Adds a themed frontend to an EXISTING backend: restructures the repo into a
# pnpm + Turborepo workspace, moves the backend to apps/api (history preserved),
# and scaffolds a Next.js app wired to the startup-kit theme at apps/web.
# See references/onboarding.md, references/scaffold.md, references/monorepo.md.
#
# Usage: scripts/add-frontend.sh [backend-dir] [workspace-name]
#   backend-dir defaults to "." (the repo root is the backend).
# Run from the root of the existing backend repo.

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=/dev/null
. "$KIT_DIR/scripts/lib/workspace.sh"

BACKEND_DIR="${1:-.}"
WS_NAME="${2:-$(basename "$(pwd)")}"

if ! command -v npx >/dev/null 2>&1; then echo "npx is required."; exit 1; fi
if [ -e apps/web ]; then echo "apps/web already exists."; exit 1; fi

echo "Adding a themed frontend to '$BACKEND_DIR'..."
ws_require_clean_git

# Move the existing backend into apps/api. When the backend IS the repo root,
# move its contents first, then write the fresh workspace root on top.
if [ "$BACKEND_DIR" = "." ]; then
  mkdir -p apps/api
  shopt -s dotglob nullglob
  for entry in *; do
    case "$entry" in
      apps|packages|.git|node_modules) continue ;;
    esac
    git mv "$entry" apps/api/ 2>/dev/null || mv "$entry" apps/api/
  done
  shopt -u dotglob nullglob
  echo "  + moved backend into apps/api"
  ws_write_root "$WS_NAME"
else
  ws_write_root "$WS_NAME"
  ws_move "$BACKEND_DIR" "apps"
  [ "$(basename "$BACKEND_DIR")" != "api" ] && \
    { git mv "apps/$(basename "$BACKEND_DIR")" apps/api 2>/dev/null || mv "apps/$(basename "$BACKEND_DIR")" apps/api; }
fi

ws_write_shared

echo "Scaffolding apps/web (Next.js + Tailwind + shadcn/ui)..."
# Use pnpm when available so the new app matches the pnpm workspace.
PM="npm"; USE_PM_FLAG="--use-npm"
if command -v pnpm >/dev/null 2>&1; then PM="pnpm"; USE_PM_FLAG="--use-pnpm"; fi

npx --yes create-next-app@latest apps/web \
  --typescript --tailwind --eslint --app --src-dir --import-alias "@/*" \
  --no-turbopack "$USE_PM_FLAG"

# Apply the kit theme and pin Tailwind to v3 to match the kit assets.
ws_apply_web_theme_v3 "$KIT_DIR" "apps/web" "$PM"

(
  cd apps/web
  npx --yes shadcn@latest add --yes --overwrite \
    button input label select textarea checkbox switch tabs \
    dialog dropdown-menu popover tooltip sheet table form card alert skeleton sonner
  npm pkg set name="web" >/dev/null 2>&1 || true
  npm pkg set dependencies.@repo/shared="workspace:*" >/dev/null 2>&1 || true
  npm pkg set scripts.typecheck="tsc --noEmit" >/dev/null 2>&1 || true
)

cat <<'EOF'

Added a themed frontend:

  apps/web        new Next.js (kit theme)  -> Vercel (Root Directory: apps/web)
  apps/api        your existing backend    -> Koyeb  (build context: apps/api)
  packages/shared shared types + zod contract

No backend source was regenerated. Next:
  1. pnpm install
  2. pnpm dev
  3. Point apps/web at the API with NEXT_PUBLIC_API_URL, and allow its origin in the backend CORS.
  4. Read references/theming.md + layout.md to build screens, references/monorepo.md to deploy.

Undo: a backup branch was created — git reset --hard <backup/pre-monorepo-...>.
EOF
