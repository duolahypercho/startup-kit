#!/usr/bin/env bash
# Pinned tool versions for the scaffold scripts. Single source of truth.
#
# These are pinned to a known-good MAJOR so a fresh clone scaffolds the same
# toolchain the kit was validated against — floating `@latest` is what makes a
# published kit "randomly break" when upstream ships a new major. Each value is
# overridable by env (e.g. SK_NEXT_MAJOR=15) so maintainers can test a bump
# without editing scripts. When you bump a default here, re-validate the scaffold
# and the pre-flight check, then commit.
#
# `@<major>` resolves to the latest release within that major, so patches and
# minor versions still flow in; only breaking majors are held back.
#
# shellcheck disable=SC2034  # these are consumed by the scaffold scripts that source this file

# create-next-app major (Next.js). Current latest major at pin time: 16.
SK_NEXT_MAJOR="${SK_NEXT_MAJOR:-16}"

# shadcn CLI major. Current latest major at pin time: 4.
SK_SHADCN_MAJOR="${SK_SHADCN_MAJOR:-4}"
