# Startup Kit

A cross-agent startup kit that lets a coding agent (Cursor, Claude Code, Codex, or similar) build a complete, good-looking product for you — with a locked design system, a guided interview, and one-command scaffolds. You describe what you want; the agent asks a few questions, then builds it.

The philosophy is restraint: make the smallest useful product that works, then polish until nothing feels accidental. Quiet, dense, tool-like UI by default; expressive treatments stay opt-in and confined to marketing surfaces.

> **The one rule that defines this kit: onboard before building.** When someone says "build me X," the agent first runs a short interview (or loads answers already saved in the repo), writes them to `.startup-kit/intake.md`, and only then scaffolds. It never guesses your whole product from silence.

## How it works

1. You point an AI agent at this repo and tell it what you want to build.
2. The agent reads `SKILL.md`, then runs onboarding (`references/onboarding.md`): it checks for saved answers, and if there are none, it interviews you in plain English (what it is, who it's for, how it should look, login, payments, and so on).
3. It writes your answers to `.startup-kit/intake.md` and reads them back for you to confirm.
4. It scaffolds the app on the kit's theme, builds your main screen, and wires everything together.
5. It runs a pre-flight quality check before calling it done.

This README has two kinds of reader. Jump to the one that's you:

- **Anyone who just wants the kit installed** → ["Install in one command"](#install-in-one-command)
- **A person who wants to build something** → ["For people: no coding needed"](#for-people-no-coding-needed)
- **An AI agent asked to use the kit** → ["For AI agents: start here"](#for-ai-agents-start-here)
- **A developer who wants the commands** → ["Quick start (for developers)"](#quick-start-for-developers)

## Install in one command

The kit is published as a public agent skill, so **anyone** can install it into their coding agent with a single command — no clone, no setup script, no account:

```bash
npx skills add duolahypercho/startup-kit
```

This uses the open [`skills`](https://github.com/vercel-labs/skills) CLI, which reads the repo straight from GitHub and copies the skill into whichever agent you choose. It works across **Cursor, Claude Code, Codex, Gemini CLI, Windsurf, and many more** — the CLI detects your installed agents and asks which to target.

Useful flags:

- `--global` / `-g` — install for all your projects (into your user skills dir) instead of just the current repo.
- `--agent <name>` / `-a` — target a specific agent, e.g. `--agent claude-code` or `--agent cursor`.
- `--yes` / `-y` — skip the prompts (handy in scripts/CI).
- `--list` — show what's in the repo without installing.

```bash
# Install globally into Claude Code, no prompts:
npx skills add duolahypercho/startup-kit --global --agent claude-code --yes
```

To update later, re-run the same `npx skills add …` command, or use the clone-based `upgrade.sh` flow below.

> **Prefer to manage the kit as one shared clone across every agent at once** (one folder, one `upgrade.sh` for all of them, plus optional update hooks)? Use the install method just below instead.

## Install across all your agents (and keep them updated)

The kit is one git repo. Clone it once, and `setup.sh` symlinks it into every AI coding agent you have — Cursor, Claude Code, Codex, and more — so all of them get the skill. Because they share one clone, a single `upgrade.sh` updates every agent at once.

```bash
git clone https://github.com/duolahypercho/startup-kit.git ~/.startup-kit
~/.startup-kit/scripts/setup.sh          # detects your agents, links the skill into each
```

- Preview what it will target: `~/.startup-kit/scripts/setup.sh --list`
- Install into one agent only: `~/.startup-kit/scripts/setup.sh --host cursor`
- Install into every known agent dir: `~/.startup-kit/scripts/setup.sh --all`
- Windows / no symlink support: add `--copy`

Then reload each agent (e.g. Cursor: Reload Window) and the skill is available.

If `setup.sh` replaced an older copy, it left a timestamped backup (e.g.
`startup-kit.bak.20260529172055`) next to the new link. Once you've confirmed the
skill works, you can delete those backups: `rm -rf ~/.cursor/skills/startup-kit.bak.*`.

### Updating

```bash
~/.startup-kit/scripts/upgrade.sh          # pull the latest, refresh every agent
~/.startup-kit/scripts/upgrade.sh --check  # only report whether a newer version exists
```

One pull updates all agents at once.

### Get notified automatically (optional)

No AI agent auto-updates skills natively, so by default you run `upgrade.sh` when you want it. To make agents tell you when a new version exists, install the session-start update hook:

```bash
~/.startup-kit/scripts/install-hooks.sh          # into every detected agent
~/.startup-kit/scripts/install-hooks.sh --list   # see which agents support it
~/.startup-kit/scripts/install-hooks.sh --uninstall
```

At the start of a session each agent runs a throttled check (at most once every few hours, never blocking) and, when you're behind, the agent proactively offers to run `upgrade.sh`. Supported today: **Cursor**, **Claude Code**, and **Codex**. Your existing hook config is preserved and backed up before any change; Node.js is required for the safe JSON edit. For Codex, run `/hooks` in the CLI once to review and trust the hook.

You can also turn this on while installing: `~/.startup-kit/scripts/setup.sh --hooks`.

### Or just paste this to your agent

> Install the startup kit: run `git clone https://github.com/duolahypercho/startup-kit.git ~/.startup-kit && ~/.startup-kit/scripts/setup.sh`, then tell me which agents it installed into. To update later, run `~/.startup-kit/scripts/upgrade.sh`.

## What you get

- A locked design system: SF Pro stack, a `13px` base, a fixed type scale (`12 / 13 / 14 / 16 / 18 / 24px`), and intent-based neutral colors.
- Light and dark mode in one token contract (switch values, never names).
- Three opt-in brand presets modeled on Linear, Vercel, and Notion.
- Tailwind v3 and v4 configs plus shadcn/ui setup with `cssVariables` enabled.
- Bundled icon starter sets (Lucide, Simple Icons, Tabler) and 42 React Bits background components.
- A guided onboarding flow: a thorough interview for new repos and detect-first gap analysis for existing code, captured in a `.startup-kit/intake.md` source of truth, that ends by scaffolding and wiring the product.
- A layered Node/TypeScript/Express backend reference, plus a monorepo pattern for keeping the frontend and backend in one repo while hosting them on different platforms (Vercel + Supabase + Koyeb).
- Focused reference docs covering forms, states, accessibility, layout, copy, auth, payments, SEO, analytics, backend, and deployment.
- One-command scaffolds (single app or monorepo) and a mechanical pre-flight quality gate.

## For people: no coding needed

You do not need to know how to code, what a "framework" is, or any of the words in this README. The kit is built so an AI agent does the work and walks you through it in plain English.

1. Open this project in an AI coding tool (Cursor, Claude Code, or similar).
2. Type this, in your own words:

   > **"Use the startup kit to build my app. Ask me questions and guide me."**

3. Answer the questions it asks. They're plain ("Who is this for?", "Should people log in?", "Does it take money?"). If you don't know an answer, just say **"you pick"** or **"whatever's easiest"** — it will choose the sensible option and tell you what it picked.
4. When it needs you to create an account somewhere (for example to store data or take payments), it will tell you exactly what to click, step by step. Nothing is assumed.

That's it. The agent figures out the rest, builds the app, and gets it ready to go live.

## Prompts to copy

Paste one of these to your AI agent to get going. Edit the parts in `[brackets]`. You don't need to be precise — the agent will ask follow-up questions.

**Start from scratch (don't know where to begin):**

> Use the startup kit. I want to build [a simple app to track my freelance invoices]. I'm not technical — ask me questions one at a time, explain anything confusing, and pick sensible defaults when I'm unsure. Walk me all the way to a running app.

**You already know what you want:**

> Use the startup kit to build [an app where coaches can post weekly workout plans and clients check them off]. People log in, each client only sees their own plans, no payments yet. Run onboarding, write the intake, then build it.

**Just explore my idea first (no building yet):**

> Use the startup kit's onboarding to interview me about [my product idea] and write the `.startup-kit/intake.md` plan. Don't build anything yet — I want to review the plan first.

**Add the kit to a project I already have:**

> Use the startup kit on this existing project. Scan it first, tell me what you found, point out where it doesn't match the kit's conventions, and propose a plan before changing anything.

**Get it online:**

> Walk me through putting my app live, step by step. Tell me exactly which accounts to create and what to click — assume I've never deployed anything.

**Just make it look good:**

> Apply the startup kit's design system to this app — the clean default theme, light and dark mode, and real empty/loading/error states. Then run the pre-flight check.

## For AI agents: start here

If you are an AI agent asked to build, scaffold, or "use the startup kit," follow this exactly. The full spec is in `SKILL.md` and `AGENTS.md`; this is the short version.

**Golden rule: never scaffold or write product code until a confirmed `.startup-kit/intake.md` exists.** A "build me X" request means *start the interview*, not *start building*. Building before onboarding is a failure of this skill.

1. **Read `SKILL.md`** — the entry point; it links each reference to read before touching that area.
2. **Look for saved answers** — run `scripts/scan-project.sh`, then check `.startup-kit/intake.md`, `AGENTS.md`, `CLAUDE.md`, `.cursorrules`, `.cursor/rules/*`, and any project brief. If a confirmed intake already exists, load it and skip to step 5.
3. **Interview the user** — follow `references/onboarding.md`. Ask in plain English, in small batches, with a recommended default for each choice. Only ask what the saved answers don't already cover.
4. **Write and confirm the intake** — copy `assets/templates/intake.md` to `.startup-kit/intake.md`, fill it, read it back to the user, and flip the line-1 marker to `status=confirmed` once they approve. Never set `confirmed` by hand to skip the interview.
5. **Build** — scaffold with `scripts/create-app.sh <name>` (single app — the default) or `scripts/create-monorepo.sh <name>` (advanced, always-on backends). These scripts refuse to run until `scripts/check-intake.sh` passes, so you cannot accidentally skip onboarding.
6. **Finish** — run `references/preflight.md` before declaring the work done.

Each `SKILL.md` section names the reference to read before working on that area (theming, forms, states, auth, payments, and so on), so you pull only the context you need. The token files in `assets/theme/` and `assets/tailwind/` are a machine-readable design spec you can consume directly.

## Quick start (for developers)

**Onboarding runs first — it is not optional.** For a new repo it interviews you through every decision a product needs (product, scope, style, theme, background animations, architecture, data, auth, payments, integrations, launch surfaces, deployment), writes a `.startup-kit/intake.md` source of truth, and only then scaffolds and wires the build. For existing code it detects first and only asks what it can't infer; if the answers are already stored (`.startup-kit/intake.md`, `AGENTS.md`, project rules), it loads them instead of re-asking. Point your agent at `references/onboarding.md`, or run the scan directly:

```bash
scripts/scan-project.sh        # read-only inventory of the current project
```

The scaffold scripts enforce this: `create-app.sh` and `create-monorepo.sh` **refuse to run until `.startup-kit/intake.md` exists**, so an agent can't skip the interview by jumping to the build. Once onboarding has written the intake:

```bash
scripts/create-app.sh my-app
cd my-app
npm run dev
```

This creates a Next.js App Router + TypeScript + Tailwind + shadcn/ui project with the light and dark token blocks, the common primitives, and the SF Pro stack. If you are an experienced developer who deliberately wants raw scaffolding without onboarding, override with `scripts/create-app.sh my-app --skip-onboarding` (or `STARTUP_KIT_SKIP_ONBOARDING=1`). See `references/scaffold.md` for other stacks (Vite, Remix, Astro, Vue, Svelte): copy the token blocks from `assets/tailwind/globals.css` and keep the same token names.

## Monorepo and split hosting

When a product needs a real backend, keep the frontend and backend in one repo but deploy each to the host that fits it:

```bash
scripts/create-monorepo.sh my-product   # apps/web + apps/api + packages/shared
scripts/install-deploy-clis.sh           # vercel, supabase, koyeb CLIs
```

This scaffolds a pnpm + Turborepo workspace: `apps/web` (Next.js on the kit theme) deploys to **Vercel**, `apps/api` (layered Express/TypeScript) deploys to **Koyeb** for always-on work, and **Supabase** provides managed Postgres, auth, and storage. The request/response contract and `zod` schemas live in `packages/shared` so both sides stay in sync. See `references/monorepo.md` for wiring, env vars, CORS, and the platform CLI commands.

## Design system at a glance

- Font: SF Pro, regular (400) and medium (500) only.
- Type sizes: `12px`, `13px` (base), `14px`, `16px`, `18px`, `24px` (largest).
- Text colors by intent: subtle `#7f7f7f`, default `#5d5d5d`, strong `#292929` (light); subtle `#8a8a8a`, default `#a1a1a1`, strong `#f5f5f5` (dark).
- Selected background `#f5f5f5` (light) / `#1a1a1a` (dark); border `#f2f2f2` (light) / `#1f1f1f` (dark).
- No gradients, decorative shadows, display typography, or broad palettes unless a project explicitly overrides the theme.

All of these live as the source of truth in `assets/theme/` and `assets/tailwind/`. Pull color through tokens; do not hardcode hex in components.

## Theme presets

The SF Pro default is the baseline. Opt-in brand identities live in `assets/theme/presets/` and follow the same token contract:

- `linear.tokens.json`: disciplined dark-first, indigo accent, four-step surface ladder, hairline borders, Inter.
- `vercel.tokens.json`: stark monochrome, ink as the brand (no chromatic accent), 100px pill CTAs, Geist + Geist Mono.
- `notion.tokens.json`: warm and illustration-rich, navy bands, pastel card tints, single purple CTA, Inter.

Use one preset per project. See `references/themes.md` for the shadcn CSS-variable mapping and font licensing. Preset fonts (Inter, Geist) are openly licensed and safe to bundle.

## Repository structure

```
SKILL.md                     Skill entry point and rules
agents/openai.yaml           Cross-agent interface metadata
references/                  Topic guides (read before building that area)
assets/
  theme/                     Light/dark tokens + CSS, and presets/
  tailwind/                  globals.css and tailwind.config.ts
  shadcn/                    components.json (v4) and components.tailwind-v3.json
  icons/                     lucide/, simple-icons/, tabler/ starter SVGs + manifests
  components/backgrounds/    42 React Bits background components + manifest.json
  templates/                 minimal-product brief, privacy policy, terms, ui/ reference layouts
  fonts/                     SF Pro install target (vendor/ is gitignored)
scripts/                     create-app and asset/font/skill download helpers
```

## References

| File | Covers |
| --- | --- |
| `onboarding.md` | Guided intake: scan, full interview, gap analysis, build blueprint |
| `minimal-product.md` | The product doctrine: one user, one job, one workflow |
| `tailwind-shadcn.md` | Tailwind token mapping and shadcn/ui setup |
| `theming.md` | Light/dark tokens and class-based dark mode |
| `themes.md` | Linear/Vercel/Notion presets and landing-page direction |
| `layout.md` | Spacing scale, breakpoints, app-shell pattern |
| `icons.md` | Lucide, Simple Icons, Tabler usage rules |
| `animation.md` | GSAP usage and performance guardrails |
| `backgrounds.md` | When and how to use expressive backgrounds |
| `forms.md` | shadcn Form + react-hook-form + zod patterns |
| `states.md` | Empty, loading, error, success, disabled states |
| `accessibility.md` | Keyboard, names, contrast, motion, live regions |
| `writing.md` | Voice, microcopy, numbers, dates |
| `content.md` | Realistic demo data, real logos, anti-slop rules |
| `auth.md` | Managed auth providers and route protection |
| `payments.md` | Stripe checkout, webhooks, entitlements |
| `seo.md` | Metadata, OG images, error/not-found pages |
| `analytics.md` | Privacy-respecting product analytics |
| `single-app.md` | Default architecture: Next.js Route Handlers + Supabase |
| `backend.md` | Layered Node/TypeScript/Express API structure |
| `monorepo.md` | One repo, split hosting (Vercel + Supabase + Koyeb) |
| `legal.md` | Privacy policy and terms templates |
| `scaffold.md` | The create-app script and other stacks |
| `preflight.md` | Mechanical done-check before shipping |

## Scripts

- `scripts/setup.sh [--host <agent>] [--all] [--copy] [--list]`: install the skill into every detected AI agent (Cursor, Claude Code, Codex, …) by symlinking this one clone into each agent's skills dir.
- `scripts/upgrade.sh [--check]`: pull the latest version and refresh every agent at once (one update for all of them).
- `scripts/install-hooks.sh [--host <agent>] [--uninstall] [--list]`: wire a throttled "update available" check into each agent's session-start hook (Cursor, Claude Code, Codex).
- `scripts/check-update.sh [--hook <agent>] [--force]`: the throttled checker the hooks call; prints an update notice (or nothing) and never blocks a session.
- `scripts/scan-project.sh [dir]`: read-only inventory of an existing project (framework, package manager, monorepo, database, env) used by onboarding.
- `scripts/check-intake.sh [path]`: validate that `.startup-kit/intake.md` exists, is confirmed, and has its required fields filled. The scaffold scripts run this as their onboarding gate; you can run it on its own to check readiness.
- `scripts/create-app.sh <name>`: scaffold a themed Next.js app (refuses to run until onboarding's intake is confirmed; `--skip-onboarding` to override).
- `scripts/create-monorepo.sh <name>`: scaffold a pnpm + Turborepo monorepo (`apps/web` + `apps/api` + `packages/shared`) for split hosting on Vercel, Supabase, and Koyeb.
- `scripts/add-backend.sh [frontend-dir]`: add a layered Express/TS backend to an existing frontend, restructuring into a workspace.
- `scripts/add-frontend.sh [backend-dir]`: add a themed Next.js frontend to an existing backend, restructuring into a workspace.
- `scripts/adopt-monorepo.sh <frontend-dir> <backend-dir>`: restructure an existing frontend + backend into a monorepo in place (`git mv`, history preserved).
- `scripts/install-deploy-clis.sh`: install the Vercel, Supabase, and Koyeb CLIs.
- `scripts/install-stripe-cli.sh`: install the Stripe CLI (Homebrew, with an official-binary fallback) for local webhook testing — `stripe login`, `stripe listen`, `stripe trigger` (`references/payments.md`).
- `scripts/download-sf-pro.sh`: download Apple's official SF Pro installer into `assets/fonts/vendor/`.
- `scripts/download-lucide-icons.sh`, `download-simple-icons.sh`, `download-tabler-icons.sh`: refresh bundled icon sets.
- `scripts/install-gsap-skills.sh`: install the official GreenSock GSAP skills when not already present.
- `scripts/test/onboarding.test.sh`: tests for the onboarding gate and intake validator (run by CI in `.github/workflows/ci.yml`, along with `bash -n` and shellcheck).
- `scripts/test/install.test.sh`: tests for the cross-agent installer (`setup.sh`), the update checker (`check-update.sh`), and the hook JSON merge (`merge-hook.js`); also run by CI.

## Fonts and licensing

SF Pro is Apple's system font. It is free to download but not freely redistributable, so it is intentionally not committed: `scripts/download-sf-pro.sh` fetches it into `assets/fonts/vendor/`, which is gitignored. Do not commit the extracted `.otf` files or the installer unless your project has confirmed license rights. On Apple devices the bundled font stack falls back to the native system font, so UI looks correct even without installing anything.

Bundled assets carry their own licenses: Lucide (ISC), Simple Icons and Tabler (each in their respective `LICENSE` files), and the background components originate from React Bits. Check brand usage terms before shipping Simple Icons logos.

## License

The startup-kit's own source (SKILL.md, references, scripts, templates, configuration) is MIT licensed — see `LICENSE`. Bundled third-party assets keep their original licenses, included alongside them.

## Pinned tool versions

The scaffold scripts pin `create-next-app` and `shadcn` to known-good majors (`scripts/lib/versions.sh`) so a fresh clone builds the toolchain the kit was validated against, instead of whatever `@latest` happens to be that day. To test a newer major without editing scripts, override per run:

```bash
SK_NEXT_MAJOR=17 scripts/create-app.sh my-app
```

When bumping a default in `scripts/lib/versions.sh`, re-validate the scaffold and run the pre-flight check before committing.

## Status

This kit is opinionated by design. It is meant for tool UI, skill interfaces, dashboards, and shippable products that should feel quiet and precise. It is not the kit for expressive marketing or award-style sites; keep that energy in the opt-in background components.
