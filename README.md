# LIFE DevOps Labs

Lab repository for the LIFE from Gjirafa DevOps course.

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed and running
- [Git](https://git-scm.com/downloads)
- [VS Code](https://code.visualstudio.com/) or [Cursor](https://cursor.sh/)
- Terminal (iTerm2, Windows Terminal, or built-in)

## Getting Started

```bash
git clone https://github.com/drensokoli/life-devops-labs.git
cd life-devops-labs
git checkout -b emri-mbiemri   # Replace with your name, e.g. dren-sokoli
```

## Repository Structure

```
life-devops-labs/
├── 01-containers/          # Lecture 1: Docker & Containerization
│   ├── 01-layers-demo/
│   ├── 02-bad-dockerfile/
│   ├── 03-multistage-dotnet/
│   ├── 04-multistage-nextjs/
│   ├── 05-layer-caching/
│   ├── 06-healthcheck/
│   ├── 07-debugging/
│   └── 08-compose-fullstack/
├── 02-kubernetes/          # Lecture 2: Kubernetes (coming soon)
└── 03-iac-cloud/           # Lecture 3: IaC & Cloud (coming soon)
```

## How This Works

1. Each lecture has its own numbered folder with sequenced demos.
2. Work on your own branch (`emri-mbiemri`).
3. Use [Conventional Commits](https://www.conventionalcommits.org/): `feat:`, `fix:`, `chore:`, `docs:`.
4. Push your branch when done. The instructor will review your work.

## Commit Convention

```
feat: add multi-stage Dockerfile for backend
fix: correct postgres connection string
chore: add .dockerignore
docs: update README with setup instructions
```
