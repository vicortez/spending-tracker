import request from 'supertest'
import { describe, expect, it } from 'vitest'
import { createApp } from '../src/app.js'

describe('createApp', () => {
  it('returns an express application that can handle requests', async () => {
    const app = createApp({ enableRequestLogging: false })

    expect(app).toBeDefined()
    expect(typeof app.listen).toBe('function')

    const response = await request(app).get('/api/test')
    expect(response.status).toBe(200)
  })

  it('returns 404 for unknown routes', async () => {
    const app = createApp({ enableRequestLogging: false })

    const response = await request(app).get('/does-not-exist')
    expect(response.status).toBe(404)
    expect(response.body).toEqual({ error: 'Not found' })
  })
})
