# syntax=docker/dockerfile:1.7

FROM node:20-alpine AS dependencies
WORKDIR /app

COPY src/package*.json ./
RUN npm ci --omit=dev && npm cache clean --force

FROM node:20-alpine AS runtime
ENV NODE_ENV=production
ENV PORT=3000

WORKDIR /app

RUN addgroup -S app && adduser -S app -G app

COPY --from=dependencies /app/node_modules ./node_modules
COPY src/index.js ./index.js
COPY src/server ./server
COPY src/routes ./routes

USER app
EXPOSE 3000

CMD ["node", "index.js"]
