# Backend

Build the backend as a Node.js + TypeScript + Express service with a strict layered architecture: a request flows from a router, to a controller, to a service, to a model, and the response flows back the same way. Each layer has one job. Do not skip layers or mix responsibilities.

This is the structure used in production by `Hypercho_UserManager`. Copy the shape, not the domain.

## Stack

- Runtime: Node.js with TypeScript (`ts-node` + `nodemon` in dev, `tsc` build to `dist/`).
- HTTP: Express 4.
- Database: MongoDB via Mongoose 8.
- Auth: JWT (`jsonwebtoken`), passwords hashed with `bcrypt`.
- Cross-cutting: `cors`, `express-rate-limit`, `body-parser`, `dotenv`, `winston` for logs.

## File Structure

Keep one folder per layer under `src/`. One file per domain inside each layer, named after the domain.

```
backend/
  src/
    index.ts            # Entry: env, middleware, mount routers, start server
    Routes/             # HTTP routing only — path -> middleware -> controller
      index.ts          # Barrel: re-export every router
      UserRouter.ts
      ProductRouter.ts
    controllers/        # HTTP layer — parse req, call service, shape res
      UserController.ts
      ProductController.ts
    services/           # Business logic — talks to models, returns plain objects
      UserManager.ts
      ProductListing.ts
    models/             # Mongoose schemas + types
      index.ts          # Barrel: re-export every model
      Users.ts
      ProductSchema.ts
    Middleware/         # auth, error handler, rate limit, request guards
      auth.middleware.ts
      error.middleware.ts
    db/                 # Database connection lifecycle
      Mongodb.ts
    lib/                # Third-party SDK clients (OpenAI, S3, Stripe)
      openai.ts
    utils/              # Pure, reusable helpers (token, generic CRUD, dates)
      CRUD.ts
      token.ts
    config/             # Typed config object with defaults
      index.ts
    Logs/               # Logger setup
      Customlog.ts
    Cron/               # Scheduled jobs
      index.ts
    types/              # Shared TypeScript types
  .env                  # Secrets and config — never commit
  .gitignore
  Dockerfile
  package.json
  tsconfig.json
```

## The Request Flow

The whole point of the structure is this one-directional flow. Every feature follows it.

```
HTTP request
  → Router        (matches path + method, runs middleware)
  → Middleware    (auth, rate limit, validation — may short-circuit)
  → Controller    (reads req, calls a service, writes res)
  → Service       (business logic, orchestration)
  → Model         (Mongoose query against MongoDB)
  ← Service       (returns a plain result object)
  ← Controller    (maps result to an HTTP status + JSON body)
HTTP response
```

Rule: controllers know about HTTP (`req`/`res`), services do not. Services know about the database, controllers do not. Keep that wall intact and the codebase stays testable.

## 1. Router

A router maps paths and methods to controller handlers and attaches middleware. It holds no logic. One router file per domain, exported as default.

```ts
// src/Routes/UserRouter.ts
import { Router } from "express";
import {
  getUserInformation,
  updateUserProfileController,
} from "../controllers/UserController";
import { authMiddleware } from "../Middleware/auth.middleware";

const r = Router();

r.get("/info", authMiddleware, getUserInformation);
r.post("/profile", authMiddleware, updateUserProfileController);

export default r;
```

Re-export every router from a barrel so the entry file stays clean:

```ts
// src/Routes/index.ts
export { default as UserRoute } from "./UserRouter";
export { default as ProductRouter } from "./ProductRouter";
```

## 2. Controller

A controller is the only layer that touches `req` and `res`. It reads input, calls one service, and maps the result to a status code and JSON body. It always wraps the call in `try/catch` and never lets an exception escape unshaped.

```ts
// src/controllers/UserController.ts
import { Request, Response } from "express";
import { updateUserProfile } from "../services/UserManager";

export const updateUserProfileController = async (
  req: Request,
  res: Response
) => {
  try {
    const userId = req.User?._id?.toString();
    if (!userId) {
      return res.status(401).json({
        success: false,
        status: 401,
        code: "UNAUTHORIZED",
        error: "User authentication required",
      });
    }

    const { username, aboutme, firstName, lastName } = req.body;
    const { success, code, message, error, data } = await updateUserProfile({
      userId,
      username,
      aboutme,
      firstName,
      lastName,
    });

    if (success) {
      return res.status(code).json({
        success: true,
        status: code,
        code: "PROFILE_UPDATED",
        message,
        data,
      });
    }

    return res.status(code).json({
      success: false,
      status: code,
      code: "UPDATE_FAILED",
      error,
    });
  } catch (e: any) {
    return res.status(500).json({
      success: false,
      status: 500,
      code: "INTERNAL_ERROR",
      error: e.message,
    });
  }
};
```

## 3. Service

A service holds the business logic. It talks to models, calls other services or `lib/` SDK clients, and returns a plain result object — never a `res`. Returning a consistent `{ success, code, message, error, data }` shape lets the controller stay a thin mapper.

```ts
// src/services/UserManager.ts
import { User } from "../models/Users";

interface UpdateProfileInput {
  userId: string;
  username?: string;
  aboutme?: string;
  firstName?: string;
  lastName?: string;
}

export const updateUserProfile = async (input: UpdateProfileInput) => {
  const { userId, username, aboutme, firstName, lastName } = input;

  const user = await User.findById(userId);
  if (!user) {
    return { success: false, code: 404, error: "User not found" };
  }

  if (username !== undefined) user.username = username;
  if (aboutme !== undefined) user.aboutme = aboutme;
  if (firstName !== undefined) user.Firstname = firstName;
  if (lastName !== undefined) user.Lastname = lastName;

  await user.save();

  return {
    success: true,
    code: 200,
    message: "Profile updated",
    data: { username: user.username, aboutme: user.aboutme },
  };
};
```

## 4. Model

A model is a Mongoose schema plus its TypeScript type. Declare the interface, build the `Schema<T>`, add indexes, and export the compiled model. Nothing else lives here.

```ts
// src/models/Users.ts
import { model, ObjectId, Schema, Types } from "mongoose";

export interface UserModel {
  _id: ObjectId;
  email: string;
  Firstname: string;
  Lastname: string;
  username: string;
  Password: string;
  Verified: boolean;
  Reg_date: Date;
}

const userSchema = new Schema<UserModel>({
  _id: { type: Schema.Types.ObjectId, default: () => new Types.ObjectId() },
  email: { type: String, required: true, lowercase: true, trim: true },
  Firstname: { type: String, required: true },
  Lastname: { type: String, default: "" },
  username: { type: String, required: true },
  Password: { type: String, default: "" },
  Verified: { type: Boolean, default: false },
  Reg_date: { type: Date, default: Date.now },
});

userSchema.index({ email: 1 }, { unique: true });

export const User = model<UserModel>("User", userSchema);
```

Re-export models from a barrel for clean imports elsewhere:

```ts
// src/models/index.ts
export { User } from "./Users";
export { default as Product } from "./ProductSchema";
```

## Middleware

Cross-cutting request concerns live in `Middleware/`. Auth verifies the token, loads the user, and attaches it to the request so downstream controllers can read `req.User`.

```ts
// src/Middleware/auth.middleware.ts
import { Request, Response, NextFunction } from "express";
import jwt from "jsonwebtoken";
import { User, UserModel } from "../models/Users";

declare global {
  namespace Express {
    interface Request {
      User?: UserModel | null;
    }
  }
}

export const authMiddleware = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader?.startsWith("Bearer ")) {
      return res.status(401).json({
        success: false,
        status: 401,
        code: "UNAUTHORIZED",
        message: "No token provided",
      });
    }

    const token = authHeader.split(" ")[1];
    const decoded = jwt.verify(token, process.env.JWT_TOKEN || "") as any;
    const userId = typeof decoded === "string" ? decoded : decoded.id;

    const user = await User.findById(userId);
    if (!user) {
      return res.status(401).json({
        success: false,
        status: 401,
        code: "USER_NOT_FOUND",
        message: "User not found",
      });
    }

    req.User = user;
    next();
  } catch {
    return res.status(401).json({
      success: false,
      status: 401,
      code: "INVALID_TOKEN",
      message: "Invalid or expired token",
    });
  }
};
```

## Database Connection

Own the connection lifecycle in `db/`. Connect before the server listens, and close on shutdown.

```ts
// src/db/Mongodb.ts
import mongoose, { connect } from "mongoose";

mongoose.set("strictQuery", false);

export const connectDB = async (url: string) => {
  if (!url) throw new Error("MongoDB URI is not provided.");
  const connection = await connect(url, {
    maxPoolSize: 10,
    serverSelectionTimeoutMS: 5000,
    socketTimeoutMS: 45000,
  });
  console.log("MongoDB connected");
  return connection;
};

export const closeDB = async () => {
  await mongoose.connection.close();
  console.log("MongoDB connection closed");
};
```

## Entry Point

`src/index.ts` wires the app: load env, apply global middleware (CORS, rate limit, body parsing), mount every router under a base path, then start. Connect to the database before listening and shut down gracefully on `SIGTERM`/`SIGINT`.

```ts
// src/index.ts
import express, { Express, Request, Response } from "express";
import bodyParser from "body-parser";
import dotenv from "dotenv";
import cors from "cors";
import rateLimit from "express-rate-limit";
import { connectDB, closeDB } from "./db/Mongodb";
import { UserRoute, ProductRouter } from "./Routes";

dotenv.config();
const PORT = process.env.PORT || 9979;
const app: Express = express();

app.use(cors({ origin: true, credentials: true }));
app.use(rateLimit({ windowMs: 60_000, max: 100 }));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

app.use("/User", UserRoute);
app.use("/Product", ProductRouter);

app.get("/", (_req: Request, res: Response) => res.send("API service"));

const start = async () => {
  try {
    await connectDB(process.env.MONGO_URI as string);
    app.listen(PORT, () => console.log(`API running on :${PORT}`));
  } catch (error: any) {
    console.error("Failed to start server:", error.message);
    process.exit(1);
  }
};

start();

const shutdown = async () => {
  await closeDB();
  process.exit(0);
};
process.on("SIGTERM", shutdown);
process.on("SIGINT", shutdown);
```

## Response Shape

Return one consistent JSON envelope from every endpoint so the frontend can handle responses uniformly.

```ts
// Success
{ "success": true, "status": 200, "code": "PROFILE_UPDATED", "message": "Profile updated", "data": { } }

// Failure
{ "success": false, "status": 404, "code": "USER_NOT_FOUND", "error": "User not found" }
```

- `success`: boolean the client checks first.
- `status`: numeric HTTP status, mirrored in the body for convenience.
- `code`: stable `SCREAMING_SNAKE_CASE` machine code the client can branch on.
- `message`/`error`: human-readable string, `message` on success, `error` on failure.
- `data`: the payload, present only on success.

## Reusable Helpers

Put generic, model-agnostic database helpers in `utils/` so domain services don't reimplement pagination or partial updates. Type them with Mongoose generics.

```ts
// src/utils/CRUD.ts
import { Model, Document, FilterQuery, UpdateQuery } from "mongoose";

export async function patch<T extends Document>(
  model: Model<T>,
  filter: FilterQuery<T>,
  update: UpdateQuery<T>
): Promise<T | null> {
  return model.findOneAndUpdate(filter, update, {
    new: true,
    runValidators: true,
  });
}
```

## package.json And tsconfig

```jsonc
// package.json (scripts)
{
  "scripts": {
    "dev": "npx nodemon ./src/index.ts",
    "build": "tsc",
    "start": "node ./dist/index.js"
  }
}
```

```jsonc
// tsconfig.json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "commonjs",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "moduleResolution": "node",
    "esModuleInterop": true,
    "skipLibCheck": true
  },
  "include": ["./src/**/*"],
  "exclude": ["./node_modules"]
}
```

## Rules

- Keep the flow one-directional: Router → Controller → Service → Model. Never call a model from a router, and never import `req`/`res` into a service.
- One file per domain per layer, named after the domain (`Product` → `ProductRouter.ts`, `ProductController.ts`, `ProductListing.ts`, `ProductSchema.ts`).
- Controllers only parse input, call a single service, and shape the response. No business logic, no direct database access.
- Services return plain result objects, never HTTP responses. They own all business logic and database access.
- Models hold only the schema, its type, and indexes.
- Wrap every controller in `try/catch` and return the standard error envelope. Never leak a stack trace or raw error to the client in production.
- Validate and authenticate in middleware, before the controller runs.
- Keep all secrets (`MONGO_URI`, `JWT_TOKEN`, API keys) in `.env`; never commit them. Validate required env vars at startup and fail fast if missing.
- Connect to the database before the server listens; close it on `SIGTERM`/`SIGINT`.
- Re-export routers and models through barrel `index.ts` files to keep imports flat.
