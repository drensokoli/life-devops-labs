# LIFE Lab 09-compose-homework — Completion Receipt

**Student:** drin-prekaj-20250418
**Generated:** 2026-05-30 19:35:06 +0200
**Lab:** 09-compose-homework
**Score:** 24 / 24 passed, 0 failed, 0 skipped

## Checks

- [x] **01.** On a personal branch (not main) — branch: drin-prekaj-20250418
- [x] **02.** docker-compose.yml is present — sha256:d751d317ae388d4c805a938cf492f37ea7cedc641d98287a2ef3e33e0cc226e6
- [x] **03.** backend/Dockerfile is present — sha256:b79ba5d3a2d4c755b6b83e0a2d5154215dae891faa2a4f14f364901b821f5c01
- [x] **04.** frontend/Dockerfile is present — sha256:27cbcff5232089deb3f3d5de0ba0b6dbabc630bb06c54843b2816458edb90f21
- [x] **05.** backend Dockerfile uses multi-stage build — multi-stage detected
- [x] **06.** backend Dockerfile sets non-root USER — non-root USER found
- [x] **07.** backend Dockerfile has HEALTHCHECK — HEALTHCHECK found
- [x] **08.** frontend Dockerfile uses multi-stage build — multi-stage detected
- [x] **09.** frontend Dockerfile sets non-root USER — non-root USER found
- [x] **10.** frontend Dockerfile has HEALTHCHECK — HEALTHCHECK found
- [x] **11.** compose stack is running — 9 containers running
- [x] **12.** postgres is healthy — container: life-shortener-postgres-1
- [x] **13.** redis is healthy — healthy
- [x] **14.** rabbitmq is healthy — healthy
- [x] **15.** backend /health returns 200 — HTTP 200
- [x] **16.** backend image is under 300 MB — 91 MB
- [x] **17.** pgAdmin service is running — container: life-shortener-pgadmin-1
- [x] **18.** pgAdmin is reachable on port 5050 — HTTP 302
- [x] **19.** frontend is reachable on port 80 — HTTP 200
- [x] **20.** nginx proxies /api/ to the backend — GET /api/urls returned JSON array
- [x] **21.** shorten a URL end-to-end — created code: 37ixpw
- [x] **22.** shortened URLs are stored in PostgreSQL — 2 row(s) in shortened_urls
- [x] **23.** Loki log aggregation is running — running
- [x] **24.** Grafana is running — running

## Diagnostic data

```
