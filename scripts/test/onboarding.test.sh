#!/usr/bin/env bash
set -uo pipefail
# shellcheck disable=SC1090  # sources the kit lib by computed path on purpose

# Tests for the onboarding gate (scripts/lib/onboarding-gate.sh) and the intake
# validator (scripts/check-intake.sh). Plain bash so it runs on macOS Bash 3.2.
# Run: scripts/test/onboarding.test.sh

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PASS=0
FAIL=0

ok()   { PASS=$((PASS + 1)); echo "  ok   - $1"; }
bad()  { FAIL=$((FAIL + 1)); echo "  FAIL - $1"; }

# assert_eq EXPECTED ACTUAL MESSAGE
assert_eq() { if [ "$1" = "$2" ]; then ok "$3"; else bad "$3 (expected '$1', got '$2')"; fi; }
# assert_zero / assert_nonzero RC MESSAGE
assert_zero()    { if [ "$1" -eq 0 ]; then ok "$2"; else bad "$2"; fi; }
assert_nonzero() { if [ "$1" -ne 0 ]; then ok "$2"; else bad "$2"; fi; }

# Run a fresh sandbox dir for each case.
sandbox() { mktemp -d "${TMPDIR:-/tmp}/sk-test.XXXXXX"; }

write_intake() {
  # $1 = dir, $2 = status (confirmed|draft), $3 = fill required fields? (yes|no)
  local dir="$1" status="$2" fill="$3"
  mkdir -p "$dir/.startup-kit"
  {
    echo "<!-- startup-kit:intake status=$status -->"
    echo "# Project Intake"
    if [ "$fill" = "yes" ]; then
      echo "- One user: A freelance designer tracking invoices"
      echo "- One job: Send and track client invoices"
      echo "- One primary workflow: Create invoice, send it, mark paid"
      echo "- Product / app name: InvoiceDesk"
    else
      echo "- One user:"
      echo "- One job:"
      echo "- One primary workflow:"
      echo "- Product / app name:"
    fi
  } > "$dir/.startup-kit/intake.md"
}

# Run the gate in a subshell inside $1; echoes the exit status.
run_gate() {
  local dir="$1"; shift
  ( cd "$dir" \
    && . "$KIT_DIR/scripts/lib/onboarding-gate.sh" \
    && og_parse_and_require "$@" >/dev/null 2>&1; echo $? )
}

echo "check-intake.sh"

check_intake_rc() { ( cd "$1" && bash "$KIT_DIR/scripts/check-intake.sh" >/dev/null 2>&1; echo $? ); }

d="$(sandbox)"
assert_nonzero "$(check_intake_rc "$d")" "fails when no intake file"

d="$(sandbox)"; write_intake "$d" draft yes
assert_nonzero "$(check_intake_rc "$d")" "fails when intake not confirmed"

d="$(sandbox)"; write_intake "$d" confirmed no
assert_nonzero "$(check_intake_rc "$d")" "fails when required fields empty"

d="$(sandbox)"; write_intake "$d" confirmed yes
assert_zero "$(check_intake_rc "$d")" "passes when confirmed and filled"

echo "onboarding gate"

d="$(sandbox)"
assert_nonzero "$(run_gate "$d" myapp)" "blocks scaffold with no intake"

d="$(sandbox)"; write_intake "$d" draft yes
assert_nonzero "$(run_gate "$d" myapp)" "blocks scaffold with unconfirmed intake"

d="$(sandbox)"; write_intake "$d" confirmed yes
assert_zero "$(run_gate "$d" myapp)" "allows scaffold with confirmed intake"

d="$(sandbox)"
assert_zero "$(run_gate "$d" myapp --skip-onboarding)" "override allows scaffold without intake"

# Override must strip the flag and preserve the real arg.
d="$(sandbox)"
remaining="$( cd "$d" \
  && . "$KIT_DIR/scripts/lib/onboarding-gate.sh" \
  && og_parse_and_require myapp --skip-onboarding >/dev/null 2>&1 \
  && set -- ${OG_ARGS[@]+"${OG_ARGS[@]}"} && echo "$*" )"
assert_eq "myapp" "$remaining" "strips --skip-onboarding, keeps app name"

# Env override path with no positional args must not error under set -u.
d="$(sandbox)"
rc="$( cd "$d" && STARTUP_KIT_SKIP_ONBOARDING=1 bash -c '
  set -euo pipefail
  . "'"$KIT_DIR"'/scripts/lib/onboarding-gate.sh"
  og_parse_and_require >/dev/null 2>&1
  set -- ${OG_ARGS[@]+"${OG_ARGS[@]}"}
  echo $#' )"
assert_eq "0" "$rc" "env override with empty args is safe"

echo ""
echo "passed: $PASS   failed: $FAIL"
[ "$FAIL" -eq 0 ]
