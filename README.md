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
├── week-01-containers/     # Week 1: Docker & Containerization
│   ├── theory/             # Part 1 demos (live coding during lecture)
│   └── practical/          # Part 2 lab (hands-on exercises)
├── week-02-kubernetes/     # Week 2: Kubernetes (coming soon)
└── week-03-iac-cloud/      # Week 3: IaC & Cloud (coming soon)
```

## How This Works

1. Each week has a `theory/` folder (demos the instructor runs during lecture) and a `practical/` folder (exercises you complete).
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
