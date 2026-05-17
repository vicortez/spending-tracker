import { describe, expect, it } from "vitest";
import request from "supertest";
import { isOriginAllowed } from "../src/config/cors.js";
import { createApp } from "../src/app.js";

const allowedOrigins = [
  "http://localhost:3000",
  "http://127.0.0.1:3000",
] as const;

describe("isOriginAllowed", () => {
  it("allows origins listed in ALLOWED_ORIGINS", () => {
    expect(isOriginAllowed("http://localhost:3000", allowedOrigins)).toBe(
      true,
    );
    expect(isOriginAllowed("http://127.0.0.1:3000", allowedOrigins)).toBe(
      true,
    );
  });

  it("rejects origins not in the list", () => {
    expect(isOriginAllowed("https://evil.example", allowedOrigins)).toBe(
      false,
    );
    expect(isOriginAllowed("http://localhost:9999", allowedOrigins)).toBe(
      false,
    );
  });

  it("allows requests without an Origin header", () => {
    expect(isOriginAllowed(undefined, allowedOrigins)).toBe(true);
  });
});

describe("corsMiddleware", () => {
  it("reflects allowed origins on API responses", async () => {
    const app = createApp({ enableRequestLogging: false });
    const origin = "http://localhost:3000";

    const response = await request(app)
      .get("/api/ping")
      .set("Origin", origin);

    expect(response.headers["access-control-allow-origin"]).toBe(origin);
    expect(response.headers["access-control-allow-credentials"]).toBe("true");
  });

  it("handles preflight OPTIONS requests", async () => {
    const app = createApp({ enableRequestLogging: false });
    const origin = "http://localhost:3000";

    const response = await request(app)
      .options("/api/ping")
      .set("Origin", origin);

    expect(response.status).toBe(204);
    expect(response.headers["access-control-allow-origin"]).toBe(origin);
    expect(response.headers["access-control-allow-methods"]).toContain("GET");
  });

  it("omits CORS headers for disallowed origins", async () => {
    const app = createApp({ enableRequestLogging: false });

    const response = await request(app)
      .get("/api/ping")
      .set("Origin", "https://evil.example");

    expect(response.headers["access-control-allow-origin"]).toBeUndefined();
  });
});
