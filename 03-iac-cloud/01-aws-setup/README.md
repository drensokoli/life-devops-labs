# 01 — AWS Setup Verification

## Purpose

Quick in-class verification that your environment is ready. **You should have already completed `00-pre-class-setup/` before today.**

## Verify Everything Is Working

Run these commands. Every one must succeed.

```bash
# 1. AWS CLI installed
aws --version
# Expected: aws-cli/2.x.x

# 2. Terraform installed
terraform version
# Expected: Terraform v1.5.x or higher

# 3. AWS profile set
echo $AWS_PROFILE
# Expected: life
# If empty: export AWS_PROFILE=life  (or set in your shell)

# 4. Logged in as the IAM user (NOT root)
aws sts get-caller-identity
# Expected Arn: arn:aws:iam::<your-account-id>:user/terraform-student

# 5. Region is eu-central-1
aws configure get region
# Expected: eu-central-1
```

## Verify Cost Safety Is Configured

```bash
# 6. Billing alerts enabled (run in us-east-1, where billing metrics live)
aws cloudwatch describe-alarms \
  --region us-east-1 \
  --alarm-name-prefix "billing-alarm" \
  --query 'MetricAlarms[].AlarmName' \
  --output table
# Expected: at least one alarm listed

# 7. Budget exists
aws budgets describe-budgets \
  --account-id $(aws sts get-caller-identity --query Account --output text) \
  --query 'Budgets[].BudgetName' \
  --output table
# Expected: life-devops-monthly-cap (or similar)

# 8. Current month spend
aws ce get-cost-and-usage \
  --time-period Start=$(date -u +%Y-%m-01),End=$(date -u +%Y-%m-%d) \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --query 'ResultsByTime[0].Total.BlendedCost.Amount' \
  --output text
# Expected: a small number (< $1 unless you've been experimenting)
```

## IAM Quick Reference

While we use `terraform-student` (admin) for learning, in production:

| Identity Type | Use For | Lifecycle |
|--------------|---------|-----------|
| Root user | Account creation, billing changes | Permanent — keep MFA, never use day-to-day |
| IAM user | Human access (CLI / Console) | Permanent credentials, rotate every 90 days |
| IAM role | Services (EC2, Lambda, GitHub Actions) | No permanent credentials — temporary tokens |
| IAM Identity Center (SSO) | Org-wide human access | SSO-managed, no static keys |

## Permission Boundaries (mentioned, not used today)

In real organizations, even admin users have **permission boundaries** — a maximum-allowed policy that can't be exceeded even if you try. We won't use them today, but know they exist.

## Tag Everything

Every resource we create today must be tagged:

```hcl
tags = {
  Owner   = var.student_name
  Course  = "LIFE-DevOps"
  Lecture = "03-iac-cloud"
  Managed = "terraform"
}
```

This makes it possible to find and destroy your resources later. We'll use a `local` for these tags so they're applied consistently.

## What If Something Failed?

| Failure | Fix |
|---------|-----|
| `aws: command not found` | Install AWS CLI v2 (see `00-pre-class-setup/`) |
| `Arn` ends in `:root` | You're using root. Switch to `terraform-student` profile |
| `Unable to locate credentials` | `aws configure --profile life`, then `export AWS_PROFILE=life` |
| Region is wrong | `aws configure set region eu-central-1 --profile life` |
| No billing alarms | Go back to Step 4 of `00-pre-class-setup/` |

## Ready?

If all 8 commands above succeeded — you're cleared for the rest of the lecture. Move on to `02-terraform-basics/`.
