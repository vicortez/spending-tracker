import { AddressInfo } from 'node:net'
import { createApp } from './app.js'
import { env } from './config/env.js'

const app = createApp()

const server = app.listen(env.port, () => {
  const addressInfo = server.address()

  if (!addressInfo) {
    console.error('Server is not yet bound to a network address')
    process.exit(1)
  }

  console.log(`API server listening on: http://${getHost(addressInfo)}:${env.port}/api`)
})

function shutdown(signal: string): void {
  console.log(`${signal} received, closing server`)
  server.close((err) => {
    if (err) {
      console.error(err)
      process.exit(1)
    }
    process.exit(0)
  })
}

process.on('SIGTERM', () => shutdown('SIGTERM'))
process.on('SIGINT', () => shutdown('SIGINT'))

function getHost(addressInfo: AddressInfo | string): string {
  // Handle case where addressInfo is a string (like a Unix socket) or an object
  return typeof addressInfo === 'string'
    ? addressInfo
    : addressInfo.address === '::'
      ? 'localhost'
      : addressInfo.address
}
