import { z } from 'zod'

export const nonBlankString = z
  .string()
  .transform((value) => value.trim())
  .refine((value) => value.length > 0, { message: 'Must not be blank' })
