#!/usr/bin/env bash
set -euo pipefail

# Turn on (or off) "an update is available — update now?" notifications by wiring
# startup-kit's update check into each agent's session-start hook. Works for
# Cursor, Claude Code, and Codex. The hook runs check-update.sh, which is
# throttled and never blocks a session.
#
# Usage:
#   scripts/install-hooks.sh                  install into every detected agent
#   scripts/install-hooks.sh --host cursor    target specific agent(s); repeatable
#   scripts/install-hooks.sh --uninstall      remove the startup-kit hook again
#   scripts/install-hooks.sh --list           list agents and detection status
#
# JSON configs are edited in place with Node (preserving your other settings),
# and a timestamped backup is written before any change.

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHECK="$KIT_DIR/scripts/check-update.sh"
MERGE="$KIT_DIR/scripts/lib/merge-hook.js"

usage() { sed -n '6,16p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; }

# name|marker|config-file   (paths relative to $HOME)
hook_hosts() {
  cat <<'EOF'
cursor|.cursor|.cursor/hooks.json
claude|.claude|.claude/settings.json
codex|.codex|.codex/hooks.json
EOF
}

MODE=install
DO_LIST=0
REQ_HOSTS=()

while [ $# -gt 0 ]; do
  case "$1" in
    --uninstall) MODE=uninstall ;;
    --host) shift; REQ_HOSTS+=("${1:-}") ;;
    --host=*) REQ_HOSTS+=("${1#*=}") ;;
    --list) DO_LIST=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
  esac
  shift
done

if [ "$DO_LIST" = "1" ]; then
  echo "Agents that support update hooks (* = detected):"
  while IFS='|' read -r name marker config; do
    if [ -d "$HOME/$marker" ]; then mark="*"; else mark=" "; fi
    printf "  [%s] %-7s -> ~/%s\n" "$mark" "$name" "$config"
  done < <(hook_hosts)
  exit 0
fi

if ! command -v node >/dev/null 2>&1; then
  echo "Node.js is required to safely edit agent config JSON." >&2
  echo "Install Node and re-run, or add the hook manually (see README)." >&2
  exit 1
fi

want_host() {
  local h="$1"
  if [ "${#REQ_HOSTS[@]}" -eq 0 ]; then return 0; fi
  for r in "${REQ_HOSTS[@]}"; do [ "$r" = "$h" ] && return 0; done
  return 1
}

changed=0
while IFS='|' read -r name marker config; do
  if [ "${#REQ_HOSTS[@]}" -eq 0 ] && [ ! -d "$HOME/$marker" ]; then
    continue
  fi
  want_host "$name" || continue

  cfg="$HOME/$config"
  if [ -f "$cfg" ]; then
    cp "$cfg" "$cfg.bak.$(date -u +%Y%m%d%H%M%S)"
  fi

  if node "$MERGE" "$name" "$cfg" "$CHECK --hook $name" "$MODE" >/dev/null; then
    if [ "$MODE" = "install" ]; then
      echo "  $name: update hook installed -> ~/$config"
      if [ "$name" = "codex" ]; then
        echo "         (Codex: run /hooks in the CLI to review and trust it; ensure hooks are enabled)"
      fi
    else
      echo "  $name: update hook removed from ~/$config"
    fi
    changed=1
  else
    echo "  $name: failed to update ~/$config" >&2
  fi
done < <(hook_hosts)

if [ "$changed" = "0" ]; then
  echo "No matching agents found. Try --list or --host <name>." >&2
  exit 1
fi

echo ""
if [ "$MODE" = "install" ]; then
  echo "Done. Each agent will now check for updates at session start and, when one"
  echo "is available, offer to run: $KIT_DIR/scripts/upgrade.sh"
  echo "Reload/restart each agent to load the hook."
else
  echo "Done. Reload/restart each agent to drop the hook."
fi
