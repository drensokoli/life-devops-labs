# 03 — Remote State Backend

## Purpose

Bootstrap an S3 bucket + DynamoDB table for storing Terraform state remotely. Then use that backend in a second module to demonstrate state sharing.

## The Chicken-and-Egg Problem

Terraform stores its state in a backend. If we want the backend to be S3, we need an S3 bucket — which is created by Terraform — but Terraform needs the bucket to exist before it can use it as a backend.

**Solution:** bootstrap the bucket and lock table with **local state**, then migrate everything else to use the **remote state**.

## Folder layout

```
03-state-backend/
├── bootstrap/      # Creates the state bucket + lock table (local state)
└── main/           # A normal module that USES the remote backend
```

## Step 1 — Bootstrap (creates the backend infrastructure)

```bash
cd bootstrap
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars

terraform init
terraform plan
terraform apply
```

Note the outputs:

```
state_bucket = "life-tf-state-dren-sokoli"
lock_table   = "life-tf-locks-dren-sokoli"
backend_config = ...
```

## Step 2 — Configure the main module to use that backend

```bash
cd ../main
```

Open `versions.tf`. Replace the `CHANGE-ME` placeholders in the `backend "s3"` block with your actual bucket and table names from Step 1:

```hcl
backend "s3" {
  bucket         = "life-tf-state-dren-sokoli"   # <-- your bucket
  key            = "demo/terraform.tfstate"
  region         = "eu-central-1"
  dynamodb_table = "life-tf-locks-dren-sokoli"   # <-- your table
  encrypt        = true
}
```

> Note: backend blocks **cannot use variables** — Terraform reads them before variables resolve. We edit them by hand or use partial configuration with `-backend-config=...`.

## Step 3 — Initialize with the remote backend

```bash
cp terraform.tfvars.example terraform.tfvars

terraform init
# Terraform asks if you want to migrate state to the new backend.
# Type 'yes'.

terraform plan
terraform apply
```

After apply, your state lives in S3, not on your laptop.

## Step 4 — Verify state is in S3

```bash
aws s3 ls s3://life-tf-state-dren-sokoli/demo/
# 2026-05-20 14:23:11      1234 terraform.tfstate

# Inspect from anywhere — same state visible
terraform state list
```

## Step 5 — Demonstrate locking

In one terminal:

```bash
terraform apply
# Hit 'yes' but DON'T let it finish — Ctrl+C mid-apply is fine for demo
```

In another terminal at the same time:

```bash
terraform apply
# Error: Error acquiring the state lock
# Lock Info:
#   ID:        ...
#   Path:      life-tf-state-dren-sokoli/demo/terraform.tfstate
```

DynamoDB blocked the second apply. No state corruption.

## Step 6 — DESTROY (in REVERSE order)

**Critical: destroy `main/` BEFORE `bootstrap/`** — otherwise you delete the backend before the resources that use it.

```bash
# In main/
terraform destroy

# Verify state is empty
terraform state list
# (no output)

# In bootstrap/
cd ../bootstrap
terraform destroy
```

> **Gotcha:** if you accidentally tried to destroy `bootstrap/` first, you'll need to manually empty the S3 bucket of all versions first. `aws s3 rm s3://... --recursive` and then delete versions.

## What You Learned

- Why local state is bad for teams
- The bootstrap pattern for backends
- How to migrate from local → remote state
- DynamoDB-based state locking
- Backend blocks cannot use variables (a Terraform footgun)

## Cost estimate

- S3 bucket: ~$0.00 for the few KB of state
- DynamoDB on-demand: ~$0.00 for the few requests we make

This lab is essentially free.

## Cleanup checklist

- [ ] `main/` destroyed
- [ ] `bootstrap/` destroyed
- [ ] `aws s3 ls` shows no `life-tf-state-*` buckets
- [ ] `aws dynamodb list-tables` shows no `life-tf-locks-*` tables
