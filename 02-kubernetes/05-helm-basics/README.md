# 05 — Helm Basics

## Purpose

Learn Helm as a consumer: install, upgrade, rollback, and inspect third-party charts. Compare Helm-managed PostgreSQL to the hand-written manifests from `03-manifests/`.

## What is Helm?

Helm is a package manager for Kubernetes. Charts are packages of templated YAML manifests. Instead of writing 60+ lines of YAML for PostgreSQL (Deployment + PVC + Service), you run one command.

---

## Step 1 — Add the Bitnami repository

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

## Step 2 — Search for PostgreSQL

```bash
helm search repo postgresql
```

You'll see `bitnami/postgresql` with the latest version.

## Step 3 — Remove hand-written PostgreSQL

```bash
# Delete our manual postgres so there's no conflict
kubectl delete -f ../03-manifests/postgres.yaml
```

## Step 4 — Install PostgreSQL via Helm

```bash
helm install life-postgres bitnami/postgresql \
  --namespace life-app \
  -f values-override.yaml
```

Watch it deploy:
```bash
kubectl get pods -w -n life-app
```

Verify:
```bash
helm list -n life-app
kubectl get all -n life-app -l app.kubernetes.io/name=postgresql
```

## Step 5 — Inspect what Helm generated

```bash
# See the actual YAML Helm applied to the cluster
helm get manifest life-postgres -n life-app | head -100

# See the values used
helm get values life-postgres -n life-app

# See all values (including defaults)
helm get values life-postgres -n life-app --all
```

Compare this to your hand-written `../03-manifests/postgres.yaml`. The Helm chart includes:
- Security contexts
- Resource limits
- Readiness/liveness probes
- Init containers
- Service account
- Network policies (optional)

All configured through one `values-override.yaml`.

## Step 6 — Upgrade with changed values

```bash
# Increase memory limit
helm upgrade life-postgres bitnami/postgresql \
  --namespace life-app \
  -f values-override.yaml \
  --set primary.resources.limits.memory=512Mi

# Check revision history
helm history life-postgres -n life-app
```

## Step 7 — Rollback

```bash
# Go back to revision 1
helm rollback life-postgres 1 -n life-app

# Verify
helm history life-postgres -n life-app
kubectl get pods -n life-app -l app.kubernetes.io/name=postgresql
```

## Step 8 — Explore the chart structure

```bash
# Download the chart locally to see what's inside
helm pull bitnami/postgresql --untar

ls postgresql/
# Chart.yaml  README.md  templates/  values.yaml

# Look at a template
cat postgresql/templates/primary/statefulset.yaml | head -50

# Look at the default values
cat postgresql/values.yaml | head -80
```

Charts are just templated YAML with Go template syntax (`{{ .Values.auth.database }}`). Values override the defaults.

## Step 9 — Clean up and restore

```bash
# Uninstall Helm release
helm uninstall life-postgres -n life-app

# Restore our hand-written version
kubectl apply -f ../03-manifests/postgres.yaml
```

## When to use Helm

| Use Helm for | Use raw manifests for |
|---|---|
| Third-party software (databases, monitoring, message brokers) | Your own application code |
| Multi-environment configs (dev/staging/prod via different values files) | Learning Kubernetes |
| Upgrade/rollback history | Simple deployments with few resources |
| Sharing deployment configs across teams | Full control and transparency |

## Key commands reference

```bash
helm repo add <name> <url>          # Add a chart repository
helm repo update                    # Refresh repo index
helm search repo <keyword>          # Find charts
helm install <release> <chart>      # Install a chart
helm upgrade <release> <chart>      # Upgrade with new values
helm rollback <release> <revision>  # Rollback to a revision
helm history <release>              # See revision history
helm get manifest <release>         # See generated YAML
helm get values <release>           # See applied values
helm uninstall <release>            # Remove everything
helm list                           # List installed releases
```
