# Changelog

All notable changes to the startup kit are recorded here. This project follows
[Semantic Versioning](https://semver.org/).

## Unreleased

### Cross-agent install and updates

- `scripts/setup.sh` installs the skill into every detected AI coding agent
  (Cursor, Claude Code, Codex, OpenCode, Factory) by symlinking one clone into
  each agent's skills directory. Supports `--host`, `--all`, `--copy`, `--list`,
  and backs up any existing install before linking.
- `scripts/upgrade.sh` fast-forwards the clone to the latest version and refreshes
  every agent at once; `--check` reports whether an update is available without
  applying it.
- `scripts/lib/hosts.sh` is the single table of known agents and their skills dirs.

### Optional "update available" notifications

- `scripts/install-hooks.sh` wires a session-start update check into each agent's
  hook system (Cursor `hooks.json`, Claude Code `settings.json`, Codex
  `hooks.json`), so agents proactively offer to update. Idempotent, backs up
  existing config, preserves unrelated hooks, and supports `--uninstall`,
  `--host`, and `--list`. Also reachable via `setup.sh --hooks`.
- `scripts/check-update.sh` is the throttled, fail-open checker the hooks call;
  it emits Cursor/Claude/Codex-shaped output and never blocks a session.
- `scripts/lib/merge-hook.js` performs the safe JSON edit (requires Node.js).

## v0.1.0 — 2026-05-29

First public release. A cross-agent startup kit that interviews the user, then
scaffolds and wires a complete product on a locked, minimal design system.

### Design system

- SF Pro stack, `13px` base, fixed type scale (`12 / 13 / 14 / 16 / 18 / 24px`),
  intent-based neutral colors.
- Light and dark mode in one token contract.
- Three opt-in brand presets (Linear, Vercel, Notion).
- Tailwind v3 and v4 configs, shadcn/ui setup with `cssVariables` enabled.
- Bundled icon sets (Lucide, Simple Icons, Tabler) and 42 React Bits background
  components with a manifest.

### Onboarding (enforced before building)

- Guided interview (`references/onboarding.md`) for new repos; detect-first gap
  analysis for existing code; everything captured in `.startup-kit/intake.md`.
- Onboarding is a hard gate at every surface an agent reads: the `SKILL.md`
  frontmatter and a top-level STOP rule, `AGENTS.md`, and the
  `agents/openai.yaml` default prompt.
- Mechanical backstop: `scripts/check-intake.sh` plus the onboarding gate make
  `create-app.sh` / `create-monorepo.sh` refuse to scaffold until a confirmed,
  filled-in intake exists (override with `--skip-onboarding`).
- Stored answers (`.startup-kit/intake.md`, `AGENTS.md`, project rules) are
  loaded instead of re-asking.

### Scaffolds and architecture

- Single app (default): Next.js App Router + Tailwind + shadcn/ui on the kit
  theme, with the background catalog bundled. Verified to build on Next.js 16.
- Monorepo (opt-in): pnpm + Turborepo with `apps/web` (Vercel), `apps/api`
  (Koyeb), and `packages/shared`, plus restructuring helpers.
- `create-next-app` and `shadcn` pinned to known-good majors via
  `scripts/lib/versions.sh` (env-overridable).
- `scripts/add-background.sh` installs any background component and its deps.

### Quality and tooling

- Reference docs for forms, states, accessibility, layout, writing, content,
  auth, payments, SEO, analytics, backend, and deployment.
- Mechanical pre-flight quality gate (`references/preflight.md`).
- Test suite for the onboarding gate (`scripts/test/onboarding.test.sh`) and CI
  (`.github/workflows/ci.yml`: `bash -n`, shellcheck, tests).
- MIT licensed; bundled third-party assets keep their original licenses.
