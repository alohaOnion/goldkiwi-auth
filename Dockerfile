# goldkiwi-auth - NestJS + Prisma
FROM node:20-alpine AS base

# 1. 의존성 설치
FROM base AS deps
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm ci

# 2. 빌드
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npx prisma generate
RUN npm run build

# 3. 프로덕션 이미지
FROM base AS runner
WORKDIR /app

ENV NODE_ENV=production

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nestjs

COPY --from=builder /app/package.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/generated ./generated
# JWT 키(private.key, public.key)는 런타임에 시크릿/볼륨으로 마운트하세요

USER nestjs

EXPOSE 3001
ENV PORT=3001

# 런타임에 DATABASE_URL 등 환경변수 주입
CMD ["node", "dist/main.js"]
