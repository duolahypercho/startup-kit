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
  local backup="backup/pre-monorepo-$(date -u +%Y%m%d%H%M%S)"
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
    "skipLibCheck": true,
    "declaration": true,
    "composite": true
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
  cat > packages/shared/package.json <<'EOF'
{
  "name": "@repo/shared",
  "version": "0.0.0",
  "private": true,
  "type": "module",
  "main": "./src/index.ts",
  "types": "./src/index.ts",
  "scripts": { "lint": "echo \"no lint\"", "typecheck": "tsc --noEmit" },
  "dependencies": { "zod": "^3.23.0" },
  "devDependencies": { "typescript": "^5.5.0" }
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

  cat > apps/api/Dockerfile <<'EOF'
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
import { checkHealth } from "../services/HealthService";

export const getHealth = async (_req: Request, res: Response) => {
  try {
    const data = await checkHealth();
    return res.status(200).json({ success: true, status: 200, code: "OK", data });
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
  echo "  + apps/api (layered Express + TypeScript)"
}

# Resolve the kit root from a script that sourced this lib.
ws_kit_dir() {
  cd "$(dirname "${BASH_SOURCE[1]}")/.." && pwd
}
