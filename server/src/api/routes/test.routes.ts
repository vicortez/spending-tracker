import { RequestHandler, Router } from 'express'

const get: RequestHandler<never, string, never, never> = async (req, res) => {
  console.log(`Remote address ${req.socket.remoteAddress}`)
  console.log(`IP [x-forwarded-for] ${req.headers['x-forwarded-for']}, [ip] ${req.ip}`)
  console.log(`Origin ${req.headers.origin}`)
  console.log(`User agent ${req.headers['user-agent']}`)
  res.type('text').send('hi')
}

export function createTestRouter(): Router {
  const router = Router()

  router.get('/', get)

  return router
}
