import 'dotenv/config'

const nodeEnv = process.env.NODE_ENV ?? 'development'

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
  isProduction: nodeEnv === 'production',
  isTest: nodeEnv === 'test',
} as const

console.log(env)
