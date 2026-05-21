import 'dotenv/config'

const nodeEnv = process.env.NODE_ENV ?? 'development'

function parseCommaSeparatedList(value: string | undefined): readonly string[] {
  if (!value?.trim()) {
    return []
  }

  return value
    .split(',')
    .map((entry) => entry.trim())
    .filter((entry) => entry.length > 0)
}

function parseAllowedOrigins(value: string | undefined): readonly string[] {
  if (!value?.trim()) {
    return []
  }

  return value
    .replaceAll(' ', '')
    .split(',')
    .map((origin) => origin.trim())
    .filter((origin) => origin.length > 0)
}

export const env = {
  nodeEnv,
  port: Number(process.env.PORT ?? 3000),
  databaseUrl: process.env.DATABASE_URL,
  allowedOrigins: parseAllowedOrigins(process.env.ALLOWED_ORIGINS),
  masterSignupCodes: parseCommaSeparatedList(process.env.MASTER_SIGNUP_CODES),
  jwtSecret: process.env.JWT_SECRET ?? '',
  jwtExpiresIn: process.env.JWT_EXPIRES_IN ?? '24h',
  isProduction: nodeEnv === 'production',
  isTest: nodeEnv === 'test',
} as const
