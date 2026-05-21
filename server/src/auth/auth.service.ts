import type { User } from '#src/generated/prisma/client.js'
import { Prisma } from '#src/generated/prisma/client.js'
import { env } from '../config/env.js'
import { HttpError } from '../errors/http-error.js'
import type { UserRepository } from '../external/persistence/user.repository.js'
import type { SignInBody, SignUpBody } from './auth.validation.js'
import { signAccessToken } from './jwt.js'
import { hashPassword, verifyPassword } from './password.js'

export type SignUpInput = SignUpBody
export type SignInInput = SignInBody

export type PublicUser = {
  id: string
  email: string
  username: string
  firstName: string
  lastName: string
  role: string
  createdAt: Date
  updatedAt: Date
}

export type AuthResult = {
  token: string
  user: PublicUser
}

export type AuthService = {
  signUp(input: SignUpInput): Promise<AuthResult>
  signIn(input: SignInInput): Promise<AuthResult>
}

export function toPublicUser(user: User): PublicUser {
  return {
    id: user.id,
    email: user.email,
    username: user.username,
    firstName: user.firstName,
    lastName: user.lastName,
    role: user.role,
    createdAt: user.createdAt,
    updatedAt: user.updatedAt,
  }
}

function issueAuthResult(user: User): AuthResult {
  return {
    token: signAccessToken({
      sub: user.id,
      email: user.email,
      role: user.role,
    }),
    user: toPublicUser(user),
  }
}

function isUniqueConstraintError(error: unknown): boolean {
  return error instanceof Prisma.PrismaClientKnownRequestError && error.code === 'P2002'
}

export function createAuthService(userRepository: UserRepository): AuthService {
  return {
    async signUp(input) {
      if (!env.masterSignupCodes.includes(input.signupCode)) {
        throw new HttpError(403, 'Invalid signup code')
      }

      const passwordHash = await hashPassword(input.password)

      try {
        const user = await userRepository.create({
          email: input.email,
          username: input.username,
          firstName: input.firstName,
          lastName: input.lastName,
          passwordHash,
        })
        return issueAuthResult(user)
      } catch (error) {
        if (isUniqueConstraintError(error)) {
          throw new HttpError(409, 'Email or username already in use')
        }
        throw error
      }
    },

    async signIn(input) {
      const user = await userRepository.findByUsername(input.username)

      if (!user) {
        throw new HttpError(401, 'Invalid username or password')
      }

      const passwordMatches = await verifyPassword(input.password, user.passwordHash)

      if (!passwordMatches) {
        throw new HttpError(401, 'Invalid username or password')
      }

      return issueAuthResult(user)
    },
  }
}
