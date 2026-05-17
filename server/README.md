# Spending Tracker API

TypeScript Express API for the spending tracker mobile app.

## Scripts

| Command         | Description                        |
| --------------- | ---------------------------------- |
| `npm run dev`   | Run with hot reload                |
| `npm run build` | Generate Prisma client and compile |
| `npm start`     | Run compiled production build      |
| `npm test`      | Run tests                          |
| `npm run lint`  | Lint source and tests              |

Copy `.env.example` to `.env` for local development. Set `DATABASE_URL` before using Prisma and `ALLOWED_ORIGINS` (comma-separated full origins, e.g. `http://localhost:3000`) for CORS.

## Dependencies

| Package              | Role                                            |
| -------------------- | ----------------------------------------------- |
| `express`            | HTTP server and routing                         |
| `dotenv`             | Load environment variables from `.env`          |
| `cross-env`          | Cross-plat commands like Seting env vars in npm |
| `cookie-parser`      | Parse cookies (e.g. auth tokens)                |
| `jsonwebtoken`       | Sign and verify JWTs                            |
| `morgan`             | HTTP request logging                            |
| `multer`             | Multipart uploads                               |
| `@prisma/client`     | PostgreSQL ORM client                           |
| `@prisma/adapter-pg` | Prisma 7 driver adapter for PostgreSQL          |
| `pg`                 | Node PostgreSQL driver (used by the adapter)    |

## Dev dependencies

| Package             | Role                                              |
| ------------------- | ------------------------------------------------- |
| `typescript`        | Type checking and compile                         |
| `tsx`               | Run TypeScript in development                     |
| `prisma`            | Schema, migrations, and client generation (dev)   |
| `vitest`            | Unit and integration tests                        |
| `supertest`         | HTTP assertions against the app without listening |
| `eslint`            | Linting                                           |
| `typescript-eslint` | TypeScript rules for ESLint                       |
| `@types/*`          | Types for packages that do not ship their own     |
