---
description: Review Terraform code against LIFE DevOps course standards and cost safety rules
---

Review the Terraform code in the current context and check:

1. **Region** — is `eu-central-1` used?
2. **Instance sizes** — are instance types `t3.micro` / `db.t3.micro` (free-tier safe)?
3. **Tags** — does every resource have the required tags: `Owner`, `Course`, `Lecture`, `Lab`, `Managed`?
4. **locals block** — are tags defined via `locals.common_tags` and referenced consistently?
5. **Variable declarations** — do all variables have `description` and `type`?
6. **Output declarations** — do all outputs have `description`? Are secrets marked `sensitive = true`?
7. **Provider/module pinning** — are providers pinned in `versions.tf`? Are module sources versioned?
8. **Lab destroy settings** — for RDS: `skip_final_snapshot = true`, `deletion_protection = false`; for ECR: `force_delete = true`
9. **Cost traps** — flag any `enable_nat_gateway = true`, `multi_az = true`, oversized instances, or detached Elastic IPs

For each failure, explain the issue and show the corrected HCL.
