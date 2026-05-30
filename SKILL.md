---
name: startup-kit
description: Cross-agent full-stack startup kit for building skill UIs and shippable products. ALWAYS run onboarding FIRST — never scaffold or build until you have interviewed the user (product, scope, style, theme, background animations, architecture, data, auth, payments, launch, deploy) or loaded their stored answers, and written a confirmed .startup-kit/intake.md. A "build me X" request triggers the interview, not the build. Frontend baseline with the default SF Pro theme, light/dark Tailwind tokens, shadcn/ui conventions, and references for forms, states, accessibility, layout, copy, demo content, auth, payments, SEO, and analytics. Backend baseline for a Node.js + TypeScript + Express + MongoDB/Mongoose API with a layered Router to Controller to Service to Model structure, middleware, and a standard response envelope. Includes a guided onboarding interview, a one-command scaffold, and a mechanical pre-flight quality check. Use when Codex, Claude Code, or another coding agent needs to create or update UI for agent skills, skill dashboards, or reusable frontend starter projects; to design API routes, controllers, services, models, or a Node.js/Express backend file structure; or to stand up a complete product with consistent typography, colors, Tailwind configuration, shadcn/ui components, backend architecture, and production-launch surfaces. Helpful for beginners who ask how to create a backend, structure an Express app, or wire routing through to services.
license: MIT
metadata:
  author: duolahypercho
  version: "1.0.0"
---

# Startup Kit

Use this skill to build agent skill interfaces and shippable products on a minimal, precise UI baseline.

The product goal is simple: make the smallest useful product that works, then polish the details until nothing feels accidental.

## STOP — Onboard before you build (hard gate)

**Do not scaffold, do not run `scripts/create-app.sh` or `scripts/create-monorepo.sh`, do not write product code, and do not silently pick defaults until onboarding has run and `.startup-kit/intake.md` exists and is confirmed.** A request like "build me X," "make an app that…," or "use the startup kit to create…" is a trigger to **start the interview**, not to start building. Building before onboarding is a failure of this skill.

The one allowed exception is **stored answers**: if the repo already records the product decisions, read them instead of re-asking. Run the gate this way, in order:

1. **Check for stored answers first.** Look for `.startup-kit/intake.md`, then `AGENTS.md` / `CLAUDE.md` / `.cursorrules` / `.cursor/rules/*`, then any project brief or memory the host exposes. Run `scripts/scan-project.sh` to inventory the repo.
2. **If a complete, confirmed intake exists:** skip the questions, summarize what you loaded in one or two sentences, and proceed to build from it (a re-run resumes via the intake's plan checklist).
3. **If answers are partial** (e.g. `AGENTS.md` names the product but not the theme/auth/data): pre-fill what's stored, then **ask only the missing questions** — never re-ask what the repo already answers.
4. **If nothing is stored:** you **must run the full interview** from `references/onboarding.md` before building. Ask the grouped questions (product, scope, style, theme, background animations, architecture, data, auth, payments, integrations, launch, deploy), one batch at a time, each with a recommended default. Do not assume defaults for the whole product silently.

When in doubt, ask. It is always correct to interview before building; it is never correct to scaffold a whole product the user never described.

## Onboarding

Read `references/onboarding.md` and run it first on any new engagement, before scaffolding or editing. This is the "guide me and build the whole thing" entry point, and it is gated by the STOP rule above.

Before building, state the one user, the one job, and the one primary workflow in a sentence. If the requirements are unclear, fill `assets/templates/minimal-product-brief.md` first. Build for that job, then run `references/preflight.md` before calling the work done.

Onboarding adapts to the starting state. Always begin with `scripts/scan-project.sh` to inventory the working directory (read-only). Then branch:

- **Greenfield (new/empty repo):** there is nothing to detect, so **interview thoroughly**. Walk the user through the grouped question bank in `references/onboarding.md` (product, scope, style, architecture, data, auth, payments, integrations, launch surfaces, deployment) — asking in batches with a recommended default per choice — then scaffold and wire the product step by step.
- **Existing code:** **detect first, then ask.** Report what the scan found, only ask what cannot be inferred, and write down the existing file structure plus a concrete gap analysis against the kit's conventions. Never modify source during the intake phase.

Assume the user may have **no technical background**. Ask in plain English, put any jargon in parentheses, explain terms in one line, and offer a "you pick the sensible default" path for every choice so they can build a real product without knowing the words. Never ask them to do setup themselves — when an account or key is needed, give exact step-by-step instructions. See the "Assume the user is not technical" section in `references/onboarding.md`.

Capture everything in `.startup-kit/intake.md` (from `assets/templates/intake.md`); it is the source of truth every later session reads, and its plan checklist tracks build progress so a re-run resumes rather than restarts.

Present the architecture as an explicit choice and **default to the single app**:

- **Single app (default):** one Next.js app on Vercel (Route Handlers for the API) + Supabase for data/auth. Right for MVPs, skill UIs, dashboards, and anything whose backend is "endpoints + a database." Use `scripts/create-app.sh`.
- **Monorepo split hosting (opt-in, advanced):** `apps/web` on Vercel + `apps/api` on Koyeb + `packages/shared`. Only when the backend must be always-on (websockets, jobs, cron, long requests), a typed contract is shared across 2+ deployed apps, or there are 3+ deployables. Scaffold with `scripts/create-monorepo.sh`; adopt existing code with `scripts/add-backend.sh`, `scripts/add-frontend.sh`, or `scripts/adopt-monorepo.sh`.

If none of the monorepo criteria hold, choose the single app. The monorepo is a convenience, not a prerequisite; for "leave it as-is," wire via env + CORS (`references/monorepo.md`). Finish by recording the choice and stating the next command.

## Scope

Use this kit for tool UI, skill interfaces, dashboards, and shippable products that should feel quiet, precise, and dense.

This is not the kit for expressive marketing or award-style sites. Do not import high-variance layouts, perpetual motion, bento-card systems, or glassmorphism into a tool surface. Keep expressive treatments confined to the opt-in background components on marketing, hero, and auth screens (`references/backgrounds.md`).

## Quick Start

Onboarding comes first (see the STOP gate above) — `scripts/create-app.sh` refuses to run until `.startup-kit/intake.md` exists. Once onboarding has written the intake, start a new app already wired to this theme with `scripts/create-app.sh <app-name>` and read `references/scaffold.md`. It creates a Next.js + Tailwind + shadcn/ui project with light/dark tokens, the common primitives, and the SF Pro stack. For other stacks, copy the token blocks from `assets/tailwind/globals.css` and keep the same token names.

## Defaults

- Use SF Pro regular and medium only.
- Use `13px` as the base font size.
- Keep type sizes to `12px`, `13px`, `14px`, `16px`, `18px`, and `24px`.
- Use `24px` as the largest UI text size.
- Use the bundled theme assets as the source of truth:
  - `assets/theme/default-theme.css`
  - `assets/theme/default-theme.tokens.json`
  - `assets/theme/dark-theme.css`
  - `assets/theme/dark-theme.tokens.json`
  - `assets/tailwind/tailwind.config.ts`
  - `assets/tailwind/globals.css`
  - `assets/shadcn/components.json`
  - `assets/shadcn/components.tailwind-v3.json`
  - `assets/icons/lucide/`
  - `assets/icons/simple-icons/`
  - `assets/icons/tabler/`
  - `assets/components/backgrounds/`
  - `assets/templates/`

## Font

Use the real SF Pro font when the target environment can legally install it.

1. Run `scripts/download-sf-pro.sh` to download Apple's official SF Pro installer into `assets/fonts/vendor/`.
2. Do not commit extracted `.otf` files or redistribute Apple font files unless the project has confirmed license rights.
3. In generated CSS, prefer the bundled font stack:

```css
font-family: "SF Pro", "SF Pro Text", -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
```

## Tailwind And Shadcn

Read `references/tailwind-shadcn.md` before creating or changing Tailwind, shadcn/ui, or component code.

Use shadcn/ui for all standard components: buttons, inputs, selects, dialogs, popovers, tabs, menus, tables, forms, labels, switches, checkboxes, tooltips, sheets, alerts, and cards.

Only create a custom component when shadcn/ui does not provide the needed primitive or when composing shadcn primitives into a domain-specific component.

When initializing shadcn/ui, use `assets/shadcn/components.json` for Tailwind CSS v4 projects or `assets/shadcn/components.tailwind-v3.json` for Tailwind CSS v3 projects. Keep `cssVariables` enabled.

## Dark Mode

Read `references/theming.md` before adding dark mode or changing color tokens.

The kit ships both schemes in one token contract. `assets/tailwind/globals.css` includes `:root` (light) and `.dark` blocks; `assets/theme/dark-theme.tokens.json` and `assets/theme/dark-theme.css` mirror the light tokens. Use class-based dark mode with `next-themes`, default to `system`, and switch token values, never token names.

## Theme Presets

The default SF Pro theme is the baseline. Read `references/themes.md` before applying a brand identity.

Opt-in presets modeled on well-known product design systems live in `assets/theme/presets/`: `linear.tokens.json` (dark-first, indigo accent, surface ladder), `vercel.tokens.json` (stark monochrome, ink-as-brand, pill CTAs), and `notion.tokens.json` (warm, pastel tints, purple CTA). Each follows the same token contract as the default and ships with an openly licensed font. Use one preset per project, or stay on the default for quiet tool UI.

## Layout And Spacing

Read `references/layout.md` before structuring pages, app shells, or grids.

Use the Tailwind 4px spacing scale, mobile-first breakpoints, and the bundled app-shell pattern. Align edges exactly, keep one rhythm per surface, and keep tool UI dense.

## Icons

Use Lucide as the default UI icon library.

Read `references/icons.md` before adding icon dependencies, choosing brand icons, or creating custom SVGs.

Use icons from `lucide-react` in React/shadcn projects. Use the bundled SVG starter set in `assets/icons/lucide/` for static templates, documentation, non-React targets, or agents that need local icon assets.

Use Simple Icons only for brand logos. Use Tabler only as a fallback when Lucide does not include the needed UI concept.

## Animation

Use the official Greensock GSAP skills for high-quality animation work: `https://github.com/greensock/gsap-skills`.

Read `references/animation.md` before adding animation. Install the official GSAP skills with `scripts/install-gsap-skills.sh` when the current agent environment does not already provide them.

Use animation only to clarify continuity, focus, feedback, or state change. Do not add motion as decoration.

## Backgrounds

Use bundled background components as expressive surfaces for marketing, hero, auth, and splash screens. Do not put animated backgrounds behind dense tool UI (dashboards, tables, forms).

Read `references/backgrounds.md` before adding a background component.

Default behavior: when a product has a landing/marketing/hero surface, wire one animated/3D background into it — do not ship a flat hero by default. Scaffolds bundle the full catalog into `src/components/backgrounds/`, install `three` + `ogl`, and provide the `animated-background.tsx` wrapper (lazy load + reduced-motion fallback + scrim). Use it:

```tsx
import { AnimatedBackground } from "@/components/backgrounds/animated-background";

<AnimatedBackground load={() => import("@/components/backgrounds/LiquidEther")} />
```

For an existing app (no scaffold) or a component needing extra packages, run `scripts/add-background.sh <Name> [target]` — it copies the source and installs the right dependencies from the manifest (`scripts/add-background.sh all` for everything).

Use `assets/components/backgrounds/manifest.json` to see the approved set — 42 React Bits components (fluid, aurora, plasma, particle, grid, glitch, and 3D effects). Most are transparent WebGL canvases that fill their parent, so wrap them in a positioned element with an explicit height. Dependencies vary by component (`ogl`, `three`, `@react-three/fiber`/`@react-three/drei`, `postprocessing`, `face-api.js`, `gsap`, or none); the manifest's `dependencyGroups` lists what to install for each. Three components — `Silk`, `Ballpit`, `LetterGlitch` — ship without CSS. Keep text contrast intact, use at most one expressive background per view, prefer the lighter options for long-lived surfaces, and provide a static fallback when `prefers-reduced-motion` is set.

## Forms

Read `references/forms.md` before building any form.

Build forms with shadcn/ui `Form` on `react-hook-form` and `zod`. Use real labels, inline validation, one primary action, a disabled-while-submitting button, and server errors mapped back to fields.

## States And Feedback

Read `references/states.md` before building flows that load, mutate, or can fail.

Provide explicit empty, loading, error, success, and disabled states. Use skeletons shaped like the content, `sonner` toasts for transient feedback, and `Alert` for section-level errors with a retry. Never show raw errors to users.

## Accessibility

Read `references/accessibility.md` and treat it as part of the quality bar.

Every action works with a keyboard, every control has an accessible name, color meets AA contrast, and async results are announced. shadcn/ui (Radix) gives correct semantics by default; do not break them.

## Writing

Read `references/writing.md` before writing UI copy.

Use plain, direct, sentence-case copy. Name results on buttons, name objects on labels, and write real empty, error, and success messages. Remove placeholder copy before finishing.

## Demo Content

Read `references/content.md` before writing example data, empty states, or social proof.

Use realistic, specific content even in examples. No generic names ("John Doe"), slop brand names ("Acme"), fake-perfect numbers (`99.99%`), text-only logo walls, `<div>`-based fake screenshots, or em dashes. Use the bundled Simple Icons for real brand logos.

## Single App (Default Architecture)

Read `references/single-app.md` before building the default single-app product.

The default for most products is one Next.js App Router app on Vercel with Route Handlers as the API edge and Supabase for data, auth, and storage. Keep the same one-directional discipline as the layered backend — Route Handler → Service → Supabase — with `zod` validation at the edge, the shared response envelope, server-only secrets, and Row Level Security in the database. Scaffold it with `scripts/create-app.sh <name>`. Only move to the monorepo when a Route Handler can no longer do the job.

## Backend

Read `references/backend.md` before building a standalone backend (the monorepo/always-on path), designing API routes, or wiring a database.

Build the backend as a Node.js + TypeScript + Express service with a strict layered flow: Router → Controller → Service → Model, and back. Controllers own HTTP (`req`/`res`) and shape responses; services own business logic and database access; models hold only the Mongoose schema and its type. Use one file per domain per layer, a single JSON response envelope (`{ success, status, code, message/error, data }`), authentication in middleware, and keep all secrets in `.env`.

## Monorepo And Split Hosting

Read `references/monorepo.md` before splitting a product into separate frontend and backend deployments.

Keep the frontend and backend in one repository, but deploy each to the host that fits it: `apps/web` (Next.js) to Vercel, `apps/api` (Express/Fastify) to Koyeb for always-on work, and Supabase for managed Postgres, auth, and storage. Use pnpm workspaces + Turborepo, share the request/response contract and `zod` schemas through `packages/shared`, scope each platform's build to its own folder, and keep public values in `NEXT_PUBLIC_*` with all other secrets server-side. Scaffold it with `scripts/create-monorepo.sh <name>` and install the platform CLIs with `scripts/install-deploy-clis.sh`.

## Auth, Payments, And Launch Surfaces

These references apply when building a shippable product rather than a single skill UI.

- `references/backend.md`: layer the server route → controller → service → repository; validate input at the edge; centralize error mapping.
- `references/auth.md`: use a managed auth provider; protect routes on the server; never store tokens in `localStorage`.
- `references/payments.md`: use Stripe; let it own card data and checkout; treat the webhook as the source of truth for entitlements.
- `references/seo.md`: set per-route metadata, OG images via `next/og`, and real `not-found`/`error` pages using the theme.
- `references/analytics.md`: pick one privacy-respecting tool and instrument the primary workflow, not every click.
- `references/legal.md`: ship a privacy policy and terms; start from `assets/templates/privacy-policy.md` and `assets/templates/terms-of-service.md` and have counsel review.

## Minimal Product Standard

Read `references/minimal-product.md` before designing screens, app flows, or templates.

Use `assets/templates/minimal-product-brief.md` when the product requirements are unclear.

Default to one primary workflow, one clear empty state, one clear error state, and one direct success state. Remove every section, option, visual, and word that does not help the user finish the job.

## Pre-Flight Check

Run `references/preflight.md` before declaring any UI done. It is a binary, tickable gate covering brief, theme, components, states, layout, accessibility, content, and engineering. If one item cannot be honestly ticked, the work is not finished.

## Implementation Rules

- Copy or adapt the asset files into the target app rather than inventing new tokens.
- Verify every imported package is in `package.json` before using it; output the install command when it is missing.
- Keep components quiet, dense, and tool-like.
- Prefer one obvious path through the product.
- Choose fewer controls and make each one exact.
- Treat spacing, alignment, labels, and disabled states as product behavior, not decoration.
- Use text colors by intent: subtle `#7f7f7f`, default `#5d5d5d`, strong `#292929` (light); subtle `#8a8a8a`, default `#a1a1a1`, strong `#f5f5f5` (dark).
- Use selected backgrounds as `#f5f5f5` (light) or `#1a1a1a` (dark).
- Use borders as `#f2f2f2` (light) or `#1f1f1f` (dark).
- Pull color through tokens so light and dark stay in sync; do not hardcode hex in components.
- Avoid larger display typography, extra font weights, gradients, decorative shadows, or broad palettes unless the target project explicitly overrides this theme.
