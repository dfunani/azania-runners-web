FROM node:18-alpine AS base

FROM base AS deps

RUN apk add --no-cache libc6-compat

WORKDIR /azania-runners-web

COPY package*.json ./

RUN npm install

FROM base AS builder

WORKDIR /azania-runners-web

COPY --from=deps /azania-runners-web/node_modules ./node_modules

COPY . .


ENV NEXT_TELEMETRY_DISABLED 1

RUN npm run build

FROM base AS runner

WORKDIR /azania-runners-web

ENV NODE_ENV production

ENV NEXT_TELEMETRY_DISABLED 1

RUN addgroup --system --gid 1001 nodejs

RUN adduser --system --uid 1001 nextjs

COPY --from=builder /azania-runners-web/public ./public

COPY --from=builder --chown=nextjs:nodejs /azania-runners-web/.next/standalone ./

COPY --from=builder --chown=nextjs:nodejs /azania-runners-web/.next/static ./.next/static

USER nextjs

EXPOSE 3000

ENV PORT 3000

CMD ["node", "server.js"] 