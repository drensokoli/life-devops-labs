# 05 — Compute, Storage, and the Student Registry on AWS

## Purpose

Provision ECR + EC2 + RDS + S3 to deploy the Student Registry app from lecture 1 to real AWS infrastructure.

## Prerequisites

- `04-vpc-networking/` already applied (VPC + subnets + SGs must exist)
- Backend image built locally:
  ```bash
  docker build -t life-backend:1.0.0 ../../01-containers/07-debugging/backend/
  docker build -t life-frontend:1.0.0 ../../01-containers/07-debugging/frontend/
  ```

## What gets created

```
ECR  ──► life-backend repository
        life-frontend repository

EC2  ──► t3.micro Amazon Linux 2023 with Docker installed (cloud-init)
        IAM role: ECR read + S3 read/write + SSM
        SSH keypair (auto-generated, saved to life-key.pem)

RDS  ──► db.t3.micro PostgreSQL 16
        Subnet group across 2 AZs
        Publicly accessible (demo only — never in real life!)

S3   ──► life-app-<name>-<suffix> bucket for logs/backups
```

About 20 resources. Apply takes ~5-7 minutes (RDS is the slowest).

## Step 1 — Configure

```bash
cd 05-compute-storage
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars and CHANGE THE DB PASSWORD
nano terraform.tfvars
```

## Step 2 — Apply

```bash
terraform init
terraform plan
terraform apply
```

Go grab water. RDS takes a while. ~5 min.

## Step 3 — Push the Docker images to ECR

```bash
# Login Docker to ECR
aws ecr get-login-password --region eu-central-1 | \
  docker login --username AWS --password-stdin $(terraform output -raw ecr_registry)

# Tag and push backend
docker tag life-backend:1.0.0 $(terraform output -raw backend_repo_url):latest
docker push $(terraform output -raw backend_repo_url):latest

# Tag and push frontend
docker tag life-frontend:1.0.0 $(terraform output -raw frontend_repo_url):latest
docker push $(terraform output -raw frontend_repo_url):latest

# Verify
aws ecr describe-images --repository-name life-backend-$(grep student_name terraform.tfvars | awk -F'"' '{print $2}') --query 'imageDetails[].imageTags' --output table
```

## Step 4 — SSH into the EC2 instance

```bash
# The key file was generated in this directory
ls -l life-key.pem  # should show -rw------- (0600)

# SSH
$(terraform output -raw ssh_command)
# Or if that didn't work:
ssh -i life-key.pem ec2-user@$(terraform output -raw ec2_public_ip)
```

> First-time SSH on Mac/Linux: type `yes` to accept the host key.

## Step 5 — Run the backend on EC2

Inside the EC2 instance:

```bash
# Login to ECR (helper script was placed by cloud-init)
~/ecr-login.sh

# Pull and run the backend
docker pull <PASTE backend_repo_url>:latest

docker run -d \
  --name backend \
  --restart unless-stopped \
  -p 8080:8080 \
  -e ASPNETCORE_URLS=http://+:8080 \
  -e ConnectionStrings__Default="Host=<PASTE rds_address>;Database=lifedb;Username=life;Password=<YOUR DB PASSWORD>" \
  <PASTE backend_repo_url>:latest

# Watch the logs as it connects
docker logs -f backend

# Test it
curl http://localhost:8080/health
```

> **Tip:** instead of pasting outputs, you can do it from your laptop:
> ```bash
> ssh -i life-key.pem ec2-user@$(terraform output -raw ec2_public_ip) \
>   "docker run -d --name backend -p 8080:8080 \
>     -e ConnectionStrings__Default='$(terraform output -raw connection_string)' \
>     $(terraform output -raw backend_repo_url):latest"
> ```

## Step 6 — Run the frontend on EC2

Still on the EC2:

```bash
docker pull <PASTE frontend_repo_url>:latest

docker run -d \
  --name frontend \
  --restart unless-stopped \
  -p 3000:3000 \
  -e NEXT_PUBLIC_API_URL="http://<EC2_PUBLIC_IP>:8080" \
  <PASTE frontend_repo_url>:latest

docker logs -f frontend
```

## Step 7 — Visit the app from your laptop

```bash
echo "Frontend: http://$(terraform output -raw ec2_public_ip):3000"
echo "Backend:  http://$(terraform output -raw ec2_public_ip):8080/health"
```

Open the frontend URL in your browser. Register your name. Same Student Registry from lecture 1, now running on AWS.

## Step 8 — Verify the database

```bash
# From your laptop (RDS is publicly accessible — demo only!)
psql -h $(terraform output -raw rds_address) -U life -d lifedb \
  -c "SELECT * FROM life3_students;"
# It will prompt for the password from terraform.tfvars
```

Or via SSM Session Manager (no SSH key needed):

```bash
aws ssm start-session --target $(terraform output -raw ec2_instance_id)
```

## Cost reality check

What this is costing per hour:

| Resource | Free tier | Cost (post-free-tier) |
|----------|-----------|---------------------|
| EC2 t3.micro | 750 hr/month free | $0.0104/hr |
| RDS db.t3.micro | 750 hr/month free | $0.017/hr |
| EBS 8 GB gp3 | 30 GB/month free | $0.08/GB/month |
| ECR storage | 500 MB free | $0.10/GB/month |
| S3 standard | 5 GB free | $0.023/GB/month |
| Data transfer out | 100 GB/month free | $0.09/GB |

**For class duration: $0.00**
**If left running 1 month: ~$20.50** (after free tier expires)

## Step 9 — DESTROY (CRITICAL)

```bash
# Stop the running containers first (cleaner)
ssh -i life-key.pem ec2-user@$(terraform output -raw ec2_public_ip) \
  "docker stop backend frontend; docker rm backend frontend"

# Then destroy AWS resources
terraform destroy
```

Type `yes` when prompted. RDS deletion takes ~5 min.

## Verify nothing is left

```bash
# No EC2 instances?
aws ec2 describe-instances \
  --filters "Name=tag:Owner,Values=YOUR-NAME" "Name=instance-state-name,Values=running,pending,stopping,stopped" \
  --query 'Reservations[].Instances[].InstanceId' \
  --output table

# No RDS?
aws rds describe-db-instances \
  --query 'DBInstances[?starts_with(DBInstanceIdentifier, `life-db-`)].DBInstanceIdentifier' \
  --output table

# No ECR images charging us for storage?
aws ecr describe-repositories \
  --query 'repositories[?starts_with(repositoryName, `life-`)].repositoryName' \
  --output table

# Check current spend
aws ce get-cost-and-usage \
  --time-period Start=$(date -u +%Y-%m-01),End=$(date -u +%Y-%m-%d) \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --query 'ResultsByTime[].Total.BlendedCost.Amount' \
  --output text
```

If anything shows up — destroy it manually before logging off.

## Cleanup checklist

- [ ] `terraform destroy` ran successfully
- [ ] No running EC2 instances
- [ ] No RDS instances
- [ ] No ECR repositories with images
- [ ] Daily spend < $1
- [ ] `life-key.pem` deleted (or kept somewhere safe)
