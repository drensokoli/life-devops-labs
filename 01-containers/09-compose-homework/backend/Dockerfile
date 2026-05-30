# Build
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Restore 

COPY LifeShortener.csproj ./
RUN dotnet restore LifeShortener.csproj

# copy and publish
COPY . ./
RUN dotnet publish LifeShortener.csproj -c Release -o /app/publish /p:UseAppHost=false

# runtime
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app

# install curl for health checks
RUN apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/*

COPY --from=build /app/publish ./
ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080

# aspnet image comes with built-in non-root "app" user 
USER app

HEALTHCHECK --interval=10s --timeout=5s --start-period=20s --retries=5 CMD curl -fsS http://localhost:8080/health || exit 1

ENTRYPOINT ["dotnet", "LifeShortener.dll"]