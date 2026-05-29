#!/usr/bin/env bash
set -euo pipefail

# Install the startup-kit skill into every AI coding agent on this machine
# (Cursor, Claude Code, Codex, and more). One git clone is symlinked into each
# agent's skills directory, so a single `scripts/upgrade.sh` updates them all.
#
# Usage:
#   scripts/setup.sh                 install into every detected agent
#   scripts/setup.sh --host cursor   install into specific agent(s); repeatable
#   scripts/setup.sh --all           install into every known agent dir
#   scripts/setup.sh --copy          copy files instead of symlinking (Windows)
#   scripts/setup.sh --list          list known agents and detection status
#
# Recommended clone path: ~/.startup-kit (but this works from any clone location).

SKILL_NAME="startup-kit"
KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=/dev/null
. "$KIT_DIR/scripts/lib/hosts.sh"

usage() {
  sed -n '6,15p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

USE_COPY=0
DO_ALL=0
DO_LIST=0
REQ_HOSTS=()

while [ $# -gt 0 ]; do
  case "$1" in
    --host) shift; REQ_HOSTS+=("${1:-}") ;;
    --host=*) REQ_HOSTS+=("${1#*=}") ;;
    --all) DO_ALL=1 ;;
    --copy) USE_COPY=1 ;;
    --list) DO_LIST=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
  esac
  shift
done

if [ "$DO_LIST" = "1" ]; then
  echo "Known agents (* = detected on this machine):"
  while IFS='|' read -r name marker skilldir; do
    if [ -d "$HOME/$marker" ]; then mark="*"; else mark=" "; fi
    printf "  [%s] %-9s -> ~/%s\n" "$mark" "$name" "$skilldir"
  done < <(sk_hosts)
  exit 0
fi

# Copy the repo (minus .git) into a destination dir. Used for --copy and as the
# fallback when symlinks are unavailable (e.g. Windows without Developer Mode).
copy_into() {
  local dest="$1"
  mkdir -p "$dest"
  ( cd "$KIT_DIR" && tar --exclude='./.git' -cf - . ) | ( cd "$dest" && tar -xf - )
}

install_host() {
  local name="$1" skilldir="$2"
  local base="$HOME/$skilldir"
  local dest="$base/$SKILL_NAME"
  mkdir -p "$base"

  if [ -L "$dest" ]; then
    local cur
    cur="$(readlink "$dest")"
    if [ "$cur" = "$KIT_DIR" ]; then
      echo "  $name: already linked"
      return 0
    fi
    rm -f "$dest"
  elif [ -e "$dest" ]; then
    local bak
    bak="$dest.bak.$(date -u +%Y%m%d%H%M%S)"
    mv "$dest" "$bak"
    echo "  $name: backed up existing install -> $(basename "$bak")"
  fi

  if [ "$USE_COPY" = "1" ]; then
    copy_into "$dest"
    echo "  $name: copied -> ~/$skilldir/$SKILL_NAME"
  elif ln -snf "$KIT_DIR" "$dest" 2>/dev/null; then
    echo "  $name: linked -> ~/$skilldir/$SKILL_NAME"
  else
    copy_into "$dest"
    echo "  $name: symlink unavailable, copied -> ~/$skilldir/$SKILL_NAME"
  fi
}

# Resolve the list of hosts to install into.
hosts_to_install=()
if [ "${#REQ_HOSTS[@]}" -gt 0 ]; then
  while IFS='|' read -r name marker skilldir; do
    for r in "${REQ_HOSTS[@]}"; do
      if [ "$r" = "$name" ]; then hosts_to_install+=("$name|$skilldir"); fi
    done
  done < <(sk_hosts)
  # Warn about any requested host we don't know.
  while IFS= read -r r; do
    if ! sk_hosts | cut -d'|' -f1 | grep -qx "$r"; then
      echo "Unknown agent '$r' (try --list)." >&2
    fi
  done < <(printf '%s\n' "${REQ_HOSTS[@]}")
else
  while IFS='|' read -r name marker skilldir; do
    if [ "$DO_ALL" = "1" ] || [ -d "$HOME/$marker" ]; then
      hosts_to_install+=("$name|$skilldir")
    fi
  done < <(sk_hosts)
fi

if [ "${#hosts_to_install[@]}" -eq 0 ]; then
  echo "No agents detected. Use --host <name> or --all (see --list)." >&2
  exit 1
fi

echo "Installing $SKILL_NAME from $KIT_DIR into:"
for h in "${hosts_to_install[@]}"; do
  install_host "${h%%|*}" "${h#*|}"
done

echo ""
echo "Done. Update anytime (refreshes every agent at once):"
echo "  $KIT_DIR/scripts/upgrade.sh"
echo "Reload each agent (e.g. Cursor: Reload Window) to pick up the skill."
