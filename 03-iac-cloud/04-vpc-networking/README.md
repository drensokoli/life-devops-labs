# 04 — VPC + Networking

## Purpose

Provision the foundational network: a VPC with two public subnets across two availability zones, an Internet Gateway, route tables, and security groups for web and database traffic.

## What gets created

```
VPC (10.0.0.0/16)
├── Public Subnet A (10.0.1.0/24, eu-central-1a)
├── Public Subnet B (10.0.2.0/24, eu-central-1b)
├── Internet Gateway
├── Route Table (default route → IGW)
├── Security Group: web (80, 443, 8080, 3000, 22 from anywhere)
└── Security Group: db (5432 from web SG only)
```

About 12 resources via the official `terraform-aws-modules/vpc/aws` module.

## Step 1 — Configure

```bash
cd 04-vpc-networking
cp terraform.tfvars.example terraform.tfvars
# Edit student_name
```

## Step 2 — Init / Plan / Apply

```bash
terraform init
terraform plan
terraform apply
```

Apply takes ~30 seconds. Note the outputs — you'll need `vpc_id` and the subnet IDs in the next lab.

## Step 3 — Verify

```bash
# List your VPC
aws ec2 describe-vpcs \
  --filters "Name=tag:Owner,Values=$(grep student_name terraform.tfvars | awk -F'"' '{print $2}')" \
  --query 'Vpcs[].{VPC:VpcId, CIDR:CidrBlock, Name:Tags[?Key==`Name`]|[0].Value}' \
  --output table

# Subnets
aws ec2 describe-subnets \
  --filters "Name=vpc-id,Values=$(terraform output -raw vpc_id)" \
  --query 'Subnets[].{Subnet:SubnetId, AZ:AvailabilityZone, CIDR:CidrBlock}' \
  --output table

# Security groups
aws ec2 describe-security-groups \
  --filters "Name=vpc-id,Values=$(terraform output -raw vpc_id)" \
  --query 'SecurityGroups[].{Name:GroupName, ID:GroupId}' \
  --output table
```

## Concepts demonstrated

### CIDR sizing

- VPC `10.0.0.0/16` = 65,536 IP addresses
- Each `/24` subnet = 256 IPs (5 reserved by AWS, so 251 usable)

### Why 2 AZs?

High availability. If one AZ fails, the other keeps serving. Required for RDS Multi-AZ (we won't use that today — costs extra).

### Why no NAT Gateway?

NAT Gateway = $32/month even idle. We'd need it for private subnets to reach the internet, but for this course everything goes in public subnets. **In production you would absolutely use NAT.**

### Security group composition

The DB security group's ingress rule says `security_groups = [aws_security_group.web.id]`, NOT a CIDR. This means only resources INSIDE the web SG can talk to the database — even if you knew the DB endpoint, your laptop couldn't connect. This is **fundamental cloud security** — least privilege at the network layer.

## Module deep dive

Look at what the VPC module created:

```bash
terraform state list
```

You'll see `module.vpc.aws_vpc.this[0]`, `module.vpc.aws_internet_gateway.this[0]`, several route tables, etc. Modules abstract this complexity but it's all real Terraform underneath.

## Cost estimate

- VPC, subnets, IGW, route tables: **$0.00** (free)
- Security groups: **$0.00** (free)

This lab costs nothing, **as long as you don't enable NAT Gateway or VPC Endpoints.**

## Cleanup

```bash
terraform destroy
```

You can destroy now or leave the VPC up — the next lab (`05-compute-storage/`) needs it. If you proceed to lab 5, leave it. Otherwise destroy.

## Cleanup checklist

- [ ] `terraform destroy` completes (or you're proceeding to lab 5)
- [ ] No leftover VPCs in your account except `default` (`aws ec2 describe-vpcs`)
