FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY *.csproj .
RUN dotnet restore

COPY . .
RUN dotnet publish -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app

ENV ASPNETCORE_URLS=http://+:8080

RUN apt-get update && apt-get install -y --no-install-recommends curl netcat-openbsd && rm -rf /var/lib/apt/lists/*
RUN groupadd -r app || true \
 && id -u app 2>/dev/null || useradd -r -g app app

COPY --from=build /app/publish .

RUN chown -R app:app /app

USER app
EXPOSE 8080

HEALTHCHECK --interval=10s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

ENTRYPOINT ["dotnet", "LifeShortener.dll"]

