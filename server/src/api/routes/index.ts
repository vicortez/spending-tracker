import { Router } from 'express'
import { createTestRouter } from './test.routes.js'

export function createApiRouter(): Router {
  const router = Router()

  router.use('/test', createTestRouter())

  return router
}
