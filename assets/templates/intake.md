<!-- startup-kit:intake status=draft -->

# Project Intake

The persistent source of truth for this product. Onboarding fills it; every later session reads it. Commit it to the repo (recommended path: `.startup-kit/intake.md`). Re-running onboarding updates this file and never overwrites source code.

Mark any section that does not apply as `N/A`. Record env/secret **names only** — never paste secret values here.

**Confirmation gate:** the scaffold scripts refuse to build until the marker on line 1 reads `status=confirmed`. Onboarding flips it to `confirmed` only after the user has reviewed and approved this intake. Do not set it by hand to skip the interview.

## 1. Product

- One user:
- One job:
- One primary workflow:
- Product type: <!-- tool/dashboard | marketing/landing | both -->
- Product / app name:

## 2. Scope

- Must-have features (v1):
  -
- Out of scope (for now):
  -
- Deadline / milestone (if any):

## 3. Style

- Direction: <!-- default SF Pro | linear | vercel | notion | custom -->
- Custom brand (if any): font / primary color / logo:
- Color scheme: <!-- light | dark | both (system) -->
- Backgrounds allowed: <!-- yes only on marketing/auth | no -->

## 4. Architecture

- Architecture: <!-- single-app (DEFAULT) | monorepo (opt-in) -->
- If monorepo, why: <!-- always-on backend | shared contract across 2+ deployed apps | 3+ deployables -->
- Starting state: <!-- greenfield | existing frontend | existing backend | existing both | two repos -->
- Chosen path: <!-- create-app | create-monorepo | add-backend | add-frontend | adopt-monorepo | wire-existing -->
- Hosting: <!-- single Next.js + Supabase on Vercel | Vercel (web) + Koyeb (api) + Supabase (data) -->

## 5. Data Model

Leave `N/A` for static marketing pages.

- Database: <!-- Supabase Postgres (DEFAULT) | other -->
- Core entities and fields:
  - `Entity` — field: type, field: type
- Relationships / uniqueness:
- Access rules (e.g. "a user only sees their own rows"):

## 6. Auth

Leave `N/A` if v1 has no accounts.

- Accounts needed: <!-- yes | no -->
- Sign-in methods: <!-- email + OAuth via Supabase Auth (DEFAULT) | magic link | other provider -->
- Roles / permissions (v1):

## 7. Payments

Leave `N/A` if nothing is sold.

- Takes money: <!-- yes | no -->
- Model: <!-- one-time | subscription | usage-based -->
- Provider: <!-- Stripe Checkout + webhook source of truth (DEFAULT) -->
- Products / prices (v1):

## 8. Integrations & External Services

Leave `N/A` if none.

- Service — purpose — have credentials? (yes / stub behind env var):
  -

## 9. Launch Surfaces

- SEO (`references/seo.md`): <!-- yes (public) | no --> — metadata / OG / error pages
- Analytics (`references/analytics.md`): <!-- yes (tool: ___) | no -->
- Legal (`references/legal.md`): <!-- yes (privacy + terms) | no -->

## 10. Deployment & Environments

- Hosting (confirm from §4):
- Custom domain: <!-- domain | platform default for now -->
- Environments: <!-- production only | production + preview/staging -->
- Env vars / secrets needed (NAMES ONLY):
  - `DATABASE_URL`
  - `NEXT_PUBLIC_SUPABASE_URL`
  - `NEXT_PUBLIC_SUPABASE_ANON_KEY`
  -

## 11. Existing Code (from scripts/scan-project.sh)

Leave blank for greenfield. Otherwise record what was detected.

### Frontend

- Location:
- Framework / version:
- Package manager:
- Notable structure:

### Backend

- Location:
- Framework / version:
- Database / auth:
- Notable structure:

### File structure (as-is)

```
<!-- paste the relevant tree so future sessions have the real layout -->
```

## 12. Gap Analysis

For existing code only. How the current code maps onto the kit's conventions, and what to change. Mark each: OK / GAP / N/A.

### Frontend

- [ ] Uses theme tokens, no hardcoded hex (`references/theming.md`)
- [ ] Type scale limited to 12/13/14/16/18/24, SF Pro stack
- [ ] shadcn/ui for standard primitives (`references/tailwind-shadcn.md`)
- [ ] Real empty/loading/error/success states (`references/states.md`)
- [ ] Forms on react-hook-form + zod (`references/forms.md`)
- [ ] Accessibility: keyboard, names, AA contrast (`references/accessibility.md`)
- [ ] Copy is real, no slop content (`references/content.md`, `references/writing.md`)

### Backend

- [ ] Layered Router → Controller → Service → Model (`references/backend.md`)
- [ ] No business logic in controllers; no `req`/`res` in services
- [ ] Every external input validated with zod at the edge
- [ ] Single response envelope `{ success, status, code, message/error, data }`
- [ ] Secrets in env only, validated at startup, never committed
- [ ] CORS scoped to known origins (not `*` with credentials)

### Deployment

- [ ] Public values use `NEXT_PUBLIC_` prefix; secrets server-side
- [ ] Build scoped per app (no cross-app rebuilds)
- [ ] Shared contract/types in one place

## 13. Plan

The ordered, concrete steps for this project. Each step names the command or reference it uses, and is checked off as the build progresses.

- [ ] 1.
- [ ] 2.
- [ ] 3.

## 14. Out Of Scope

What we are deliberately not building yet.

-
