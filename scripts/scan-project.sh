#!/usr/bin/env bash
set -euo pipefail

# Inventories an existing project so onboarding can detect-first, then ask.
# Prints a structured Markdown report to stdout: package manifests, frameworks,
# package manager, monorepo layout, database/auth, and env files.
#
# Read-only. Never modifies the project. Used by references/onboarding.md.
# Usage: scripts/scan-project.sh [target-dir]   (defaults to current directory)

TARGET="${1:-.}"

if [ ! -d "$TARGET" ]; then
  echo "Target directory '$TARGET' does not exist."
  exit 1
fi

cd "$TARGET"
ROOT="$(pwd)"

have() { command -v "$1" >/dev/null 2>&1; }
exists() { [ -e "$1" ]; }

# Find files while skipping vendored/build directories.
find_files() {
  # $1 = filename pattern
  find . \
    -type d \( -name node_modules -o -name .git -o -name dist -o -name .next \
      -o -name .turbo -o -name build -o -name .venv -o -name venv \
      -o -name __pycache__ \) -prune -o \
    -type f -name "$1" -print 2>/dev/null | sed 's|^\./||' | sort
}

echo "# Project Scan"
echo
echo "- Root: \`$ROOT\`"
echo "- Scanned: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo

# ---------------------------------------------------------------------------
# Git
# ---------------------------------------------------------------------------
echo "## Git"
echo
if [ -d .git ] || git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "?")"
  REMOTE="$(git remote get-url origin 2>/dev/null || echo "none")"
  DIRTY="$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')"
  echo "- Repository: yes (branch \`$BRANCH\`)"
  echo "- Remote: $REMOTE"
  echo "- Uncommitted changes: $DIRTY file(s)"
else
  echo "- Repository: none (not a git repo)"
fi
echo

# ---------------------------------------------------------------------------
# Package manager
# ---------------------------------------------------------------------------
echo "## Package Manager"
echo
PM="unknown"
exists pnpm-lock.yaml && PM="pnpm"
exists package-lock.json && PM="npm"
exists yarn.lock && PM="yarn"
exists bun.lockb && PM="bun"
echo "- Detected: $PM"
echo

# ---------------------------------------------------------------------------
# Workspace / monorepo
# ---------------------------------------------------------------------------
echo "## Workspace Layout"
echo
MONO="no"
exists pnpm-workspace.yaml && MONO="yes (pnpm-workspace.yaml)"
exists turbo.json && MONO="yes (turbo.json present)"
if have node && exists package.json; then
  HAS_WS="$(node -e 'try{const p=require("./package.json");process.stdout.write(p.workspaces?"yes":"no")}catch(e){process.stdout.write("no")}' 2>/dev/null || echo no)"
  [ "$HAS_WS" = "yes" ] && MONO="yes (package.json workspaces)"
fi
echo "- Monorepo: $MONO"
echo

# ---------------------------------------------------------------------------
# Node manifests + framework detection
# ---------------------------------------------------------------------------
echo "## Node / JS Manifests"
echo
PKGS="$(find_files package.json || true)"
if [ -z "$PKGS" ]; then
  echo "- None found."
else
  while IFS= read -r pkg; do
    [ -z "$pkg" ] && continue
    dir="$(dirname "$pkg")"
    if have node; then
      node -e '
        const fs=require("fs");
        const p=JSON.parse(fs.readFileSync(process.argv[1],"utf8"));
        const d={...(p.dependencies||{}),...(p.devDependencies||{})};
        const has=(n)=>Object.prototype.hasOwnProperty.call(d,n);
        const fw=[];
        if(has("next"))fw.push("Next.js");
        if(has("vite"))fw.push("Vite");
        if(has("react")&&!has("next"))fw.push("React");
        if(has("vue")||has("nuxt"))fw.push("Vue/Nuxt");
        if(has("svelte")||has("@sveltejs/kit"))fw.push("Svelte/SvelteKit");
        if(has("astro"))fw.push("Astro");
        if(has("express"))fw.push("Express");
        if(has("fastify"))fw.push("Fastify");
        if(has("@nestjs/core"))fw.push("NestJS");
        if(has("@hono/node-server")||has("hono"))fw.push("Hono");
        const db=[];
        if(has("mongoose"))db.push("MongoDB/Mongoose");
        if(has("pg")||has("postgres"))db.push("Postgres");
        if(has("prisma")||has("@prisma/client"))db.push("Prisma");
        if(has("drizzle-orm"))db.push("Drizzle");
        if(has("@supabase/supabase-js"))db.push("Supabase");
        const role = (fw.some(f=>["Express","Fastify","NestJS","Hono"].includes(f))) ? "backend"
                   : (fw.length? "frontend" : "library/unknown");
        const dir=process.argv[2];
        console.log(`- \`${dir}\` — **${role}**`);
        console.log(`  - name: ${p.name||"(unnamed)"}`);
        console.log(`  - frameworks: ${fw.length?fw.join(", "):"none detected"}`);
        if(db.length) console.log(`  - data/auth: ${db.join(", ")}`);
        const scripts=Object.keys(p.scripts||{});
        if(scripts.length) console.log(`  - scripts: ${scripts.join(", ")}`);
      ' "$pkg" "$dir" 2>/dev/null || echo "- \`$pkg\` (could not parse)"
    else
      echo "- \`$pkg\` (node not available to parse)"
    fi
  done <<< "$PKGS"
fi
echo

# ---------------------------------------------------------------------------
# Python backend detection
# ---------------------------------------------------------------------------
echo "## Python Manifests"
echo
PY="$(find_files requirements.txt; find_files pyproject.toml; find_files manage.py)"
if [ -z "$PY" ]; then
  echo "- None found."
else
  echo "$PY" | while IFS= read -r f; do [ -n "$f" ] && echo "- \`$f\`"; done
  echo
  echo "  (FastAPI/Django/Flask backend likely — inspect imports to confirm.)"
fi
echo

# ---------------------------------------------------------------------------
# Environment files
# ---------------------------------------------------------------------------
echo "## Environment Files"
echo
ENVS="$(find_files '.env'; find_files '.env.*'; find_files '.env.example')"
if [ -z "$ENVS" ]; then
  echo "- None found."
else
  echo "$ENVS" | sort -u | while IFS= read -r f; do [ -n "$f" ] && echo "- \`$f\`"; done
fi
echo

# ---------------------------------------------------------------------------
# Deploy config already present
# ---------------------------------------------------------------------------
echo "## Existing Deploy Config"
echo
for f in vercel.json .vercel koyeb.yaml Dockerfile docker-compose.yml supabase; do
  exists "$f" && echo "- \`$f\`"
done
echo

echo "---"
echo "_Scan is read-only. Use this inventory to fill the intake artifact"
echo "(\`assets/templates/intake.md\`) and choose an onboarding path._"
