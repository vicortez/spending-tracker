import { z } from 'zod'
import { nonBlankString } from '../api/validation/fields.js'

export const signInBodySchema = z.object({
  username: nonBlankString,
  password: nonBlankString,
})

export const signUpBodySchema = z.object({
  email: nonBlankString,
  username: nonBlankString,
  firstName: nonBlankString,
  lastName: nonBlankString,
  password: nonBlankString,
  signupCode: nonBlankString,
})

export type SignInBody = z.infer<typeof signInBodySchema>
export type SignUpBody = z.infer<typeof signUpBodySchema>

export function formatValidationError(error: z.ZodError): string {
  return error.issues
    .map((issue) => {
      const field = issue.path.join('.') || 'body'
      return `${field}: ${issue.message}`
    })
    .join('; ')
}
