import { env } from '../../config/env.js'
import { Prisma, type PrismaClient } from '../../generated/prisma/client.js'
import { getPrisma, parseSchemaFromDatabaseUrl } from './client.js'

export type DatabaseCatalog = {
  database: string
  schema: string
  tables: string[]
}

type DatabaseNameRow = { database: string }
type TableNameRow = { table_name: string }

export function isPrismaClientError(error: unknown): error is Prisma.PrismaClientKnownRequestError {
  return error instanceof Prisma.PrismaClientKnownRequestError
}

export function isDatabaseError(error: unknown): boolean {
  return isPrismaClientError(error)
}

export async function getDatabaseCatalog(
  client: PrismaClient,
  schema = parseSchemaFromDatabaseUrl(env.databaseUrl ?? ''),
): Promise<DatabaseCatalog> {
  const databaseRows = await client.$queryRaw<DatabaseNameRow[]>`
    SELECT current_database()::text AS database
  `
  const tableRows = await client.$queryRaw<TableNameRow[]>`
    SELECT table_name::text AS table_name
    FROM information_schema.tables
    WHERE table_schema = ${schema}
      AND table_type = 'BASE TABLE'
    ORDER BY table_name
  `

  return {
    database: databaseRows[0]?.database ?? 'unknown',
    schema,
    tables: tableRows.map((row) => row.table_name),
  }
}

function getErrorMessage(error: unknown): string {
  if (error instanceof Error) {
    return error.message
  }
  return String(error)
}

export async function logDatabaseError(
  error: unknown,
  client: PrismaClient = getPrisma(),
): Promise<void> {
  console.error(`Database request failed: ${getErrorMessage(error)}`)

  if (isPrismaClientError(error)) {
    console.error(`Prisma error code: ${error.code}`)
    if (error.meta) {
      console.error('Prisma meta:', error.meta)
    }
  }

  try {
    const catalog = await getDatabaseCatalog(client)
    console.error('Database context:', {
      database: catalog.database,
      schema: catalog.schema,
      tables: catalog.tables,
    })
  } catch (catalogError) {
    console.error('Database context unavailable:', getErrorMessage(catalogError))
  }
}
