# syntax=docker/dockerfile:1

# ─── Build stage ──────────────────────────────────────────────────────────────
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Restore first (better layer caching) — only the csproj invalidates this layer.
COPY LifeShortener.csproj ./
RUN dotnet restore LifeShortener.csproj

# Build + publish a self-contained framework-dependent release.
COPY . ./
RUN dotnet publish LifeShortener.csproj -c Release -o /app/publish --no-restore

# ─── Runtime stage ────────────────────────────────────────────────────────────
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app

# curl is needed for the HEALTHCHECK below.
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /app/publish ./

# Bind Kestrel to 8080 on all interfaces.
ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080

# Run as the built-in non-root "app" user shipped in the aspnet image.
USER app

HEALTHCHECK --interval=15s --timeout=5s --start-period=20s --retries=5 \
    CMD curl -sf http://localhost:8080/health || exit 1

ENTRYPOINT ["dotnet", "LifeShortener.dll"]
