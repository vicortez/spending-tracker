import { Book } from '#src/generated/prisma/client.js'
import type { RequestHandler } from 'express'
import { Router } from 'express'
import {
  createBookRepository,
  type BookRepository,
} from '../../external/persistence/book.repository.js'
import { getPrisma } from '../../external/persistence/client.js'

export type TestRouterDeps = {
  bookRepository?: BookRepository
}

const get: RequestHandler<never, string, never, never> = async (req, res) => {
  console.log(`Remote address ${req.socket.remoteAddress}`)
  console.log(`IP [x-forwarded-for] ${req.headers['x-forwarded-for']}, [ip] ${req.ip}`)
  console.log(`Origin ${req.headers.origin}`)
  console.log(`User agent ${req.headers['user-agent']}`)
  res.type('text').send('hi')
}

export function createTestRouter(deps: TestRouterDeps = {}): Router {
  const router = Router()
  const bookRepository = deps.bookRepository ?? createBookRepository(getPrisma())

  const createDummy: RequestHandler<never, Book, never, never> = async (_req, res, next) => {
    try {
      const book = await bookRepository.createDummy()
      res.status(201).json(book)
    } catch (error) {
      next(error)
    }
  }

  const getDummy: RequestHandler<never, unknown, never, never> = async (_req, res, next) => {
    try {
      const books = await bookRepository.findAll()
      res.json(books)
    } catch (error) {
      next(error)
    }
  }

  router.get('/', get)
  router.post('/dummy', createDummy)
  router.get('/dummy', getDummy)

  return router
}
