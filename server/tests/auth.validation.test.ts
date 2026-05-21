import { describe, expect, it } from 'vitest'
import { signInBodySchema, signUpBodySchema } from '../src/auth/auth.validation.js'

describe('signInBodySchema', () => {
  it('accepts non-blank username and password', () => {
    const result = signInBodySchema.safeParse({
      username: 'testuser',
      password: 'password123',
    })

    expect(result.success).toBe(true)
    if (result.success) {
      expect(result.data).toEqual({
        username: 'testuser',
        password: 'password123',
      })
    }
  })

  it('rejects blank and whitespace-only values', () => {
    const result = signInBodySchema.safeParse({
      username: '   ',
      password: '',
    })

    expect(result.success).toBe(false)
  })

  it('rejects missing fields', () => {
    const result = signInBodySchema.safeParse({ username: 'testuser' })

    expect(result.success).toBe(false)
  })
})

describe('signUpBodySchema', () => {
  it('accepts non-blank signup fields', () => {
    const result = signUpBodySchema.safeParse({
      email: 'user@example.com',
      username: 'testuser',
      firstName: 'Test',
      lastName: 'User',
      password: 'password123',
      signupCode: 'test-signup-code',
    })

    expect(result.success).toBe(true)
  })

  it('rejects blank signup fields', () => {
    const result = signUpBodySchema.safeParse({
      email: 'user@example.com',
      username: 'testuser',
      firstName: ' ',
      lastName: 'User',
      password: 'password123',
      signupCode: 'test-signup-code',
    })

    expect(result.success).toBe(false)
  })
})
