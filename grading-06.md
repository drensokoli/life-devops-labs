# LIFE Lab 06 — grading report

_Generated: 2026-06-01 09:22:56 +0200_

- Total submissions found: **14**
- Successfully decrypted: **9**
- Missing / failed: **5**

## Scoreboard

| Branch | Score | Failed checks | Notes |
|--------|-------|---------------|-------|
| `albin-dana-20250055` | **25/25** | — |  |
| `andi-morina-20250115` | **25/25** | — |  |
| `arianit-sadriu-20250183` | **25/25** | — |  |
| `enes-drejta-12345` | **25/25** | — |  |
| `kaltrina-rashiti-20250815` | **25/25** | — |  |
| `nida-perolli-20250965` | **25/25** | — |  |
| `olti-ramadani-1234` | **25/25** | — |  |
| `rudina-citaku-20251083` | **25/25** | — |  |
| `jona-fazliu-20250806` | **22/25** | backend_replicas, frontend_replicas |  |
| `dren-halili-12345` | — | (no data) | no_receipt: receipt not committed |
| `drin-prekaj-20250418` | — | (no data) | decrypt_failed_rc1: could not decrypt (forged or corrupted blob?) |
| `jeta-fazliu-20250786` | — | (no data) | decrypt_failed_rc1: could not decrypt (forged or corrupted blob?) |
| `leke-perlaska-20231063` | — | (no data) | no_receipt: receipt not committed |
| `sumea-peci-123445679` | — | (no data) | no_receipt: receipt not committed |

## Per-submission detail

### `albin-dana-20250055` — 25/25

- generated_at_utc: `2026-05-30T19:18:12Z`
- bundle_id: `0cb6ecb8`
- branch in receipt: `albin-dana-20250055`
- host: `Darwin 24.3.0 arm64`
- docker_version: `29.2.1`
- branched from: `main`

**Checks:**

- ✅ branch — branch: albin-dana-20250055
- ✅ namespace — life-app
- ✅ configmap — app-config
- ✅ configmap_connstr — points to postgres-service
- ✅ secret — db-credentials
- ✅ secret_user — user: life
- ✅ postgres_deploy — postgres
- ✅ postgres_running — Running
- ✅ postgres_readiness — pg_isready probe found
- ✅ postgres_limits — memory limit: 256Mi
- ✅ postgres_svc — postgres-service
- ✅ backend_deploy — backend
- ✅ backend_replicas — 3 replicas ready
- ✅ backend_liveness — path: /health
- ✅ backend_readiness — path: /health
- ✅ backend_limits — memory limit: 512Mi
- ✅ backend_svc — backend-service
- ✅ frontend_deploy — frontend
- ✅ frontend_replicas — 2 replicas ready
- ✅ frontend_liveness — httpGet probe found
- ✅ frontend_limits — memory limit: 256Mi
- ✅ frontend_svc — frontend-service
- ✅ ingress — app-ingress
- ✅ ingress_host — host: life.local
- ✅ backend_health — HTTP 200

### `andi-morina-20250115` — 25/25

- generated_at_utc: `2026-05-30T21:40:16Z`
- bundle_id: `5c36f150`
- branch in receipt: `andi-morina-20250115`
- host: `Linux 6.6.87.2-microsoft-standard-WSL2 x86_64`
- docker_version: `29.2.1`
- branched from: `main`

**Checks:**

- ✅ branch — branch: andi-morina-20250115
- ✅ namespace — life-app
- ✅ configmap — app-config
- ✅ configmap_connstr — points to postgres-service
- ✅ secret — db-credentials
- ✅ secret_user — user: life
- ✅ postgres_deploy — postgres
- ✅ postgres_running — Running
- ✅ postgres_readiness — pg_isready probe found
- ✅ postgres_limits — memory limit: 256Mi
- ✅ postgres_svc — postgres-service
- ✅ backend_deploy — backend
- ✅ backend_replicas — 3 replicas ready
- ✅ backend_liveness — path: /health
- ✅ backend_readiness — path: /health
- ✅ backend_limits — memory limit: 512Mi
- ✅ backend_svc — backend-service
- ✅ frontend_deploy — frontend
- ✅ frontend_replicas — 2 replicas ready
- ✅ frontend_liveness — httpGet probe found
- ✅ frontend_limits — memory limit: 256Mi
- ✅ frontend_svc — frontend-service
- ✅ ingress — app-ingress
- ✅ ingress_host — host: life.local
- ✅ backend_health — HTTP 200

### `arianit-sadriu-20250183` — 25/25

- generated_at_utc: `2026-05-30T20:14:18Z`
- bundle_id: `c127c0cd`
- branch in receipt: `arianit-sadriu-20250183`
- host: `Linux 6.6.87.2-microsoft-standard-WSL2 x86_64`
- docker_version: `
The command 'docker' could not be found in this WSL 2 distro.
We recommend to activate the WSL integration in Docker Desktop settings.

For details about using Docker Desktop with WSL 2, visit:

https://docs.docker.com/go/wsl2/`
- branched from: `main`

**Checks:**

- ✅ branch — branch: arianit-sadriu-20250183
- ✅ namespace — life-app
- ✅ configmap — app-config
- ✅ configmap_connstr — points to postgres-service
- ✅ secret — db-credentials
- ✅ secret_user — user: life
- ✅ postgres_deploy — postgres
- ✅ postgres_running — Running
- ✅ postgres_readiness — pg_isready probe found
- ✅ postgres_limits — memory limit: 256Mi
- ✅ postgres_svc — postgres-service
- ✅ backend_deploy — backend
- ✅ backend_replicas — 3 replicas ready
- ✅ backend_liveness — path: /health
- ✅ backend_readiness — path: /health
- ✅ backend_limits — memory limit: 512Mi
- ✅ backend_svc — backend-service
- ✅ frontend_deploy — frontend
- ✅ frontend_replicas — 2 replicas ready
- ✅ frontend_liveness — httpGet probe found
- ✅ frontend_limits — memory limit: 256Mi
- ✅ frontend_svc — frontend-service
- ✅ ingress — app-ingress
- ✅ ingress_host — host: life.local
- ✅ backend_health — HTTP 200

### `enes-drejta-12345` — 25/25

- generated_at_utc: `2026-05-31T22:19:54Z`
- bundle_id: `e94a258f`
- branch in receipt: `enes-drejta-12345`
- host: `Linux 7.0.4-100.fc43.x86_64 x86_64`
- docker_version: `29.4.3`
- branched from: `main`

**Checks:**

- ✅ branch — branch: enes-drejta-12345
- ✅ namespace — life-app
- ✅ configmap — app-config
- ✅ configmap_connstr — points to postgres-service
- ✅ secret — db-credentials
- ✅ secret_user — user: life
- ✅ postgres_deploy — postgres
- ✅ postgres_running — Running
- ✅ postgres_readiness — pg_isready probe found
- ✅ postgres_limits — memory limit: 256Mi
- ✅ postgres_svc — postgres-service
- ✅ backend_deploy — backend
- ✅ backend_replicas — 3 replicas ready
- ✅ backend_liveness — path: /health
- ✅ backend_readiness — path: /health
- ✅ backend_limits — memory limit: 512Mi
- ✅ backend_svc — backend-service
- ✅ frontend_deploy — frontend
- ✅ frontend_replicas — 2 replicas ready
- ✅ frontend_liveness — httpGet probe found
- ✅ frontend_limits — memory limit: 256Mi
- ✅ frontend_svc — frontend-service
- ✅ ingress — app-ingress
- ✅ ingress_host — host: life.local
- ✅ backend_health — HTTP 200

### `kaltrina-rashiti-20250815` — 25/25

- generated_at_utc: `2026-05-30T19:58:17Z`
- bundle_id: `d3bbc789`
- branch in receipt: `kaltrina-rashiti-20250815`
- host: `Linux 6.6.87.2-microsoft-standard-WSL2 x86_64`
- docker_version: `29.4.2`
- branched from: `main`

**Checks:**

- ✅ branch — branch: kaltrina-rashiti-20250815
- ✅ namespace — life-app
- ✅ configmap — app-config
- ✅ configmap_connstr — points to postgres-service
- ✅ secret — db-credentials
- ✅ secret_user — user: life
- ✅ postgres_deploy — postgres
- ✅ postgres_running — Running
- ✅ postgres_readiness — pg_isready probe found
- ✅ postgres_limits — memory limit: 256Mi
- ✅ postgres_svc — postgres-service
- ✅ backend_deploy — backend
- ✅ backend_replicas — 2 replicas ready
- ✅ backend_liveness — path: /health
- ✅ backend_readiness — path: /health
- ✅ backend_limits — memory limit: 512Mi
- ✅ backend_svc — backend-service
- ✅ frontend_deploy — frontend
- ✅ frontend_replicas — 2 replicas ready
- ✅ frontend_liveness — httpGet probe found
- ✅ frontend_limits — memory limit: 256Mi
- ✅ frontend_svc — frontend-service
- ✅ ingress — app-ingress
- ✅ ingress_host — host: life.local
- ✅ backend_health — HTTP 200

### `nida-perolli-20250965` — 25/25

- generated_at_utc: `2026-05-30T16:06:39Z`
- bundle_id: `f758f454`
- branch in receipt: `nida-perolli-20250965`
- host: `Linux 6.6.114.1-microsoft-standard-WSL2 x86_64`
- docker_version: `29.4.3`
- branched from: `main`

**Checks:**

- ✅ branch — branch: nida-perolli-20250965
- ✅ namespace — life-app
- ✅ configmap — app-config
- ✅ configmap_connstr — points to postgres-service
- ✅ secret — db-credentials
- ✅ secret_user — user: life
- ✅ postgres_deploy — postgres
- ✅ postgres_running — Running
- ✅ postgres_readiness — pg_isready probe found
- ✅ postgres_limits — memory limit: 256Mi
- ✅ postgres_svc — postgres-service
- ✅ backend_deploy — backend
- ✅ backend_replicas — 3 replicas ready
- ✅ backend_liveness — path: /health
- ✅ backend_readiness — path: /health
- ✅ backend_limits — memory limit: 512Mi
- ✅ backend_svc — backend-service
- ✅ frontend_deploy — frontend
- ✅ frontend_replicas — 2 replicas ready
- ✅ frontend_liveness — httpGet probe found
- ✅ frontend_limits — memory limit: 256Mi
- ✅ frontend_svc — frontend-service
- ✅ ingress — app-ingress
- ✅ ingress_host — host: life.local
- ✅ backend_health — HTTP 200

### `olti-ramadani-1234` — 25/25

- generated_at_utc: `2026-05-30T16:24:18Z`
- bundle_id: `1fee6c53`
- branch in receipt: `olti-ramadani-1234`
- host: `Linux 7.0.3-arch1-2 x86_64`
- docker_version: `29.4.3`
- branched from: `main`

**Checks:**

- ✅ branch — branch: olti-ramadani-1234
- ✅ namespace — life-app
- ✅ configmap — app-config
- ✅ configmap_connstr — points to postgres-service
- ✅ secret — db-credentials
- ✅ secret_user — user: life
- ✅ postgres_deploy — postgres
- ✅ postgres_running — Running
- ✅ postgres_readiness — pg_isready probe found
- ✅ postgres_limits — memory limit: 256Mi
- ✅ postgres_svc — postgres-service
- ✅ backend_deploy — backend
- ✅ backend_replicas — 3 replicas ready
- ✅ backend_liveness — path: /health
- ✅ backend_readiness — path: /health
- ✅ backend_limits — memory limit: 512Mi
- ✅ backend_svc — backend-service
- ✅ frontend_deploy — frontend
- ✅ frontend_replicas — 2 replicas ready
- ✅ frontend_liveness — httpGet probe found
- ✅ frontend_limits — memory limit: 256Mi
- ✅ frontend_svc — frontend-service
- ✅ ingress — app-ingress
- ✅ ingress_host — host: life.local
- ✅ backend_health — HTTP 200

### `rudina-citaku-20251083` — 25/25

- generated_at_utc: `2026-05-31T13:08:27Z`
- bundle_id: `30ed1556`
- branch in receipt: `rudina-citaku-20251083`
- host: `Linux 6.6.87.2-microsoft-standard-WSL2 x86_64`
- docker_version: `29.1.3`
- branched from: `main`

**Checks:**

- ✅ branch — branch: rudina-citaku-20251083
- ✅ namespace — life-app
- ✅ configmap — app-config
- ✅ configmap_connstr — points to postgres-service
- ✅ secret — db-credentials
- ✅ secret_user — user: life
- ✅ postgres_deploy — postgres
- ✅ postgres_running — Running
- ✅ postgres_readiness — pg_isready probe found
- ✅ postgres_limits — memory limit: 256Mi
- ✅ postgres_svc — postgres-service
- ✅ backend_deploy — backend
- ✅ backend_replicas — 2 replicas ready
- ✅ backend_liveness — path: /health
- ✅ backend_readiness — path: /health
- ✅ backend_limits — memory limit: 512Mi
- ✅ backend_svc — backend-service
- ✅ frontend_deploy — frontend
- ✅ frontend_replicas — 2 replicas ready
- ✅ frontend_liveness — httpGet probe found
- ✅ frontend_limits — memory limit: 256Mi
- ✅ frontend_svc — frontend-service
- ✅ ingress — app-ingress
- ✅ ingress_host — host: life.local
- ✅ backend_health — HTTP 200

### `jona-fazliu-20250806` — 22/25

- generated_at_utc: `2026-05-30T21:47:16Z`
- bundle_id: `3c6b2704`
- branch in receipt: `jona-fazliu-20250806`
- host: `Linux 6.6.87.2-microsoft-standard-WSL2 x86_64`
- docker_version: `29.3.1`
- branched from: `main`

**Checks:**

- ✅ branch — branch: jona-fazliu-20250806
- ✅ namespace — life-app
- ✅ configmap — app-config
- ✅ configmap_connstr — points to postgres-service
- ✅ secret — db-credentials
- ✅ secret_user — user: life
- ✅ postgres_deploy — postgres
- ✅ postgres_running — Running
- ✅ postgres_readiness — pg_isready probe found
- ✅ postgres_limits — memory limit: 256Mi
- ✅ postgres_svc — postgres-service
- ✅ backend_deploy — backend
- ❌ backend_replicas — 1 replicas ready — expected at least 2
- ✅ backend_liveness — path: /health
- ✅ backend_readiness — path: /health
- ✅ backend_limits — memory limit: 512Mi
- ✅ backend_svc — backend-service
- ✅ frontend_deploy — frontend
- ❌ frontend_replicas — 0 replicas ready — expected at least 2
- ✅ frontend_liveness — httpGet probe found
- ✅ frontend_limits — memory limit: 256Mi
- ✅ frontend_svc — frontend-service
- ✅ ingress — app-ingress
- ✅ ingress_host — host: life.local
- ⏭ backend_health — depends on check 13

### `dren-halili-12345` — no_receipt

> receipt not committed

### `drin-prekaj-20250418` — decrypt_failed_rc1

> could not decrypt (forged or corrupted blob?)

### `jeta-fazliu-20250786` — decrypt_failed_rc1

> could not decrypt (forged or corrupted blob?)

### `leke-perlaska-20231063` — no_receipt

> receipt not committed

### `sumea-peci-123445679` — no_receipt

> receipt not committed

