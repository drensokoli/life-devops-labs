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
RECEIPT_PATH="${SCRIPT_DIR}/lab-06-receipt.md"
NAMESPACE="life-app"

TOTAL=0
PASSED=0
RESULTS=()

check() {
  local id="$1" desc="$2"
  shift 2
  TOTAL=$((TOTAL + 1))

  if eval "$@" > /dev/null 2>&1; then
    PASSED=$((PASSED + 1))
    RESULTS+=("| $id | $desc | PASS |")
    printf "  ✓ %s — %s\n" "$id" "$desc"
  else
    RESULTS+=("| $id | $desc | **FAIL** |")
    printf "  ✗ %s — %s\n" "$id" "$desc"
  fi
}

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   Lab 06 — Kubernetes Homework Verify    ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# Pre-flight
if ! command -v kubectl &> /dev/null; then
  echo "ERROR: kubectl not found. Install it first."
  exit 1
fi

if ! kubectl cluster-info &> /dev/null; then
  echo "ERROR: Cannot reach Kubernetes cluster. Is it running?"
  exit 1
fi

echo "Running checks..."
echo ""

# --- Namespace ---
check "01" "Namespace life-app exists" \
  "kubectl get namespace $NAMESPACE"

# --- ConfigMap ---
check "02" "ConfigMap app-config exists" \
  "kubectl get configmap app-config -n $NAMESPACE"

check "03" "ConfigMap has ConnectionStrings__Default" \
  "kubectl get configmap app-config -n $NAMESPACE -o jsonpath='{.data.ConnectionStrings__Default}' | grep -q 'postgres-service'"

# --- Secret ---
check "04" "Secret db-credentials exists" \
  "kubectl get secret db-credentials -n $NAMESPACE"

check "05" "Secret has POSTGRES_USER" \
  "kubectl get secret db-credentials -n $NAMESPACE -o jsonpath='{.data.POSTGRES_USER}' | base64 -d | grep -q 'life'"

# --- PostgreSQL ---
check "06" "Postgres deployment exists" \
  "kubectl get deployment postgres -n $NAMESPACE"

check "07" "Postgres pod is Running" \
  "kubectl get pods -n $NAMESPACE -l app=postgres -o jsonpath='{.items[0].status.phase}' | grep -q Running"

check "08" "Postgres has readiness probe" \
  "kubectl get deployment postgres -n $NAMESPACE -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.exec.command}' | grep -q 'pg_isready'"

check "09" "Postgres has resource limits" \
  "kubectl get deployment postgres -n $NAMESPACE -o jsonpath='{.spec.template.spec.containers[0].resources.limits.memory}' | grep -q 'Mi'"

check "10" "Postgres service exists" \
  "kubectl get svc postgres-service -n $NAMESPACE"

# --- Backend ---
check "11" "Backend deployment exists" \
  "kubectl get deployment backend -n $NAMESPACE"

check "12" "Backend has 2+ replicas ready" \
  "[ \$(kubectl get deployment backend -n $NAMESPACE -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo 0) -ge 2 ]"

check "13" "Backend has liveness probe" \
  "kubectl get deployment backend -n $NAMESPACE -o jsonpath='{.spec.template.spec.containers[0].livenessProbe.httpGet.path}' | grep -q 'health'"

check "14" "Backend has readiness probe" \
  "kubectl get deployment backend -n $NAMESPACE -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet.path}' | grep -q 'health'"

check "15" "Backend has resource limits" \
  "kubectl get deployment backend -n $NAMESPACE -o jsonpath='{.spec.template.spec.containers[0].resources.limits.memory}' | grep -q 'Mi'"

check "16" "Backend service exists" \
  "kubectl get svc backend-service -n $NAMESPACE"

# --- Frontend ---
check "17" "Frontend deployment exists" \
  "kubectl get deployment frontend -n $NAMESPACE"

check "18" "Frontend has 2+ replicas ready" \
  "[ \$(kubectl get deployment frontend -n $NAMESPACE -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo 0) -ge 2 ]"

check "19" "Frontend has liveness probe" \
  "kubectl get deployment frontend -n $NAMESPACE -o jsonpath='{.spec.template.spec.containers[0].livenessProbe}' | grep -q 'httpGet'"

check "20" "Frontend has resource limits" \
  "kubectl get deployment frontend -n $NAMESPACE -o jsonpath='{.spec.template.spec.containers[0].resources.limits.memory}' | grep -q 'Mi'"

check "21" "Frontend service exists" \
  "kubectl get svc frontend-service -n $NAMESPACE"

# --- Ingress ---
check "22" "Ingress app-ingress exists" \
  "kubectl get ingress app-ingress -n $NAMESPACE"

check "23" "Ingress has host life.local" \
  "kubectl get ingress app-ingress -n $NAMESPACE -o jsonpath='{.spec.rules[0].host}' | grep -q 'life.local'"

# --- Application health ---
check "24" "Backend health endpoint responds (via port-forward)" \
  "kubectl port-forward svc/backend-service 18080:80 -n $NAMESPACE &
   PF_PID=\$!
   sleep 3
   STATUS=\$(curl -sf -o /dev/null -w '%{http_code}' http://localhost:18080/health 2>/dev/null || echo 000)
   kill \$PF_PID 2>/dev/null || true
   wait \$PF_PID 2>/dev/null || true
   [ \"\$STATUS\" = \"200\" ]"

# --- Summary ---
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
printf "  Result: %d / %d checks passed\n" "$PASSED" "$TOTAL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# --- Generate receipt ---
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
STUDENT=$(echo "$BRANCH" | sed 's/-/ /g')

cat > "$RECEIPT_PATH" <<EOF
# Lab 06 — Kubernetes Homework Receipt

| | |
|---|---|
| **Student** | ${STUDENT} |
| **Branch** | ${BRANCH} |
| **Commit** | ${COMMIT} |
| **Timestamp** | ${TIMESTAMP} |
| **Score** | ${PASSED} / ${TOTAL} |

## Results

| # | Check | Status |
|---|-------|--------|
$(printf '%s\n' "${RESULTS[@]}")

---

*Generated by verify.sh at ${TIMESTAMP}*
EOF

echo "Receipt written to: $RECEIPT_PATH"
echo ""
