import { Router } from 'express'
import { createAuthRouter, type AuthRouterDeps } from './auth.routes.js'
import { createTestRouter, type TestRouterDeps } from './test.routes.js'

export type ApiRouterOptions = {
  testRouterDeps?: TestRouterDeps
  authRouterDeps?: AuthRouterDeps
}

export function createApiRouter(options: ApiRouterOptions = {}): Router {
  const router = Router()

  router.use('/auth', createAuthRouter(options.authRouterDeps))
  router.use('/test', createTestRouter(options.testRouterDeps))

  return router
}
