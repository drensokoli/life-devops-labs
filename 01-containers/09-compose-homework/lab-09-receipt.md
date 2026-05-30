# LIFE Lab 09-compose-homework — Completion Receipt

**Student:** rudina-citaku-20251083
**Generated:** 2026-05-30 16:39:07 +0200
**Lab:** 09-compose-homework
**Score:** 22 / 24 passed, 2 failed, 0 skipped

## Checks

- [x] **01.** On a personal branch (not main) — branch: rudina-citaku-20251083
- [x] **02.** docker-compose.yml is present — sha256:c57bdb71735546cb4c222ab3266a64009bc0c0b3983dbcc6f1421ea9ca882678
- [x] **03.** backend/Dockerfile is present — sha256:1c6d71054c8498595d74fe8ce20b98108a8414b3532f678209d6054f44db2794
- [x] **04.** frontend/Dockerfile is present — sha256:77f4d636b067e99ca971ab27c5d129fde58fff302789813f4f851a78ee45bfe8
- [x] **05.** backend Dockerfile uses multi-stage build — multi-stage detected
- [ ] **06.** backend Dockerfile sets non-root USER — no non-root USER instruction — add USER app (or similar) to final stage
- [x] **07.** backend Dockerfile has HEALTHCHECK — HEALTHCHECK found
- [x] **08.** frontend Dockerfile uses multi-stage build — multi-stage detected
- [ ] **09.** frontend Dockerfile sets non-root USER — no non-root USER instruction — add USER nextjs (or similar) to final stage
- [x] **10.** frontend Dockerfile has HEALTHCHECK — HEALTHCHECK found
- [x] **11.** compose stack is running — 12 containers running
- [x] **12.** postgres is healthy — container: life-shortener-postgres-1
- [x] **13.** redis is healthy — healthy
- [x] **14.** rabbitmq is healthy — healthy
- [x] **15.** backend /health returns 200 — HTTP 200
- [x] **16.** backend image is under 300 MB — 91 MB
- [x] **17.** pgAdmin service is running — container: life-shortener-pgadmin-1
- [x] **18.** pgAdmin is reachable on port 5050 — HTTP 302
- [x] **19.** frontend is reachable on port 80 — HTTP 200
- [x] **20.** nginx proxies /api/ to the backend — GET /api/urls returned JSON array
- [x] **21.** shorten a URL end-to-end — created code: 644ub5
- [x] **22.** shortened URLs are stored in PostgreSQL — 2 row(s) in shortened_urls
- [x] **23.** Loki log aggregation is running — running
- [x] **24.** Grafana is running — running

## Diagnostic data

```
