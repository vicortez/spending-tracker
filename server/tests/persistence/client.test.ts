import { describe, expect, it, vi } from 'vitest'
import type { PrismaClient } from '../../src/generated/prisma/client.js'
import { pingPostgres } from '../../src/external/persistence/client.js'

describe('pingPostgres', () => {
  it('resolves when the database responds', async () => {
    const client = {
      $queryRaw: vi.fn().mockResolvedValue([{ '?column?': 1 }]),
    } as unknown as PrismaClient

    await expect(pingPostgres(client)).resolves.toBeUndefined()
    expect(client.$queryRaw).toHaveBeenCalledOnce()
  })

  it('rejects when the database is unreachable', async () => {
    const client = {
      $queryRaw: vi.fn().mockRejectedValue(new Error('connection refused')),
    } as unknown as PrismaClient

    await expect(pingPostgres(client)).rejects.toThrow('connection refused')
  })
})
