import type { RequestHandler } from 'express'
import { Router } from 'express'
import { createAuthService, type AuthResult, type AuthService } from '../../auth/auth.service.js'
import { signInBodySchema, signUpBodySchema } from '../../auth/auth.validation.js'
import { getPrisma } from '../../external/persistence/client.js'
import { createUserRepository } from '../../external/persistence/user.repository.js'
import { parseRequestBody } from '../validation/parse-request-body.js'

export type AuthRouterDeps = {
  authService?: AuthService
}

export function createAuthRouter(deps: AuthRouterDeps = {}): Router {
  const router = Router()
  const authService = deps.authService ?? createAuthService(createUserRepository(getPrisma()))

  const postSignUp: RequestHandler<never, AuthResult> = async (req, res, next) => {
    try {
      const body = parseRequestBody(signUpBodySchema, req.body)
      const result = await authService.signUp(body)
      res.status(201).json(result)
    } catch (error) {
      next(error)
    }
  }

  const postSignIn: RequestHandler<never, AuthResult> = async (req, res, next) => {
    try {
      console.log(req.body)
      const body = parseRequestBody(signInBodySchema, req.body)
      const result = await authService.signIn(body)
      res.json(result)
    } catch (error) {
      next(error)
    }
  }

  router.post('/signup', postSignUp)
  router.post('/signin', postSignIn)

  return router
}
