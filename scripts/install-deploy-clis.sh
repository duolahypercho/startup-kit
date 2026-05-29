#!/usr/bin/env bash
set -uo pipefail

# Installs the platform CLIs used for split hosting (see references/monorepo.md),
# each via its OFFICIAL method:
#   vercel    npm i -g vercel                       (https://vercel.com/docs/cli)
#   koyeb     Homebrew or the official install script — no official npm package
#             (https://www.koyeb.com/docs/build-and-deploy/cli/installation)
#   supabase  Homebrew / Scoop / standalone binary — global npm is NOT supported
#             (https://supabase.com/docs/guides/local-development/cli/getting-started)
#
# Best-effort: each CLI installs independently, and one failure does not stop the
# others. Re-run any time to upgrade. Usage: scripts/install-deploy-clis.sh

have() { command -v "$1" >/dev/null 2>&1; }

VERCEL_OK=1
KOYEB_OK=1
SUPABASE_OK=1

# --- Vercel: official method is npm global. ---
install_vercel() {
  if have npm; then
    echo "Installing Vercel CLI (npm)..."
    npm i -g vercel && return 0
  fi
  echo "Vercel: npm not found. Install Node.js/npm, then run: npm i -g vercel"
  return 1
}

# --- Koyeb: no official npm package. Homebrew, else the official install script. ---
install_koyeb() {
  if have brew; then
    echo "Installing Koyeb CLI (Homebrew)..."
    brew install koyeb/tap/koyeb && return 0
  fi
  if have curl; then
    echo "Installing Koyeb CLI (official install script)..."
    if curl -fsSL https://raw.githubusercontent.com/koyeb/koyeb-cli/master/install.sh | sh; then
      echo "  Koyeb installed to ~/.koyeb/bin. Add it to your PATH if needed:"
      echo "    export PATH=\$HOME/.koyeb/bin:\$PATH"
      return 0
    fi
  fi
  echo "Koyeb: need Homebrew or curl. See"
  echo "  https://www.koyeb.com/docs/build-and-deploy/cli/installation"
  return 1
}

# --- Supabase: global npm install is unsupported by Supabase. ---
install_supabase() {
  if have brew; then
    echo "Installing Supabase CLI (Homebrew)..."
    brew install supabase/tap/supabase && return 0
  fi
  echo "Supabase: global npm install is not supported. Use one of:"
  echo "  - macOS/Linux:  brew install supabase/tap/supabase"
  echo "  - Windows:      scoop bucket add supabase https://github.com/supabase/scoop-bucket.git && scoop install supabase"
  echo "  - No install:   npx supabase <command>        (requires Node.js 20+)"
  echo "  - Per project:  npm install supabase --save-dev"
  echo "  Docs: https://supabase.com/docs/guides/local-development/cli/getting-started"
  return 1
}

install_vercel   || VERCEL_OK=0
echo
install_koyeb    || KOYEB_OK=0
echo
install_supabase || SUPABASE_OK=0

echo
echo "Install summary:"
if have vercel;   then echo "  vercel    installed  ($(vercel --version 2>/dev/null || echo '?'))"; else echo "  vercel    not installed"; fi
if have koyeb;    then echo "  koyeb     installed  ($(koyeb version 2>/dev/null | head -1 || echo '?'))"; else echo "  koyeb     not installed"; fi
if have supabase; then echo "  supabase  installed  ($(supabase --version 2>/dev/null || echo '?'))"; else echo "  supabase  not installed (use npx supabase if you skipped a global install)"; fi

echo
echo "Next, authenticate each CLI you installed:"
echo "  vercel login"
echo "  koyeb login          # or: koyeb init"
echo "  supabase login       # or: npx supabase login"
echo
echo "Then follow references/monorepo.md to link apps/web to Vercel,"
echo "apps/api to Koyeb, and connect Supabase."

# Exit non-zero only if every install failed, so partial success is still success.
[ "$VERCEL_OK" -eq 1 ] || [ "$KOYEB_OK" -eq 1 ] || [ "$SUPABASE_OK" -eq 1 ]
