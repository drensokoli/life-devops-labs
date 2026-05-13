# 06 — Debugging Demo: LIFE-3 Student Registry

## Overview

A full-stack app (Next.js + .NET API + PostgreSQL) used to demonstrate:
1. The classic `localhost` networking mistake
2. Docker debugging commands (`ps`, `logs`, `exec`, `inspect`)
3. Observable live logs across multiple containers
4. The `docker compose logs -f` workflow

## The App

- **Frontend** (http://localhost:3000) — "Register Student" form with name input + student list
- **Backend** (http://localhost:8080) — POST /api/students, GET /api/students
- **Database** — PostgreSQL with a `life3_students` table

---

## Demo Flow

### Step 1 — Start the BROKEN version

```bash
docker compose -f docker-compose.broken.yml up --build
```

Watch the backend logs. You'll see:
```
[STARTUP] Failed to connect to database: Connection refused on localhost:5432
```

The backend uses `Host=localhost` in its connection string. Inside the container, `localhost` means the container itself — not the postgres container.

### Step 2 — Debug with the toolkit

```bash
# See container status (backend may be restarting)
docker ps -a

# Check backend logs
docker logs -f 06-debugging-backend-1

# Shell into the backend container
docker exec -it 06-debugging-backend-1 /bin/sh

# Inside: check environment variables
env | grep Connection

# Inside: try to reach postgres
wget -qO- http://postgres:5432 || echo "Connection test done"

# Exit the shell
exit

# Inspect full container details
docker inspect 06-debugging-backend-1 | grep -A5 NetworkSettings
```

### Step 3 — Stop the broken version

```bash
docker compose -f docker-compose.broken.yml down
```

### Step 4 — Explain the fix

The fix: change `Host=localhost` to `Host=postgres` (the service name in docker-compose). Docker's internal DNS resolves service names to container IPs.

### Step 5 — Start the WORKING version

```bash
docker compose up --build
```

Backend logs now show:
```
[STARTUP] Connected to PostgreSQL successfully
[STARTUP] LIFE-3 Student Registry API running on port 8080
```

### Step 6 — Use the app and watch logs

```bash
# Terminal 1: stream all container logs
docker compose logs -f
```

```bash
# Terminal 2: open browser to http://localhost:3000
# Type a student name, click "Register"
# Watch Terminal 1:
#   [Frontend] POST http://localhost:8080/api/students { name: "Dren Sokoli" }
#   [API] Saved student: Dren Sokoli (total: 1)
```

Have each student register their name — everyone sees the logs streaming.

### Step 7 — Inspect the database directly

```bash
docker exec -it 06-debugging-postgres-1 psql -U life -d lifedb -c "SELECT * FROM life3_students;"
```

### Step 8 — Clean up

```bash
docker compose down -v
```

---

## Alternative: Manual Steps (Option B)

For a more educational approach showing what docker-compose does under the hood:

```bash
# Create a network
docker network create debug-net

# Start postgres
docker run -d --name postgres --network debug-net \
  -e POSTGRES_USER=life -e POSTGRES_PASSWORD=life2026 -e POSTGRES_DB=lifedb \
  postgres:16-alpine

# Wait for postgres to be ready
sleep 3

# Build and run the backend
docker build -t life-api ./backend
docker run -d --name backend --network debug-net \
  -e ConnectionStrings__Default="Host=postgres;Database=lifedb;Username=life;Password=life2026" \
  -p 8080:8080 life-api

# Build and run the frontend
docker build -t life-frontend ./frontend
docker run -d --name frontend --network debug-net \
  -e NEXT_PUBLIC_API_URL="http://localhost:8080" \
  -p 3000:3000 life-frontend

# View logs
docker logs -f backend

# Clean up
docker stop frontend backend postgres
docker rm frontend backend postgres
docker network rm debug-net
```
