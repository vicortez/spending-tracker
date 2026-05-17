import type { RequestHandler } from "express";
import { isOriginAllowed } from "../config/cors.js";
import { env } from "../config/env.js";

const allowedMethods = "GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS";
const allowedHeaders = "Content-Type,Authorization";

export const corsMiddleware: RequestHandler = (req, res, next) => {
  const origin = req.headers.origin;

  if (origin && isOriginAllowed(origin, env.allowedOrigins)) {
    res.setHeader("Access-Control-Allow-Origin", origin);
    res.setHeader("Vary", "Origin");
    res.setHeader("Access-Control-Allow-Credentials", "true");
  }

  if (req.method === "OPTIONS") {
    res.setHeader("Access-Control-Allow-Methods", allowedMethods);
    res.setHeader("Access-Control-Allow-Headers", allowedHeaders);
    res.status(204).end();
    return;
  }

  next();
};
