---
name: scaffold-k8s-manifests
description: Scaffold Kubernetes Deployment, Service, ConfigMap, and Secret manifests for a given app
---

# Scaffold Kubernetes Manifests

## When to use
Use when a student needs to create Kubernetes manifests for an app and doesn't have them yet.

## Steps

1. **Gather info** (ask if not obvious from context):
   - App name and container image tag
   - Port the app listens on
   - Any environment variables needed (separate sensitive from non-sensitive)
   - Health check path (default `/health` for liveness, `/ready` for readiness)

2. **Create `deployment.yaml`** following `kubernetes.mdc` rules:
   - `imagePullPolicy: Never` (local dev default)
   - Both `livenessProbe` and `readinessProbe`
   - `resources.requests` and `resources.limits`
   - References to ConfigMap and/or Secret via `envFrom` or `env`

3. **Create `service.yaml`** — `ClusterIP` by default; `NodePort` if the student needs external access on Docker Desktop.

4. **Create `configmap.yaml`** for non-sensitive env vars.

5. **Create `secret.yaml`** using `stringData` for any sensitive values. Include a comment warning never to commit real secrets.

6. **Show the apply order**:
   ```bash
   kubectl apply -f configmap.yaml
   kubectl apply -f secret.yaml
   kubectl apply -f deployment.yaml
   kubectl apply -f service.yaml
   ```
