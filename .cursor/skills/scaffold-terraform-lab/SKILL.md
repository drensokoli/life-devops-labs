---
name: scaffold-terraform-lab
description: Scaffold a Terraform lab module with proper structure, tagging, and cost-safe defaults
---

# Scaffold Terraform Lab

## When to use
Use when a student needs to create Terraform code for a new lab under `03-iac-cloud/`.

## Steps

1. **Determine what resources to create** from the lab README or student description.

2. **Create `versions.tf`**:
   ```hcl
   terraform {
     required_version = ">= 1.5"
     required_providers {
       aws = {
         source  = "hashicorp/aws"
         version = "~> 5.0"
       }
     }
   }

   provider "aws" {
     region = var.aws_region
   }
   ```

3. **Create `variables.tf`** — every variable needs `description` and `type`. Always include:
   - `student_name` (string)
   - `aws_region` with default `"eu-central-1"`

4. **Create `main.tf`** with:
   - `locals` block for `common_tags`
   - All resources tagged with `local.common_tags`
   - Free-tier instance sizes only (`t3.micro`, `db.t3.micro`)
   - Lab-safe destroy settings where applicable

5. **Create `outputs.tf`** — every output needs `description`. Mark secrets `sensitive = true`.

6. **Create `terraform.tfvars.example`** with placeholder values. Remind the student never to commit `terraform.tfvars`.

7. **Cost check** — before finishing, confirm the configuration contains none of the cost traps listed in `terraform.mdc`.
