#!/usr/bin/env bash
set -euo pipefail

# Scaffolds a pnpm + Turborepo monorepo wired to the startup-kit theme:
#   apps/web      Next.js frontend (theme baseline)        -> deploy to Vercel
#   apps/api      Express + TypeScript layered API          -> deploy to Koyeb
#   packages/shared  shared types + zod schemas (web + api)
#
# Frontend and backend live in one repo and deploy to different hosts.
# See references/monorepo.md.
#
# Usage: scripts/create-monorepo.sh <product-name>

PRODUCT_NAME="${1:-startup-product}"
KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v pnpm >/dev/null 2>&1; then
  echo "pnpm is required. Install it with: npm i -g pnpm"
  exit 1
fi
if ! command -v npx >/dev/null 2>&1; then
  echo "npx is required."
  exit 1
fi

if [ -e "$PRODUCT_NAME" ]; then
  echo "Path '$PRODUCT_NAME' already exists. Choose a new name or remove it."
  exit 1
fi

echo "Creating monorepo '$PRODUCT_NAME'..."
mkdir -p "$PRODUCT_NAME"/{apps,packages}
cd "$PRODUCT_NAME"

# ---------------------------------------------------------------------------
# Workspace root
# ---------------------------------------------------------------------------
cat > package.json <<EOF
{
  "name": "$PRODUCT_NAME",
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

cat > pnpm-workspace.yaml <<'EOF'
packages:
  - "apps/*"
  - "packages/*"
EOF

cat > turbo.json <<'EOF'
{
  "$schema": "https://turbo.build/schema.json",
  "tasks": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": [".next/**", "!.next/cache/**", "dist/**"]
    },
    "dev": {
      "cache": false,
      "persistent": true
    },
    "lint": {},
    "typecheck": {
      "dependsOn": ["^build"]
    }
  }
}
EOF

cat > tsconfig.base.json <<'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "Bundler",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "declaration": true,
    "composite": true
  }
}
EOF

cat > .gitignore <<'EOF'
node_modules/
.next/
dist/
.turbo/
.env
.env.*
!.env.example
.vercel
.DS_Store
EOF

cat > .env.example <<'EOF'
# Frontend (public — safe to expose to the browser)
NEXT_PUBLIC_API_URL=http://localhost:9979
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=

# Backend (server-only secrets — never commit real values)
DATABASE_URL=
SUPABASE_SERVICE_ROLE_KEY=
JWT_TOKEN=
EOF

# ---------------------------------------------------------------------------
# packages/shared — the contract imported by both apps
# ---------------------------------------------------------------------------
mkdir -p packages/shared/src
cat > packages/shared/package.json <<'EOF'
{
  "name": "@repo/shared",
  "version": "0.0.0",
  "private": true,
  "type": "module",
  "main": "./src/index.ts",
  "types": "./src/index.ts",
  "scripts": {
    "lint": "echo \"no lint\"",
    "typecheck": "tsc --noEmit"
  },
  "dependencies": {
    "zod": "^3.23.0"
  },
  "devDependencies": {
    "typescript": "^5.5.0"
  }
}
EOF

cat > packages/shared/tsconfig.json <<'EOF'
{
  "extends": "../../tsconfig.base.json",
  "compilerOptions": { "outDir": "dist", "rootDir": "src" },
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

// Standard JSON envelope returned by every API endpoint.
export type ApiResponse<T> =
  | { success: true; status: number; code: string; message?: string; data: T }
  | { success: false; status: number; code: string; error: string };
EOF

# ---------------------------------------------------------------------------
# apps/api — Express + TypeScript, layered (see references/backend.md)
# ---------------------------------------------------------------------------
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
# Comma-separated list of allowed origins (your Vercel domains).
CORS_ORIGINS=http://localhost:3000
EOF

cat > apps/api/Dockerfile <<'EOF'
# Build the api workspace from the monorepo root context.
FROM node:20-slim AS build
WORKDIR /app
RUN corepack enable
COPY . .
RUN pnpm install --frozen-lockfile
RUN pnpm --filter api build

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

function required(name: string): string {
  const value = process.env[name];
  if (!value) throw new Error(`Missing required env var: ${name}`);
  return value;
}

export const config = {
  port: Number(process.env.PORT ?? 9979),
  corsOrigins: (process.env.CORS_ORIGINS ?? "http://localhost:3000")
    .split(",")
    .map((o) => o.trim()),
  // Fail fast on real deploys; uncomment as you wire the database.
  // databaseUrl: required("DATABASE_URL"),
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
import { checkHealth } from "../services/HealthService";

export const getHealth = async (_req: Request, res: Response) => {
  try {
    const data = await checkHealth();
    return res
      .status(200)
      .json({ success: true, status: 200, code: "OK", data });
  } catch (e: any) {
    return res.status(500).json({
      success: false,
      status: 500,
      code: "INTERNAL_ERROR",
      error: e.message,
    });
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

# ---------------------------------------------------------------------------
# apps/web — Next.js with the startup-kit theme
# ---------------------------------------------------------------------------
echo ""
echo "Scaffolding apps/web (Next.js + Tailwind + shadcn/ui)..."
npx create-next-app@latest apps/web \
  --typescript --tailwind --eslint --app --src-dir --import-alias "@/*" --no-turbopack

# Theme: replace the generated stylesheet with the kit baseline.
cp "$KIT_DIR/assets/tailwind/globals.css" "apps/web/src/app/globals.css"
mkdir -p apps/web/src/styles
cp "$KIT_DIR/assets/theme/default-theme.css" "apps/web/src/styles/default-theme.css"
cp "$KIT_DIR/assets/theme/dark-theme.css" "apps/web/src/styles/dark-theme.css"

# shadcn/ui init using the kit config.
cp "$KIT_DIR/assets/shadcn/components.tailwind-v3.json" "apps/web/components.json"
(
  cd apps/web
  npx shadcn@latest add button input label select textarea checkbox switch tabs \
    dialog dropdown-menu popover tooltip sheet table form card alert skeleton sonner
)

# Make apps/web depend on the shared package and the theme deps.
(
  cd apps/web
  npm pkg set dependencies.@repo/shared="workspace:*"
  npm pkg set name="web"
  npm pkg set scripts.typecheck="tsc --noEmit"
)

# ---------------------------------------------------------------------------
# Install everything through the workspace.
# ---------------------------------------------------------------------------
echo ""
echo "Installing workspace dependencies with pnpm..."
pnpm install

echo ""
echo "Created monorepo '$PRODUCT_NAME'."
echo ""
echo "  apps/web        Next.js frontend   -> deploy to Vercel (Root Directory: apps/web)"
echo "  apps/api        Express API        -> deploy to Koyeb  (build context: apps/api)"
echo "  packages/shared shared types + zod schemas"
echo ""
echo "Next:"
echo "  1. cd $PRODUCT_NAME && pnpm dev"
echo "  2. Install platform CLIs: scripts/install-deploy-clis.sh"
echo "  3. Read references/monorepo.md to wire Vercel, Supabase, and Koyeb."
