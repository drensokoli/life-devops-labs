# 06 — Kubernetes Homework

> **Academic integrity:** Collaboration and AI tools are welcome for learning and research.
> However, every student must write and apply their own manifests individually.
> Identical submissions will be flagged.

## Overview

During class you watched the Student Registry get deployed step by step. Now it's your turn — deploy it yourself using the starter manifests provided.

## What's Provided

- `starter/` folder with partial manifests — most have TODOs for you to fill in
- `verify.sh` — run it to check your work and generate a receipt

## What You Build

Complete the manifests so the following resources run in the `life-app` namespace:

| Resource | Service Name | Port |
|----------|-------------|------|
| PostgreSQL | `postgres-service` | 5432 |
| .NET Backend | `backend-service` | 80 → 8080 |
| Next.js Frontend | `frontend-service` | 80 → 3000 |
| Ingress | `app-ingress` | 80 (host: life.local) |

## Tasks

### Task 1 — Build Docker Images

Build the Student Registry images from lecture 1:

```bash
docker build -t life-backend:1.0.0 ../../../01-containers/07-debugging/backend/
docker build -t life-frontend:1.0.0 ../../../01-containers/07-debugging/frontend/
```

> **Minikube users:** Run `eval $(minikube docker-env)` first.

### Task 2 — Complete the Starter Manifests

Copy the `starter/` manifests to a working folder and fill in all `# TODO` comments:

```bash
cp -r starter/ manifests/
cd manifests/
```

Each file has specific TODOs:
- **namespace.yaml** — ready to use (no changes needed)
- **configmap.yaml** — fill in the connection string and database name
- **secret.yaml** — fill in the credentials
- **postgres.yaml** — add readiness probe, resource limits, and PVC
- **backend.yaml** — write the full Deployment + Service
- **frontend.yaml** — write the full Deployment + Service
- **ingress.yaml** — add path rules for frontend and backend

### Task 3 — Deploy Everything

```bash
kubectl apply -f namespace.yaml
kubectl config set-context --current --namespace=life-app
kubectl apply -f configmap.yaml -f secret.yaml
kubectl apply -f postgres.yaml
# Wait for postgres to be ready
kubectl get pods -w
kubectl apply -f backend.yaml
kubectl apply -f frontend.yaml
kubectl apply -f ingress.yaml
```

### Task 4 — Verify the Application Works

```bash
# Add to /etc/hosts if not already done
echo "127.0.0.1 life.local" | sudo tee -a /etc/hosts

# Open http://life.local and register your name
# Check the database
kubectl exec -it deployment/postgres -- psql -U life -d lifedb \
  -c "SELECT * FROM life3_students;"
```

### Task 5 — Add Probes and Resource Limits

Ensure ALL deployments have:
- **Liveness probe** (httpGet to health/root endpoint)
- **Readiness probe** (httpGet to health/root endpoint)
- **Resource requests** (memory + cpu)
- **Resource limits** (memory + cpu)

### Task 6 — Scale and Rolling Update

```bash
# Scale backend to 3 replicas
kubectl scale deployment backend --replicas=3
kubectl get pods -l app=backend

# Perform a rolling update (rebuild with v2 tag or just change an env var)
kubectl set image deployment/backend backend=life-backend:2.0.0
kubectl rollout status deployment/backend

# Rollback
kubectl rollout undo deployment/backend
```

### Task 7 — Run the Verification Script

```bash
cd ..
chmod +x verify.sh
./verify.sh
```

The script generates `lab-06-receipt.md` with your results.

## Submission

1. **Push to GitHub:**
```bash
git add -A
git commit -m "feat: complete kubernetes homework"
git push origin <your-branch>
```

2. **Upload to Moodle:** Submit the `lab-06-receipt.md` file.

## Checklist

- [ ] Namespace `life-app` exists
- [ ] ConfigMap and Secret are created
- [ ] PostgreSQL is running and healthy
- [ ] Backend is running with 2+ replicas
- [ ] Frontend is running with 2+ replicas
- [ ] All pods have liveness and readiness probes
- [ ] All pods have resource requests and limits
- [ ] Ingress routes `/` to frontend and `/api` to backend
- [ ] Student registration works through http://life.local
- [ ] Successfully scaled backend to 3 replicas
- [ ] Successfully performed a rolling update and rollback
- [ ] `verify.sh` passes and receipt is generated
- [ ] Pushed to your branch on GitHub
- [ ] Receipt uploaded to Moodle

## Tips

- `kubectl describe pod <name>` is your best friend for debugging
- `kubectl logs <pod> --previous` shows logs from a crashed container
- If images aren't found, check `imagePullPolicy: Never` is set
- On minikube, build images inside minikube's Docker: `eval $(minikube docker-env)`
- Windows users: run `verify.sh` from WSL2 or Git Bash
