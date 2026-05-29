#!/usr/bin/env bash
# Shared helpers for the monorepo restructuring scripts (adopt/add-backend/add-frontend).
# Source this from a script; do not run it directly. All functions operate on the
# current working directory, which must be the repository root.

# Abort unless the git working tree is clean, then create a timestamped backup branch
# so any restructuring can be undone with a single checkout.
ws_require_clean_git() {
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Not a git repository. Initialize git and commit your work first:"
    echo "  git init && git add -A && git commit -m 'snapshot before restructure'"
    return 1
  fi
  if [ -n "$(git status --porcelain)" ]; then
    echo "Working tree is not clean. Commit or stash your changes before restructuring."
    return 1
  fi
  local backup
  backup="backup/pre-monorepo-$(date -u +%Y%m%d%H%M%S)"
  git branch "$backup"
  echo "Created backup branch '$backup' (restore with: git reset --hard $backup)."
}

# Move a path into a new location, preserving history when possible.
ws_move() {
  # $1 = source, $2 = destination directory
  local src="$1" destdir="$2"
  mkdir -p "$destdir"
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git mv "$src" "$destdir/" 2>/dev/null || { mv "$src" "$destdir/"; git add -A "$destdir" 2>/dev/null || true; }
  else
    mv "$src" "$destdir/"
  fi
}

# Write the workspace root files, skipping any that already exist so we never
# clobber a project's own config.
ws_write_root() {
  # $1 = workspace name
  local name="$1"

  if [ ! -f pnpm-workspace.yaml ]; then
    cat > pnpm-workspace.yaml <<'EOF'
packages:
  - "apps/*"
  - "packages/*"
EOF
    echo "  + pnpm-workspace.yaml"
  fi

  if [ ! -f turbo.json ]; then
    cat > turbo.json <<'EOF'
{
  "$schema": "https://turbo.build/schema.json",
  "daemon": false,
  "tasks": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": [".next/**", "!.next/cache/**", "dist/**"]
    },
    "dev": { "cache": false, "persistent": true },
    "lint": {},
    "typecheck": { "dependsOn": ["^build"] }
  }
}
EOF
    echo "  + turbo.json"
  fi

  if [ ! -f tsconfig.base.json ]; then
    cat > tsconfig.base.json <<'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "Bundler",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true
  }
}
EOF
    echo "  + tsconfig.base.json"
  fi

  if [ ! -f package.json ]; then
    cat > package.json <<EOF
{
  "name": "$name",
  "private": true,
  "packageManager": "pnpm@9.0.0",
  "scripts": {
    "dev": "turbo run dev",
    "build": "turbo run build",
    "lint": "turbo run lint",
    "typecheck": "turbo run typecheck"
  },
  "devDependencies": {
    "turbo": "^2.0.0",
    "typescript": "^5.5.0"
  }
}
EOF
    echo "  + package.json (workspace root)"
  else
    echo "  ! root package.json already exists — left unchanged; add turbo scripts manually if needed."
  fi

  # Ensure common ignores exist without duplicating lines.
  for line in "node_modules/" ".next/" "dist/" ".turbo/" ".vercel"; do
    if [ ! -f .gitignore ] || ! grep -qxF "$line" .gitignore 2>/dev/null; then
      echo "$line" >> .gitignore
    fi
  done
}

# Create packages/shared with the typed request/response contract, if absent.
ws_write_shared() {
  if [ -d packages/shared ]; then
    echo "  ! packages/shared already exists — left unchanged."
    return 0
  fi
  mkdir -p packages/shared/src
  # Built to dist (CommonJS + declarations) and consumed via node_modules, so both
  # the tsc-built api and the Next.js web app import it as a normal dependency.
  # turbo's build dependsOn ^build ensures shared compiles before its consumers.
  cat > packages/shared/package.json <<'EOF'
{
  "name": "@repo/shared",
  "version": "0.0.0",
  "private": true,
  "main": "./dist/index.js",
  "types": "./dist/index.d.ts",
  "exports": {
    ".": { "types": "./dist/index.d.ts", "default": "./dist/index.js" }
  },
  "scripts": {
    "build": "tsc",
    "dev": "tsc --watch --preserveWatchOutput",
    "lint": "echo \"no lint\"",
    "typecheck": "tsc --noEmit"
  },
  "dependencies": { "zod": "^3.23.0" },
  "devDependencies": { "typescript": "^5.5.0" }
}
EOF
  cat > packages/shared/tsconfig.json <<'EOF'
{
  "extends": "../../tsconfig.base.json",
  "compilerOptions": {
    "module": "commonjs",
    "moduleResolution": "node",
    "outDir": "dist",
    "rootDir": "src",
    "composite": false,
    "declaration": true
  },
  "include": ["src/**/*"]
}
EOF
  cat > packages/shared/src/index.ts <<'EOF'
import { z } from "zod";

// One source of truth for the request/response contract.
// Import these in both apps/web and apps/api so the boundary stays in sync.

export const UserSchema = z.object({
  id: z.string(),
  email: z.string().email(),
  name: z.string().min(1),
});
export type User = z.infer<typeof UserSchema>;

export type ApiResponse<T> =
  | { success: true; status: number; code: string; message?: string; data: T }
  | { success: false; status: number; code: string; error: string };
EOF
  echo "  + packages/shared (typed contract)"
}

# Scaffold a minimal layered Express + TypeScript service at apps/api.
# Full structure and rules live in references/backend.md.
ws_write_api() {
  if [ -e apps/api ]; then
    echo "  ! apps/api already exists — left unchanged."
    return 0
  fi
  mkdir -p apps/api/src/{Routes,controllers,services,Middleware,config}

  cat > apps/api/package.json <<'EOF'
{
  "name": "api",
  "version": "0.0.0",
  "private": true,
  "scripts": {
    "dev": "nodemon --watch src --ext ts --exec \"node --import tsx ./src/index.ts\"",
    "build": "tsc",
    "start": "node ./dist/index.js",
    "lint": "echo \"no lint\"",
    "typecheck": "tsc --noEmit"
  },
  "dependencies": {
    "@repo/shared": "workspace:*",
    "cors": "^2.8.5",
    "dotenv": "^16.4.0",
    "express": "^4.19.0",
    "express-rate-limit": "^7.2.0",
    "zod": "^3.23.0"
  },
  "devDependencies": {
    "@types/cors": "^2.8.17",
    "@types/express": "^4.17.21",
    "@types/node": "^20.14.0",
    "nodemon": "^3.1.0",
    "tsx": "^4.15.0",
    "typescript": "^5.5.0"
  }
}
EOF

  cat > apps/api/tsconfig.json <<'EOF'
{
  "extends": "../../tsconfig.base.json",
  "compilerOptions": {
    "module": "commonjs",
    "moduleResolution": "node",
    "outDir": "./dist",
    "rootDir": "./src",
    "composite": false
  },
  "include": ["./src/**/*"]
}
EOF

  cat > apps/api/.env.example <<'EOF'
PORT=9979
DATABASE_URL=
JWT_TOKEN=
# Comma-separated allowed origins (your Vercel domains).
CORS_ORIGINS=http://localhost:3000
EOF

  # NOTE: build context is the MONOREPO ROOT (not apps/api) so the workspace,
  # lockfile, and packages/shared are available. On Koyeb set the build context
  # to the repo root and the Dockerfile path to apps/api/Dockerfile, and commit
  # pnpm-lock.yaml. turbo builds packages/shared before api.
  cat > apps/api/Dockerfile <<'EOF'
# Build context: monorepo root.
FROM node:20-slim AS build
WORKDIR /app
RUN corepack enable
COPY . .
RUN pnpm install --frozen-lockfile
RUN pnpm exec turbo run build --filter=api

FROM node:20-slim AS run
WORKDIR /app
RUN corepack enable
COPY --from=build /app /app
EXPOSE 9979
CMD ["pnpm", "--filter", "api", "start"]
EOF

  cat > apps/api/src/config/index.ts <<'EOF'
import dotenv from "dotenv";

dotenv.config();

export const config = {
  port: Number(process.env.PORT ?? 9979),
  corsOrigins: (process.env.CORS_ORIGINS ?? "http://localhost:3000")
    .split(",")
    .map((o) => o.trim()),
};
EOF

  cat > apps/api/src/Routes/index.ts <<'EOF'
export { default as HealthRoute } from "./HealthRouter";
EOF

  cat > apps/api/src/Routes/HealthRouter.ts <<'EOF'
import { Router } from "express";
import { getHealth } from "../controllers/HealthController";

const r = Router();
r.get("/", getHealth);
export default r;
EOF

  cat > apps/api/src/controllers/HealthController.ts <<'EOF'
import { Request, Response } from "express";
import type { ApiResponse } from "@repo/shared";
import { checkHealth } from "../services/HealthService";

export const getHealth = async (_req: Request, res: Response) => {
  try {
    const data = await checkHealth();
    const body: ApiResponse<typeof data> = {
      success: true,
      status: 200,
      code: "OK",
      data,
    };
    return res.status(200).json(body);
  } catch (e: any) {
    const body: ApiResponse<never> = {
      success: false,
      status: 500,
      code: "INTERNAL_ERROR",
      error: e.message,
    };
    return res.status(500).json(body);
  }
};
EOF

  cat > apps/api/src/services/HealthService.ts <<'EOF'
export const checkHealth = async () => {
  return { status: "ok", uptime: process.uptime() };
};
EOF

  cat > apps/api/src/index.ts <<'EOF'
import express, { Express } from "express";
import cors from "cors";
import rateLimit from "express-rate-limit";
import { config } from "./config";
import { HealthRoute } from "./Routes";

const app: Express = express();

app.use(cors({ origin: config.corsOrigins, credentials: true }));
app.use(rateLimit({ windowMs: 60_000, max: 100 }));
app.use(express.json());

app.use("/health", HealthRoute);

app.listen(config.port, () => {
  console.log(`API running on :${config.port}`);
});
EOF
  echo "  + apps/api (layered Express + TypeScript)"
}

# Apply the kit theme to a freshly created Next.js app and pin Tailwind to v3.
# create-next-app now scaffolds Tailwind v4 (CSS-first, no config file), but the
# kit's globals.css and shadcn config target v3 — so we install v3 explicitly and
# write the matching tailwind.config.ts + postcss config.
# $1 = kit dir, $2 = path to the web app, $3 = package manager (pnpm|npm)
ws_apply_web_theme_v3() {
  local kit="$1" web="$2" pm="${3:-npm}"

  cp "$kit/assets/tailwind/globals.css" "$web/src/app/globals.css"
  mkdir -p "$web/src/styles"
  cp "$kit/assets/theme/default-theme.css" "$web/src/styles/default-theme.css"
  cp "$kit/assets/theme/dark-theme.css" "$web/src/styles/dark-theme.css"
  cp "$kit/assets/tailwind/tailwind.config.ts" "$web/tailwind.config.ts"
  cp "$kit/assets/shadcn/components.tailwind-v3.json" "$web/components.json"

  (
    cd "$web" || exit 1
    # Drop the v4 toolchain create-next-app installed, pin v3, and write configs.
    # tailwindcss-animate is required by the kit's tailwind.config.ts.
    if [ "$pm" = "pnpm" ]; then
      pnpm remove tailwindcss @tailwindcss/postcss >/dev/null 2>&1 || true
      pnpm add -D "tailwindcss@^3" postcss autoprefixer tailwindcss-animate >/dev/null 2>&1
      # shadcn base runtime deps — normally added by `shadcn init`, which we skip
      # because we ship our own components.json, globals.css, and tailwind config.
      pnpm add class-variance-authority clsx tailwind-merge lucide-react >/dev/null 2>&1
    else
      npm uninstall tailwindcss @tailwindcss/postcss >/dev/null 2>&1 || true
      npm install -D "tailwindcss@^3" postcss autoprefixer tailwindcss-animate >/dev/null 2>&1
      npm install class-variance-authority clsx tailwind-merge lucide-react >/dev/null 2>&1
    fi
    rm -f postcss.config.mjs postcss.config.js
    cat > postcss.config.js <<'PCFG'
module.exports = { plugins: { tailwindcss: {}, autoprefixer: {} } };
PCFG
    # The cn() helper shadcn components import from @/lib/utils.
    mkdir -p src/lib
    if [ ! -f src/lib/utils.ts ]; then
      cat > src/lib/utils.ts <<'CN'
import { type ClassValue, clsx } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
CN
    fi
  )
}

# Bundle the React Bits animated/3D background catalog into a web app and ship a
# reusable wrapper so any background can be dropped in "wherever" with a lazy
# import, a reduced-motion fallback, and a legibility scrim. The component source
# files are cheap and tree-shaken (only imported ones reach the bundle), so we
# copy the whole catalog and pre-install the two most common WebGL runtimes
# (three + ogl) that cover the majority of the components. Heavier components
# (postprocessing, react-three-fiber, gsap, face-api.js) declare their own deps
# in manifest.json — install those on demand with scripts/add-background.sh.
# $1 = kit dir, $2 = path to the web app, $3 = package manager (pnpm|npm)
ws_add_backgrounds() {
  local kit="$1" web="$2" pm="${3:-npm}"
  local dest="$web/src/components/backgrounds"
  mkdir -p "$dest"

  # Catalog source (components fill their parent; most render on a transparent canvas).
  cp "$kit"/assets/components/backgrounds/*.jsx "$dest"/ 2>/dev/null || true
  cp "$kit"/assets/components/backgrounds/*.css "$dest"/ 2>/dev/null || true
  cp "$kit"/assets/components/backgrounds/manifest.json "$dest"/ 2>/dev/null || true

  # Reusable wrapper: lazy-loads the chosen background only when motion is allowed,
  # renders a static fallback under prefers-reduced-motion, and layers a scrim so
  # foreground copy stays legible. Keeps the heavy WebGL work in a client leaf.
  cat > "$dest/animated-background.tsx" <<'EOF'
"use client";

import { useEffect, useRef, useState, type ComponentType } from "react";

type BackgroundModule = { default: ComponentType<Record<string, unknown>> };

type AnimatedBackgroundProps = {
  /** Lazy import of a component in this folder, e.g. () => import("@/components/backgrounds/LiquidEther"). */
  load: () => Promise<BackgroundModule>;
  /** Props forwarded to the background component (colors, speed, etc.). */
  componentProps?: Record<string, unknown>;
  /** Extra classes for the absolutely-positioned wrapper. */
  className?: string;
  /** Static fallback shown when the user prefers reduced motion. */
  fallbackClassName?: string;
  /** Translucent scrim + bottom fade for foreground legibility. Default true. */
  scrim?: boolean;
};

/**
 * Drop an animated/3D background behind any section. The parent must be
 * positioned (e.g. `relative isolate overflow-hidden`):
 *
 *   <section className="relative isolate overflow-hidden">
 *     <AnimatedBackground load={() => import("@/components/backgrounds/LiquidEther")} />
 *     <div className="relative z-10"> ...content... </div>
 *   </section>
 */
export function AnimatedBackground({
  load,
  componentProps,
  className = "",
  fallbackClassName = "bg-[radial-gradient(120%_100%_at_50%_0%,hsl(var(--primary)/0.12),transparent_70%)]",
  scrim = true,
}: AnimatedBackgroundProps) {
  const [Background, setBackground] = useState<ComponentType<Record<string, unknown>> | null>(null);
  const [allowMotion, setAllowMotion] = useState(false);
  const loadRef = useRef(load);
  loadRef.current = load;

  useEffect(() => {
    const query = window.matchMedia("(prefers-reduced-motion: reduce)");
    const sync = () => setAllowMotion(!query.matches);
    sync();
    query.addEventListener("change", sync);
    return () => query.removeEventListener("change", sync);
  }, []);

  useEffect(() => {
    if (!allowMotion) {
      setBackground(null);
      return;
    }
    let active = true;
    loadRef.current().then((mod) => {
      if (active) setBackground(() => mod.default);
    });
    return () => {
      active = false;
    };
  }, [allowMotion]);

  return (
    <div
      aria-hidden
      className={`pointer-events-none absolute inset-0 -z-10 overflow-hidden ${className}`}
    >
      {Background ? (
        <Background {...componentProps} />
      ) : (
        <div className={`h-full w-full ${fallbackClassName}`} />
      )}
      {scrim ? (
        <>
          <div className="absolute inset-0 bg-background/30" />
          <div className="absolute inset-0 bg-gradient-to-b from-transparent via-transparent to-background" />
        </>
      ) : null}
    </div>
  );
}
EOF

  cat > "$dest/README.md" <<'EOF'
# Backgrounds

Animated / 3D background components from React Bits, bundled by the startup-kit
scaffold. These are expressive surfaces for marketing, hero, auth, and splash —
not for dense tool UI. See `references/backgrounds.md` for the full guidance.

## Use one

The parent must be a positioned box with height. Wrap the background with
`AnimatedBackground` so it lazy-loads, falls back to a static gradient under
`prefers-reduced-motion`, and keeps text legible:

```tsx
import { AnimatedBackground } from "@/components/backgrounds/animated-background";

<section className="relative isolate overflow-hidden">
  <AnimatedBackground
    load={() => import("@/components/backgrounds/LiquidEther")}
    componentProps={{ colors: ["#5227FF", "#FF9FFC", "#B497CF"] }}
  />
  <div className="relative z-10">{/* hero content */}</div>
</section>
```

## Dependencies

`three` and `ogl` are installed by default, which covers most components
(LiquidEther, Prism, Aurora, Particles, Galaxy, Threads, and more).

Components that need extra packages (postprocessing, @react-three/fiber, gsap,
face-api.js) list them in `manifest.json`. Install any component's deps with:

```bash
scripts/add-background.sh <Name>          # e.g. Hyperspeed, Dither, DotGrid
```

`manifest.json` is the source of truth for every component's files and deps.
EOF

  # Pre-install the common WebGL runtimes so the popular backgrounds work out of the box.
  (
    cd "$web" || exit 1
    if [ "$pm" = "pnpm" ]; then
      pnpm add three ogl >/dev/null 2>&1 || true
    else
      npm install three ogl >/dev/null 2>&1 || true
    fi
  )
}

# Resolve the kit root from a script that sourced this lib.
ws_kit_dir() {
  cd "$(dirname "${BASH_SOURCE[1]}")/.." && pwd
}
