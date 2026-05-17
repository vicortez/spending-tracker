import { Router } from 'express'
import { createTestRouter, type TestRouterDeps } from './test.routes.js'

export type ApiRouterOptions = {
  testRouterDeps?: TestRouterDeps
}

export function createApiRouter(options: ApiRouterOptions = {}): Router {
  const router = Router()

  router.use('/test', createTestRouter(options.testRouterDeps))

  return router
}
