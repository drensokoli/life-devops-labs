# LIFE Lab 09-compose-homework — Completion Receipt

**Student:** jeta-fazliu-20250786
**Generated:** 2026-05-30 23:39:21 +0200
**Lab:** 09-compose-homework
**Score:** 22 / 24 passed, 2 failed, 0 skipped

## Checks

- [x] **01.** On a personal branch (not main) — branch: jeta-fazliu-20250786
- [x] **02.** docker-compose.yml is present — sha256:8a2a8f5ec44e9351ec18ff5f34bcf8339a92b206aaa96df032c8470ecc081864
- [x] **03.** backend/Dockerfile is present — sha256:999f8811ebab7187447f4a952e1c694499352fa3026722a640e3398c305e034c
- [x] **04.** frontend/Dockerfile is present — sha256:b2e37c100f7265b069c4b575b73e363601da3eaaa1c3678a8b88980843982d02
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
- [x] **21.** shorten a URL end-to-end — created code: 2y3e24
- [x] **22.** shortened URLs are stored in PostgreSQL — 4 row(s) in shortened_urls
- [x] **23.** Loki log aggregation is running — running
- [x] **24.** Grafana is running — running

## Diagnostic data

```
