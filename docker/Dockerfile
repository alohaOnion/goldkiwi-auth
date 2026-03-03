# 1) deps: 의존성 설치만 (캐시 최적화)
#FROM node:22.10.0-bookworm-slim AS deps
FROM harbor.gk-msa.link:10443/dockerhub_proxy/library/node:22.10.0-bookworm-slim AS deps
WORKDIR /app

# npm 버전 고정
RUN npm install --global npm@11.1.13

COPY package.json package-lock.json ./

RUN npm ci


# 2) build: 소스 복사 후 빌드
#FROM node:22.10.0-bookworm-slim AS build
FROM harbor.gk-msa.link:10443/dockerhub_proxy/library/node:22.10.0-bookworm-slim AS build
WORKDIR /app
RUN npm install --global npm@11.1.13

COPY --from=deps /app/node_modules ./node_modules
COPY . .

RUN npm run build

# 3) runtime: 배포용 최소 이미지 (devDependencies 제거)
#FROM node:22.10.0-bookworm-slim AS runtime
FROM harbor.gk-msa.link:10443/dockerhub_proxy/library/node:22.10.0-bookworm-slim AS runtime
WORKDIR /app
ENV NODE_ENV=prod
RUN npm install --global npm@11.1.13

# 런타임에 필요한 파일만 복사
COPY package.json package-lock.json ./

# prod 의존성만 설치 (최종 이미지 최소화)
RUN npm ci --omit=dev && npm cache clean --force

# 빌드 산출물만 복사
COPY --from=build /app/dist ./dist

EXPOSE 3000
CMD ["node", "dist/main.js"]
