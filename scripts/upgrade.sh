#!/usr/bin/env bash
set -euo pipefail

# Update the startup-kit skill to the latest published version, then refresh every
# agent it's installed into. Because setup.sh symlinks one clone into each agent,
# a single pull here updates Cursor, Claude Code, Codex, and the rest at once.
#
# Usage:
#   scripts/upgrade.sh            update to the latest version
#   scripts/upgrade.sh --check    report whether an update is available, don't apply

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$KIT_DIR"

CHECK_ONLY=0
[ "${1:-}" = "--check" ] && CHECK_ONLY=1

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Not a git checkout: $KIT_DIR" >&2
  echo "Reinstall with the clone command in the README, then run scripts/setup.sh." >&2
  exit 1
fi

branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo main)"
git fetch --tags --quiet origin || { echo "Could not reach origin (offline?)." >&2; exit 1; }

before="$(git rev-parse HEAD)"
remote="$(git rev-parse "origin/$branch" 2>/dev/null || echo "")"

if [ -z "$remote" ] || [ "$before" = "$remote" ]; then
  echo "startup-kit is already up to date ($(git describe --tags --abbrev=0 2>/dev/null || echo "$branch"))."
  exit 0
fi

if [ "$CHECK_ONLY" = "1" ]; then
  echo "An update is available for startup-kit:"
  git log --oneline "$before..$remote" | sed 's/^/  /'
  echo "Apply it with: $KIT_DIR/scripts/upgrade.sh"
  exit 0
fi

# Fast-forward only, so local edits are never silently clobbered.
if ! git pull --ff-only origin "$branch" >/dev/null 2>&1; then
  echo "Could not fast-forward $KIT_DIR (you have local changes)." >&2
  echo "Commit or stash them, or reset to the release:" >&2
  echo "  git -C \"$KIT_DIR\" reset --hard origin/$branch" >&2
  exit 1
fi

after="$(git rev-parse HEAD)"
echo "Updated startup-kit:"
git log --oneline "$before..$after" | sed 's/^/  /'

# Refresh installs: a no-op for symlinked agents, re-copies for --copy installs.
"$KIT_DIR/scripts/setup.sh" >/dev/null 2>&1 || true

echo ""
echo "Now at $(git describe --tags --abbrev=0 2>/dev/null || git rev-parse --short HEAD)."
echo "Reload each agent (e.g. Cursor: Reload Window) to pick up the changes."
