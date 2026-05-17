import cookieParser from 'cookie-parser'
import express, { type Express } from 'express'
import morgan from 'morgan'
import { corsMiddleware } from './api/middleware/cors.js'
import { errorHandler } from './api/middleware/error-handler.js'
import { notFoundHandler } from './api/middleware/not-found.js'
import { createApiRouter } from './api/routes/index.js'
import { env } from './config/env.js'

export type CreateAppOptions = {
  enableRequestLogging?: boolean
}

export function createApp(options: CreateAppOptions = {}): Express {
  const { enableRequestLogging = !env.isTest } = options
  const app = express()

  app.disable('x-powered-by')
  app.set('trust proxy', 1)
  app.use(corsMiddleware)

  if (enableRequestLogging) {
    app.use(morgan(env.isProduction ? 'combined' : 'dev'))
  }

  app.use(express.json({ limit: '1mb' }))
  app.use(express.urlencoded({ extended: true }))
  app.use(cookieParser())

  app.use('/api', createApiRouter())

  app.use(notFoundHandler)
  app.use(errorHandler)

  return app
}
