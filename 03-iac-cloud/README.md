# IaC and Cloud

All demos and labs for the Infrastructure as Code lecture.

> **MONEY WARNING:** This lecture uses real AWS resources. You can be charged real money if you don't follow the safety guides. Complete `00-pre-class-setup/` BEFORE the lecture and ALWAYS run `terraform destroy` at the end of every session.

## Demo Index

| # | Folder | Topic | When |
|---|--------|-------|------|
| 00 | `00-pre-class-setup/` | AWS account + billing alerts + IAM + CLI | **Before class** |
| 01 | `01-aws-setup/` | In-class verify checklist + IAM refresher | Part 1 |
| 02 | `02-terraform-basics/` | First Terraform: provider, resource, S3 bucket | Part 1 |
| 03 | `03-state-backend/` | Remote state in S3 + DynamoDB locking | Part 1 |
| 04 | `04-vpc-networking/` | VPC + subnets + IGW + security groups | Part 2 |
| 05 | `05-compute-storage/` | ECR + EC2 + RDS + S3 deploying Student Registry | Part 2 |
| 06 | `06-cicd-github-actions/` | OIDC IAM role + GitHub Actions deploy workflow | Part 2 |
| 07 | `07-iac-homework/` | Homework: full stack from scratch + verify | Homework |

## Prerequisites

- AWS account (free tier active) — created via `00-pre-class-setup/`
- AWS CLI v2 installed and configured (`aws --version`)
- Terraform >= 1.5 (`terraform version`)
- Docker images from lectures 1+2 (built locally)
- A code editor (VS Code or Cursor with HCL/Terraform extension)

## Region

We use `eu-central-1` (Frankfurt) consistently across all labs. Closest free-tier region for students in Kosovo/Albania.

## Cost Safety Rules

1. **Always** `terraform destroy` at the end of every session
2. **Never** commit AWS credentials, `.tfstate`, `*.tfstate.backup`, or `.tfvars` to git (`.gitignore` already handles this)
3. **Always** verify zero running compute after class:
   ```bash
   aws ec2 describe-instances --query 'Reservations[].Instances[?State.Name==`running`]' --output table
   aws rds describe-db-instances --output table
   ```
4. **Set up billing alerts** before any apply (covered in `00-pre-class-setup/`)
5. **Never** enable NAT Gateway, EKS, or db.t3.small+ — they cost money even when idle

## Repository structure inside this folder

Each demo folder follows this pattern:
```
0X-name/
├── README.md          # Step-by-step walkthrough
├── main.tf            # Resources
├── variables.tf       # Inputs
├── outputs.tf         # What to expose
├── versions.tf        # Provider pins
└── terraform.tfvars.example   # Template students copy
```

## How to use

Each folder has its own `README.md`. Work through them in order during the lecture or at home for practice. Every `terraform apply` should be followed by `terraform destroy` when you're done.
