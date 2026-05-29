# Onboarding

Run this first, before any building. Onboarding is the entry point to the whole kit: it figures out where the user is starting, what they want, and the one path that fits — then writes it down so every later session shares the same context.

The rule that makes onboarding production-grade: **detect first, then ask.** Inspect the project before asking anything, report what was found, and only ask what cannot be inferred. Never interrogate the user for facts the repo already answers.

Onboarding is read-only. It inspects and plans; it never modifies source code. The only file it writes is the intake artifact.

## The Flow

Work through these steps in order. The output is a completed intake file and a chosen path.

### Step 0 — Scan the working directory

Run the inventory before talking about anything:

```bash
scripts/scan-project.sh
```

It reports git state, package manager, monorepo layout, every `package.json` with its detected role (frontend/backend) and frameworks, Python manifests, database/auth libraries, env files, and existing deploy config — all read-only.

Then read the key files it surfaced (root `package.json`, app entry points, existing folder structure) so the plan is grounded in the real code, not assumptions. Summarize what you found back to the user in one or two sentences before asking anything, e.g. *"I found a Next.js frontend in `web/` and an Express + MongoDB API in `server/`, npm, not yet a workspace."*

### Step 1 — Style

Ask only what the scan cannot answer:

- **Direction**: the quiet SF Pro default (tool UI), a preset (`linear`, `vercel`, `notion`), or a custom brand. For custom, collect font, primary color, and logo, then map them onto the token contract (`references/themes.md`, `references/theming.md`) — change token values, never names.
- **Product type**: tool/dashboard vs marketing/landing. This decides whether expressive backgrounds are allowed at all (`references/backgrounds.md`); dense tool UI gets none.

### Step 2 — Architecture and path

Confirm the detected starting state, then choose exactly one path:

| Detected starting state | Path | How |
| --- | --- | --- |
| Nothing yet (greenfield) | `create-monorepo` or single app | `scripts/create-monorepo.sh` / `scripts/create-app.sh` |
| Existing frontend only | `add-backend` | `scripts/add-backend.sh` |
| Existing backend only | `add-frontend` | `scripts/add-frontend.sh` |
| Existing frontend + backend in one repo | `adopt-monorepo` | `scripts/adopt-monorepo.sh` |
| Two separate repos, or "leave it as-is" | `wire-existing` | no restructure; connect via env + CORS (`references/monorepo.md`) |

Then pick hosting: a single Next.js app on Vercel, or the split — Vercel (`apps/web`) + Koyeb (`apps/api`) + Supabase (data/auth). Use the decision table in `references/monorepo.md`. The monorepo is a convenience, never a prerequisite: if the user wants to keep their structure, choose `wire-existing` and only generate connection glue.

### Step 3 — If code exists, understand it and write it down

For any existing frontend or backend, produce a written map (not changes):

1. **Stack and versions** — framework, package manager, database, auth, hosting already in use.
2. **Actual file structure** — the real tree of the relevant app(s), captured into the intake file so future sessions know the layout.
3. **Gap analysis** — walk the checklist in `assets/templates/intake.md` section 5, marking each item OK / GAP / N/A against the kit's conventions (`references/backend.md`, `references/theming.md`, `references/states.md`, `references/forms.md`, `references/accessibility.md`, `references/content.md`). Name concrete gaps: hardcoded hex instead of tokens, business logic in controllers, no `zod` validation at the edge, secrets in code, missing error/empty states, slop content.
4. **Migration plan** — the ordered steps to close the gaps, smallest useful change first.

If the stack is one the kit does not cover, record that honestly in the intake and note which conventions still apply (env handling, response shape, accessibility) versus which do not.

### Step 4 — Write the intake and state the plan

Copy `assets/templates/intake.md` to `.startup-kit/intake.md` in the target repo and fill every section: product, style, architecture, existing code, gap analysis, plan, out-of-scope. Commit it. This single artifact is the source of truth; re-running onboarding updates it in place and never touches source code.

Finish by stating the chosen path and the exact next command, then proceed to build against the relevant references.

## Re-Running

Onboarding is idempotent. Running it again re-scans, refreshes the intake, and revises the plan. It must not regenerate or overwrite existing source; structural moves only happen through the explicit `adopt-monorepo` / `add-backend` / `add-frontend` scripts, each of which has its own safety checks.

## Rules

- Detect before asking. Run `scripts/scan-project.sh`, read the real files, and report findings before any question.
- Never modify source during onboarding. The only write is `.startup-kit/intake.md`.
- Ask only what cannot be inferred; keep it to style and the few architecture choices.
- One path only. Pick a single starting-state path and a single hosting choice, and record both.
- Treat the monorepo as optional. If the user wants their structure left alone, choose `wire-existing`.
- Always write down the existing file structure and a concrete gap analysis for existing code — vague "looks fine" is not acceptable.
- Be honest about unsupported stacks; record what applies and what does not.
- End with one artifact and one next command, not an open-ended menu.
