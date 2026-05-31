# syntax=docker/dockerfile:1

# ─── Stage 1: build ──────────────────────────────────────────────────────────
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Restore as a separate, cache-friendly layer: only invalidated when the
# project file (and therefore the dependency graph) changes.
COPY LifeShortener.csproj ./
RUN dotnet restore

# Copy the rest of the source and publish a framework-dependent build.
# UseAppHost=false skips the native launcher — we start the app with
# `dotnet LifeShortener.dll` instead.
COPY . ./
RUN dotnet publish LifeShortener.csproj \
    -c Release \
    -o /app/publish \
    --no-restore \
    /p:UseAppHost=false

# ─── Stage 2: runtime ────────────────────────────────────────────────────────
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app

# curl is only needed so the HEALTHCHECK below can probe /health.
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*

# Bring in only the published output — no SDK, no source.
COPY --from=build /app/publish ./

# Bind Kestrel to 0.0.0.0:8080 inside the container.
ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080

# Drop privileges: the .NET 8 base image ships a non-root `app` user.
USER app

HEALTHCHECK --interval=10s --timeout=5s --start-period=30s --retries=5 \
    CMD curl -sf http://localhost:8080/health || exit 1

ENTRYPOINT ["dotnet", "LifeShortener.dll"]
