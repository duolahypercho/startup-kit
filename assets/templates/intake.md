# Project Intake

The persistent source of truth for this product. Onboarding fills it; every later session reads it. Commit it to the repo (recommended path: `.startup-kit/intake.md`). Re-running onboarding updates this file and never overwrites source code.

## 1. Product

- One user:
- One job:
- One primary workflow:
- Product type: <!-- tool/dashboard | marketing/landing | both -->

## 2. Style

- Direction: <!-- default SF Pro | linear | vercel | notion | custom -->
- Custom brand (if any): font / primary color / logo:
- Backgrounds allowed: <!-- yes only on marketing/auth | no -->

## 3. Architecture

- Architecture: <!-- single-app (DEFAULT) | monorepo (opt-in) -->
- If monorepo, why: <!-- always-on backend | shared contract across 2+ deployed apps | 3+ deployables -->
- Starting state: <!-- greenfield | existing frontend | existing backend | existing both | two repos -->
- Chosen path: <!-- create-app | create-monorepo | add-backend | add-frontend | adopt-monorepo | wire-existing -->
- Hosting: <!-- single Next.js + Supabase on Vercel | Vercel (web) + Koyeb (api) + Supabase (data) -->

## 4. Existing Code (from scripts/scan-project.sh)

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

## 5. Gap Analysis

How the current code maps onto the kit's conventions, and what to change. Mark each: OK / GAP / N/A.

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

## 6. Plan

The ordered, concrete steps for this project. Each step names the command or reference it uses.

1.
2.
3.

## 7. Out Of Scope

What we are deliberately not building yet.

-
