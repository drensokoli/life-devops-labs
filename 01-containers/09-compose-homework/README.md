# 09 — Compose Homework: LIFE Shortener

> **Before you start — read this.**
>
> You may discuss this homework with classmates and you may use AI tools to help you understand concepts or debug problems.
>
> However, **every student must complete and submit this individually on their own laptop.** This means:
>
> - Your `docker-compose.yml`, Dockerfiles, and config files must be written and run by you, not copied from someone else.
> - `./verify.sh` must be run on your own machine while your stack is actually running.
> - Every submission is reviewed individually during grading.
>
> Working in a group to understand the material is fine. Handing in someone else's work is not.

## Overview

In Lab 08 you explored a pre-built full-stack compose file. Now you build it yourself.

You are given:

- The **backend** source code (`.NET 8`, no `Dockerfile`)
- The **frontend** source code (`Next.js 14`, no `Dockerfile`)
- A **partial** `docker-compose.starter.yml` with infrastructure services wired up but application services missing
- A **starter** Nginx config in `nginx/nginx.conf.starter`
- A **starter** Grafana datasource file in `grafana/datasources.yml`

You need to:

1. Write a production-quality `Dockerfile` for each service
2. Complete `docker-compose.starter.yml` → save as `docker-compose.yml`
3. Add the missing services: `backend`, `frontend`, `nginx`, `pgAdmin`
4. Complete `nginx/nginx.conf` (copy from starter and fill in the TODOs)
5. Complete `grafana/datasources.yml` so Grafana can query Loki
6. Copy `.env.example` → `.env` and fill in `PGADMIN_DEFAULT_EMAIL` and `PGADMIN_DEFAULT_PASSWORD`
7. Bring the whole stack up and verify it works

---

## The App: LIFE Shortener

A minimal URL-shortening service:

- **Backend** — .NET 8 REST API
  - `POST /api/shorten` — accepts `{ "url": "https://..." }`, returns a short code
  - `GET /api/urls` — lists the last 50 shortened URLs
  - `GET /health` — returns 200 when the database is reachable
- **Frontend** — Next.js 14 UI that calls the backend API
- **PostgreSQL** — stores `shortened_urls` table (auto-created on startup)
- **Redis** — caches URL lookups
- **RabbitMQ** — receives an event on every new shortening
- **Nginx** — reverse-proxies `/` → frontend, `/api/` → backend
- **Loki + Grafana** — aggregates logs from all containers
- **pgAdmin** — browse the `shortened_urls` table visually
- **Keycloak** — identity provider (just needs to be running and healthy)
- **Kafka + ZooKeeper** — message broker (just needs to be running and healthy)

---

## Tasks

### Task 1 — Backend Dockerfile (`backend/Dockerfile`)

Write a multi-stage Dockerfile for the .NET 8 backend.

Requirements:
- Use the official `mcr.microsoft.com/dotnet/sdk:8.0` image for build and `mcr.microsoft.com/dotnet/aspnet:8.0` for runtime
- Multi-stage (build + runtime stages)
- Final image must run as a **non-root user** (e.g. `USER app`)
- Final image must include a `HEALTHCHECK` that calls `GET /health`
- Set `ASPNETCORE_URLS=http://+:8080` so the app binds to port 8080

### Task 2 — Frontend Dockerfile (`frontend/Dockerfile`)

Write a multi-stage Dockerfile for the Next.js 14 frontend.

Requirements:
- Use `node:20-alpine` as the base
- Multi-stage (deps → build → runtime) — use the Next.js `standalone` output
- Final image must run as a **non-root user** (e.g. `USER nextjs`)
- Final image must include a `HEALTHCHECK` that calls `GET /` (the app's root page)
- The app listens on port 3000

### Task 3 — Complete `docker-compose.yml`

Copy `docker-compose.starter.yml` → `docker-compose.yml` and add:

| Service    | Key requirements |
|------------|-----------------|
| `pgadmin`  | image `dpage/pgadmin4`, env vars from `.env`, port `5050:80`, depends on `postgres` healthy, volume `pgadmin_data` |
| `backend`  | built from `./backend`, env vars for Postgres / Redis / RabbitMQ URLs, port `8080:8080`, healthcheck on `/health`, depends on `postgres`, `redis`, `rabbitmq` healthy |
| `frontend` | built from `./frontend`, `NEXT_PUBLIC_API_URL=http://localhost/api`, depends on `backend` healthy |
| `nginx`    | image `nginx:alpine`, mounts `./nginx/nginx.conf:/etc/nginx/nginx.conf:ro`, port `80:80`, depends on `frontend` + `backend` healthy |

Also add the missing `pgadmin_data` volume at the bottom.

### Task 4 — Nginx config (`nginx/nginx.conf`)

Copy `nginx/nginx.conf.starter` → `nginx/nginx.conf` and fill in the upstreams and location blocks.

The reverse proxy must:
- Route `/` → frontend (port 3000)
- Route `/api/` → backend (port 8080)

### Task 5 — Grafana datasource (`grafana/datasources.yml`)

Fill in the Loki URL so Grafana can query logs. Use the docker-compose service name, not `localhost`.

---

## Verification

When your full stack is running:

```bash
# from 09-compose-homework/
./verify.sh
```

The script probes each service, records pass/fail for every check, and writes `lab-09-receipt.md`. You can rerun it as many times as you like — it overwrites the previous report.

**Submit** by committing `lab-09-receipt.md` (and all your work) to your personal branch and pushing:

```bash
git add .
git commit -m "lab-09 submission"
git push origin your-name-lastname-id
```

---

## Checklist

Before you submit, make sure:

- [ ] `docker compose up` brings all 11 services to `healthy`
- [ ] `http://localhost` shows the LIFE Shortener UI
- [ ] Shortening a URL inserts a row into `shortened_urls` (visible in pgAdmin at `http://localhost:5050`)
- [ ] `http://localhost:8080/api/urls` returns the row(s) as JSON
- [ ] `./verify.sh` runs without crashing and produces `lab-09-receipt.md`
- [ ] Both `Dockerfile` files use multi-stage builds and a non-root user

---

## Tips

- Run `docker compose logs -f backend` while testing — the backend prints what it connects to.
- For the Next.js frontend use `output: 'standalone'` in `next.config.js` (already configured) — this is what makes the multi-stage image work.
- `NEXT_PUBLIC_API_URL` must be set at **build time** for Next.js (`ARG` + `ENV` in the Dockerfile).
- `depends_on` with `condition: service_healthy` only works if the dependency has a `healthcheck` — check each service carefully.
- The Loki logging driver must be installed on your Docker engine. If `docker compose up` errors on the logging driver, install it:
  ```bash
  docker plugin install grafana/loki-docker-driver:latest --alias loki --grant-all-permissions
  ```

---

## Windows users

`verify.sh` is a Bash script — it will not run in PowerShell or CMD.

**Use WSL2** (Windows Subsystem for Linux 2). Docker Desktop for Windows automatically enables WSL2 integration, so your containers are reachable from inside WSL2 without any extra setup.

**If you have never opened WSL2 before:**

1. Open **PowerShell as Administrator** and run:
   ```powershell
   wsl --install
   ```
   Restart when prompted.

2. Open the **Ubuntu** app from the Start menu (or run `wsl` in a terminal).

3. Inside the WSL2 shell, navigate to your homework folder. Your Windows drives are mounted at `/mnt/c/`, `/mnt/d/`, etc.:
   ```bash
   cd /mnt/c/Users/YourName/path/to/09-compose-homework
   ```

4. Run the verification script normally:
   ```bash
   ./verify.sh
   ```

Docker Desktop shares the Docker socket with WSL2 automatically, so `docker` commands work inside WSL2 without any extra configuration.
