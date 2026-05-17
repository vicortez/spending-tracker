import { AddressInfo } from 'node:net'
import { createApp } from './app.js'
import { env } from './config/env.js'
import { pingPostgres } from './external/persistence/client.js'

async function start(): Promise<void> {
  try {
    await pingPostgres()
    console.log('PostgreSQL: connected')
  } catch (error: unknown) {
    console.error('PostgreSQL: connection failed: ', error)
  }

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
}

start().catch((error: unknown) => {
  console.error(error)
  process.exit(1)
})

function getHost(addressInfo: AddressInfo | string): string {
  return typeof addressInfo === 'string'
    ? addressInfo
    : addressInfo.address === '::'
      ? 'localhost'
      : addressInfo.address
}
