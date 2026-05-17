import type { Book, PrismaClient } from '../../generated/prisma/client.js'

export type BookRepository = {
  createDummy(): Promise<Book>
  findAll(): Promise<Book[]>
}

const dummyBook = {
  title: 'The Pragmatic Programmer',
  author: 'Andrew Hunt and David Thomas',
} as const

export function createBookRepository(client: PrismaClient): BookRepository {
  return {
    createDummy() {
      return client.book.create({ data: dummyBook })
    },
    findAll() {
      return client.book.findMany({ orderBy: { createdAt: 'desc' } })
    },
  }
}
