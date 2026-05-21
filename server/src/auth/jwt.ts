import jwt, { type SignOptions } from 'jsonwebtoken'
import { env } from '../config/env.js'

export type AccessTokenPayload = {
  sub: string
  email: string
  role: string
}

export function signAccessToken(payload: AccessTokenPayload): string {
  if (!env.jwtSecret) {
    throw new Error('JWT_SECRET is required to sign access tokens')
  }

  return jwt.sign(payload, env.jwtSecret, {
    expiresIn: env.jwtExpiresIn as SignOptions['expiresIn'],
  })
}
