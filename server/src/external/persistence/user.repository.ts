import type { Prisma, PrismaClient, User } from '#src/generated/prisma/client.js'

export type CreateUserInput = {
  email: string
  username: string
  firstName: string
  lastName: string
  passwordHash: string
  role?: Prisma.UserCreateInput['role']
}

export type UserRepository = {
  create(input: CreateUserInput): Promise<User>
  findByUsername(username: string): Promise<User | null>
}

export function createUserRepository(client: PrismaClient): UserRepository {
  return {
    create(input) {
      return client.user.create({
        data: {
          email: input.email,
          username: input.username,
          firstName: input.firstName,
          lastName: input.lastName,
          passwordHash: input.passwordHash,
          role: input.role ?? 'USER',
        },
      })
    },
    findByUsername(username) {
      return client.user.findUnique({ where: { username } })
    },
  }
}
