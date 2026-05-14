# 02 — The Bad Dockerfile

## Purpose

Show what a naive single-stage Dockerfile looks like — and why it's a problem in production.

## What's Wrong

```dockerfile
FROM mcr.microsoft.com/dotnet/sdk:8.0   # SDK = 750 MB build tool
WORKDIR /app
COPY . .                                 # copies everything including bin/, obj/
RUN dotnet publish -c Release -o /out
ENTRYPOINT ["dotnet", "/out/LifeApi.dll"]
```

Problems:
- The final image includes the full **SDK** (build tools, compilers) — ~750 MB instead of ~200 MB
- `COPY . .` before restore means **every code change** busts the dependency cache
- No `.dockerignore` — sends `bin/`, `obj/`, `.git/` to the build daemon unnecessarily
- No health check, no non-root user

## Commands

```bash
# Build and check the image size
docker build -t life-api-bad .
docker images life-api-bad

# Run it
docker run -p 8080:8080 life-api-bad

# Compare with the multi-stage version (after building 03-multistage-dotnet)
docker images | grep life-api
```

## What to observe

- Image size is much larger than it needs to be
- The SDK (compilers, build tools) ships to production — a security risk
- Next demo (03) fixes all of this with a multi-stage build
