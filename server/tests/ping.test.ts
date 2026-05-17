import request from 'supertest'
import { describe, expect, it } from 'vitest'
import { createApp } from '../src/app.js'

describe('GET /api/test', () => {
  it('returns "hi" as plain text', async () => {
    const app = createApp({ enableRequestLogging: false })

    const response = await request(app).get('/api/test')

    expect(response.status).toBe(200)
    expect(response.headers['content-type']).toMatch(/text\/plain/)
    expect(response.text).toBe('hi')
  })
})
