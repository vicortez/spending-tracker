import { Router } from 'express'

export function createTestRouter(): Router {
  const router = Router()

  router.get('/', (_req, res) => {
    console.log(`Remote address ${_req.socket.remoteAddress}`)
    console.log(`IP ${_req.headers['x-forwarded-for']} or ${_req.ip}`)
    console.log(`Origin ${_req.headers.origin}`)
    console.log(`User agent ${_req.headers['user-agent']}`)
    res.type('text').send('hi')
  })

  return router
}
