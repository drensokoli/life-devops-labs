#!/usr/bin/env bash
# verify-fixed.sh — Lab 09 completion check (local patch of verify.sh)
#
# This is an unmodified copy of the original verify.sh EXCEPT for ONE line:
# the `_dockerfile_has` function now uses `grep -P` instead of `grep -E`.
#
# Reason: the original script's pattern '^USER[[:space:]]+(?!0|root)' uses a
# Perl-compatible negative lookahead `(?!...)`, which is NOT valid in POSIX
# Extended Regex (`grep -E`). On GNU grep this pattern silently fails to match
# any input, so checks 06 and 09 always report "no non-root USER instruction"
# even when the Dockerfile correctly contains `USER app` / `USER nextjs`.
#
# Verified locally:
#   $ echo "USER app" | grep -iE '^USER[[:space:]]+(?!0|root)'   # exit 1 (no match)
#   $ echo "USER app" | grep -iP '^USER[[:space:]]+(?!0|root)'   # exit 0 (match)
#
# All other logic, output format, receipt path, and check IDs are IDENTICAL
# to verify.sh. See VERIFY_BUGS.txt for full details.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_TOOLS_DIR="$(cd "${SCRIPT_DIR}/../../lab-tools" && pwd)"
RECEIPT_PATH="${SCRIPT_DIR}/lab-09-receipt.md"

# ── Sanity: lab-tools must be present ────────────────────────────────────────
if [[ ! -f "${LAB_TOOLS_DIR}/_lib.sh" ]]; then
  printf '\nERROR: lab-tools/_lib.sh not found at %s\n' "${LAB_TOOLS_DIR}/_lib.sh" >&2
  printf 'Make sure you cloned the full repo and have not deleted lab-tools/.\n\n' >&2
  exit 1
fi

# shellcheck source=../../lab-tools/_lib.sh
source "${LAB_TOOLS_DIR}/_lib.sh"

# ── Constants ─────────────────────────────────────────────────────────────────
LAB_NAME="09-compose-homework"
TOTAL_CHECKS=24
COMPOSE_FILE="${SCRIPT_DIR}/docker-compose.yml"
BACKEND_DF="${SCRIPT_DIR}/backend/Dockerfile"
FRONTEND_DF="${SCRIPT_DIR}/frontend/Dockerfile"

BACKEND_URL="http://localhost:8080"
FRONTEND_URL="http://localhost"
PGADMIN_URL="http://localhost:5050"

_lab_init "${LAB_NAME}" "${RECEIPT_PATH}" "${TOTAL_CHECKS}"

# ── Helper: container info ────────────────────────────────────────────────────
_container_name() {
  local service="$1"
  docker ps --format '{{.Names}}' 2>/dev/null \
    | grep -E "(life.shortener|life-shortener)[-_]${service}[-_]" \
    | head -1 \
    || true
}

_service_running() {
  local svc="$1"
  local name
  name="$(_container_name "$svc")"
  [[ -n "$name" ]] && docker inspect "$name" --format '{{.State.Running}}' 2>/dev/null | grep -q true
}

_service_healthy() {
  local svc="$1"
  local name
  name="$(_container_name "$svc")"
  [[ -n "$name" ]] && docker inspect "$name" --format '{{.State.Health.Status}}' 2>/dev/null | grep -q healthy
}

_image_of() {
  local svc="$1"
  local name
  name="$(_container_name "$svc")"
  [[ -n "$name" ]] && docker inspect "$name" --format '{{.Config.Image}}' 2>/dev/null || true
}

_image_size_mb() {
  local img="$1"
  local bytes
  bytes=$(docker image inspect "$img" --format '{{.Size}}' 2>/dev/null || true)
  [[ -n "$bytes" ]] && echo $(( bytes / 1024 / 1024 )) || echo "0"
}

_http_status() {
  local url="$1"
  curl -sf -o /dev/null -w '%{http_code}' --max-time 5 "$url" 2>/dev/null || true
}

_http_body() {
  local url="$1"
  curl -sf --max-time 5 "$url" 2>/dev/null || true
}

# >>> PATCHED: -E → -P so PCRE negative lookahead `(?!...)` works correctly.
_dockerfile_has() {
  local file="$1" pattern="$2"
  grep -qiP "$pattern" "$file" 2>/dev/null
}
# <<< END PATCH

# ── Check 01: branch name ─────────────────────────────────────────────────────
if _check_begin 1 "branch" "On a personal branch (not main)"; then
  branch="$(_get_current_branch)"
  if _is_valid_branch_name "$branch"; then
    _check_pass "branch: ${branch}"
  else
    _check_fail "branch is '${branch:-unknown}' — checkout your personal branch first"
  fi
fi

# ── Check 02: docker-compose.yml present ─────────────────────────────────────
if _check_begin 2 "compose_file" "docker-compose.yml is present"; then
  if [[ -f "${COMPOSE_FILE}" ]]; then
    hash=$(_sha256_file "${COMPOSE_FILE}")
    _fact_set "compose_sha256" "$(_json_string "$hash")"
    _check_pass "${hash}"
  else
    _check_fail "docker-compose.yml not found — copy from docker-compose.starter.yml and fill in TODOs"
  fi
fi

# ── Check 03: backend Dockerfile present ─────────────────────────────────────
if _check_begin 3 "backend_dockerfile" "backend/Dockerfile is present"; then
  if [[ -f "${BACKEND_DF}" ]]; then
    hash=$(_sha256_file "${BACKEND_DF}")
    _fact_set "backend_dockerfile_sha256" "$(_json_string "$hash")"
    _check_pass "${hash}"
  else
    _check_fail "backend/Dockerfile not found — write it!"
  fi
fi

# ── Check 04: frontend Dockerfile present ────────────────────────────────────
if _check_begin 4 "frontend_dockerfile" "frontend/Dockerfile is present"; then
  if [[ -f "${FRONTEND_DF}" ]]; then
    hash=$(_sha256_file "${FRONTEND_DF}")
    _fact_set "frontend_dockerfile_sha256" "$(_json_string "$hash")"
    _check_pass "${hash}"
  else
    _check_fail "frontend/Dockerfile not found — write it!"
  fi
fi

# ── Check 05: backend Dockerfile is multi-stage ──────────────────────────────
if _check_begin 5 "backend_multistage" "backend Dockerfile uses multi-stage build" 3; then
  if _dockerfile_has "${BACKEND_DF}" '^FROM[[:space:]]+.*[[:space:]]+AS[[:space:]]'; then
    _check_pass "multi-stage detected"
  else
    _check_fail "no multi-stage FROM ... AS ... found"
  fi
fi

# ── Check 06: backend Dockerfile has non-root USER ───────────────────────────
if _check_begin 6 "backend_nonroot" "backend Dockerfile sets non-root USER" 3; then
  if _dockerfile_has "${BACKEND_DF}" '^USER[[:space:]]+(?!0|root)'; then
    _check_pass "non-root USER found"
  else
    _check_fail "no non-root USER instruction — add USER app (or similar) to final stage"
  fi
fi

# ── Check 07: backend Dockerfile has HEALTHCHECK ─────────────────────────────
if _check_begin 7 "backend_healthcheck_df" "backend Dockerfile has HEALTHCHECK" 3; then
  if _dockerfile_has "${BACKEND_DF}" '^HEALTHCHECK'; then
    _check_pass "HEALTHCHECK found"
  else
    _check_fail "no HEALTHCHECK in backend/Dockerfile"
  fi
fi

# ── Check 08: frontend Dockerfile is multi-stage ─────────────────────────────
if _check_begin 8 "frontend_multistage" "frontend Dockerfile uses multi-stage build" 4; then
  if _dockerfile_has "${FRONTEND_DF}" '^FROM[[:space:]]+.*[[:space:]]+AS[[:space:]]'; then
    _check_pass "multi-stage detected"
  else
    _check_fail "no multi-stage FROM ... AS ... found"
  fi
fi

# ── Check 09: frontend Dockerfile has non-root USER ──────────────────────────
if _check_begin 9 "frontend_nonroot" "frontend Dockerfile sets non-root USER" 4; then
  if _dockerfile_has "${FRONTEND_DF}" '^USER[[:space:]]+(?!0|root)'; then
    _check_pass "non-root USER found"
  else
    _check_fail "no non-root USER instruction — add USER nextjs (or similar) to final stage"
  fi
fi

# ── Check 10: frontend Dockerfile has HEALTHCHECK ────────────────────────────
if _check_begin 10 "frontend_healthcheck_df" "frontend Dockerfile has HEALTHCHECK" 4; then
  if _dockerfile_has "${FRONTEND_DF}" '^HEALTHCHECK'; then
    _check_pass "HEALTHCHECK found"
  else
    _check_fail "no HEALTHCHECK in frontend/Dockerfile"
  fi
fi

# ── Check 11: stack is up ─────────────────────────────────────────────────────
if _check_begin 11 "stack_up" "compose stack is running" 2; then
  running=$(docker ps --format '{{.Names}}' 2>/dev/null | grep -cE "(life.shortener|life-shortener)[-_]" || true)
  if (( running >= 8 )); then
    _check_pass "${running} containers running"
  elif (( running > 0 )); then
    _check_fail "${running} containers running — expected at least 8 (run docker compose up -d)"
  else
    _check_fail "no life-shortener containers found — run: docker compose up -d"
  fi
fi

# ── Check 12: postgres healthy ───────────────────────────────────────────────
if _check_begin 12 "postgres_healthy" "postgres is healthy" 11; then
  name="$(_container_name postgres)"
  if _service_healthy "postgres"; then
    img="$(_image_of "postgres")"
    _fact_set "postgres_container" "$(_json_string "${name}")"
    _fact_set "postgres_image" "$(_json_string "${img}")"
    _check_pass "container: ${name}"
  else
    _check_fail "postgres not healthy — check: docker compose logs postgres"
  fi
fi

# ── Check 13: redis healthy ──────────────────────────────────────────────────
if _check_begin 13 "redis_healthy" "redis is healthy" 11; then
  if _service_healthy "redis"; then
    _fact_set "redis_container" "$(_json_string "$(_container_name redis)")"
    _check_pass "healthy"
  else
    _check_fail "redis not healthy"
  fi
fi

# ── Check 14: rabbitmq healthy ───────────────────────────────────────────────
if _check_begin 14 "rabbitmq_healthy" "rabbitmq is healthy" 11; then
  if _service_healthy "rabbitmq"; then
    _fact_set "rabbitmq_container" "$(_json_string "$(_container_name rabbitmq)")"
    _check_pass "healthy"
  else
    _check_fail "rabbitmq not healthy"
  fi
fi

# ── Extra facts: file hashes for collusion detection ─────────────────────────
nginx_conf="${SCRIPT_DIR}/nginx/nginx.conf"
if [[ -f "$nginx_conf" ]]; then
  _fact_set "nginx_conf_sha256" "$(_json_string "$(_sha256_file "$nginx_conf")")"
fi

# Record the branch ancestry so the grader can detect branches forked from
# another student branch instead of main.
_fact_set "branch_parent_commits" "$(_json_string "$(git log --oneline --first-parent HEAD...$(git rev-parse origin/main 2>/dev/null || git rev-list --max-parents=0 HEAD) 2>/dev/null | wc -l | tr -d ' ')")"
_fact_set "branch_fork_point" "$(_json_string "$(git merge-base HEAD origin/main 2>/dev/null | cut -c1-12 || true)")"
_fact_set "branch_fork_point_subject" "$(_json_string "$(git log -1 --format='%s' "$(git merge-base HEAD origin/main 2>/dev/null)" 2>/dev/null || true)")"

# ── Check 15: backend responds ───────────────────────────────────────────────
if _check_begin 15 "backend_http" "backend /health returns 200" 11 12; then
  status=$(_http_status "${BACKEND_URL}/health")
  _fact_set "backend_health_status" "$(_json_string "${status}")"
  if [[ "$status" == "200" ]]; then
    name="$(_container_name backend)"
    img="$(_image_of "backend")"
    _fact_set "backend_container" "$(_json_string "${name}")"
    _fact_set "backend_image" "$(_json_string "${img}")"
    _check_pass "HTTP 200"
  else
    _check_fail "HTTP ${status:-no response} from ${BACKEND_URL}/health"
  fi
fi

# ── Check 16: backend image size ─────────────────────────────────────────────
if _check_begin 16 "backend_image_size" "backend image is under 300 MB" 15; then
  img="$(_image_of "backend")"
  if [[ -n "$img" ]]; then
    mb=$(_image_size_mb "$img")
    _fact_set "backend_image_size_mb" "${mb}"
    if (( mb < 300 )); then
      _check_pass "${mb} MB"
    else
      _check_fail "${mb} MB — use multi-stage to slim down the runtime image"
    fi
  else
    _check_skip "backend image not found"
  fi
fi

# ── Check 17: pgAdmin running ────────────────────────────────────────────────
if _check_begin 17 "pgadmin_running" "pgAdmin service is running" 11 12; then
  if _service_running "pgadmin"; then
    name="$(_container_name pgadmin)"
    _fact_set "pgadmin_container" "$(_json_string "${name}")"
    _check_pass "container: ${name}"
  else
    _check_fail "pgAdmin container not found — add the pgadmin service to docker-compose.yml"
  fi
fi

# ── Check 18: pgAdmin UI reachable ───────────────────────────────────────────
if _check_begin 18 "pgadmin_http" "pgAdmin is reachable on port 5050" 17; then
  status=$(_http_status "${PGADMIN_URL}")
  if [[ "$status" == "200" || "$status" == "302" || "$status" == "301" ]]; then
    _check_pass "HTTP ${status}"
  else
    _check_fail "HTTP ${status:-no response} from ${PGADMIN_URL}"
  fi
fi

# ── Check 19: frontend reachable ─────────────────────────────────────────────
if _check_begin 19 "frontend_http" "frontend is reachable on port 80" 11; then
  status=$(_http_status "${FRONTEND_URL}/")
  _fact_set "frontend_http_status" "$(_json_string "${status}")"
  if [[ "$status" == "200" ]]; then
    _check_pass "HTTP 200"
  else
    _check_fail "HTTP ${status:-no response} from ${FRONTEND_URL}/"
  fi
fi

# ── Check 20: nginx proxies /api/ to backend ─────────────────────────────────
if _check_begin 20 "nginx_api_proxy" "nginx proxies /api/ to the backend" 19 15; then
  body=$(_http_body "${FRONTEND_URL}/api/urls")
  if printf '%s' "$body" | grep -qE '\[|\]'; then
    _fact_set "nginx_api_proxy_sample" "$(_json_string "${body:0:80}")"
    _check_pass "GET /api/urls returned JSON array"
  else
    _check_fail "GET ${FRONTEND_URL}/api/urls did not return JSON — check nginx.conf location for /api/"
  fi
fi

# ── Check 21: shorten round-trip (POST → GET → DB) ───────────────────────────
if _check_begin 21 "shorten_roundtrip" "shorten a URL end-to-end" 20; then
  ts=$(date +%s 2>/dev/null || printf '%s' "$RANDOM")
  test_url="https://verify.test.life/${ts}"

  resp=$(curl -sf --max-time 10 \
    -X POST "${BACKEND_URL}/api/shorten" \
    -H "Content-Type: application/json" \
    -d "{\"url\":\"${test_url}\"}" 2>/dev/null || true)

  if printf '%s' "$resp" | grep -q '"code"'; then
    code=$(printf '%s' "$resp" | grep -o '"code":"[^"]*"' | head -1 | sed 's/"code":"//;s/"//')
    _fact_set "shorten_test_code" "$(_json_string "${code}")"
    _fact_set "shorten_test_url" "$(_json_string "${test_url}")"
    _check_pass "created code: ${code}"
  else
    _check_fail "POST /api/shorten did not return a code — resp: ${resp:0:120}"
  fi
fi

# ── Check 22: shortened URL is in PostgreSQL ─────────────────────────────────
if _check_begin 22 "db_row_exists" "shortened URLs are stored in PostgreSQL" 21 12; then
  pg_name="$(_container_name postgres)"
  if [[ -n "$pg_name" ]]; then
    count=$(docker exec "$pg_name" \
      psql -U life -d lifedb -t -c \
      "SELECT COUNT(*) FROM shortened_urls;" 2>/dev/null \
      | tr -d '[:space:]' || true)
    _fact_set "shortened_urls_count" "$(_json_string "${count}")"
    if [[ -n "$count" && "$count" -gt 0 ]] 2>/dev/null; then
      _check_pass "${count} row(s) in shortened_urls"
    else
      _check_fail "shortened_urls table is empty or unreachable (count=${count:-?})"
    fi
  else
    _check_skip "postgres container not found"
  fi
fi

# ── Check 23: loki is running ────────────────────────────────────────────────
if _check_begin 23 "loki_running" "Loki log aggregation is running" 11; then
  if _service_healthy "loki" || _service_running "loki"; then
    _fact_set "loki_container" "$(_json_string "$(_container_name loki)")"
    _check_pass "running"
  else
    _check_fail "Loki container not found or not running"
  fi
fi

# ── Check 24: grafana is running ─────────────────────────────────────────────
if _check_begin 24 "grafana_running" "Grafana is running" 11; then
  if _service_healthy "grafana" || _service_running "grafana"; then
    _fact_set "grafana_container" "$(_json_string "$(_container_name grafana)")"
    _check_pass "running"
  else
    _check_fail "Grafana container not found or not running"
  fi
fi

# ── Finalize ──────────────────────────────────────────────────────────────────
_lab_finalize
