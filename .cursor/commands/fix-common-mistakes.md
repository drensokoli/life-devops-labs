---
description: Scan the current file for common DevOps mistakes and fix them
---

Scan the current file for these common mistakes and fix every one you find. After fixing, list what was changed and why.

**Docker / Compose mistakes**
- `localhost` used as a hostname to reach another container → replace with the service name
- `:latest` image tag → suggest a pinned version
- `COPY . .` before `RUN npm install` or `RUN dotnet restore` → reorder for layer caching
- Missing `USER` instruction in final stage → add `USER 1001`
- Missing `HEALTHCHECK` → add one appropriate for the app

**Kubernetes mistakes**
- Missing `livenessProbe` or `readinessProbe` → add sensible HTTP probes
- Missing `resources` block → add requests/limits
- Pod selector mismatch with Service → align labels
- `imagePullPolicy` not set to `Never` for local images → add it

**Terraform mistakes**
- Missing tags → add `Owner`, `Course`, `Lecture`, `Lab`, `Managed`
- `enable_nat_gateway = true` → warn and remove (cost trap)
- `multi_az = true` → warn and remove (cost trap)
- Instance type larger than `t3.micro` → downsize
- Missing `skip_final_snapshot = true` on RDS → add it
- Hardcoded region other than `eu-central-1` → flag it
