#!/usr/bin/env bash
# verify.sh — Lab 06 (Kubernetes) completion check
#
# Run from the 06-k8s-homework directory while your cluster is running.
#
# Usage:
#   ./verify.sh
#
# Generates lab-06-receipt.md with pass/fail for each check.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_TOOLS_DIR="$(cd "${SCRIPT_DIR}/../../lab-tools" && pwd)"
RECEIPT_PATH="${SCRIPT_DIR}/lab-06-receipt.md"

# ── Sanity: lab-tools must be present ────────────────────────────────────────
if [[ ! -f "${LAB_TOOLS_DIR}/_lib.sh" ]]; then
  printf '\nERROR: lab-tools/_lib.sh not found at %s\n' "${LAB_TOOLS_DIR}/_lib.sh" >&2
  printf 'Make sure you cloned the full repo and have not deleted lab-tools/.\n\n' >&2
  exit 1
fi

# shellcheck source=../../lab-tools/_lib.sh
source "${LAB_TOOLS_DIR}/_lib.sh"

# ── Constants ─────────────────────────────────────────────────────────────────
LAB_NAME="06-k8s-homework"
TOTAL_CHECKS=25
NAMESPACE="life-app"
MANIFESTS_DIR="${SCRIPT_DIR}/manifests"

_lab_init "${LAB_NAME}" "${RECEIPT_PATH}" "${TOTAL_CHECKS}"

# ── Pre-flight ────────────────────────────────────────────────────────────────
if ! command -v kubectl &> /dev/null; then
  printf '\nERROR: kubectl not found. Install it first.\n\n' >&2
  exit 1
fi

if ! kubectl cluster-info &> /dev/null; then
  printf '\nERROR: Cannot reach Kubernetes cluster. Is it running?\n\n' >&2
  exit 1
fi

# ── Check 01: branch name ─────────────────────────────────────────────────────
if _check_begin 1 "branch" "On a personal branch (not main)"; then
  branch="$(_get_current_branch)"
  if _is_valid_branch_name "$branch"; then
    _check_pass "branch: ${branch}"
  else
    _check_fail "branch is '${branch:-unknown}' — checkout your personal branch first"
  fi
fi

# ── Check 02: Namespace ───────────────────────────────────────────────────────
if _check_begin 2 "namespace" "Namespace life-app exists"; then
  if kubectl get namespace "${NAMESPACE}" > /dev/null 2>&1; then
    _check_pass "${NAMESPACE}"
  else
    _check_fail "namespace '${NAMESPACE}' not found — apply namespace.yaml"
  fi
fi

# ── Check 03: ConfigMap exists ────────────────────────────────────────────────
if _check_begin 3 "configmap" "ConfigMap app-config exists" 2; then
  if kubectl get configmap app-config -n "${NAMESPACE}" > /dev/null 2>&1; then
    _check_pass "app-config"
  else
    _check_fail "ConfigMap app-config not found"
  fi
fi

# ── Check 04: ConfigMap has connection string ─────────────────────────────────
if _check_begin 4 "configmap_connstr" "ConfigMap has ConnectionStrings__Default" 3; then
  val=$(kubectl get configmap app-config -n "${NAMESPACE}" \
        -o jsonpath='{.data.ConnectionStrings__Default}' 2>/dev/null || true)
  if printf '%s' "$val" | grep -q 'postgres-service'; then
    _check_pass "points to postgres-service"
  else
    _check_fail "ConnectionStrings__Default missing or doesn't reference postgres-service"
  fi
fi

# ── Check 05: Secret exists ───────────────────────────────────────────────────
if _check_begin 5 "secret" "Secret db-credentials exists" 2; then
  if kubectl get secret db-credentials -n "${NAMESPACE}" > /dev/null 2>&1; then
    _check_pass "db-credentials"
  else
    _check_fail "Secret db-credentials not found"
  fi
fi

# ── Check 06: Secret has POSTGRES_USER ───────────────────────────────────────
if _check_begin 6 "secret_user" "Secret has POSTGRES_USER" 5; then
  val=$(kubectl get secret db-credentials -n "${NAMESPACE}" \
        -o jsonpath='{.data.POSTGRES_USER}' 2>/dev/null \
        | base64 -d 2>/dev/null || true)
  if [[ -n "$val" ]]; then
    _check_pass "user: ${val}"
  else
    _check_fail "POSTGRES_USER key missing or empty"
  fi
fi

# ── Check 07: Postgres deployment exists ─────────────────────────────────────
if _check_begin 7 "postgres_deploy" "Postgres deployment exists" 2; then
  if kubectl get deployment postgres -n "${NAMESPACE}" > /dev/null 2>&1; then
    _check_pass "postgres"
  else
    _check_fail "deployment/postgres not found"
  fi
fi

# ── Check 08: Postgres pod is Running ────────────────────────────────────────
if _check_begin 8 "postgres_running" "Postgres pod is Running" 7; then
  phase=$(kubectl get pods -n "${NAMESPACE}" -l app=postgres \
          -o jsonpath='{.items[0].status.phase}' 2>/dev/null || true)
  if [[ "$phase" == "Running" ]]; then
    _check_pass "Running"
  else
    _check_fail "phase=${phase:-not found}"
  fi
fi

# ── Check 09: Postgres has readiness probe ───────────────────────────────────
if _check_begin 9 "postgres_readiness" "Postgres has readiness probe" 7; then
  probe=$(kubectl get deployment postgres -n "${NAMESPACE}" \
          -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.exec.command}' \
          2>/dev/null || true)
  if printf '%s' "$probe" | grep -q 'pg_isready'; then
    _check_pass "pg_isready probe found"
  else
    _check_fail "readinessProbe with pg_isready not found"
  fi
fi

# ── Check 10: Postgres has resource limits ───────────────────────────────────
if _check_begin 10 "postgres_limits" "Postgres has resource limits" 7; then
  mem=$(kubectl get deployment postgres -n "${NAMESPACE}" \
        -o jsonpath='{.spec.template.spec.containers[0].resources.limits.memory}' \
        2>/dev/null || true)
  if [[ -n "$mem" ]]; then
    _check_pass "memory limit: ${mem}"
  else
    _check_fail "resources.limits.memory not set"
  fi
fi

# ── Check 11: Postgres service exists ────────────────────────────────────────
if _check_begin 11 "postgres_svc" "Postgres service exists" 2; then
  if kubectl get svc postgres-service -n "${NAMESPACE}" > /dev/null 2>&1; then
    _check_pass "postgres-service"
  else
    _check_fail "service/postgres-service not found"
  fi
fi

# ── Check 12: Backend deployment exists ──────────────────────────────────────
if _check_begin 12 "backend_deploy" "Backend deployment exists" 2; then
  if kubectl get deployment backend -n "${NAMESPACE}" > /dev/null 2>&1; then
    _check_pass "backend"
  else
    _check_fail "deployment/backend not found"
  fi
fi

# ── Check 13: Backend has 2+ replicas ready ───────────────────────────────────
if _check_begin 13 "backend_replicas" "Backend has 2+ replicas ready" 12; then
  ready=$(kubectl get deployment backend -n "${NAMESPACE}" \
          -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo 0)
  if [[ "${ready:-0}" -ge 2 ]]; then
    _check_pass "${ready} replicas ready"
  else
    _check_fail "${ready:-0} replicas ready — expected at least 2"
  fi
fi

# ── Check 14: Backend has liveness probe ─────────────────────────────────────
if _check_begin 14 "backend_liveness" "Backend has liveness probe" 12; then
  path=$(kubectl get deployment backend -n "${NAMESPACE}" \
         -o jsonpath='{.spec.template.spec.containers[0].livenessProbe.httpGet.path}' \
         2>/dev/null || true)
  if printf '%s' "$path" | grep -q 'health'; then
    _check_pass "path: ${path}"
  else
    _check_fail "livenessProbe.httpGet.path not set to /health"
  fi
fi

# ── Check 15: Backend has readiness probe ────────────────────────────────────
if _check_begin 15 "backend_readiness" "Backend has readiness probe" 12; then
  path=$(kubectl get deployment backend -n "${NAMESPACE}" \
         -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet.path}' \
         2>/dev/null || true)
  if printf '%s' "$path" | grep -q 'health'; then
    _check_pass "path: ${path}"
  else
    _check_fail "readinessProbe.httpGet.path not set to /health"
  fi
fi

# ── Check 16: Backend has resource limits ────────────────────────────────────
if _check_begin 16 "backend_limits" "Backend has resource limits" 12; then
  mem=$(kubectl get deployment backend -n "${NAMESPACE}" \
        -o jsonpath='{.spec.template.spec.containers[0].resources.limits.memory}' \
        2>/dev/null || true)
  if [[ -n "$mem" ]]; then
    _check_pass "memory limit: ${mem}"
  else
    _check_fail "resources.limits.memory not set"
  fi
fi

# ── Check 17: Backend service exists ─────────────────────────────────────────
if _check_begin 17 "backend_svc" "Backend service exists" 2; then
  if kubectl get svc backend-service -n "${NAMESPACE}" > /dev/null 2>&1; then
    _check_pass "backend-service"
  else
    _check_fail "service/backend-service not found"
  fi
fi

# ── Check 18: Frontend deployment exists ─────────────────────────────────────
if _check_begin 18 "frontend_deploy" "Frontend deployment exists" 2; then
  if kubectl get deployment frontend -n "${NAMESPACE}" > /dev/null 2>&1; then
    _check_pass "frontend"
  else
    _check_fail "deployment/frontend not found"
  fi
fi

# ── Check 19: Frontend has 2+ replicas ready ──────────────────────────────────
if _check_begin 19 "frontend_replicas" "Frontend has 2+ replicas ready" 18; then
  ready=$(kubectl get deployment frontend -n "${NAMESPACE}" \
          -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo 0)
  if [[ "${ready:-0}" -ge 2 ]]; then
    _check_pass "${ready} replicas ready"
  else
    _check_fail "${ready:-0} replicas ready — expected at least 2"
  fi
fi

# ── Check 20: Frontend has liveness probe ────────────────────────────────────
if _check_begin 20 "frontend_liveness" "Frontend has liveness probe" 18; then
  probe=$(kubectl get deployment frontend -n "${NAMESPACE}" \
          -o jsonpath='{.spec.template.spec.containers[0].livenessProbe}' \
          2>/dev/null || true)
  if printf '%s' "$probe" | grep -q 'httpGet'; then
    _check_pass "httpGet probe found"
  else
    _check_fail "livenessProbe not set"
  fi
fi

# ── Check 21: Frontend has resource limits ───────────────────────────────────
if _check_begin 21 "frontend_limits" "Frontend has resource limits" 18; then
  mem=$(kubectl get deployment frontend -n "${NAMESPACE}" \
        -o jsonpath='{.spec.template.spec.containers[0].resources.limits.memory}' \
        2>/dev/null || true)
  if [[ -n "$mem" ]]; then
    _check_pass "memory limit: ${mem}"
  else
    _check_fail "resources.limits.memory not set"
  fi
fi

# ── Check 22: Frontend service exists ────────────────────────────────────────
if _check_begin 22 "frontend_svc" "Frontend service exists" 2; then
  if kubectl get svc frontend-service -n "${NAMESPACE}" > /dev/null 2>&1; then
    _check_pass "frontend-service"
  else
    _check_fail "service/frontend-service not found"
  fi
fi

# ── Check 23: Ingress exists ─────────────────────────────────────────────────
if _check_begin 23 "ingress" "Ingress app-ingress exists" 2; then
  if kubectl get ingress app-ingress -n "${NAMESPACE}" > /dev/null 2>&1; then
    _check_pass "app-ingress"
  else
    _check_fail "ingress/app-ingress not found"
  fi
fi

# ── Check 24: Ingress has host life.local ────────────────────────────────────
if _check_begin 24 "ingress_host" "Ingress has host life.local" 23; then
  host=$(kubectl get ingress app-ingress -n "${NAMESPACE}" \
         -o jsonpath='{.spec.rules[0].host}' 2>/dev/null || true)
  if printf '%s' "$host" | grep -q 'life.local'; then
    _check_pass "host: ${host}"
  else
    _check_fail "first rule host is '${host:-not set}' — expected life.local"
  fi
fi

# ── Check 25: Backend health endpoint responds ───────────────────────────────
if _check_begin 25 "backend_health" "Backend health endpoint responds (via port-forward)" 13 17; then
  kubectl port-forward svc/backend-service 18080:80 -n "${NAMESPACE}" > /dev/null 2>&1 &
  PF_PID=$!
  sleep 3
  STATUS=$(curl -sf -o /dev/null -w '%{http_code}' http://localhost:18080/health 2>/dev/null || echo 000)
  kill "$PF_PID" 2>/dev/null || true
  wait "$PF_PID" 2>/dev/null || true
  if [[ "$STATUS" == "200" ]]; then
    _check_pass "HTTP 200"
  else
    _check_fail "HTTP ${STATUS} from /health"
  fi
fi

# ── Extra facts for anti-collusion ────────────────────────────────────────────
for f in namespace configmap secret postgres backend frontend ingress; do
  manifest="${MANIFESTS_DIR}/${f}.yaml"
  if [[ -f "$manifest" ]]; then
    _fact_set "${f}_yaml_sha256" "$(_json_string "$(_sha256_file "$manifest")")"
  fi
done

_fact_set "branch_parent_commits" "$(_json_string "$(git log --oneline --first-parent HEAD...$(git rev-parse origin/main 2>/dev/null || git rev-list --max-parents=0 HEAD) 2>/dev/null | wc -l | tr -d ' ')")"
_fact_set "branch_fork_point"     "$(_json_string "$(git merge-base HEAD origin/main 2>/dev/null | cut -c1-12 || true)")"
_fact_set "branch_fork_point_subject" "$(_json_string "$(git log -1 --format='%s' "$(git merge-base HEAD origin/main 2>/dev/null)" 2>/dev/null || true)")"

_fact_set "kubectl_context"       "$(_json_string "$(kubectl config current-context 2>/dev/null || true)")"
_fact_set "kubectl_server"        "$(_json_string "$(kubectl cluster-info 2>/dev/null | head -1 || true)")"

# ── Finalize ──────────────────────────────────────────────────────────────────
_lab_finalize
