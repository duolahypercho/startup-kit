# AGENTS.md — Startup Kit

This repository is the **startup-kit** skill (`SKILL.md` is the entry point). Read this before acting in or with this kit.

## The one rule that matters most: onboard before you build

When a user asks you to build, scaffold, or "use the startup kit to create" a product, that is a request to **start the onboarding interview — not to start building.**

**Do not** scaffold, run `scripts/create-app.sh` / `scripts/create-monorepo.sh`, write product code, or pick defaults silently until onboarding has produced a **confirmed** `.startup-kit/intake.md`. This holds even if you build the app by hand without the kit's scripts.

Run onboarding this way (full detail in `references/onboarding.md`):

1. **Check for stored answers first.** Run `scripts/scan-project.sh`, then look for `.startup-kit/intake.md`, `AGENTS.md`/`CLAUDE.md`/`.cursorrules`/`.cursor/rules/*`, and any project brief. If a complete confirmed intake exists, load it and build from it — don't re-ask.
2. **Ask the missing questions.** If nothing is stored, run the full interview (product, scope, style, theme, background animations, architecture, data, auth, payments, integrations, launch, deploy), one batch at a time, each with a recommended default. If answers are partial, ask only what's missing.
3. **Write and confirm the intake.** Copy `assets/templates/intake.md` to `.startup-kit/intake.md`, fill it, read it back to the user, and flip the line-1 marker to `status=confirmed` only after they approve.
4. **Then build.** The scaffold scripts enforce this — they refuse to run until `scripts/check-intake.sh` passes (confirmed intake with required fields). Override only on purpose with `--skip-onboarding` / `STARTUP_KIT_SKIP_ONBOARDING=1`.

Building before a confirmed intake exists is a failure of this skill. When in doubt, ask the user — interviewing first is always correct.

## Working in this repo

- This repo *is* the skill; do not scaffold a product into it. Edit the kit's references, assets, and scripts.
- Keep `SKILL.md`, `README.md`, `agents/openai.yaml`, and this file consistent — they all state the onboarding-first rule.
- Shell scripts target macOS Bash 3.2; keep them POSIX-friendly and run `bash -n` + `shellcheck` before committing.
- Validate the gate behavior with `scripts/test/onboarding.test.sh` after changing the gate, `check-intake.sh`, or the scaffold scripts.
