import request from 'supertest'
import { describe, expect, it, vi } from 'vitest'
import { createApp } from '../src/app.js'
import type { BookRepository } from '../src/external/persistence/book.repository.js'

const mockBook = {
  id: 'book_1',
  title: 'The Pragmatic Programmer',
  author: 'Andrew Hunt and David Thomas',
  createdAt: new Date('2024-01-01T00:00:00.000Z'),
}

function createMockBookRepository(
  overrides: Partial<BookRepository> = {},
): BookRepository {
  return {
    createDummy: async () => mockBook,
    findAll: async () => [mockBook],
    ...overrides,
  }
}

describe('POST /api/test/create-dummy', () => {
  it('creates a dummy book and returns 201', async () => {
    const createDummy = vi.fn().mockResolvedValue(mockBook)
    const app = createApp({
      enableRequestLogging: false,
      testRouterDeps: {
        bookRepository: createMockBookRepository({ createDummy }),
      },
    })

    const response = await request(app).post('/api/test/create-dummy')

    expect(response.status).toBe(201)
    expect(createDummy).toHaveBeenCalledOnce()
    expect(response.body).toMatchObject({
      id: mockBook.id,
      title: mockBook.title,
      author: mockBook.author,
    })
  })
})

describe('GET /api/test/get-dummy', () => {
  it('returns all books as JSON', async () => {
    const findAll = vi.fn().mockResolvedValue([mockBook])
    const app = createApp({
      enableRequestLogging: false,
      testRouterDeps: {
        bookRepository: createMockBookRepository({ findAll }),
      },
    })

    const response = await request(app).get('/api/test/get-dummy')

    expect(response.status).toBe(200)
    expect(findAll).toHaveBeenCalledOnce()
    expect(response.body).toHaveLength(1)
    expect(response.body[0]).toMatchObject({
      id: mockBook.id,
      title: mockBook.title,
      author: mockBook.author,
    })
  })
})
