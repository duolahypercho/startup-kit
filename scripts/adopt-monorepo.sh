#!/usr/bin/env bash
set -euo pipefail

# Restructures an EXISTING repo that already holds a frontend and a backend into
# a pnpm + Turborepo workspace, without regenerating any source. Moves use
# `git mv` to preserve history. See references/onboarding.md and references/monorepo.md.
#
# Usage: scripts/adopt-monorepo.sh <frontend-dir> <backend-dir> [workspace-name]
#   e.g. scripts/adopt-monorepo.sh web server my-product
#
# Run from the root of the repo you are restructuring.

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=/dev/null
. "$KIT_DIR/scripts/lib/workspace.sh"

FRONTEND_DIR="${1:-}"
BACKEND_DIR="${2:-}"
WS_NAME="${3:-$(basename "$(pwd)")}"

if [ -z "$FRONTEND_DIR" ] || [ -z "$BACKEND_DIR" ]; then
  echo "Usage: scripts/adopt-monorepo.sh <frontend-dir> <backend-dir> [workspace-name]"
  exit 1
fi
if [ ! -d "$FRONTEND_DIR" ]; then echo "Frontend dir '$FRONTEND_DIR' not found."; exit 1; fi
if [ ! -d "$BACKEND_DIR" ]; then echo "Backend dir '$BACKEND_DIR' not found."; exit 1; fi
if [ -e apps/web ] || [ -e apps/api ]; then
  echo "apps/web or apps/api already exists. This repo may already be a workspace."
  exit 1
fi

echo "Adopting '$FRONTEND_DIR' and '$BACKEND_DIR' into a monorepo workspace..."
ws_require_clean_git

echo "Writing workspace root..."
ws_write_root "$WS_NAME"

echo "Moving apps (history preserved)..."
ws_move "$FRONTEND_DIR" "apps"
ws_move "$BACKEND_DIR" "apps"
# Normalize folder names to apps/web and apps/api.
[ -d "apps/$(basename "$FRONTEND_DIR")" ] && [ "$(basename "$FRONTEND_DIR")" != "web" ] && \
  { git mv "apps/$(basename "$FRONTEND_DIR")" apps/web 2>/dev/null || mv "apps/$(basename "$FRONTEND_DIR")" apps/web; }
[ -d "apps/$(basename "$BACKEND_DIR")" ] && [ "$(basename "$BACKEND_DIR")" != "api" ] && \
  { git mv "apps/$(basename "$BACKEND_DIR")" apps/api 2>/dev/null || mv "apps/$(basename "$BACKEND_DIR")" apps/api; }

echo "Writing packages/shared..."
ws_write_shared

# Best-effort: set workspace package names + typecheck scripts.
if command -v npm >/dev/null 2>&1; then
  ( cd apps/web 2>/dev/null && [ -f package.json ] && npm pkg set name="web" >/dev/null 2>&1 || true )
  ( cd apps/api 2>/dev/null && [ -f package.json ] && npm pkg set name="api" >/dev/null 2>&1 || true )
fi

cat <<EOF

Adopted into a monorepo:

  apps/web        (was $FRONTEND_DIR)  -> deploy to Vercel (Root Directory: apps/web)
  apps/api        (was $BACKEND_DIR)   -> deploy to Koyeb  (build context: apps/api)
  packages/shared shared types + zod contract

No source was regenerated. Next:
  1. Install with your package manager (pnpm recommended): pnpm install
  2. Review apps/web and apps/api package.json names + scripts.
  3. On Vercel, set the project Root Directory to apps/web.
  4. Read references/monorepo.md to wire env vars, CORS, and the CLIs.

Undo: a backup branch was created — git reset --hard <backup/pre-monorepo-...>.
EOF
