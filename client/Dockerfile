# buildステージ
FROM node:18 AS builder
WORKDIR /build
COPY . ./
RUN npm install
RUN npm run build
RUN mv .next/static .next/standalone/.next 
RUN mv public .next/standalone

# 実行ステージ
FROM amazon/aws-lambda-nodejs:18
ENV PORT=3000

COPY --from=public.ecr.aws/awsguru/aws-lambda-adapter:0.7.1 /lambda-adapter /opt/extensions/lambda-adapter
COPY --from=builder /build/.next/standalone ./

ENTRYPOINT ["node"]
CMD ["server.js"]