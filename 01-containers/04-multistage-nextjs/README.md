# 04 — Multi-Stage Next.js Dockerfile

## Purpose

Show the correct pattern for building a Next.js app — three stages (deps, builder, runner), standalone output mode, non-root user, health check.

## The Three Stages

```dockerfile
# Stage 1: install production deps only (cached unless package.json changes)
FROM node:20-alpine AS deps
COPY package.json package-lock.json* ./
RUN npm ci --only=production

# Stage 2: build the app (needs devDependencies too)
FROM node:20-alpine AS builder
COPY package.json package-lock.json* ./
RUN npm ci
COPY . .
RUN npm run build        # outputs .next/standalone via next.config.js output: 'standalone'

# Stage 3: minimal runtime (no node_modules, just the standalone bundle)
FROM node:20-alpine AS runner
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public
USER nextjs
CMD ["node", "server.js"]
```

Key: `output: 'standalone'` in `next.config.js` tells Next.js to bundle everything needed into a single folder — no `node_modules` in the runtime image.

## Commands

```bash
# Build the image
docker build -t life-frontend .
docker images life-frontend

# Run it
docker run -p 3000:3000 life-frontend

# Check the health endpoint
curl http://localhost:3000/
```

## What to observe

- The final image is much smaller than if you just `COPY . .` and run `npm start`
- `node_modules` from the builder stage does NOT end up in the runner — only the compiled standalone bundle
- Modify `app/page.tsx` and rebuild — the `npm ci` (deps install) layer hits cache; only the build step reruns
- `USER nextjs` — non-root user, same security principle as the .NET example
