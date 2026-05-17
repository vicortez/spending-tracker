import { env } from '#src/config/env.js'
import { isDatabaseError, logDatabaseError } from '#src/external/persistence/database-error.js'
import type { ErrorRequestHandler } from 'express'

export const errorHandler: ErrorRequestHandler = async (err, _req, res, _next) => {
  const status = err.status ?? 500
  const message =
    status === 500 && env.isProduction ? 'Internal server error' : err.message

  if (isDatabaseError(err)) {
    await logDatabaseError(err)
  } else if (!env.isProduction) {
    console.error(err)
  }

  res.status(status).json({ error: message })
}
