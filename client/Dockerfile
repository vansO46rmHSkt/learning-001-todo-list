# buildステージ
FROM node:18-alpine AS base

FROM base AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /build
COPY package.json pnpm-lock.yaml ./
RUN yarn global add pnpm; \
  pnpm i --frozen-lockfile;

FROM base AS builder
WORKDIR /build
COPY --from=deps /build/node_modules ./node_modules
COPY . .
RUN yarn build 

# 実行ステージ
FROM amazon/aws-lambda-nodejs:18
ENV PORT=3000

COPY --from=public.ecr.aws/awsguru/aws-lambda-adapter:0.7.1 /lambda-adapter /opt/extensions/lambda-adapter
COPY --from=builder /build/public ./public
COPY --from=builder /build/.next/standalone ./
COPY --from=builder /build/.next/static ./.next/static

ENTRYPOINT ["node"]
CMD ["server.js"]