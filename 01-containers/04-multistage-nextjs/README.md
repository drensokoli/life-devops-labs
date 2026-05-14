# 04 — Multi-Stage Next.js Dockerfile

## Purpose

Show what a naive Next.js Dockerfile looks like, measure the pain, then fix it with a proper multi-stage build.

Two Dockerfiles:
- `Dockerfile.bad` — single stage, ships everything including devDependencies and build tools
- `Dockerfile` — three stages, minimal runtime image, non-root user, health check

---

## Step 1: Build the bad version

```bash
docker build -f Dockerfile.bad -t life-frontend-bad .
docker images life-frontend-bad
```

Run it:
```bash
docker run -p 3000:3000 life-frontend-bad
```

Open http://localhost:3000. It works — but look at the image size.

### What's wrong with `Dockerfile.bad`

```dockerfile
FROM node:20-alpine
COPY . .             # copies everything, including .next/, .git/, any secrets
RUN npm install      # installs devDependencies too — test tools, linters, etc.
RUN npm run build
CMD ["npm", "start"] # starts a dev-mode server, not a production server
```

Problems:
- Ships all `node_modules` including devDependencies (linters, test tools, type checkers)
- `COPY . .` before install means **every code change** busts the dependency cache
- No non-root user
- No health check

```bash
# Stop it before moving on
docker stop $(docker ps -q --filter ancestor=life-frontend-bad)
```

---

## Step 2: Build the good version

```bash
docker build -f Dockerfile -t life-frontend-good .
docker images life-frontend-good
```

Compare sizes:
```bash
docker images | grep life-frontend
```

Run it:
```bash
docker run -p 3000:3000 life-frontend-good
```

### What `Dockerfile` does differently

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
RUN npm run build   # outputs to .next/standalone (see next.config.js)

# Stage 3: minimal runtime (no node_modules, just the compiled bundle)
FROM node:20-alpine AS runner
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public
USER nextjs         # non-root user
HEALTHCHECK CMD wget --no-verbose --tries=1 --spider http://localhost:3000/ || exit 1
CMD ["node", "server.js"]
```

Key: `output: 'standalone'` in `next.config.js` tells Next.js to produce a self-contained bundle — no `node_modules` needed in the final image.

---

## What to observe

- The good image is significantly smaller — `node_modules` and build tools are gone from the runtime
- Modify `app/page.tsx` and rebuild the good version — `npm ci` (deps install) is cached, only the build step reruns
- `USER nextjs` — non-root user, same security principle as the .NET examples
- `npm start` in the bad version uses Next.js dev infrastructure; `node server.js` in the good version is a lean production server

## Cleanup

```bash
docker rmi life-frontend-bad life-frontend-good
```
