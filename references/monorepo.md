# Monorepo And Split Hosting

Keep the frontend and backend in one repository, but deploy each to the platform that fits it. The repo is where the code lives; hosting is where each part runs. They do not have to match.

Use this when a product needs more than Next.js Route Handlers — a standalone API server, a managed database, or a backend that scales on its own. For a UI-only skill or an app whose only server work is a few endpoints, stay with a single Next.js app (`references/scaffold.md`) and skip this.

## The Pattern

```
┌──────────────────┐      ┌───────────────────────┐
│  apps/web         │      │  apps/api              │
│  Next.js          │ ───▶ │  Express / Fastify     │ ──▶ Postgres
│  → Vercel         │ HTTPS│  → Koyeb               │
└──────────────────┘      └───────────────────────┘
            │                         │
            └──────── one repo ───────┘
                   packages/shared
```

- **Frontend** (`apps/web`) deploys to **Vercel**.
- **Backend** (`apps/api`) deploys to **Koyeb** (an always-on server) when you need websockets, background jobs, long-running requests, or a traditional framework.
- **Data, auth, storage** come from **Supabase** (managed Postgres + auth + storage + realtime). Supabase is a service you connect to, not a folder you deploy.
- **Shared code** (types, `zod` schemas, constants) lives in `packages/shared` and is imported by both apps so the contract stays in one place.

Pick the backend host by what the work needs:

| Need | Host |
| --- | --- |
| Database, auth, file storage, simple APIs | Supabase alone (often no `apps/api`) |
| Custom server framework, long-running requests | Koyeb |
| Websockets, background jobs, cron, queues | Koyeb |
| Both managed data and custom server logic | Supabase + Koyeb |

## Repository Layout

```
my-product/
  apps/
    web/                 # Next.js (startup-kit theme) → Vercel
    api/                 # Express/Fastify service     → Koyeb
  packages/
    shared/              # types + zod schemas shared by web and api
  package.json           # workspace root, scripts run through turbo
  pnpm-workspace.yaml    # declares apps/* and packages/*
  turbo.json             # task graph + caching
  .gitignore
  tsconfig.base.json
```

Use **pnpm workspaces + Turborepo**. pnpm links the local packages; Turborepo runs and caches `build`, `dev`, `lint`, and `typecheck` across them and can skip an app whose inputs did not change.

Scaffold it with `scripts/create-monorepo.sh <name>`. The web app follows the same theme wiring as `scripts/create-app.sh`; the api app follows the layered structure in `references/backend.md`.

## How Each Platform Builds One Folder

The repo connects to each platform once. Each build is scoped to its own subfolder, so an unrelated change does not redeploy everything.

- **Vercel** — set the project **Root Directory** to `apps/web`. Vercel detects the monorepo, installs from the workspace root, and builds only that app. Add a Turborepo "ignored build step" so a deploy is skipped when `apps/web` and its dependencies are unchanged.
- **Koyeb** — two supported options. With the **buildpack**, set the build command to `pnpm exec turbo run build --filter=api` and the run command to `pnpm --filter api start` (both run from the repo root, so `packages/shared` builds first). With the **Dockerfile** (`apps/api/Dockerfile`), set the build context to the **repository root** (not `apps/api`) and the Dockerfile path to `apps/api/Dockerfile`, and commit `pnpm-lock.yaml` — the Dockerfile copies the whole workspace so the lockfile and `packages/shared` are present.
- **Supabase** — no folder deploys. Keep `supabase/` migrations and Edge Functions in the repo and apply them with the Supabase CLI; the database itself is hosted by Supabase.

Both platforms watch the **same GitHub repo**. A push triggers each independently.

## Wiring The Two Sides

- **Env vars, never hardcode.** The browser may only see public values: `NEXT_PUBLIC_API_URL`, `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY`. Secrets (`SUPABASE_SERVICE_ROLE_KEY`, `DATABASE_URL`, API keys) stay server-side on Vercel and Koyeb. See `references/backend.md` for `.env` rules.
- **CORS.** The backend (Koyeb service or Supabase Edge Function) must allow the Vercel origin — the production domain and Vercel preview URLs. Do not ship `origin: *` with credentials.
- **One contract.** Define request/response types and `zod` schemas once in `packages/shared` and import them in both `apps/web` and `apps/api`. Validate every external input at the edge with those schemas.
- **Atomic changes.** Because both sides are in one repo, change an endpoint and its caller in a single commit and PR.

## CLI Tooling

Install the three platform CLIs with `scripts/install-deploy-clis.sh`, which uses each tool's official method: Vercel via npm, Koyeb via Homebrew or its install script (there is no official npm package), and Supabase via Homebrew or the standalone binary (a global `npm i -g supabase` is not supported). Each authenticates against its own account; none of them commit secrets to the repo.

### Vercel CLI

```bash
npm i -g vercel
vercel login
cd apps/web
vercel link                 # connect this folder to a Vercel project
vercel pull                 # download env vars into .env.local
vercel                      # deploy a preview
vercel --prod               # deploy to production
```

Set the project Root Directory to `apps/web` in the dashboard or during `vercel link`.

### Supabase CLI

Global `npm i -g supabase` is not supported. Install via Homebrew (or Scoop on Windows / the standalone binary), or run it with `npx supabase` without installing — both shown below.

```bash
brew install supabase/tap/supabase   # macOS/Linux; or run: npx supabase <command>
supabase login
supabase init               # creates supabase/ in the repo
supabase link --project-ref <ref>
supabase db push            # apply local migrations to the hosted project
supabase functions deploy <name>   # deploy an Edge Function
supabase start              # optional: run the full stack locally in Docker
```

### Koyeb CLI

There is no official npm package for the Koyeb CLI. Install via Homebrew, or the official install script (binary lands in `~/.koyeb/bin`).

```bash
brew install koyeb/tap/koyeb   # or: curl -fsSL https://raw.githubusercontent.com/koyeb/koyeb-cli/master/install.sh | sh
koyeb login
koyeb app init <name> \
  --git github.com/<org>/<repo> \
  --git-branch main \
  --git-build-command "pnpm --filter api build" \
  --git-run-command "pnpm --filter api start"
koyeb service list
koyeb service redeploy <id>
```

Prefer connecting the Git repo so Koyeb redeploys on push; use the CLI for setup, env vars, and manual redeploys.

## Rules

- One repo holds everything; each app deploys to the host that fits its workload. Do not split into multiple repos just to use multiple hosts.
- Scope every platform build to its own folder (`apps/web`, `apps/api`). Never let one app's deploy rebuild the other.
- Put the shared request/response contract and `zod` schemas in `packages/shared`; import them in both apps. Do not duplicate types across the boundary.
- Public values use the `NEXT_PUBLIC_` prefix; everything else is a server-only secret kept in platform env settings, never committed.
- Set CORS to the exact Vercel origins (production + previews), with credentials only when needed. Never `*` with credentials.
- Use Koyeb (not Vercel functions) for websockets, background jobs, cron, and long-running work; use Vercel for the frontend and its own Route Handlers.
- Use the CLIs for setup and env management, but let Git-connected deploys be the default trigger so deploys stay reproducible.
- Validate required env vars at startup on both sides and fail fast when one is missing (`references/backend.md`).
