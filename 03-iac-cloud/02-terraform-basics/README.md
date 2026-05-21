# 02 — Terraform Basics

## Purpose

Your first Terraform run. Create an S3 bucket, upload an object, then destroy it cleanly.

## Files in this folder

- `versions.tf` — provider pins (Terraform >= 1.5, AWS provider 5.x)
- `variables.tf` — inputs (region, student name)
- `main.tf` — the actual resources
- `outputs.tf` — values to expose after apply
- `terraform.tfvars.example` — template for your inputs

## Step 1 — Set your variables

```bash
cd 02-terraform-basics
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars and set student_name to your kebab-case name
```

## Step 2 — Initialize

```bash
terraform init
```

What this does:
- Downloads the AWS provider plugin (~10 MB)
- Creates `.terraform/` directory and `.terraform.lock.hcl`
- Verifies the backend (we're using local state today)

## Step 3 — Plan

```bash
terraform plan
```

Read the plan carefully. You should see:
- `+ create` for `random_id.suffix`
- `+ create` for `aws_s3_bucket.lab`
- `+ create` for `aws_s3_bucket_public_access_block.lab`
- `+ create` for `aws_s3_bucket_versioning.lab`
- `+ create` for `aws_s3_object.hello`

**Plan: 5 to add, 0 to change, 0 to destroy.**

## Step 4 — Apply

```bash
terraform apply
# Type 'yes' when prompted
```

After ~15 seconds you'll see the outputs:
```
bucket_name   = "life-lab-dren-sokoli-a1b2c3d4"
bucket_arn    = "arn:aws:s3:::life-lab-dren-sokoli-a1b2c3d4"
bucket_region = "eu-central-1"
```

## Step 5 — Verify in AWS

```bash
# List buckets via CLI
aws s3 ls | grep life-lab

# Read the object back
aws s3 cp s3://$(terraform output -raw bucket_name)/hello.txt -

# Or via console:
# https://s3.console.aws.amazon.com/s3/buckets
```

## Step 6 — Make a change (re-apply pattern)

Open `main.tf` and change the content:
```hcl
content = "Hello from Terraform — owner: ${var.student_name} v2"
```

```bash
terraform plan
# Notice: "1 to change" — just the object content
terraform apply
```

This is the magic of declarative IaC — Terraform diffs your code vs reality and only changes what's different.

## Step 7 — Inspect the state

```bash
terraform state list
# Shows all tracked resources

terraform state show aws_s3_bucket.lab
# Detailed view of one resource

terraform output
# All outputs
```

## Step 8 — DESTROY

**Always do this when done:**

```bash
terraform destroy
# Type 'yes' when prompted
```

You should see **5 to destroy**. Confirm.

```bash
# Verify it's gone
aws s3 ls | grep life-lab
# (no output)
```

## Common Issues

| Error | Cause | Fix |
|-------|-------|-----|
| `BucketAlreadyExists` | S3 bucket names are globally unique | The `random_id` suffix should prevent this. Re-run init. |
| `AccessDenied` | Wrong IAM user or missing permission | `aws sts get-caller-identity` — confirm you're `terraform-student` |
| `InvalidLocationConstraint` | Region mismatch | Check `aws_region` in tfvars matches your CLI default |
| `Failed to query available provider packages` | Network or version pin issue | Check internet, re-run `terraform init -upgrade` |

## What You Learned

- The init/plan/apply/destroy workflow
- Variables, locals, outputs, resources
- Using `random_id` for unique naming
- Reading and trusting the plan output
- The S3 public access block (security default)

## Cleanup checklist

- [ ] `terraform destroy` ran successfully
- [ ] `aws s3 ls` shows no `life-lab-*` buckets
- [ ] You're ready for `03-state-backend/`
