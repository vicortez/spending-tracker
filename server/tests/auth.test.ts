import jwt from 'jsonwebtoken'
import request from 'supertest'
import { describe, expect, it, vi } from 'vitest'
import { createApp } from '../src/app.js'
import type { AuthResult, AuthService } from '../src/auth/auth.service.js'
import { HttpError } from '../src/errors/http-error.js'

const publicUser = {
  id: '550e8400-e29b-41d4-a716-446655440000',
  email: 'user@example.com',
  username: 'testuser',
  firstName: 'Test',
  lastName: 'User',
  role: 'USER',
  createdAt: new Date('2024-01-01T00:00:00.000Z'),
  updatedAt: new Date('2024-01-01T00:00:00.000Z'),
}

const authResult: AuthResult = {
  token: 'signed-token',
  user: publicUser,
}

function createMockAuthService(overrides: Partial<AuthService> = {}): AuthService {
  return {
    signUp: vi.fn().mockResolvedValue(authResult),
    signIn: vi.fn().mockResolvedValue(authResult),
    ...overrides,
  }
}

describe('POST /api/auth/signup', () => {
  it('returns 201 with token and user on success', async () => {
    const signUp = vi.fn().mockResolvedValue(authResult)
    const app = createApp({
      enableRequestLogging: false,
      authRouterDeps: { authService: createMockAuthService({ signUp }) },
    })

    const response = await request(app).post('/api/auth/signup').send({
      email: 'user@example.com',
      username: 'testuser',
      firstName: 'Test',
      lastName: 'User',
      password: 'password123',
      signupCode: 'test-signup-code',
    })

    expect(response.status).toBe(201)
    expect(signUp).toHaveBeenCalledWith({
      email: 'user@example.com',
      username: 'testuser',
      firstName: 'Test',
      lastName: 'User',
      password: 'password123',
      signupCode: 'test-signup-code',
    })
    expect(response.body).toEqual({
      token: authResult.token,
      user: {
        ...publicUser,
        createdAt: publicUser.createdAt.toISOString(),
        updatedAt: publicUser.updatedAt.toISOString(),
      },
    })
  })

  it('returns 400 when required signup fields are blank', async () => {
    const signUp = vi.fn()
    const app = createApp({
      enableRequestLogging: false,
      authRouterDeps: { authService: createMockAuthService({ signUp }) },
    })

    const response = await request(app).post('/api/auth/signup').send({
      email: 'user@example.com',
      username: '   ',
      firstName: 'Test',
      lastName: 'User',
      password: 'password123',
      signupCode: 'test-signup-code',
    })

    expect(response.status).toBe(400)
    expect(signUp).not.toHaveBeenCalled()
    expect(response.body.error).toContain('username')
  })

  it('returns 403 for an invalid signup code', async () => {
    const app = createApp({
      enableRequestLogging: false,
      authRouterDeps: {
        authService: createMockAuthService({
          signUp: vi
            .fn()
            .mockRejectedValue(new HttpError(403, 'Invalid signup code')),
        }),
      },
    })

    const response = await request(app).post('/api/auth/signup').send({
      email: 'user@example.com',
      username: 'testuser',
      firstName: 'Test',
      lastName: 'User',
      password: 'password123',
      signupCode: 'wrong-code',
    })

    expect(response.status).toBe(403)
    expect(response.body).toEqual({ error: 'Invalid signup code' })
  })
})

describe('POST /api/auth/signin', () => {
  it('returns token and user on success', async () => {
    const signIn = vi.fn().mockResolvedValue(authResult)
    const app = createApp({
      enableRequestLogging: false,
      authRouterDeps: { authService: createMockAuthService({ signIn }) },
    })

    const response = await request(app).post('/api/auth/signin').send({
      username: 'testuser',
      password: 'password123',
    })

    expect(response.status).toBe(200)
    expect(signIn).toHaveBeenCalledWith({
      username: 'testuser',
      password: 'password123',
    })
    expect(response.body.token).toBe(authResult.token)
  })

  it('returns 400 when username or password is blank', async () => {
    const signIn = vi.fn()
    const app = createApp({
      enableRequestLogging: false,
      authRouterDeps: { authService: createMockAuthService({ signIn }) },
    })

    const response = await request(app).post('/api/auth/signin').send({
      username: ' ',
      password: 'password123',
    })

    expect(response.status).toBe(400)
    expect(signIn).not.toHaveBeenCalled()
    expect(response.body.error).toContain('username')
  })

  it('returns 401 for invalid credentials', async () => {
    const app = createApp({
      enableRequestLogging: false,
      authRouterDeps: {
        authService: createMockAuthService({
          signIn: vi
            .fn()
            .mockRejectedValue(new HttpError(401, 'Invalid username or password')),
        }),
      },
    })

    const response = await request(app).post('/api/auth/signin').send({
      username: 'testuser',
      password: 'wrong-password',
    })

    expect(response.status).toBe(401)
    expect(response.body).toEqual({ error: 'Invalid username or password' })
  })
})

describe('JWT issuance', () => {
  it('issues a token that expires according to JWT_EXPIRES_IN', async () => {
    vi.spyOn(await import('../src/auth/password.js'), 'hashPassword').mockResolvedValue(
      'hashed',
    )
    const { createAuthService } = await import('../src/auth/auth.service.js')
    const { env } = await import('../src/config/env.js')

    const authService = createAuthService({
      create: vi.fn().mockResolvedValue({
        id: publicUser.id,
        email: publicUser.email,
        username: publicUser.username,
        passwordHash: 'hashed',
        role: 'USER',
        createdAt: publicUser.createdAt,
        updatedAt: publicUser.updatedAt,
      }),
      findByUsername: vi.fn(),
    })

    const result = await authService.signUp({
      email: publicUser.email,
      username: publicUser.username,
      firstName: publicUser.firstName,
      lastName: publicUser.lastName,
      password: 'password123',
      signupCode: 'test-signup-code',
    })

    const decoded = jwt.verify(result.token, env.jwtSecret) as jwt.JwtPayload
    const ttlSeconds = (decoded.exp ?? 0) - (decoded.iat ?? 0)

    expect(ttlSeconds).toBe(24 * 60 * 60)
    expect(decoded.sub).toBe(publicUser.id)
  })
})
