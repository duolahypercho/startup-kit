# Single App (Default Architecture)

The default for most products: one Next.js App Router app on Vercel, with Route Handlers as the API edge and Supabase for data, auth, and storage. Fewer moving parts than the monorepo, fast to ship, and enough for an MVP, a skill UI, a dashboard, or anything whose backend is "endpoints + a database."

Choose this unless a monorepo criterion holds (always-on backend, a typed contract across 2+ deployed apps, or 3+ deployables — see `references/monorepo.md`). Scaffold it with `scripts/create-app.sh <name>`.

## The Shape

```
┌─────────────────────────────────────────────┐
│  Next.js app (Vercel)                         │
│                                               │
│  app/(routes)            React UI             │
│  app/api/.../route.ts    Route Handlers (API) │
│  lib/services            business logic       │
│  lib/supabase            data access clients  │ ──▶ Supabase
│  lib/validation          zod schemas (edge)   │     (Postgres + Auth + Storage)
└─────────────────────────────────────────────┘
```

Keep the same one-directional discipline as the layered backend (`references/backend.md`), just without a separate server:

```
Route Handler   (owns the HTTP request/response, validates input, shapes the envelope)
  → Service      (business logic; no Request/Response objects)
    → Supabase   (data access via the server client)
  ← Service      (returns a plain result object)
← Route Handler  (maps the result to a status + JSON envelope)
```

Rule: route handlers know about HTTP; services do not. Services know about Supabase; route handlers do not call the database directly.

## File Structure

```
src/
  app/
    (marketing)/            # public pages, if any
    (app)/                  # authed product surface
    api/
      <domain>/
        route.ts            # GET/POST handlers for the domain
    layout.tsx
    globals.css             # kit tokens (light + dark)
  components/               # shadcn primitives + composed UI
  lib/
    supabase/
      server.ts             # server client (RSC, route handlers, actions)
      client.ts             # browser client (client components)
      admin.ts              # service-role client (server-only, never imported client-side)
    services/
      <domain>.ts           # business logic, returns plain result objects
    validation/
      <domain>.ts           # zod schemas validated at the edge
    env.ts                  # typed, validated environment access
middleware.ts               # session refresh + route protection
.env.local                  # secrets — never committed
```

One file per domain in `services/` and `validation/`, named after the domain (`project` → `services/project.ts`, `validation/project.ts`, `app/api/projects/route.ts`).

## Supabase Clients

Use the official `@supabase/ssr` package and keep three clients with clear boundaries. Install: `npm install @supabase/supabase-js @supabase/ssr`.

```ts
// src/lib/supabase/server.ts — for RSC, Route Handlers, and Server Actions
import { cookies } from "next/headers";
import { createServerClient } from "@supabase/ssr";
import { env } from "@/lib/env";

export async function supabaseServer() {
  const cookieStore = await cookies();
  return createServerClient(env.NEXT_PUBLIC_SUPABASE_URL, env.NEXT_PUBLIC_SUPABASE_ANON_KEY, {
    cookies: {
      getAll: () => cookieStore.getAll(),
      setAll: (toSet) => {
        try {
          toSet.forEach(({ name, value, options }) => cookieStore.set(name, value, options));
        } catch {
          // called from a Server Component — middleware refreshes the session instead
        }
      },
    },
  });
}
```

```ts
// src/lib/supabase/client.ts — for client components
import { createBrowserClient } from "@supabase/ssr";
import { env } from "@/lib/env";

export const supabaseBrowser = () =>
  createBrowserClient(env.NEXT_PUBLIC_SUPABASE_URL, env.NEXT_PUBLIC_SUPABASE_ANON_KEY);
```

```ts
// src/lib/supabase/admin.ts — service role, SERVER ONLY. Never import in a client component.
import "server-only";
import { createClient } from "@supabase/supabase-js";
import { env } from "@/lib/env";

export const supabaseAdmin = () =>
  createClient(env.NEXT_PUBLIC_SUPABASE_URL, env.SUPABASE_SERVICE_ROLE_KEY, {
    auth: { autoRefreshToken: false, persistSession: false },
  });
```

The `admin` client bypasses Row Level Security — use it only for trusted server-side work (webhooks, admin tasks), never to serve normal user requests.

## Typed Environment

Validate env at startup and fail fast when something is missing. Keep public values prefixed with `NEXT_PUBLIC_`; everything else is server-only.

```ts
// src/lib/env.ts
import { z } from "zod";

const schema = z.object({
  NEXT_PUBLIC_SUPABASE_URL: z.string().url(),
  NEXT_PUBLIC_SUPABASE_ANON_KEY: z.string().min(1),
  SUPABASE_SERVICE_ROLE_KEY: z.string().min(1).optional(),
});

export const env = schema.parse({
  NEXT_PUBLIC_SUPABASE_URL: process.env.NEXT_PUBLIC_SUPABASE_URL,
  NEXT_PUBLIC_SUPABASE_ANON_KEY: process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY,
  SUPABASE_SERVICE_ROLE_KEY: process.env.SUPABASE_SERVICE_ROLE_KEY,
});
```

## Validation At The Edge

Every external input is validated with `zod` in the route handler before it reaches a service.

```ts
// src/lib/validation/project.ts
import { z } from "zod";

export const CreateProjectInput = z.object({
  name: z.string().min(1).max(120),
  description: z.string().max(2000).optional(),
});
export type CreateProjectInput = z.infer<typeof CreateProjectInput>;
```

## Service Layer

Services hold business logic and own data access. They return a plain result object — never a `Response`.

```ts
// src/lib/services/project.ts
import { supabaseServer } from "@/lib/supabase/server";
import type { CreateProjectInput } from "@/lib/validation/project";

export async function createProject(userId: string, input: CreateProjectInput) {
  const supabase = await supabaseServer();
  const { data, error } = await supabase
    .from("projects")
    .insert({ owner: userId, name: input.name, description: input.description })
    .select()
    .single();

  if (error) return { success: false as const, code: 400, error: error.message };
  return { success: true as const, code: 201, data };
}
```

## Route Handler

The route handler is the HTTP edge: authenticate, validate, call one service, and map the result to the standard envelope — the same envelope the rest of the kit uses (`references/backend.md`).

```ts
// src/app/api/projects/route.ts
import { NextRequest, NextResponse } from "next/server";
import { supabaseServer } from "@/lib/supabase/server";
import { CreateProjectInput } from "@/lib/validation/project";
import { createProject } from "@/lib/services/project";

export async function POST(req: NextRequest) {
  const supabase = await supabaseServer();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) {
    return NextResponse.json(
      { success: false, status: 401, code: "UNAUTHORIZED", error: "Sign in required" },
      { status: 401 },
    );
  }

  const parsed = CreateProjectInput.safeParse(await req.json());
  if (!parsed.success) {
    return NextResponse.json(
      { success: false, status: 422, code: "INVALID_INPUT", error: parsed.error.message },
      { status: 422 },
    );
  }

  const result = await createProject(user.id, parsed.data);
  if (!result.success) {
    return NextResponse.json(
      { success: false, status: result.code, code: "CREATE_FAILED", error: result.error },
      { status: result.code },
    );
  }

  return NextResponse.json(
    { success: true, status: result.code, code: "PROJECT_CREATED", data: result.data },
    { status: result.code },
  );
}
```

Same envelope as the layered backend, so the frontend handles every response uniformly:

```ts
// Success
{ "success": true, "status": 201, "code": "PROJECT_CREATED", "data": { } }
// Failure
{ "success": false, "status": 422, "code": "INVALID_INPUT", "error": "..." }
```

## Auth And Route Protection

Use Supabase Auth (`references/auth.md`). Refresh the session and protect routes in `middleware.ts` — client checks are UX, the server check is security.

```ts
// middleware.ts
import { NextResponse, type NextRequest } from "next/server";
import { createServerClient } from "@supabase/ssr";

export async function middleware(req: NextRequest) {
  const res = NextResponse.next({ request: req });
  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll: () => req.cookies.getAll(),
        setAll: (toSet) => toSet.forEach(({ name, value, options }) => res.cookies.set(name, value, options)),
      },
    },
  );

  const { data: { user } } = await supabase.auth.getUser();
  const isProtected = req.nextUrl.pathname.startsWith("/app");
  if (isProtected && !user) {
    const url = req.nextUrl.clone();
    url.pathname = "/sign-in";
    url.searchParams.set("redirect", req.nextUrl.pathname);
    return NextResponse.redirect(url);
  }
  return res;
}

export const config = { matcher: ["/((?!_next/static|_next/image|favicon.ico).*)"] };
```

## Data Model And RLS

Enforce access in the database with Row Level Security, not just in code. Keep migrations in `supabase/migrations/` and apply them with the Supabase CLI (`references/monorepo.md` has the CLI commands).

```sql
-- a user only sees and edits their own rows
alter table projects enable row level security;

create policy "owner reads" on projects
  for select using (auth.uid() = owner);
create policy "owner writes" on projects
  for insert with check (auth.uid() = owner);
```

## Deploy

- Connect the repo to **Vercel**; it builds and hosts the whole app, Route Handlers included.
- Set env vars in the Vercel project: `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY` (public), and `SUPABASE_SERVICE_ROLE_KEY` plus any provider secrets (server-only).
- Supabase is a connected service, not a deploy target; apply migrations with `supabase db push`.

## When To Graduate To A Monorepo

Move to the monorepo split (`references/monorepo.md`) only when a Route Handler can no longer do the job: you need websockets, background jobs, cron, queues, or long-running requests that don't fit serverless; a typed contract shared across two independently deployed apps; or a third deployable. Until then, the single app is less to build and less to maintain.

## Rules

- Keep the flow one-directional: Route Handler → Service → Supabase. Never query the database directly from a route handler or a component that should go through a service.
- Validate every external input with `zod` in the route handler before calling a service.
- Return the standard envelope `{ success, status, code, message/error, data }` from every handler.
- Authenticate on the server (`supabase.auth.getUser()` + middleware). Never trust a client-only flag.
- Public config uses `NEXT_PUBLIC_`; the service-role key and other secrets stay server-only and are never imported into client code (`import "server-only"`).
- Enforce access with Row Level Security in the database, not only in application code.
- Validate required env vars at startup (`lib/env.ts`) and fail fast when one is missing.
