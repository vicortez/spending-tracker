import path from "node:path";
import { defineConfig } from "vitest/config";

export default defineConfig({
  resolve: {
    alias: {
      "#src": path.resolve(import.meta.dirname, "src"),
    },
  },
  test: {
    environment: "node",
    include: ["tests/**/*.test.ts"],
    env: {
      ALLOWED_ORIGINS: "http://localhost:3000,http://127.0.0.1:3000",
      MASTER_SIGNUP_CODES: "test-signup-code",
      JWT_SECRET: "test-jwt-secret",
      JWT_EXPIRES_IN: "24h",
    },
  },
});
