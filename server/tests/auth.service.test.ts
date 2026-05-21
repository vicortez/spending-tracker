import { describe, expect, it, vi } from 'vitest'
import { Prisma } from '../src/generated/prisma/client.js'
import { createAuthService } from '../src/auth/auth.service.js'
import type { UserRepository } from '../src/external/persistence/user.repository.js'
import * as password from '../src/auth/password.js'

const storedUser = {
  id: '550e8400-e29b-41d4-a716-446655440000',
  email: 'user@example.com',
  username: 'testuser',
  firstName: 'Test',
  lastName: 'User',
  passwordHash: 'hashed-password',
  role: 'USER' as const,
  createdAt: new Date('2024-01-01T00:00:00.000Z'),
  updatedAt: new Date('2024-01-01T00:00:00.000Z'),
}

function createRepository(overrides: Partial<UserRepository> = {}): UserRepository {
  return {
    create: vi.fn().mockResolvedValue(storedUser),
    findByUsername: vi.fn().mockResolvedValue(storedUser),
    ...overrides,
  }
}

describe('createAuthService', () => {
  it('rejects signup when the signup code is invalid', async () => {
    const authService = createAuthService(createRepository())

    await expect(
      authService.signUp({
        email: 'user@example.com',
        username: 'testuser',
        firstName: 'Test',
        lastName: 'User',
        password: 'password123',
        signupCode: 'invalid-code',
      }),
    ).rejects.toMatchObject({ status: 403, message: 'Invalid signup code' })
  })

  it('creates a user and returns a token on valid signup', async () => {
    vi.spyOn(password, 'hashPassword').mockResolvedValue('hashed-password')
    const create = vi.fn().mockResolvedValue(storedUser)
    const authService = createAuthService(createRepository({ create }))

    const result = await authService.signUp({
      email: 'user@example.com',
      username: 'testuser',
      firstName: 'Test',
      lastName: 'User',
      password: 'password123',
      signupCode: 'test-signup-code',
    })

    expect(create).toHaveBeenCalledWith({
      email: 'user@example.com',
      username: 'testuser',
      firstName: 'Test',
      lastName: 'User',
      passwordHash: 'hashed-password',
    })
    expect(result.token).toBeTypeOf('string')
    expect(result.user).not.toHaveProperty('passwordHash')
  })

  it('returns 409 when email or username already exists', async () => {
    vi.spyOn(password, 'hashPassword').mockResolvedValue('hashed-password')
    const create = vi
      .fn()
      .mockRejectedValue(
        new Prisma.PrismaClientKnownRequestError('unique violation', {
          code: 'P2002',
          clientVersion: '7.8.0',
        }),
      )
    const authService = createAuthService(createRepository({ create }))

    await expect(
      authService.signUp({
        email: 'user@example.com',
        username: 'testuser',
        firstName: 'Test',
        lastName: 'User',
        password: 'password123',
        signupCode: 'test-signup-code',
      }),
    ).rejects.toMatchObject({
      status: 409,
      message: 'Email or username already in use',
    })
  })

  it('returns 401 when credentials are invalid', async () => {
    vi.spyOn(password, 'verifyPassword').mockResolvedValue(false)
    const authService = createAuthService(
      createRepository({
        findByUsername: vi.fn().mockResolvedValue(storedUser),
      }),
    )

    await expect(
      authService.signIn({
        username: 'testuser',
        password: 'wrong-password',
      }),
    ).rejects.toMatchObject({
      status: 401,
      message: 'Invalid username or password',
    })
  })
})
