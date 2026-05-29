#!/usr/bin/env bash
set -euo pipefail

# Scaffolds a pnpm + Turborepo monorepo wired to the startup-kit theme:
#   apps/web         Next.js frontend (kit theme, Tailwind v3) -> deploy to Vercel
#   apps/api         Express + TypeScript layered API           -> deploy to Koyeb
#   packages/shared  shared types + zod schemas (web + api)
#
# Frontend and backend live in one repo and deploy to different hosts.
# See references/monorepo.md.
#
# Usage: scripts/create-monorepo.sh <product-name>

PRODUCT_NAME="${1:-startup-product}"
KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=/dev/null
. "$KIT_DIR/scripts/lib/workspace.sh"

if ! command -v pnpm >/dev/null 2>&1; then
  echo "pnpm is required. Enable it with: corepack enable pnpm   (or: npm i -g pnpm)"
  exit 1
fi
if ! command -v npx >/dev/null 2>&1; then
  echo "npx is required."
  exit 1
fi
if [ -e "$PRODUCT_NAME" ]; then
  echo "Path '$PRODUCT_NAME' already exists. Choose a new name or remove it."
  exit 1
fi

echo "Creating monorepo '$PRODUCT_NAME'..."
mkdir -p "$PRODUCT_NAME"/{apps,packages}
cd "$PRODUCT_NAME"

# ---------------------------------------------------------------------------
# Workspace root
# ---------------------------------------------------------------------------
cat > package.json <<EOF
{
  "name": "$PRODUCT_NAME",
  "private": true,
  "packageManager": "pnpm@9.0.0",
  "scripts": {
    "dev": "turbo run dev",
    "build": "turbo run build",
    "lint": "turbo run lint",
    "typecheck": "turbo run typecheck"
  },
  "devDependencies": {
    "turbo": "^2.0.0",
    "typescript": "^5.5.0"
  }
}
EOF

cat > pnpm-workspace.yaml <<'EOF'
packages:
  - "apps/*"
  - "packages/*"
EOF

cat > turbo.json <<'EOF'
{
  "$schema": "https://turbo.build/schema.json",
  "tasks": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": [".next/**", "!.next/cache/**", "dist/**"]
    },
    "dev": { "cache": false, "persistent": true },
    "lint": {},
    "typecheck": { "dependsOn": ["^build"] }
  }
}
EOF

cat > tsconfig.base.json <<'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "Bundler",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true
  }
}
EOF

cat > .gitignore <<'EOF'
node_modules/
.next/
dist/
.turbo/
.env
.env.*
!.env.example
.vercel
.DS_Store
EOF

cat > .env.example <<'EOF'
# Frontend (public — safe to expose to the browser)
NEXT_PUBLIC_API_URL=http://localhost:9979
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=

# Backend (server-only secrets — never commit real values)
DATABASE_URL=
SUPABASE_SERVICE_ROLE_KEY=
JWT_TOKEN=
EOF

# ---------------------------------------------------------------------------
# packages/shared and apps/api (shared, fixed helpers)
# ---------------------------------------------------------------------------
echo "Writing packages/shared..."
ws_write_shared
echo "Writing apps/api..."
ws_write_api

# ---------------------------------------------------------------------------
# apps/web — Next.js with the startup-kit theme (Tailwind v3)
# ---------------------------------------------------------------------------
echo ""
echo "Scaffolding apps/web (Next.js + Tailwind + shadcn/ui)..."
npx --yes create-next-app@latest apps/web \
  --typescript --tailwind --eslint --app --src-dir --import-alias "@/*" \
  --no-turbopack --use-pnpm

# Apply the kit theme and pin Tailwind to v3 to match the kit assets.
ws_apply_web_theme_v3 "$KIT_DIR" "apps/web" "pnpm"

# shadcn/ui primitives using the kit config.
(
  cd apps/web
  npx --yes shadcn@latest add --yes --overwrite \
    button input label select textarea checkbox switch tabs \
    dialog dropdown-menu popover tooltip sheet table form card alert skeleton sonner
  npm pkg set name="web" >/dev/null
  npm pkg set dependencies.@repo/shared="workspace:*" >/dev/null
  npm pkg set scripts.typecheck="tsc --noEmit" >/dev/null
)

# ---------------------------------------------------------------------------
# Install everything through the workspace.
# ---------------------------------------------------------------------------
echo ""
echo "Installing workspace dependencies with pnpm..."
# Scaffolding generates a fresh lockfile, so never freeze it (CI sets frozen by default).
pnpm install --no-frozen-lockfile

echo ""
echo "Created monorepo '$PRODUCT_NAME'."
echo ""
echo "  apps/web        Next.js frontend   -> Vercel (Root Directory: apps/web)"
echo "  apps/api        Express API        -> Koyeb  (build context: repo root, Dockerfile: apps/api/Dockerfile)"
echo "  packages/shared shared types + zod schemas (built to dist, consumed by both)"
echo ""
echo "Next:"
echo "  1. cd $PRODUCT_NAME && pnpm build   (builds shared, then api + web)"
echo "  2. pnpm dev                          (runs all three)"
echo "  3. Install platform CLIs: scripts/install-deploy-clis.sh"
echo "  4. Read references/monorepo.md to wire Vercel, Supabase, and Koyeb."
