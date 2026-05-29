# Onboarding

Run this first, before any building. Onboarding is the front door to the whole kit: it figures out where the user is starting, asks everything needed to build the right product, writes it all down, and then guides the build to a running app.

**This is a hard gate (see the STOP rule in `SKILL.md`).** Never scaffold or write product code until onboarding has produced a confirmed `.startup-kit/intake.md`. A "build me X" request triggers the interview, not the build.

**Always ask the questions unless the repo already answers them.** Before interviewing, check for stored answers — `.startup-kit/intake.md` first, then `AGENTS.md` / `CLAUDE.md` / `.cursorrules` / `.cursor/rules/*`, then any host-provided brief or memory. If a complete confirmed intake exists, load it and skip the questions. If answers are partial, pre-fill them and ask only what's missing. If nothing is stored, run the full interview below — do not silently assume defaults for the whole product.

Onboarding has two jobs that depend on the starting state:

- **Greenfield (new repo / empty directory):** there is nothing to detect, so **interview thoroughly**. Walk the user through every decision a real product needs — product, users, scope, style, architecture, data, auth, payments, integrations, deployment, and launch surfaces — then scaffold and wire it for them. This is the "guide me and build the whole thing" path.
- **Existing code:** **detect first, then ask.** Inspect the project before asking anything, report what was found, and only ask what cannot be inferred. Never interrogate the user for facts the repo already answers.

Onboarding is read-only on source code. It inspects, asks, and plans; the only file it writes during the intake phase is `.startup-kit/intake.md`. Building (scaffolding, wiring) happens after the intake is confirmed.

## The Flow

```
0. Scan            read-only inventory + check for stored answers (intake, AGENTS.md, rules)
1. Branch          stored intake → load & build · greenfield → full interview · existing → detect-first
2. Interview       ask the question bank below, grouped and confirmed (skip what's stored)
3. Intake          write .startup-kit/intake.md and read it back to the user
4. Blueprint       state the ordered build plan and the first command
5. Build           run the scaffold, then wire each surface, checking the plan off
```

### Step 0 — Scan the working directory and check for stored answers

Always run the inventory first, even on what looks like an empty folder:

```bash
scripts/scan-project.sh
```

It reports git state, package manager, monorepo layout, every `package.json` with its detected role (frontend/backend) and frameworks, Python manifests, database/auth libraries, env files, and existing deploy config — all read-only. If it finds nothing, treat the project as greenfield.

In the same pass, check for **stored answers** so you don't re-ask what's already written down, in this priority order:

1. `.startup-kit/intake.md` — the kit's own source of truth. If present and confirmed, this answers everything; load it and go to Step 4/5.
2. `AGENTS.md`, `CLAUDE.md`, `.cursorrules`, `.cursor/rules/*`, `README.md`, or a project brief — these may name the product, users, scope, or stack.
3. Any host-provided memory or context the agent has access to.

Map whatever you find onto the intake fields, then in Step 2 ask **only the questions that remain unanswered**. If nothing is stored, the full interview is mandatory.

Then read the key files it surfaced (root `package.json`, app entry points, folder structure) so the plan is grounded in real code. Summarize what you found in one or two sentences before asking anything, e.g. *"This is an empty directory — I'll set the product up from scratch,"* or *"I found a Next.js frontend in `web/` and an Express + MongoDB API in `server/`, npm, not yet a workspace."*

### Step 1 — Branch on the starting state

- **Confirmed `.startup-kit/intake.md` found → resume.** Load it, summarize what you read, and continue the build from its plan checklist. Re-ask only if the user wants to change something.
- **Nothing found → greenfield.** Go to Step 2 and run the full interview.
- **Code or stored notes found → existing.** Skip the questions the scan and stored answers (`AGENTS.md`, rules, README) already cover. Still run the interview for everything they do *not* tell you (the product definition, the style direction, the launch surfaces, the deploy targets), then add the gap analysis in Step 3b.

## Step 2 — The Interview

Conduct a clean, guided interview. Rules that keep it from feeling like an interrogation:

- **Ask in grouped batches, not one giant list.** Cover one group, confirm, move on. Use the host's interactive multiple-choice UI when available; otherwise number the options so the user can answer with a letter or short phrase.
- **State a recommended default for every choice** so the user can say "defaults" and move fast. The kit is opinionated; lead with the opinion.
- **Never re-ask what the scan answered.** For existing code, pre-fill the answer and let the user correct it.
- **Skip groups that do not apply.** A pure skill UI has no payments; a marketing page has no data model. Confirm a group is out of scope rather than walking every question in it.
- **One question, one purpose.** Each answer must map to a field in the intake or a build step. If an answer changes nothing you build, do not ask it.

### Assume the user is not technical

Treat the person as a smart beginner who may have **zero coding background**. The whole point is that they can build a real product without knowing what any of the words mean.

- **Lead with the everyday question, put the jargon in parentheses.** Ask "Do people need to log in with their own account? (auth)" — not "Which auth provider?"
- **Explain any technical term in one short line** the first time it appears. No assumed knowledge.
- **Always offer a "let you decide" path.** If they say "I don't know," "you pick," or "whatever's easiest," choose the recommended default, tell them what you picked in one plain sentence, and move on. Never block on a technical decision.
- **Never ask them to do setup themselves.** If something needs an account or a key (Supabase, Stripe, a domain), say so plainly, offer to scaffold around it with a placeholder, and give them the exact click-by-click steps when they're ready — don't assume they know how.
- **One question at a time is fine** for a non-technical user, even if it's slower. Reading back a wall of options can overwhelm.
- **Translate the architecture choice into outcomes, not tech.** "One simple app that's quick to launch (recommended)" vs. "a bigger setup for apps that need always-on background work" — not "single app vs. monorepo split hosting."

Walk these groups in order. Defaults are in **bold**. Phrase each as plain English first; the parenthetical is for your own mapping, not a script to read verbatim.

### Group A — Product (always)

1. "Who is this for?" — the **one user** in a sentence.
2. "What's the main thing they want to get done?" — the **one job**.
3. "Walk me through how they'd do that, step by step." — the **one primary workflow**.
4. "Is this more of a **tool people use to get work done**, a **page that tells people about something** (marketing/landing), or both?"
5. "What do you want to call it?" — the working **product name** (becomes the app/repo name; suggest one if they're unsure).

### Group B — Scope (always)

6. "What are the few things it absolutely has to do for the first version?" — the **must-haves** (keep it small).
7. "What should we deliberately leave for later?" — explicitly **out of scope**.
8. "Is there a date you're aiming for?" — any **deadline** shaping scope.

### Group C — Style (always)

9. "How should it look?" Offer plain choices: **clean and simple (recommended default)**, or "like Linear / Vercel / Notion" (presets), or "match my brand" (custom — then collect font, main color, and logo and map them onto the token contract; change token values, never names — `references/themes.md`, `references/theming.md`).
10. "Light, dark, or **let it follow the user's device** (default)?"
11. Only if it's a marketing/landing page: "The hero gets a moving/animated background by default — any preference (calm, bold, none)?" Default to wiring one in; tools and dashboards get **none** (`references/backgrounds.md`) — don't ask there.

### Group D — Architecture (always — present as a real choice, in plain outcomes)

This is the key technical decision, but the user never needs to know the words. Present it as two outcomes and **recommend the simple app by default**. Do not default anyone into the bigger setup.

- **"A) One simple app — quick to launch, easy to run (recommended)."** Behind the scenes: one Next.js app on Vercel with Route Handlers for the API and Supabase for data, accounts, and file storage. Right for almost everything: an MVP, a tool, a dashboard, or anything whose backend is "some endpoints plus a database."
- **"B) A bigger setup for apps that need always-on background work."** Behind the scenes: a monorepo with `apps/web` on Vercel + `apps/api` on Koyeb + `packages/shared`, with Supabase for data. More to set up and maintain. Only pick it when at least one is true:
  - the app must do **always-on background work** — live updates/websockets, scheduled jobs, queues, or long tasks that don't fit a quick request;
  - two separately-deployed apps must **share the same data shapes/contract**;
  - there will be **three or more separate apps** (e.g. site + admin + API).

12. Which outcome fits — A or B? If B, **which reason** justifies it? If they're unsure, choose **A** and tell them they can grow into B later.

Then resolve the path from the architecture and the detected starting state:

| Architecture | Detected starting state | Path | How |
| --- | --- | --- | --- |
| Single app | Nothing yet | `create-app` | `scripts/create-app.sh`, then wire Supabase |
| Single app | Existing Next.js app | `wire-existing` | keep it; add Route Handlers + Supabase, apply the kit theme |
| Monorepo | Nothing yet | `create-monorepo` | `scripts/create-monorepo.sh` |
| Monorepo | Existing frontend only | `add-backend` | `scripts/add-backend.sh` |
| Monorepo | Existing backend only | `add-frontend` | `scripts/add-frontend.sh` |
| Monorepo | Existing frontend + backend in one repo | `adopt-monorepo` | `scripts/adopt-monorepo.sh` |
| Either | Two separate repos, or "leave it as-is" | `wire-existing` | no restructure; connect via env + CORS (`references/monorepo.md`) |

### Group E — Data (skip for static marketing pages)

13. "What kinds of things does the app keep track of, and what details matter for each?" — the **core entities** and rough fields (e.g. a Task has a title, a due date, and whether it's done). Infer obvious fields yourself; don't make them list every column.
14. Where the data lives: default to **Supabase** (a managed database, no setup for them to do); only change if the project already uses something else.
15. "Should each person only see their own stuff, or can everyone see everything?" — capture the basic **access rule** (e.g. "a user only sees their own rows").

### Group F — Accounts / login (skip if no accounts)

16. "Do people need to **log in with their own account**? (auth)" If no, skip the rest of this group.
17. "How should they sign in?" Default to **email plus 'continue with Google/GitHub'** (`references/auth.md`). Don't make them choose a provider — that's handled for them.
18. "Are there different kinds of users with different powers — like an admin vs a regular member? (roles)"

### Group G — Payments (skip if nothing is sold)

19. "Does the app **take money** from users?" If no, skip the rest of this group.
20. "Is it a **one-time payment**, a **recurring subscription** (default), or **pay-as-you-go** (usage-based)?"
21. Tell them payments run through **Stripe** (the standard, secure way — Stripe handles the card details, not us) and confirm the products/prices for v1 (`references/payments.md`).

### Group H — Other services it connects to (skip if none)

22. "Does it need to connect to anything else — send email, store files/images, use an AI model, maps, search, etc.?"
23. For each: "Do you already have an account/key for that, or should I set it up with a placeholder so it works later?" Never assume they have keys; offer the placeholder path.

### Group I — Launch extras (ask in plain terms which apply)

24. "Should this show up nicely in Google and when shared on social? (SEO)" — yes for anything public (`references/seo.md`).
25. "Do you want to see **how many people use it and what they do**? (analytics)" — yes/no, and pick a privacy-respecting tool for them (`references/analytics.md`).
26. "Will you collect personal info or take payments?" If yes, we add a **privacy policy and terms** from the templates (`references/legal.md`) — and remind them a lawyer should review.

### Group J — Going live (always)

27. Confirm where it's hosted (from the architecture choice): **one app on Vercel + Supabase** (default), or the bigger Vercel + Koyeb + Supabase setup. Say it in one plain sentence; they don't choose hosts manually.
28. "Do you own a **website address (domain)** you want to use, or should we start with the free one the platform gives you?"
29. "Just a **live version** for now (default), or also a private **test version** to try changes before they go live?" (production vs. preview/staging.)
30. Note which **accounts/keys** the build will need (database, Supabase, Stripe, any service from Group H). Record the **names only**, never the secret values, and tell the user plainly which ones they'll need to create an account for, with steps, when it's time.

After the last applicable group, **read the choices back as a short plain-English summary** (no jargon) and ask the user to confirm or correct before writing anything. If they confirmed defaults throughout, just summarize what you're about to build and start.

## Step 3 — Write the intake

Copy `assets/templates/intake.md` to `.startup-kit/intake.md` in the target repo and fill every section from the interview: product, scope, style, architecture, data model, auth, payments, integrations, launch surfaces, deployment, env/secrets (names only), plan, and out-of-scope. Leave a group's section marked `N/A` when it was skipped. Commit it. This single artifact is the source of truth; re-running onboarding updates it in place and never touches source code.

The intake's line-1 marker starts as `<!-- startup-kit:intake status=draft -->`. After you read the intake back and the user approves it, flip it to `status=confirmed`. The scaffold scripts run `scripts/check-intake.sh`, which refuses to build until the marker reads `confirmed` and the always-required product fields are filled — so confirming the intake is what unlocks the build. Never set `confirmed` by hand to skip the interview.

### Step 3b — For existing code, add the map and gap analysis

For any existing frontend or backend, also produce a written map (not changes):

1. **Stack and versions** — framework, package manager, database, auth, hosting already in use.
2. **Actual file structure** — the real tree of the relevant app(s), captured into the intake so future sessions know the layout.
3. **Gap analysis** — walk the checklist in `assets/templates/intake.md` (section "Gap Analysis"), marking each item OK / GAP / N/A against the kit's conventions (`references/backend.md`, `references/theming.md`, `references/states.md`, `references/forms.md`, `references/accessibility.md`, `references/content.md`). Name concrete gaps: hardcoded hex instead of tokens, business logic in controllers, no `zod` validation at the edge, secrets in code, missing error/empty states, slop content.
4. **Migration plan** — the ordered steps to close the gaps, smallest useful change first.

If the stack is one the kit does not cover, record that honestly and note which conventions still apply (env handling, response shape, accessibility) versus which do not.

## Step 4 — Blueprint the build

Turn the intake into an ordered, concrete plan in the intake's "Plan" section. Each step names the command or reference it uses and produces something runnable. A typical greenfield single-app plan:

1. Scaffold the app — `scripts/create-app.sh <name>` (`references/scaffold.md`).
2. Wrap the theme provider and mount `<Toaster />` (`references/theming.md`, `references/states.md`).
3. Wire Supabase: clients, typed env, and the layered Route Handler → Service → Supabase data layer (`references/single-app.md`). For the monorepo path, use `references/backend.md` and `references/monorepo.md` instead.
4. Build the schema/entities from Group E, with Row Level Security (`references/single-app.md`).
5. Build auth flows if Group F applies (`references/auth.md`).
6. Build the **primary workflow** screen first — the one job, end to end, with real empty/loading/error/success states (`references/minimal-product.md`, `references/states.md`).
7. Add forms with `react-hook-form` + `zod` (`references/forms.md`).
8. Add payments if Group G applies (`references/payments.md`).
9. If there's a landing/marketing/hero surface, wire one bundled animated/3D background into it with `AnimatedBackground` (`references/backgrounds.md`). The scaffold already bundled the catalog and installed `three` + `ogl`; don't ship a flat hero by default. Keep tool/dashboard screens flat.
10. Add launch surfaces from Group I (`references/seo.md`, `references/analytics.md`, `references/legal.md`).
11. Configure deploy + env from Group J (`references/monorepo.md` for split hosting).
12. Run `references/preflight.md` before calling it done.

State the plan and the exact first command, then proceed.

## Step 5 — Build it

Execute the plan top to bottom. After each step, update the checklist in the intake so a later session can resume exactly where this one stopped. Read the reference named in a step before doing that step. Stop and ask only when a decision was genuinely not covered by the intake. End the build phase by running the pre-flight check.

## Re-Running

Onboarding is idempotent. Running it again re-scans, refreshes the intake, and revises the plan. It must not regenerate or overwrite existing source; structural moves only happen through the explicit `adopt-monorepo` / `add-backend` / `add-frontend` scripts, each of which has its own safety checks. Build progress is tracked in the intake checklist, so a re-run resumes rather than restarts.

## Rules

- Scan before asking. Run `scripts/scan-project.sh`, read the real files, and report findings before any question.
- Greenfield gets the full interview; existing code gets detect-first with only the gaps asked.
- Ask in grouped batches with a recommended default per choice; never dump the whole question bank at once.
- Never modify source during the intake phase. The only write before the build is `.startup-kit/intake.md`.
- Present the architecture as a real choice and default to the single app. Only choose the monorepo when a stated criterion holds, and record which one.
- One path only. Pick a single starting-state path and a single hosting choice, and record both.
- Record env/secret **names** only — never paste secret values into the intake.
- Always write down the existing file structure and a concrete gap analysis for existing code — vague "looks fine" is not acceptable.
- End the intake phase with one artifact and one next command, then build the plan and run pre-flight.
