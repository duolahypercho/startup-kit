#!/usr/bin/env bash
# Shared onboarding precondition for the scaffold scripts (create-app / create-monorepo).
#
# The startup kit interviews the user (or loads stored answers) BEFORE building and
# records the result in .startup-kit/intake.md. These scripts refuse to scaffold a
# whole product until that file exists, so an agent cannot skip onboarding by jumping
# straight to the build step. This is the mechanical backstop behind the "STOP — onboard
# before you build" gate in SKILL.md.
#
# Override only when you deliberately want raw scaffolding (e.g. an experienced developer
# who is not using onboarding):
#   --skip-onboarding                 flag (stripped from the args the caller sees)
#   STARTUP_KIT_SKIP_ONBOARDING=1     environment variable
#
# Usage from a scaffold script:
#   . "$KIT_DIR/scripts/lib/onboarding-gate.sh"
#   og_parse_and_require "$@" || exit 1
#   set -- ${OG_ARGS[@]+"${OG_ARGS[@]}"}   # rebuild positional args without the flag

_OG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse args, strip --skip-onboarding into OG_ARGS, and require a confirmed intake unless
# skipped. Validates .startup-kit/intake.md in the current working directory (where
# onboarding writes it) via check-intake.sh — it must exist, be marked confirmed, and have
# its required fields filled. Returns non-zero with guidance when onboarding has not run.
og_parse_and_require() {
  OG_ARGS=()
  local skip="${STARTUP_KIT_SKIP_ONBOARDING:-}"
  local arg
  for arg in "$@"; do
    case "$arg" in
      --skip-onboarding) skip=1 ;;
      *) OG_ARGS+=("$arg") ;;
    esac
  done

  if bash "$_OG_DIR/../check-intake.sh" ".startup-kit/intake.md" >/dev/null 2>&1; then
    return 0
  fi

  if [ -n "$skip" ]; then
    echo "WARNING: scaffolding without a confirmed onboarding intake." >&2
    echo "         Building from defaults; the user may not have been interviewed." >&2
    return 0
  fi

  # Surface the specific reasons (missing file / not confirmed / empty fields).
  bash "$_OG_DIR/../check-intake.sh" ".startup-kit/intake.md" >&2 || true

  cat >&2 <<'EOF'

  ──────────────────────────────────────────────────────────────────────────
  Onboarding is not complete — refusing to scaffold (see reasons above).

  The startup kit interviews the user (product, scope, style, theme,
  background animations, architecture, data, auth, payments, launch, deploy)
  and writes a confirmed .startup-kit/intake.md BEFORE building anything.

  If you are an agent: stop and run onboarding now.
    1. Read references/onboarding.md
    2. Check the repo for stored answers (.startup-kit/intake.md, AGENTS.md,
       CLAUDE.md, .cursorrules, .cursor/rules/*). Use them if present.
    3. If nothing is stored, interview the user, then write
       .startup-kit/intake.md from assets/templates/intake.md and flip the
       line-1 marker to status=confirmed once the user approves it.
    4. Re-run this script.

  To scaffold anyway, on purpose, without onboarding:
    --skip-onboarding   (or set STARTUP_KIT_SKIP_ONBOARDING=1)
  ──────────────────────────────────────────────────────────────────────────

EOF
  return 1
}
