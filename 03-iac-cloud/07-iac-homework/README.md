# 07 — IaC and Cloud Homework

> **Academic integrity:** AI assistance and collaboration are encouraged for learning.
> Each student must apply their own infrastructure to their own AWS account and submit their own receipt.
> Identical Terraform code is fine — identical receipts (same VPC IDs, etc.) will be flagged.
>
> **MONEY WARNING:** This homework provisions real AWS resources. Run `terraform destroy` IMMEDIATELY after generating your receipt. Set a 1-hour calendar alarm.

## Overview

You watched the instructor deploy a full stack to AWS. Now do it yourself, from a starter file with TODOs to fill in.

## What You Build

The same architecture as `05-compute-storage/` but in a separate VPC with the `07-iac-homework` tag — so the verify script can tell yours apart.

```
VPC (10.10.0.0/16)
├── 2 public subnets across 2 AZs
├── Internet Gateway + route table
├── Security Group: web (80, 443, 8080, 3000, 22)
├── Security Group: db (5432 from web SG only)
├── EC2 t3.micro with Docker (Amazon Linux 2023)
├── IAM role: ECR read + S3 + SSM
├── RDS PostgreSQL db.t3.micro
└── S3 bucket
```

## Tasks

### Task 0 — Prepare

```bash
cd 07-iac-homework/starter
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars and CHANGE THE DB PASSWORD
nano terraform.tfvars
```

### Task 1 — Complete the Starter

Open `starter/main.tf`. Fill in every `TODO`. The patterns you need are all in:
- `04-vpc-networking/main.tf` (VPC + SGs)
- `05-compute-storage/main.tf` (EC2, RDS, IAM, S3)

**Required tags on all resources:**
```hcl
tags = local.common_tags  # which contains Owner, Course, Lab=07-iac-homework, Managed
```

The verify script looks specifically for `Lab=07-iac-homework` tags. If you forget the tag, your VPC won't be found.

Don't forget to also fill in the TODOs in:
- `variables.tf` (instance_type, vpc_cidr)
- `outputs.tf` (vpc_id, ec2_public_ip, rds_address, app_bucket)

### Task 2 — Apply

```bash
terraform init
terraform plan
terraform apply
```

Expect ~20 resources, ~5-7 minutes.

### Task 3 — Deploy the Student Registry

Push the images to your ECR repos (created in lab 05) and deploy on the homework EC2:

```bash
# From this directory
EC2_IP=$(terraform output -raw ec2_public_ip)
RDS=$(terraform output -raw rds_address)

# Get ECR registry from lab 05's outputs
cd ../../05-compute-storage
REGISTRY=$(terraform output -raw ecr_registry)
BACKEND_REPO=$(terraform output -raw backend_repo_url)
FRONTEND_REPO=$(terraform output -raw frontend_repo_url)
cd -

# Tag your local images and push
aws ecr get-login-password | docker login --username AWS --password-stdin $REGISTRY
docker push $BACKEND_REPO:latest
docker push $FRONTEND_REPO:latest

# Connect to the homework EC2 via SSM (no SSH key needed if you used the same key from 05)
aws ssm start-session --target $(terraform output -raw ec2_instance_id)
```

Inside the EC2:
```bash
# ECR login
aws ecr get-login-password --region eu-central-1 | \
  docker login --username AWS --password-stdin <ECR_REGISTRY>

# Pull and run
docker run -d --name backend -p 8080:8080 \
  -e ConnectionStrings__Default="Host=<RDS_HOST>;Database=lifedb;Username=life;Password=<DB_PASS>" \
  <BACKEND_REPO>:latest

docker run -d --name frontend -p 3000:3000 <FRONTEND_REPO>:latest
```

### Task 4 — Verify

```bash
# Test backend health from your laptop
curl http://$EC2_IP:8080/health

# Open the frontend
echo "http://$EC2_IP:3000"

# Register a name. Verify it lands in the database.
psql -h <RDS_HOST> -U life -d lifedb -c "SELECT * FROM life3_students;"
```

### Task 5 — Run Verification

```bash
cd ..  # to 07-iac-homework/
chmod +x verify.sh
./verify.sh
```

The script checks 18 conditions and writes `lab-07-receipt.md`.

### Task 6 — Submit

```bash
git add lab-07-receipt.md starter/main.tf starter/variables.tf starter/outputs.tf
git commit -m "lab-07 submission"
git push origin <your-branch>
```

Upload `lab-07-receipt.md` to Moodle.

### Task 7 — DESTROY (CRITICAL)

```bash
cd starter
terraform destroy
# Type 'yes'
```

Then verify cleanup:

```bash
aws ec2 describe-instances \
  --filters "Name=tag:Lab,Values=07-iac-homework" "Name=instance-state-name,Values=running,pending,stopping,stopped" \
  --query 'Reservations[].Instances[].InstanceId' \
  --output table
# Should be empty

aws rds describe-db-instances \
  --query 'DBInstances[?starts_with(DBInstanceIdentifier, `life-hw-`)].DBInstanceIdentifier' \
  --output table
# Should be empty

aws s3 ls | grep life-hw
# Should be empty
```

## Submission Checklist

- [ ] All TODOs in `starter/` filled in
- [ ] `terraform apply` succeeds
- [ ] Frontend reachable at http://EC2_IP:3000
- [ ] Backend health endpoint returns 200
- [ ] Database query returns at least one registered name
- [ ] `verify.sh` shows score >= 16/18
- [ ] `lab-07-receipt.md` generated and pushed to your branch
- [ ] Receipt uploaded to Moodle
- [ ] **`terraform destroy` ran successfully**
- [ ] **Verified zero running EC2 / RDS / S3 buckets in your account**

## Tips

- Read `04-vpc-networking/main.tf` and `05-compute-storage/main.tf` carefully — most of what you need is there
- Use Cursor / Copilot — but understand what you're committing
- `terraform validate` catches syntax errors before you apply
- `terraform fmt` cleans up indentation
- If apply fails halfway, you can re-run `terraform apply` — Terraform picks up where it left off
- If RDS won't delete, set `skip_final_snapshot = true` and `deletion_protection = false`, then re-apply, then destroy

## Common gotchas

| Symptom | Likely cause | Fix |
|---------|-------------|-----|
| `Error: error reading VPC: ... not found` | Tag mismatch | Set `Lab = "07-iac-homework"` exactly |
| RDS won't destroy | Final snapshot or deletion protection | `skip_final_snapshot = true`, `deletion_protection = false` |
| Backend health endpoint returns 502 / refused | Container not running | `docker ps` on EC2; check `docker logs backend` |
| Backend running but DB error | Wrong host/password in connection string | Re-check terraform output `rds_address` |
| Verify "DB SG only allows 5432 from web SG" fails | DB SG allows 0.0.0.0/0 | Change to `security_groups = [aws_security_group.web.id]` |
