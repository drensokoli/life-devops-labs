# LIFE Lab 06-k8s-homework — Completion Receipt

**Student:** drin-prekaj-20250418
**Generated:** 2026-05-30 23:45:07 +0200
**Lab:** 06-k8s-homework
**Score:** 25 / 25 passed, 0 failed, 0 skipped

## Checks

- [x] **01.** On a personal branch (not main) — branch: drin-prekaj-20250418
- [x] **02.** Namespace life-app exists — life-app
- [x] **03.** ConfigMap app-config exists — app-config
- [x] **04.** ConfigMap has ConnectionStrings__Default — points to postgres-service
- [x] **05.** Secret db-credentials exists — db-credentials
- [x] **06.** Secret has POSTGRES_USER — user: life
- [x] **07.** Postgres deployment exists — postgres
- [x] **08.** Postgres pod is Running — Running
- [x] **09.** Postgres has readiness probe — pg_isready probe found
- [x] **10.** Postgres has resource limits — memory limit: 256Mi
- [x] **11.** Postgres service exists — postgres-service
- [x] **12.** Backend deployment exists — backend
- [x] **13.** Backend has 2+ replicas ready — 2 replicas ready
- [x] **14.** Backend has liveness probe — path: /health
- [x] **15.** Backend has readiness probe — path: /health
- [x] **16.** Backend has resource limits — memory limit: 512Mi
- [x] **17.** Backend service exists — backend-service
- [x] **18.** Frontend deployment exists — frontend
- [x] **19.** Frontend has 2+ replicas ready — 2 replicas ready
- [x] **20.** Frontend has liveness probe — httpGet probe found
- [x] **21.** Frontend has resource limits — memory limit: 256Mi
- [x] **22.** Frontend service exists — frontend-service
- [x] **23.** Ingress app-ingress exists — app-ingress
- [x] **24.** Ingress has host life.local — host: life.local
- [x] **25.** Backend health endpoint responds (via port-forward) — HTTP 200

## Diagnostic data

```
