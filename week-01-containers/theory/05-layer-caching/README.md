# 05 — Layer Caching Demo

## Purpose

Demonstrate the impact of instruction order on Docker build speed.

## Demo Steps

### 1. Build both images from scratch

```bash
docker build -f Dockerfile.bad -t caching-bad:v1 .
docker build -f Dockerfile.good -t caching-good:v1 .
```

### 2. Make a small code change

```bash
echo "// updated" >> src/index.ts
```

### 3. Rebuild both and compare

```bash
# This one re-runs npm ci (slow!)
docker build -f Dockerfile.bad -t caching-bad:v2 .

# This one skips npm ci (CACHED)
docker build -f Dockerfile.good -t caching-good:v2 .
```

## What to observe

- In the "bad" build: `COPY . .` invalidates the cache, so `npm ci` runs again
- In the "good" build: `COPY package.json` is CACHED, `npm ci` is CACHED
- Only `COPY . .` and `npm run build` re-run in the good version
- Time difference: ~60s vs ~5s on rebuild
