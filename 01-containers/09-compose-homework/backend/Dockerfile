FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY LifeShortener.csproj .
RUN dotnet restore
COPY . .
RUN dotnet publish -c Release -o /app/publish --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/*
COPY --from=build /app/publish .
ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080
RUN chown -R app /app
USER app
HEALTHCHECK --interval=10s --timeout=5s --retries=5 \
  CMD curl -sf http://localhost:8080/health || exit 1
ENTRYPOINT ["dotnet", "LifeShortener.dll"]
