# 08 — Full-Stack Docker Compose

## Overview

The complete 10-service development environment orchestrated with a single `docker-compose.yml`. This is the same Student Registry app from `07-debugging`, but now surrounded by the full infrastructure: caching, messaging, identity, observability, and a reverse proxy.

## Architecture

```
┌────────────────────────────────────────────────────────┐
│                    Nginx (:80)                          │
│                  Reverse Proxy                         │
├──────────────────┬─────────────────────────────────────┤
│ Next.js (:3000)  │        .NET API (:8080)             │
│   Frontend       │         Backend                     │
├──────────────────┴──────────┬──────────────────────────┤
│                             │                          │
│  PostgreSQL (:5432)   Redis (:6379)   Keycloak (:8180)│
│                             │                          │
│  RabbitMQ (:5672/15672)  Kafka (:9092)                │
│                             │                          │
│  Loki (:3100)         Grafana (:3001)                 │
└────────────────────────────────────────────────────────┘
```

## Setup

```bash
# Copy the environment file
cp .env.example .env

# Build and start everything
docker compose up -d --build

# Watch startup logs
docker compose logs -f
```

## Verify Each Service

```bash
# Check all container health
docker compose ps

# PostgreSQL
docker exec -it life-postgres psql -U life -d lifedb -c "SELECT version();"

# Redis
docker exec -it life-redis redis-cli ping

# RabbitMQ Management UI
echo "Open http://localhost:15672 (life/life2026)"

# Kafka — list topics
docker exec -it life-kafka kafka-topics --bootstrap-server localhost:9092 --list

# Keycloak Admin Console
echo "Open http://localhost:8180 (admin/admin)"

# Grafana
echo "Open http://localhost:3001 (admin/admin)"

# Application (direct)
echo "Frontend: http://localhost:3000"
echo "Backend:  http://localhost:8080/api/students"

# Application (through Nginx)
echo "Open http://localhost"
```

## Register Students

Open http://localhost:3000 (or http://localhost through Nginx), type your name, click Register.

Watch all logs:
```bash
docker compose logs -f backend frontend
```

Inspect the database:
```bash
docker exec -it life-postgres psql -U life -d lifedb -c "SELECT * FROM life3_students;"
```

## Common Issues

| Problem | Diagnosis | Fix |
|---------|-----------|-----|
| Container exits immediately | `docker compose logs <service>` | Check env vars, config |
| Can't connect between services | Wrong hostname | Use service name, not localhost |
| Port already in use | `lsof -i :PORT` | Stop conflicting service or change port |
| Keycloak slow to start | Normal — 30-60s boot | Wait for health check to pass |
| Build context too large | Missing .dockerignore | Check ../07-debugging/backend and frontend |

## Useful Commands

```bash
# Logs for a specific service
docker compose logs -f backend

# Shell into a container
docker compose exec backend /bin/sh

# Restart one service
docker compose restart backend

# Rebuild one service after code changes
docker compose up -d --build backend

# Stop everything
docker compose down

# Nuclear option: stop + delete volumes (loses all data)
docker compose down -v
```

## Cleanup

```bash
docker compose down -v
```
