# 03 — Deploy Student Registry to Kubernetes

## Purpose

Deploy the same Student Registry app from lecture 1 (PostgreSQL + .NET Backend + Next.js Frontend) to a Kubernetes cluster using raw manifests.

## Prerequisites

- Cluster running (see `01-cluster-setup/`)
- Ingress controller installed
- Docker images built from lecture 1 (each image’s `Dockerfile` lives in its own folder):

```bash
# From this directory: life-devops-labs/02-kubernetes/03-manifests/
docker build -t life-backend:1.0.0 ../../01-containers/07-debugging/backend/ -f ../../01-containers/07-debugging/backend/Dockerfile
docker build -t life-frontend:1.0.0 ../../01-containers/07-debugging/frontend/ -f ../../01-containers/07-debugging/frontend/Dockerfile
```

Use the **`backend/`** or **`frontend/`** path as the last argument (build context). Do **not** point at `07-debugging/` alone (there is no Dockerfile there), and you do **not** need `-f Dockerfile` unless you pass an explicit path to a file — a bare `-f Dockerfile` is read from your **current shell directory**, which often causes “no such file or directory”.

> **Minikube users:** Run `eval $(minikube docker-env)` BEFORE building so images end up inside minikube's Docker.

## Step-by-Step Deployment

### 1. Create the namespace

```bash
kubectl apply -f namespace.yaml
kubectl config set-context --current --namespace=life-app
```

### 2. Apply configuration

```bash
kubectl apply -f configmap.yaml
kubectl apply -f secret.yaml

kubectl get configmaps
kubectl get secrets
```

### 3. Deploy PostgreSQL

```bash
kubectl apply -f postgres.yaml

kubectl get pods -w
# Wait for Running + Ready (1/1)

kubectl logs -f deployment/postgres
```

### 4. Deploy Backend

```bash
kubectl apply -f backend.yaml

kubectl get pods -w
kubectl rollout status deployment/backend
```

Test it:
```bash
kubectl port-forward svc/backend-service 8080:80
# In another terminal:
curl http://localhost:8080/health
```

### 5. Deploy Frontend

```bash
kubectl apply -f frontend.yaml

kubectl get pods -w
kubectl rollout status deployment/frontend
```

Test it:
```bash
kubectl port-forward svc/frontend-service 3000:80
# Open http://localhost:3000
```

### 6. Configure Ingress

```bash
kubectl apply -f ingress.yaml

# Add to hosts file
# macOS/Linux:
echo "127.0.0.1 life.local" | sudo tee -a /etc/hosts
# Windows (run as admin):
# Add "127.0.0.1 life.local" to C:\Windows\System32\drivers\etc\hosts
```

> **Minikube users:** Use `$(minikube ip)` instead of `127.0.0.1`.

### 7. Verify everything

```bash
kubectl get all -n life-app
```

Open http://life.local — register your name!

```bash
# Check the database
kubectl exec -it deployment/postgres -- psql -U life -d lifedb \
  -c "SELECT * FROM life3_students;"
```

## Cleanup

```bash
kubectl delete -f .
# Or delete the entire namespace:
kubectl delete namespace life-app
```
