# 07 — Debugging Demo: LIFE-3 Student Registry

## Overview

A full-stack app (Next.js + .NET API + PostgreSQL) used to demonstrate:
1. The classic `localhost` networking mistake
2. Docker debugging commands (`ps`, `logs`, `exec`, `inspect`)
3. Observable live logs across multiple containers
4. How containers communicate via Docker networks

## The App

- **Frontend** (http://localhost:3000) — "Register Student" form with name input + student list
- **Backend** (http://localhost:8080) — POST /api/students, GET /api/students
- **Database** — PostgreSQL with a `life3_students` table

---

## Demo Flow (Manual Docker Commands)

This approach shows exactly what happens under the hood — each container managed individually.

### Step 1 — Build the images

```bash
docker build -t life-api ./backend
docker build -t life-frontend ./frontend
```

### Step 2 — Start the BROKEN backend (localhost mistake)

```bash
# Create a network so containers can find each other
docker network create debug-net

# Start postgres
docker run -d --name postgres --network debug-net \
  -e POSTGRES_USER=life -e POSTGRES_PASSWORD=life2026 -e POSTGRES_DB=lifedb \
  postgres:16-alpine

# Wait for postgres to be ready
sleep 3

# Start the backend with the BROKEN connection string (Host=localhost)
docker run -d --name backend --network debug-net \
  -e ConnectionStrings__Default="Host=localhost;Database=lifedb;Username=life;Password=life2026" \
  -p 8080:8080 life-api
```

### Step 3 — Debug with the toolkit

```bash
# Container is Up but going unhealthy — watch the status
docker ps -a
# NAMES     STATUS
# backend   Up 15 seconds (health: starting)
# postgres  Up 30 seconds

# After ~40 seconds (start_period + 3 retries × 10s):
# backend   Up About a minute (unhealthy)

# Check backend logs — the startup error and health check failures are there
docker logs backend
# [STARTUP] Failed to connect to database: Failed to connect to 127.0.0.1:5432
# [STARTUP] Starting anyway — health check will report unhealthy.
# [HEALTH] DB unreachable: Failed to connect to 127.0.0.1:5432
# [HEALTH] DB unreachable: ...

# Shell into the running container
docker exec -it backend /bin/sh

# Inside: check the connection string
env | grep Connection
# ConnectionStrings__Default=Host=localhost;...

# nc exits 0 if it connects, 1 if refused
nc -zv localhost 5432 && echo "localhost port open by name!" || echo "cannot reach localhost"

# Exit the shell
exit

# Inspect full container details — check network and env
docker inspect backend | grep -A5 NetworkSettings

# Inside: prove postgres IS reachable by its container name
nc -zv postgres 5432 && echo "postgres port open by name!" || echo "cannot reach postgres"

```

### Step 4 — Explain the fix

The problem: `localhost` inside a container means the container itself, NOT other containers.

The fix: use the container **name** as the hostname. Since we named it `postgres`, the backend connects to `Host=postgres`.

### Step 5 — Stop the broken backend, start the fixed one

```bash
docker stop backend && docker rm backend

# Start backend with CORRECT connection string (Host=postgres)
docker run -d --name backend --network debug-net \
  -e ConnectionStrings__Default="Host=postgres;Database=lifedb;Username=life;Password=life2026" \
  -p 8080:8080 life-api
```

Check logs:
```bash
docker logs backend
# [STARTUP] Connected to PostgreSQL successfully
# [STARTUP] LIFE-3 Student Registry API running on port 8080
```

### Step 6 — Start the frontend

```bash
docker run -d --name frontend --network debug-net \
  -e NEXT_PUBLIC_API_URL="http://localhost:8080" \
  -p 3000:3000 life-frontend
```

### Step 7 — Use the app and watch logs in real-time

```bash
# Terminal 1: tail backend logs
docker logs -f backend

# Terminal 2: open http://localhost:3000 in browser
# Type a student name, click "Register"
# Watch Terminal 1:
#   [API] Saved student: Dren Sokoli (total: 1)
```

Have each student register their name — everyone sees the logs streaming.

### Step 8 — Inspect the database directly

```bash
docker exec -it postgres psql -U life -d lifedb -c "SELECT * FROM life3_students;"
```

### Step 9 — Feel the pain

Count the commands you just ran. That was 3 containers. Imagine doing this for 10 services with health checks, startup ordering, environment files, and volumes. That's why docker-compose exists.

### Step 10 — Clean up

```bash
docker stop frontend backend postgres
docker rm frontend backend postgres
docker network rm debug-net
```

---

## Homework: Repeat with Docker Compose (Option B)

The same exercise, but declarative. Two compose files are provided:

**Start the broken version:**
```bash
docker compose -f docker-compose.broken.yml up --build
```

Backend logs show the same `localhost` error.

**Stop and start the working version:**
```bash
docker compose -f docker-compose.broken.yml down
docker compose up --build
```

**Use the app + stream all logs together:**
```bash
docker compose logs -f
```

**Inspect the database:**
```bash
docker exec -it 07-debugging-postgres-1 psql -U life -d lifedb -c "SELECT * FROM life3_students;"
```

**Clean up:**
```bash
docker compose down -v
```

Notice how much simpler this is — one file, one command, all services orchestrated automatically. That's what we'll build next in `08-compose-fullstack/`.
