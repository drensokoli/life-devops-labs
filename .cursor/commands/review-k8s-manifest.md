---
description: Review Kubernetes YAML manifests against LIFE DevOps course standards
---

Review the Kubernetes manifest(s) in the current context and check:

1. **Probes** — does every container have both `livenessProbe` and `readinessProbe`?
2. **Resource limits** — does every container have `resources.requests` AND `resources.limits`?
3. **Label alignment** — do the `Deployment` selector labels match the pod template labels and the `Service` selector?
4. **Secrets vs ConfigMaps** — is sensitive config in a `Secret` (using `stringData`) rather than a `ConfigMap`?
5. **imagePullPolicy** — is `imagePullPolicy: Never` set for locally-built images?
6. **Service DNS** — are inter-pod connections using service names, not hardcoded IPs?

For each failure, explain the problem and provide the corrected YAML snippet.
