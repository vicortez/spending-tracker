import type { z } from 'zod'
import { HttpError } from '../../errors/http-error.js'
import { formatValidationError } from '../../auth/auth.validation.js'

export function parseRequestBody<T>(schema: z.ZodType<T>, body: unknown): T {
  const result = schema.safeParse(body)

  if (!result.success) {
    throw new HttpError(400, formatValidationError(result.error))
  }

  return result.data
}
