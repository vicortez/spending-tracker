import type { ErrorRequestHandler } from "express";
import { env } from "../config/env.js";

export const errorHandler: ErrorRequestHandler = (err, _req, res, _next) => {
  const status = err.status ?? 500;
  const message =
    status === 500 && env.isProduction ? "Internal server error" : err.message;

  if (!env.isProduction) {
    console.error(err);
  }

  res.status(status).json({ error: message });
};
