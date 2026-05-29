# Startup Kit

A cross-agent frontend startup kit for building agent skill UIs and shippable products on a minimal, precise baseline. It gives a coding agent (Cursor, Claude Code, Codex, or similar) a single source of truth for typography, color, Tailwind configuration, shadcn/ui conventions, and the production surfaces a real product needs.

The philosophy is restraint: make the smallest useful product that works, then polish until nothing feels accidental. Quiet, dense, tool-like UI by default; expressive treatments stay opt-in and confined to marketing surfaces.

## What you get

- A locked design system: SF Pro stack, a `13px` base, a fixed type scale (`12 / 13 / 14 / 16 / 18 / 24px`), and intent-based neutral colors.
- Light and dark mode in one token contract (switch values, never names).
- Three opt-in brand presets modeled on Linear, Vercel, and Notion.
- Tailwind v3 and v4 configs plus shadcn/ui setup with `cssVariables` enabled.
- Bundled icon starter sets (Lucide, Simple Icons, Tabler) and 42 React Bits background components.
- A detect-first onboarding flow that inspects existing code, captures a `.startup-kit/intake.md` source of truth, and routes greenfield or existing projects to the right path.
- A layered Node/TypeScript/Express backend reference, plus a monorepo pattern for keeping the frontend and backend in one repo while hosting them on different platforms (Vercel + Supabase + Koyeb).
- Focused reference docs covering forms, states, accessibility, layout, copy, auth, payments, SEO, analytics, backend, and deployment.
- One-command scaffolds (single app or monorepo) and a mechanical pre-flight quality gate.

## Quick start

Start with onboarding — it inspects any existing code, asks only what it can't infer (style + architecture), writes a `.startup-kit/intake.md` source of truth, and routes you to the right path. Point your agent at `references/onboarding.md`, or run the scan directly:

```bash
scripts/scan-project.sh        # read-only inventory of the current project
```

For a greenfield app, scaffold one already wired to the theme:

```bash
scripts/create-app.sh my-app
cd my-app
npm run dev
```

This creates a Next.js App Router + TypeScript + Tailwind + shadcn/ui project with the light and dark token blocks, the common primitives, and the SF Pro stack. See `references/scaffold.md` for other stacks (Vite, Remix, Astro, Vue, Svelte): copy the token blocks from `assets/tailwind/globals.css` and keep the same token names.

## Monorepo and split hosting

When a product needs a real backend, keep the frontend and backend in one repo but deploy each to the host that fits it:

```bash
scripts/create-monorepo.sh my-product   # apps/web + apps/api + packages/shared
scripts/install-deploy-clis.sh           # vercel, supabase, koyeb CLIs
```

This scaffolds a pnpm + Turborepo workspace: `apps/web` (Next.js on the kit theme) deploys to **Vercel**, `apps/api` (layered Express/TypeScript) deploys to **Koyeb** for always-on work, and **Supabase** provides managed Postgres, auth, and storage. The request/response contract and `zod` schemas live in `packages/shared` so both sides stay in sync. See `references/monorepo.md` for wiring, env vars, CORS, and the platform CLI commands.

## Using it as an agent skill

The repo is structured as a skill: `SKILL.md` is the entry point and the `references/` files are loaded on demand. Point your agent at this repo, then prompt it to build with the kit. Each `SKILL.md` section names the reference an agent should read before touching that area (forms, states, theming, and so on), so the agent pulls only the context it needs.

The token files double as a machine-readable design spec, which is the format coding agents now consume directly.

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
  templates/                 minimal-product brief, privacy policy, terms
  fonts/                     SF Pro install target (vendor/ is gitignored)
scripts/                     create-app and asset/font/skill download helpers
```

## References

| File | Covers |
| --- | --- |
| `onboarding.md` | Detect-first intake: scan, style, architecture, gap analysis |
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
| `backend.md` | Layered Node/TypeScript/Express API structure |
| `monorepo.md` | One repo, split hosting (Vercel + Supabase + Koyeb) |
| `legal.md` | Privacy policy and terms templates |
| `scaffold.md` | The create-app script and other stacks |
| `preflight.md` | Mechanical done-check before shipping |

## Scripts

- `scripts/scan-project.sh [dir]`: read-only inventory of an existing project (framework, package manager, monorepo, database, env) used by onboarding.
- `scripts/create-app.sh <name>`: scaffold a themed Next.js app.
- `scripts/create-monorepo.sh <name>`: scaffold a pnpm + Turborepo monorepo (`apps/web` + `apps/api` + `packages/shared`) for split hosting on Vercel, Supabase, and Koyeb.
- `scripts/add-backend.sh [frontend-dir]`: add a layered Express/TS backend to an existing frontend, restructuring into a workspace.
- `scripts/add-frontend.sh [backend-dir]`: add a themed Next.js frontend to an existing backend, restructuring into a workspace.
- `scripts/adopt-monorepo.sh <frontend-dir> <backend-dir>`: restructure an existing frontend + backend into a monorepo in place (`git mv`, history preserved).
- `scripts/install-deploy-clis.sh`: install the Vercel, Supabase, and Koyeb CLIs.
- `scripts/download-sf-pro.sh`: download Apple's official SF Pro installer into `assets/fonts/vendor/`.
- `scripts/download-lucide-icons.sh`, `download-simple-icons.sh`, `download-tabler-icons.sh`: refresh bundled icon sets.
- `scripts/install-gsap-skills.sh`: install the official GreenSock GSAP skills when not already present.

## Fonts and licensing

SF Pro is Apple's system font. It is free to download but not freely redistributable, so it is intentionally not committed: `scripts/download-sf-pro.sh` fetches it into `assets/fonts/vendor/`, which is gitignored. Do not commit the extracted `.otf` files or the installer unless your project has confirmed license rights. On Apple devices the bundled font stack falls back to the native system font, so UI looks correct even without installing anything.

Bundled assets carry their own licenses: Lucide (ISC), Simple Icons and Tabler (each in their respective `LICENSE` files), and the background components originate from React Bits. Check brand usage terms before shipping Simple Icons logos.

## Status

This kit is opinionated by design. It is meant for tool UI, skill interfaces, dashboards, and shippable products that should feel quiet and precise. It is not the kit for expressive marketing or award-style sites; keep that energy in the opt-in background components.
