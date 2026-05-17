import { env } from '#src/config/env.js'
import { PrismaClient } from '#src/generated/prisma/client.js'
import { PrismaPg } from '@prisma/adapter-pg'

export function createPrismaClient(connectionString: string = env.databaseUrl ?? ''): PrismaClient {
  if (!connectionString) {
    throw new Error('DATABASE_URL is required to create a Prisma client')
  }

  const adapter = new PrismaPg(
    { connectionString },
    {
      schema: parseSchemaFromDatabaseUrl(connectionString),
    },
  )
  return new PrismaClient({ adapter })
}

const globalForPrisma = globalThis as unknown as { prisma?: PrismaClient }

export function getPrisma(): PrismaClient {
  if (!globalForPrisma.prisma) {
    globalForPrisma.prisma = createPrismaClient()
  }
  return globalForPrisma.prisma
}

export async function pingPostgres(client: PrismaClient = getPrisma()): Promise<void> {
  await client.$queryRaw`SELECT 1`
}

export function parseSchemaFromDatabaseUrl(databaseUrl: string, fallback = 'public'): string {
  try {
    return new URL(databaseUrl).searchParams.get('schema') ?? fallback
  } catch {
    return fallback
  }
}
