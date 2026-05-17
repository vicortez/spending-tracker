import { describe, expect, it, vi } from 'vitest'
import { Prisma } from '../../src/generated/prisma/client.js'
import {
  getDatabaseCatalog,
  isDatabaseError,
  isPrismaClientError,
  logDatabaseError,
  parseSchemaFromDatabaseUrl,
} from '../../src/external/persistence/database-error.js'
import type { PrismaClient } from '../../src/generated/prisma/client.js'

describe('parseSchemaFromDatabaseUrl', () => {
  it('reads the schema query parameter', () => {
    expect(
      parseSchemaFromDatabaseUrl(
        'postgresql://user:pass@localhost:5432/mydb?schema=public',
      ),
    ).toBe('public')
  })

  it('falls back to public when the schema param is missing', () => {
    expect(
      parseSchemaFromDatabaseUrl('postgresql://user:pass@localhost:5432/mydb'),
    ).toBe('public')
  })
})

describe('isPrismaClientError', () => {
  it('detects Prisma known request errors', () => {
    const error = new Prisma.PrismaClientKnownRequestError('table missing', {
      code: 'P2021',
      clientVersion: '7.8.0',
    })

    expect(isPrismaClientError(error)).toBe(true)
    expect(isDatabaseError(error)).toBe(true)
  })

  it('rejects non-Prisma errors', () => {
    expect(isPrismaClientError(new Error('nope'))).toBe(false)
  })
})

describe('getDatabaseCatalog', () => {
  it('returns database name, schema, and table names', async () => {
    const client = {
      $queryRaw: vi
        .fn()
        .mockResolvedValueOnce([{ database: 'spending_tracker' }])
        .mockResolvedValueOnce([
          { table_name: 'Book' },
          { table_name: '_prisma_migrations' },
        ]),
    } as unknown as PrismaClient

    const catalog = await getDatabaseCatalog(client, 'public')

    expect(catalog).toEqual({
      database: 'spending_tracker',
      schema: 'public',
      tables: ['Book', '_prisma_migrations'],
    })
  })
})

describe('logDatabaseError', () => {
  it('logs the failure and database context', async () => {
    const error = new Prisma.PrismaClientKnownRequestError(
      'The table `public.Book` does not exist in the current database.',
      {
        code: 'P2021',
        clientVersion: '7.8.0',
        meta: { modelName: 'Book', table: 'public.Book' },
      },
    )
    const client = {
      $queryRaw: vi
        .fn()
        .mockResolvedValueOnce([{ database: 'spending_tracker' }])
        .mockResolvedValueOnce([{ table_name: '_prisma_migrations' }]),
    } as unknown as PrismaClient
    const errorSpy = vi.spyOn(console, 'error').mockImplementation(() => {})

    await logDatabaseError(error, client)

    expect(errorSpy).toHaveBeenCalled()
    expect(errorSpy.mock.calls[0]?.[0]).toBe(
      'Database request failed: The table `public.Book` does not exist in the current database.',
    )
    expect(errorSpy.mock.calls).toContainEqual([
      'Database context:',
      {
        database: 'spending_tracker',
        schema: 'public',
        tables: ['_prisma_migrations'],
      },
    ])

    errorSpy.mockRestore()
  })
})
