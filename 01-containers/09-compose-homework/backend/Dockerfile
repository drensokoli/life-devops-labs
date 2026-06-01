FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
USER root
WORKDIR /src

COPY LifeShortener.csproj ./
RUN dotnet restore LifeShortener.csproj

COPY . ./
RUN dotnet publish LifeShortener.csproj \
    -c Release \
    -o /app/publish \
    /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app

ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/* \
    && (id app >/dev/null 2>&1 || useradd --create-home --shell /usr/sbin/nologin app)

COPY --from=build /app/publish .

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
    CMD curl -fsS http://localhost:8080/health || exit 1

USER app

ENTRYPOINT ["dotnet", "LifeShortener.dll"]