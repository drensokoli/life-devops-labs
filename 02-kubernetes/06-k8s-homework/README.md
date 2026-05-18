# 06 — Kubernetes Homework: Student Registry

> **Before you start — read this.**
>
> You may discuss this homework with classmates and you may use AI tools to help you understand concepts or debug problems.
>
> However, **every student must complete and submit this individually on their own laptop.** This means:
>
> - Your manifests must be written and applied by you, not copied from someone else.
> - `./verify.sh` must be run on your own machine while your cluster is actually running.
> - Every submission is reviewed individually during grading.
>
> Working in a group to understand the material is fine. Handing in someone else's work is not.

## Overview

In class you watched the Student Registry get deployed step by step. Now you deploy it yourself from scratch using the starter manifests provided.

You are given:

- The **backend** and **frontend** Docker images from Lab 01 (already built)
- A `starter/` folder with partial manifests — most have `# TODO` comments for you to fill in
- `verify.sh` — run it to check your work and generate a tamper-proof receipt

You need to:

1. Build the Docker images
2. Complete the starter manifests and copy them to a `manifests/` folder
3. Deploy everything to the `life-app` namespace
4. Add probes and resource limits to all deployments
5. Scale and perform a rolling update
6. Run `verify.sh` and submit

---

## The App: Student Registry

A minimal student registration service:

- **Backend** — .NET 8 REST API
  - `POST /api/students` — register a student by name
  - `GET /api/students` — list all registered students
  - `GET /health` — returns 200 when the database is reachable
- **Frontend** — Next.js 14 UI that calls the backend API
- **PostgreSQL** — stores `life3_students` table (auto-created on startup)

---

## Tasks

### Task 1 — Build Docker Images

```bash
# From the repo root — run eval $(minikube docker-env) first if you are on minikube
docker build -t life-backend:1.0.0 life-devops-labs/01-containers/07-debugging/backend/
docker build \
  --build-arg NEXT_PUBLIC_API_URL=http://life.local/api \
  -t life-frontend:1.0.0 \
  life-devops-labs/01-containers/07-debugging/frontend/
```

> **Minikube users:** Run `eval $(minikube docker-env)` before building so images land inside minikube's Docker, not your host's.

> **`NEXT_PUBLIC_` gotcha:** Next.js inlines environment variables that start with `NEXT_PUBLIC_` at build time into the JavaScript bundle. They are not injected at runtime. You must pass the API URL as a `--build-arg` when building the image — setting it in the Kubernetes manifest has no effect.

### Task 2 — Complete the Starter Manifests

Copy the starter files to a working folder:

```bash
cp -r starter/ manifests/
cd manifests/
```

Fill in every `# TODO` comment. Here is what each file needs:

| File | What to fill in |
|------|----------------|
| `namespace.yaml` | Ready to use — no changes needed |
| `configmap.yaml` | `POSTGRES_HOST`, `POSTGRES_DB`, and `ConnectionStrings__Default` |
| `secret.yaml` | `POSTGRES_USER` and `POSTGRES_PASSWORD` |
| `postgres.yaml` | Resource requests/limits and a `readinessProbe` using `pg_isready` |
| `backend.yaml` | Write the full Deployment + Service (see spec in the file) |
| `frontend.yaml` | Write the full Deployment + Service (see spec in the file) |
| `ingress.yaml` | Add path rules: `/api(/|$)(.*)` → backend, `/()(.*)` → frontend |

### Task 3 — Deploy Everything

```bash
kubectl apply -f namespace.yaml
kubectl config set-context --current --namespace=life-app

kubectl apply -f configmap.yaml -f secret.yaml
kubectl apply -f postgres.yaml

# Wait for postgres to be ready before continuing
kubectl get pods -w

kubectl apply -f backend.yaml
kubectl apply -f frontend.yaml
kubectl apply -f ingress.yaml
```

### Task 4 — Add Probes and Resource Limits

Ensure **all three deployments** (postgres, backend, frontend) have:

- **Liveness probe** — httpGet to the health or root endpoint
- **Readiness probe** — httpGet to the health or root endpoint
- **Resource requests** — `memory` and `cpu`
- **Resource limits** — `memory` and `cpu`

The postgres starter already shows the pattern — apply the same to backend and frontend.

### Task 5 — Test the Application

```bash
# Add to /etc/hosts if not already done
echo "127.0.0.1 life.local" | sudo tee -a /etc/hosts

# Open http://life.local and register your name
# Then confirm the row is in the database
kubectl exec -it deployment/postgres -- psql -U life -d lifedb \
  -c "SELECT * FROM life3_students;"
```

### Task 6 — Scale and Rolling Update

```bash
# Scale backend to 3 replicas
kubectl scale deployment backend --replicas=3
kubectl get pods -l app=backend

# Trigger a rolling update by bumping an env var or image tag
kubectl set env deployment/backend APP_VERSION=v2
kubectl rollout status deployment/backend

# Rollback
kubectl rollout undo deployment/backend
```

### Task 7 — Run the Verification Script

```bash
# From the 06-k8s-homework/ directory, on your personal branch
chmod +x verify.sh
./verify.sh
```

The script runs 25 checks, writes `lab-06-receipt.md` with your results and an encrypted diagnostic blob, and prints a score. You can re-run it as many times as you like — it overwrites the previous receipt each time.

---

## Verification

**The script requires you to be on a personal branch** — not `main`. Your branch must follow the format `firstname-lastname-id` (all lowercase, hyphens only). Create it before running:

```bash
git checkout -b jane-doe-s12345
```

**Submission requires two steps — both are mandatory:**

**1. GitHub** — commit everything and push to your personal branch:

```bash
git add .
git commit -m "lab-06 submission"
git push origin jane-doe-s12345
```

**2. Moodle** — upload the `lab-06-receipt.md` file to the Moodle assignment.

Your submission is only complete when both are done.

---

## Checklist

Before you submit, make sure:

- [ ] All pods are `Running` — `kubectl get pods` shows no CrashLoopBackOff
- [ ] `http://life.local` loads the Student Registry UI
- [ ] Registering a name inserts a row — verify with `psql` or `kubectl exec`
- [ ] All deployments have liveness probes, readiness probes, and resource limits
- [ ] Backend scales to 3 replicas and rolling update completes cleanly
- [ ] `./verify.sh` passes all 25 checks and produces `lab-06-receipt.md`
- [ ] You are on a personal branch (`firstname-lastname-id`), not `main`
- [ ] Receipt pushed to GitHub and uploaded to Moodle

---

## Tips

- `kubectl describe pod <name>` is your best friend for debugging — always check `Events` at the bottom.
- `kubectl logs <pod> --previous` shows logs from a crashed container.
- If images aren't found, check `imagePullPolicy: Never` is set and you built the image inside minikube's Docker.
- The Ingress `rewrite-target: /$2` annotation strips the path prefix — this is why the path rules use capture groups like `/api(/|$)(.*)`.
- `depends_on` does not exist in Kubernetes — use `readinessProbe` to ensure pods only receive traffic when healthy.
- The `/api` ingress rule must come **before** the `/` catch-all rule, otherwise all requests match `/` first.

---

## Windows users

`verify.sh` is a Bash script — it will not run in PowerShell or CMD.

**Use WSL2** (Windows Subsystem for Linux 2). Docker Desktop for Windows automatically enables WSL2 integration, so your cluster is reachable from inside WSL2 without any extra setup.

**If you have never opened WSL2 before:**

1. Open **PowerShell as Administrator** and run:
   ```powershell
   wsl --install
   ```
   Restart when prompted.

2. Open the **Ubuntu** app from the Start menu (or run `wsl` in a terminal).

3. Inside the WSL2 shell, navigate to your homework folder. Your Windows drives are mounted at `/mnt/c/`, `/mnt/d/`, etc.:
   ```bash
   cd /mnt/c/Users/YourName/path/to/06-k8s-homework
   ```

4. Run the verification script normally:
   ```bash
   ./verify.sh
   ```

`kubectl` commands work inside WSL2 automatically when Docker Desktop's WSL2 integration is enabled.
