---
description: Review the current Dockerfile against LIFE DevOps course standards
---

Review the Dockerfile in the current context against these criteria and provide a checklist with pass/fail for each item:

1. **Multi-stage build** — is there a separate build and runtime stage?
2. **Non-root user** — is `USER 1001` (or a named non-root user) set in the final stage?
3. **HEALTHCHECK** — is a `HEALTHCHECK` instruction present?
4. **Pinned tags** — are all `FROM` images pinned to a specific version (not `:latest`)?
5. **Layer caching** — are dependency manifests (`*.csproj`, `package.json`, etc.) copied before the full source?
6. **Slim/Alpine base** — does the runtime stage use an Alpine or slim image?
7. **.dockerignore** — does a `.dockerignore` exist alongside this Dockerfile?

For each failure, explain the problem and show the corrected snippet.
