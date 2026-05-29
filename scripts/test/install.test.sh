#!/usr/bin/env bash
set -uo pipefail

# Tests for the cross-agent installer and the auto-update hooks:
#   scripts/setup.sh, scripts/check-update.sh, scripts/lib/merge-hook.js
# Plain bash so it runs on macOS Bash 3.2 and on CI. Run: scripts/test/install.test.sh

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MERGE="$KIT_DIR/scripts/lib/merge-hook.js"
PASS=0
FAIL=0

ok()  { PASS=$((PASS + 1)); echo "  ok   - $1"; }
bad() { FAIL=$((FAIL + 1)); echo "  FAIL - $1"; }

assert_eq()       { if [ "$1" = "$2" ]; then ok "$3"; else bad "$3 (expected '$1', got '$2')"; fi; }
assert_empty()    { if [ -z "$1" ]; then ok "$2"; else bad "$2 (expected empty, got '$1')"; fi; }
assert_contains() { case "$2" in *"$1"*) ok "$3" ;; *) bad "$3 (missing '$1')" ;; esac; }
assert_true()     { if [ "$1" -eq 0 ] 2>/dev/null || eval "$1"; then ok "$2"; else bad "$2"; fi; }

sandbox() { mktemp -d "${TMPDIR:-/tmp}/sk-itest.XXXXXX"; }

HAVE_NODE=0
command -v node >/dev/null 2>&1 && HAVE_NODE=1
HAVE_GIT=0
command -v git >/dev/null 2>&1 && HAVE_GIT=1

# ---------------------------------------------------------------------------
echo "merge-hook.js (idempotent, preserves existing config)"
if [ "$HAVE_NODE" = "0" ]; then
  echo "  -- skipped (node not installed)"
else
  jget() { node -e 'const o=JSON.parse(require("fs").readFileSync(process.argv[1],"utf8"));const f=new Function("o","return ("+process.argv[2]+")");process.stdout.write(String(f(o)))' "$1" "$2" 2>/dev/null; }

  d="$(sandbox)"; cfg="$d/hooks.json"
  node "$MERGE" cursor "$cfg" "/x/check-update.sh --hook cursor" install >/dev/null
  assert_eq "1" "$(jget "$cfg" 'o.hooks.sessionStart.length')" "cursor: one entry after install"
  assert_eq "1" "$(jget "$cfg" 'o.version')" "cursor: version set to 1"
  node "$MERGE" cursor "$cfg" "/x/check-update.sh --hook cursor" install >/dev/null
  assert_eq "1" "$(jget "$cfg" 'o.hooks.sessionStart.length')" "cursor: no duplicate on re-install"
  node "$MERGE" cursor "$cfg" "/x/check-update.sh --hook cursor" uninstall >/dev/null
  assert_eq "undefined" "$(jget "$cfg" 'o.hooks&&o.hooks.sessionStart')" "cursor: pruned on uninstall"

  # Claude: must preserve unrelated keys and pre-existing hooks.
  d="$(sandbox)"; cfg="$d/settings.json"
  printf '%s\n' '{"model":"claude-opus","hooks":{"SessionStart":[{"hooks":[{"type":"command","command":"echo keep-me"}]}]}}' > "$cfg"
  node "$MERGE" claude "$cfg" "/x/check-update.sh --hook claude" install >/dev/null
  assert_eq "2" "$(jget "$cfg" 'o.hooks.SessionStart.length')" "claude: ours added beside existing hook"
  assert_eq "claude-opus" "$(jget "$cfg" 'o.model')" "claude: unrelated key preserved"
  node "$MERGE" claude "$cfg" "/x/check-update.sh --hook claude" install >/dev/null
  assert_eq "2" "$(jget "$cfg" 'o.hooks.SessionStart.length')" "claude: no duplicate on re-install"
  node "$MERGE" claude "$cfg" "/x/check-update.sh --hook claude" uninstall >/dev/null
  assert_eq "1" "$(jget "$cfg" 'o.hooks.SessionStart.length')" "claude: only ours removed on uninstall"
  assert_eq "echo keep-me" "$(jget "$cfg" 'o.hooks.SessionStart[0].hooks[0].command')" "claude: existing hook kept"

  # Codex: matcher + command shape.
  d="$(sandbox)"; cfg="$d/hooks.json"
  node "$MERGE" codex "$cfg" "/x/check-update.sh --hook codex" install >/dev/null
  assert_eq "startup|resume" "$(jget "$cfg" 'o.hooks.SessionStart[0].matcher')" "codex: matcher set"
  assert_contains "--hook codex" "$(jget "$cfg" 'o.hooks.SessionStart[0].hooks[0].command')" "codex: command wired"
fi

# ---------------------------------------------------------------------------
echo "check-update.sh (formats, behind/current, fail-open)"
if [ "$HAVE_GIT" = "0" ]; then
  echo "  -- skipped (git not installed)"
else
  make_behind_repo() {
    local root; root="$(sandbox)"
    (
      cd "$root" || exit 1
      git init -q --bare origin.git
      git clone -q origin.git work 2>/dev/null
      mkdir -p work/scripts
      cp "$KIT_DIR/scripts/check-update.sh" work/scripts/
      cd work || exit 1
      git -c user.email=t@t -c user.name=t add -A
      git -c user.email=t@t -c user.name=t commit -qm v1
      git push -q -u origin HEAD:main
      git checkout -q -B main
      cd "$root" || exit 1
      git clone -q origin.git ahead 2>/dev/null
      cd ahead || exit 1
      git -c user.email=t@t -c user.name=t commit -q --allow-empty -m two
      git -c user.email=t@t -c user.name=t commit -q --allow-empty -m three
      git push -q origin HEAD:main
    ) >/dev/null 2>&1
    echo "$root/work"
  }

  w="$(make_behind_repo)"
  assert_contains "behind" "$(bash "$w/scripts/check-update.sh" --force)" "plain: reports behind"

  if [ "$HAVE_NODE" = "1" ]; then
    cout="$(bash "$w/scripts/check-update.sh" --hook cursor --force)"
    assert_eq "1" "$(printf '%s' "$cout" | node -e 'try{const o=JSON.parse(require("fs").readFileSync(0,"utf8"));process.stdout.write(o.additional_context?"1":"0")}catch(e){process.stdout.write("0")}')" "cursor: valid additional_context JSON"
    clout="$(bash "$w/scripts/check-update.sh" --hook claude --force)"
    assert_eq "SessionStart" "$(printf '%s' "$clout" | node -e 'try{const o=JSON.parse(require("fs").readFileSync(0,"utf8"));process.stdout.write(o.hookSpecificOutput.hookEventName)}catch(e){process.stdout.write("ERR")}')" "claude: valid hookSpecificOutput envelope"
  fi

  # Bring it current -> no notification.
  ( cd "$w" && git pull -q --ff-only origin main && rm -f .update-check.stamp ) >/dev/null 2>&1
  assert_empty "$(bash "$w/scripts/check-update.sh" --force)" "current: prints nothing"

  # Not a git checkout -> fail open (no output, exit 0).
  d="$(sandbox)"; mkdir -p "$d/scripts"; cp "$KIT_DIR/scripts/check-update.sh" "$d/scripts/"
  out="$(bash "$d/scripts/check-update.sh" --force)"; rc=$?
  assert_empty "$out" "non-git: prints nothing"
  assert_eq "0" "$rc" "non-git: exits 0 (fail open)"
fi

# ---------------------------------------------------------------------------
echo "setup.sh (link, backup, idempotent, copy)"
h="$(sandbox)"
mkdir -p "$h/.cursor/skills/startup-kit" "$h/.codex"
echo old > "$h/.cursor/skills/startup-kit/SKILL.md"
HOME="$h" bash "$KIT_DIR/scripts/setup.sh" >/dev/null 2>&1

if [ -L "$h/.cursor/skills/startup-kit" ] && [ "$(readlink "$h/.cursor/skills/startup-kit")" = "$KIT_DIR" ]; then
  ok "setup: cursor linked to kit"
else
  bad "setup: cursor linked to kit"
fi
if ls -d "$h/.cursor/skills/"startup-kit.bak.* >/dev/null 2>&1; then ok "setup: backed up old install"; else bad "setup: backed up old install"; fi
if [ -L "$h/.codex/skills/startup-kit" ]; then ok "setup: codex linked"; else bad "setup: codex linked"; fi
assert_contains "already linked" "$(HOME="$h" bash "$KIT_DIR/scripts/setup.sh" 2>&1)" "setup: idempotent re-run"

HOME="$h" bash "$KIT_DIR/scripts/setup.sh" --host factory --copy >/dev/null 2>&1
if [ -f "$h/.factory/skills/startup-kit/SKILL.md" ] && [ ! -L "$h/.factory/skills/startup-kit" ]; then ok "setup: --copy makes a real dir"; else bad "setup: --copy makes a real dir"; fi
if [ ! -d "$h/.factory/skills/startup-kit/.git" ]; then ok "setup: --copy excludes .git"; else bad "setup: --copy excludes .git"; fi

echo ""
echo "passed: $PASS   failed: $FAIL"
[ "$FAIL" -eq 0 ]
