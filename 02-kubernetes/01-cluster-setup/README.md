# 01 — Cluster Setup

## Purpose

Verify your local Kubernetes cluster is running and kubectl is configured.

## Option A: Docker Desktop (Recommended)

1. Open Docker Desktop
2. Go to **Settings → Kubernetes**
3. Check **Enable Kubernetes**
4. Click **Apply & Restart**
5. Wait for the Kubernetes status to show green

## Option B: Minikube (Fallback)

```bash
# Install minikube (if not already)
# macOS: brew install minikube
# Windows: choco install minikube
# Linux: https://minikube.sigs.k8s.io/docs/start/

minikube start --driver=docker --cpus=4 --memory=4096
```

## Verify

```bash
# Check kubectl talks to the cluster
kubectl cluster-info

# See your node
kubectl get nodes
# NAME             STATUS   ROLES           AGE   VERSION
# docker-desktop   Ready    control-plane   1m    v1.29.x

# Check system pods are running
kubectl get pods -n kube-system
```

## Install Helm

```bash
# macOS
brew install helm

# Windows
choco install kubernetes-helm

# Linux
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verify
helm version
```

## Enable Ingress Controller

```bash
# Docker Desktop
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.0/deploy/static/provider/cloud/deploy.yaml

# Minikube
minikube addons enable ingress

# Verify (wait ~60s for it to start)
kubectl get pods -n ingress-nginx
```

## What to observe

- `kubectl get nodes` shows one node in `Ready` status
- `kubectl get pods -n kube-system` shows core components running (coredns, etcd, kube-apiserver, etc.)
- The ingress controller pod is running in `ingress-nginx` namespace
