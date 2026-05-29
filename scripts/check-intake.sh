#!/usr/bin/env bash
set -euo pipefail

# Validates that a startup-kit intake is present, confirmed, and has its always-required
# fields filled. Exits 0 when the intake is ready to build from; non-zero (with reasons)
# otherwise. Used by the scaffold scripts' onboarding gate, and runnable on its own.
#
# Usage: scripts/check-intake.sh [path]      (default: .startup-kit/intake.md)

INTAKE="${1:-.startup-kit/intake.md}"
problems=()

if [ ! -f "$INTAKE" ]; then
  echo "No intake at '$INTAKE' — run onboarding first (references/onboarding.md)." >&2
  exit 1
fi

# Confirmation marker, written only after the user reviews and approves the intake.
if ! grep -qiE 'startup-kit:intake[^>]*status=confirmed' "$INTAKE"; then
  problems+=("intake is not confirmed — line 1 marker must read 'status=confirmed' (it is set after the user approves the intake)")
fi

# Always-required product fields must have a non-empty value after the colon.
require_field() {
  local label="$1"
  local line val
  line="$(grep -m1 -E "^- ${label}:" "$INTAKE" 2>/dev/null || true)"
  # Everything after the first colon is the field value (labels contain no colon).
  val="${line#*:}"
  if [ -z "$(printf '%s' "$val" | tr -d '[:space:]')" ]; then
    problems+=("required field is empty: '${label}'")
  fi
}
require_field "One user"
require_field "One job"
require_field "One primary workflow"
require_field "Product / app name"

if [ "${#problems[@]}" -gt 0 ]; then
  echo "Intake at '$INTAKE' is not ready to build:" >&2
  for p in "${problems[@]}"; do echo "  - $p" >&2; done
  echo "Finish onboarding (references/onboarding.md) and confirm the intake before scaffolding." >&2
  exit 1
fi

echo "Intake OK: $INTAKE (confirmed, required fields present)."
