# 04 — Kubernetes Operations

## Purpose

Practice scaling, rolling updates, rollbacks, and debugging with the Student Registry deployment from `03-manifests/`.

## Prerequisites

Student Registry deployed and running in `life-app` namespace (all pods healthy).

---

## Scaling

```bash
# Scale backend to 3 replicas
kubectl scale deployment backend --replicas=3

# Watch new pods appear
kubectl get pods -w -l app=backend

# Verify
kubectl get deployment backend
# READY 3/3

# Scale back down
kubectl scale deployment backend --replicas=2
```

---

## Rolling Update

```bash
# Rebuild the backend image with a "v2" tag
docker build -t life-backend:2.0.0 ../../01-containers/07-debugging/backend/

# Update the image
kubectl set image deployment/backend backend=life-backend:2.0.0

# Watch the rollout
kubectl rollout status deployment/backend

# Verify pods are running the new image
kubectl get pods -l app=backend -o jsonpath='{.items[*].spec.containers[0].image}'
```

---

## Rollback

```bash
# Check revision history
kubectl rollout history deployment/backend

# Rollback to previous version
kubectl rollout undo deployment/backend

# Watch it
kubectl rollout status deployment/backend

# Verify we're back to v1
kubectl get pods -l app=backend -o jsonpath='{.items[*].spec.containers[0].image}'
```

---

## Debugging Checklist

### Pod won't start

```bash
kubectl get pods
# STATUS: Pending / ImagePullBackOff / ErrImagePull / CrashLoopBackOff

kubectl describe pod <pod-name>
# Look at the Events section at the bottom

kubectl logs <pod-name>
kubectl logs <pod-name> --previous    # logs from crashed container
```

### Service not reachable

```bash
# Check the service exists and has endpoints
kubectl get svc backend-service
kubectl get endpoints backend-service
# If Endpoints is <none> → selector doesn't match any pod labels

# Verify labels match
kubectl get pods --show-labels
kubectl describe svc backend-service
```

### Shell into a pod

```bash
kubectl exec -it deployment/backend -- /bin/sh

# Inside: check env vars
env | grep POSTGRES

# Inside: test database connectivity
nc -zv postgres-service 5432

exit
```

### Resource usage

```bash
kubectl top pods -n life-app
kubectl top nodes
```

---

## Intentional Break Exercise

Try breaking things and fixing them:

```bash
# 1. Set a wrong image tag
kubectl set image deployment/backend backend=life-backend:doesnt-exist
kubectl get pods -w
# See ImagePullBackOff
kubectl rollout undo deployment/backend

# 2. Delete a pod and watch self-healing
kubectl delete pod <backend-pod-name>
kubectl get pods -w
# New pod appears automatically

# 3. Check what happens with wrong labels
kubectl patch svc backend-service -p '{"spec":{"selector":{"app":"wrong"}}}'
kubectl get endpoints backend-service
# Endpoints: <none> — service can't find any pods
# Fix it:
kubectl patch svc backend-service -p '{"spec":{"selector":{"app":"backend"}}}'
```
