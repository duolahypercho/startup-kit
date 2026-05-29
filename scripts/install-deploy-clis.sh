#!/usr/bin/env bash
set -euo pipefail

# Installs the platform CLIs used for split hosting (see references/monorepo.md):
#   vercel    frontend (apps/web) hosting
#   supabase  managed Postgres + auth + storage
#   koyeb     always-on backend (apps/api) hosting
#
# Each CLI authenticates against its own account; none of them touch the repo's
# secrets. Re-run any time to upgrade. Usage: scripts/install-deploy-clis.sh

if ! command -v npm >/dev/null 2>&1; then
  echo "npm is required to install the Vercel and Koyeb CLIs."
  exit 1
fi

echo "Installing Vercel CLI..."
npm i -g vercel

echo "Installing Koyeb CLI..."
npm i -g koyeb

echo "Installing Supabase CLI..."
if command -v brew >/dev/null 2>&1; then
  brew install supabase/tap/supabase || npm i -g supabase
else
  npm i -g supabase
fi

echo ""
echo "Installed CLIs:"
command -v vercel   >/dev/null 2>&1 && echo "  vercel   $(vercel --version 2>/dev/null || echo '?')"
command -v koyeb    >/dev/null 2>&1 && echo "  koyeb    $(koyeb version 2>/dev/null || echo '?')"
command -v supabase >/dev/null 2>&1 && echo "  supabase $(supabase --version 2>/dev/null || echo '?')"
echo ""
echo "Next, authenticate each:"
echo "  vercel login"
echo "  supabase login"
echo "  koyeb login"
echo ""
echo "Then follow references/monorepo.md to link apps/web to Vercel,"
echo "apps/api to Koyeb, and connect Supabase."
