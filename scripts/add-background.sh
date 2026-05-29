#!/usr/bin/env bash
set -euo pipefail

# Add a React Bits animated/3D background to an app: copies the component source
# into src/components/backgrounds/ and installs its npm dependencies.
#
# Usage:
#   scripts/add-background.sh <Name|all> [target-app-dir]
#
# Examples:
#   scripts/add-background.sh LiquidEther          # into the current app
#   scripts/add-background.sh Prism ./apps/web     # into a monorepo web app
#   scripts/add-background.sh all                  # every component + all deps
#
# Run it from anywhere; the kit location is resolved from this script's path.
# The full catalog (and per-component dependencies) lives in
# assets/components/backgrounds/manifest.json.

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_DIR="$KIT_DIR/assets/components/backgrounds"
MANIFEST="$SRC_DIR/manifest.json"
RESOLVE="$KIT_DIR/scripts/lib/bg-resolve.js"

NAME="${1:-}"
TARGET="${2:-.}"

if ! command -v node >/dev/null 2>&1; then
  echo "node is required." >&2
  exit 1
fi

if [ -z "$NAME" ]; then
  echo "Usage: scripts/add-background.sh <Name|all> [target-app-dir]"
  echo ""
  echo "Available backgrounds:"
  node "$RESOLVE" "$MANIFEST" all >/dev/null 2>&1 || true
  node -e 'const m=JSON.parse(require("fs").readFileSync(process.argv[1],"utf8"));console.log("  "+m.backgrounds.map(b=>b.name).join(", "))' "$MANIFEST"
  exit 1
fi

# Resolve files + deps (and validate the name). bg-resolve prints a helpful
# error to stderr and exits non-zero for unknown names. Avoid `mapfile` so this
# runs on the bash 3.2 that ships with macOS.
if ! INFO="$(node "$RESOLVE" "$MANIFEST" "$NAME")"; then
  exit 1
fi

LINES=()
while IFS= read -r line; do LINES+=("$line"); done <<< "$INFO"
read -r -a FILES <<< "${LINES[0]:-}"
read -r -a DEPS <<< "${LINES[1]:-}"
RESOLVED="${LINES[2]:-$NAME}"

# Prefer a src/ layout; fall back to a flat components/ dir.
if [ -d "$TARGET/src" ]; then
  DEST="$TARGET/src/components/backgrounds"
else
  DEST="$TARGET/components/backgrounds"
fi
mkdir -p "$DEST"

for f in "${FILES[@]}"; do
  cp "$SRC_DIR/$f" "$DEST/$f"
done
echo "Copied into $DEST: ${FILES[*]}"

if [ "${#DEPS[@]}" -gt 0 ] && [ -n "${DEPS[0]}" ]; then
  # Detect the package manager from the target's lockfile.
  pm="npm"
  if [ -f "$TARGET/pnpm-lock.yaml" ]; then pm="pnpm"
  elif [ -f "$TARGET/yarn.lock" ]; then pm="yarn"
  elif [ -f "$TARGET/bun.lockb" ]; then pm="bun"
  fi

  echo "Installing dependencies with $pm: ${DEPS[*]}"
  (
    cd "$TARGET"
    case "$pm" in
      pnpm) pnpm add "${DEPS[@]}" ;;
      yarn) yarn add "${DEPS[@]}" ;;
      bun) bun add "${DEPS[@]}" ;;
      *) npm install "${DEPS[@]}" ;;
    esac
  )
else
  echo "No external dependencies required."
fi

echo ""
echo "Added background(s): $RESOLVED"
echo "Wrap with AnimatedBackground, e.g.:"
echo "  <AnimatedBackground load={() => import(\"@/components/backgrounds/${RESOLVED%% *}\")} />"
echo "See src/components/backgrounds/README.md and references/backgrounds.md."
