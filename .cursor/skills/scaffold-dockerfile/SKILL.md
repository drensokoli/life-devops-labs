---
name: scaffold-dockerfile
description: Scaffold a production-ready Dockerfile for a given app type following LIFE DevOps course standards
---

# Scaffold Dockerfile

## When to use
Use when a student asks to create a Dockerfile for their app and there isn't one yet.

## Steps

1. **Detect app type** — look at files in the directory:
   - `*.csproj` → .NET
   - `package.json` with Next.js dependency → Next.js
   - `package.json` without Next.js → generic Node.js
   - `requirements.txt` / `pyproject.toml` → Python

2. **Generate the Dockerfile** using the appropriate pattern from the rules (see `dockerfile.mdc`).

3. **Generate a `.dockerignore`** alongside it:

   For Node.js:
   ```
   node_modules
   .next
   .git
   *.md
   ```

   For .NET:
   ```
   bin
   obj
   .git
   *.md
   ```

4. **Confirm the HEALTHCHECK endpoint** — ask the student what path the app serves its health check on (default `/health`).

5. **Output** both files and explain each layer's purpose in 1 sentence per stage.
