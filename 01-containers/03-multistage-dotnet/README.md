# 03 — Multi-Stage .NET Dockerfile

## Purpose

Show the correct pattern for building a .NET app — separate build and runtime stages, minimal final image, non-root user, health check.

## What's Different from 02

```dockerfile
# Stage 1: build (SDK — only needed here)
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY *.csproj .          # copy project file FIRST
RUN dotnet restore       # restore dependencies (cached unless .csproj changes)
COPY . .
RUN dotnet publish -c Release -o /app/publish

# Stage 2: runtime (aspnet — no SDK, ~200 MB)
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app
COPY --from=build /app/publish .
USER 1001                # non-root user
EXPOSE 8080
HEALTHCHECK CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1
ENTRYPOINT ["dotnet", "LifeApi.dll"]
```

Improvements over 02:
- Runtime image uses `aspnet` (not `sdk`) — ~3x smaller
- `COPY *.csproj` first — `dotnet restore` is cached unless dependencies change
- Non-root user (`USER 1001`)
- Health check included

## Commands

```bash
# Build and check the image size
docker build -t life-api-good .
docker images life-api-good

# Compare with the bad version
docker images | grep life-api

# Run it
docker run -p 8080:8080 life-api-good

# Check the health endpoint
curl http://localhost:8080/health
```

## What to observe

- Image size is significantly smaller than 02 (no SDK in the runtime image)
- `COPY *.csproj` + `RUN dotnet restore` are cached on rebuild — only invalidated when dependencies change
- Modify `Program.cs` and rebuild — restore layer hits cache, only publish re-runs
