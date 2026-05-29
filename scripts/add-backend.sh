#!/usr/bin/env bash
set -euo pipefail

# Adds a backend to an EXISTING frontend: restructures the repo into a pnpm +
# Turborepo workspace, moves the frontend to apps/web (history preserved via
# git mv), and scaffolds a layered Express/TypeScript service at apps/api.
# See references/onboarding.md, references/backend.md, references/monorepo.md.
#
# Usage: scripts/add-backend.sh [frontend-dir] [workspace-name]
#   frontend-dir defaults to "." (the repo root is the frontend).
# Run from the root of the existing frontend repo.

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=/dev/null
. "$KIT_DIR/scripts/lib/workspace.sh"

FRONTEND_DIR="${1:-.}"
WS_NAME="${2:-$(basename "$(pwd)")}"

if [ -e apps/api ]; then echo "apps/api already exists."; exit 1; fi

echo "Adding a backend to '$FRONTEND_DIR'..."
ws_require_clean_git

# Move the frontend into apps/web. When the frontend IS the repo root, move its
# contents (including package.json) into apps/web first, then write the fresh
# workspace root on top — otherwise the app's manifest gets stranded at the root.
if [ "$FRONTEND_DIR" = "." ]; then
  mkdir -p apps/web
  shopt -s dotglob nullglob
  for entry in *; do
    case "$entry" in
      apps|packages|.git|node_modules) continue ;;
    esac
    git mv "$entry" apps/web/ 2>/dev/null || mv "$entry" apps/web/
  done
  shopt -u dotglob nullglob
  echo "  + moved frontend into apps/web"
  ws_write_root "$WS_NAME"
else
  ws_write_root "$WS_NAME"
  ws_move "$FRONTEND_DIR" "apps"
  [ "$(basename "$FRONTEND_DIR")" != "web" ] && \
    { git mv "apps/$(basename "$FRONTEND_DIR")" apps/web 2>/dev/null || mv "apps/$(basename "$FRONTEND_DIR")" apps/web; }
fi

ws_write_shared
ws_write_api

if command -v npm >/dev/null 2>&1; then
  ( cd apps/web 2>/dev/null && [ -f package.json ] && npm pkg set name="web" >/dev/null 2>&1 || true )
fi

cat <<'EOF'

Added a backend:

  apps/web        your existing frontend  -> Vercel (Root Directory: apps/web)
  apps/api        new Express/TS service  -> Koyeb  (build context: apps/api)
  packages/shared shared types + zod contract

No frontend source was regenerated. Next:
  1. pnpm install
  2. pnpm dev   (runs web + api via turbo)
  3. Point the frontend at the API with NEXT_PUBLIC_API_URL.
  4. Read references/backend.md to build real endpoints, references/monorepo.md to deploy.

Undo: a backup branch was created — git reset --hard <backup/pre-monorepo-...>.
EOF
