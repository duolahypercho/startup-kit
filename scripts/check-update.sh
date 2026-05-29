#!/usr/bin/env bash
# Check whether a newer version of startup-kit is published, and if so print a
# short "update available" message. Designed to be wired into each agent's
# session-start hook (Cursor, Claude Code, Codex) so the agent can proactively
# offer to update — see scripts/install-hooks.sh.
#
# This script NEVER blocks a session and NEVER errors out: any failure (offline,
# not a git checkout, etc.) results in no output and exit 0.
#
# Usage:
#   scripts/check-update.sh                 plain message if an update exists
#   scripts/check-update.sh --hook cursor   emit Cursor sessionStart JSON
#   scripts/check-update.sh --hook claude   emit Claude Code SessionStart JSON
#   scripts/check-update.sh --hook codex    plain text (Codex injects stdout)
#   scripts/check-update.sh --force         ignore the throttle and fetch now
#
# A network fetch runs at most once per SK_UPDATE_THROTTLE seconds (default 4h);
# in between, it compares against the last-fetched state with no network.

set -uo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)" || exit 0
STAMP="$KIT_DIR/.update-check.stamp"
THROTTLE="${SK_UPDATE_THROTTLE:-14400}"
FORMAT="plain"
FORCE=0

while [ $# -gt 0 ]; do
  case "$1" in
    --hook) shift; FORMAT="${1:-plain}" ;;
    --hook=*) FORMAT="${1#*=}" ;;
    --force) FORCE=1 ;;
    *) : ;;
  esac
  shift
done

cd "$KIT_DIR" 2>/dev/null || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

now="$(date +%s 2>/dev/null || echo 0)"
last=0
[ -f "$STAMP" ] && last="$(cat "$STAMP" 2>/dev/null || echo 0)"
case "$last" in ''|*[!0-9]*) last=0 ;; esac

if [ "$FORCE" = "1" ] || [ "$(( now - last ))" -ge "$THROTTLE" ]; then
  # Bounded, quiet fetch: aborts if the network stalls so session start is never
  # held up, and never fails the script.
  git -c http.lowSpeedLimit=1000 -c http.lowSpeedTime=5 fetch --quiet origin >/dev/null 2>&1 || true
  echo "$now" > "$STAMP" 2>/dev/null || true
fi

branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo main)"
behind="$(git rev-list --count "HEAD..origin/$branch" 2>/dev/null || echo 0)"
case "$behind" in ''|*[!0-9]*) behind=0 ;; esac

[ "$behind" -gt 0 ] || exit 0

upgrade="$KIT_DIR/scripts/upgrade.sh"
plural="s"; [ "$behind" = "1" ] && plural=""
msg="[startup-kit] A newer version of the startup-kit skill is available (this machine is ${behind} commit${plural} behind). Proactively tell the user an update is available and offer to update all of their AI coding agents at once by running: ${upgrade}"

json_escape() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  s="${s//$'\n'/\\n}"
  printf '%s' "$s"
}

case "$FORMAT" in
  cursor)
    printf '{"additional_context": "%s"}\n' "$(json_escape "$msg")" ;;
  claude)
    printf '{"hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": "%s"}}\n' "$(json_escape "$msg")" ;;
  codex|plain|*)
    printf '%s\n' "$msg" ;;
esac
exit 0
