# Kubernetes

All demos and labs for the Kubernetes lecture.

## Demo Index

| # | Folder | Topic | Session |
|---|--------|-------|---------|
| 01 | `01-cluster-setup/` | Verify cluster, kubectl basics | Part 1 |
| 02 | `02-api-demo/` | kubectl as a REST client (`-v=8`) | Part 1 |
| 03 | `03-manifests/` | Deploy Student Registry to K8s | Part 2 |
| 04 | `04-operations/` | Scaling, rolling update, rollback, debugging | Part 2 |
| 05 | `05-helm-basics/` | Helm install, upgrade, rollback (bitnami/postgresql) | Part 2 |
| 06 | `06-k8s-homework/` | Homework: complete starter manifests + verify | Homework |

## Prerequisites

- Docker Desktop with Kubernetes enabled **OR** minikube
- kubectl installed (`kubectl version --client`)
- Helm installed (`helm version`)
- Docker images from lecture 1 (built from `01-containers/07-debugging/`)

## How to use

Each folder has its own README with step-by-step commands. Work through them in order during the lecture or at home for practice.
