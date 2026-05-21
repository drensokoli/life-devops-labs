#!/usr/bin/env bash
# verify.sh — Lab 07 (IaC and Cloud) completion check
#
# Run from the 07-iac-homework directory after terraform apply.
#
# Usage:
#   ./verify.sh
#
# Generates lab-07-receipt.md with pass/fail for each check.
# Reads STUDENT_NAME from terraform.tfvars (or pass as $1).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RECEIPT_PATH="${SCRIPT_DIR}/lab-07-receipt.md"

# Find student_name
if [ -n "${1:-}" ]; then
  STUDENT_NAME="$1"
elif [ -f "${SCRIPT_DIR}/starter/terraform.tfvars" ]; then
  STUDENT_NAME=$(grep -E '^\s*student_name' "${SCRIPT_DIR}/starter/terraform.tfvars" | sed -E 's/.*"(.*)".*/\1/')
elif [ -f "${SCRIPT_DIR}/terraform.tfvars" ]; then
  STUDENT_NAME=$(grep -E '^\s*student_name' "${SCRIPT_DIR}/terraform.tfvars" | sed -E 's/.*"(.*)".*/\1/')
else
  echo "ERROR: Cannot find student_name. Pass as first argument: ./verify.sh dren-sokoli"
  exit 1
fi

REGION="${AWS_REGION:-eu-central-1}"

TOTAL=0
PASSED=0
RESULTS=()

check() {
  local id="$1" desc="$2"
  shift 2
  TOTAL=$((TOTAL + 1))

  if eval "$@" > /dev/null 2>&1; then
    PASSED=$((PASSED + 1))
    RESULTS+=("| $id | $desc | PASS |")
    printf "  ✓ %s — %s\n" "$id" "$desc"
  else
    RESULTS+=("| $id | $desc | **FAIL** |")
    printf "  ✗ %s — %s\n" "$id" "$desc"
  fi
}

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║   Lab 07 — IaC and Cloud Homework Verify    ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
echo "Student: $STUDENT_NAME"
echo "Region:  $REGION"
echo ""

# Pre-flight
if ! command -v aws >/dev/null 2>&1; then
  echo "ERROR: aws CLI not installed."
  exit 1
fi

if ! aws sts get-caller-identity >/dev/null 2>&1; then
  echo "ERROR: AWS credentials not configured. Run: aws configure --profile life && export AWS_PROFILE=life"
  exit 1
fi

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "Account: $ACCOUNT_ID"
echo ""
echo "Running checks..."
echo ""

# ─── VPC + Networking ───
check "01" "VPC tagged Owner=$STUDENT_NAME exists" \
  "[ \$(aws ec2 describe-vpcs --region $REGION --filters 'Name=tag:Owner,Values=$STUDENT_NAME' 'Name=tag:Lab,Values=07-iac-homework' --query 'length(Vpcs)' --output text) -ge 1 ]"

VPC_ID=$(aws ec2 describe-vpcs --region "$REGION" \
  --filters "Name=tag:Owner,Values=$STUDENT_NAME" "Name=tag:Lab,Values=07-iac-homework" \
  --query 'Vpcs[0].VpcId' --output text 2>/dev/null || echo "")

check "02" "VPC has 2 public subnets" \
  "[ \$(aws ec2 describe-subnets --region $REGION --filters 'Name=vpc-id,Values=$VPC_ID' 'Name=tag:Name,Values=*public*' --query 'length(Subnets)' --output text) -eq 2 ]"

check "03" "Internet Gateway attached to VPC" \
  "[ \$(aws ec2 describe-internet-gateways --region $REGION --filters 'Name=attachment.vpc-id,Values=$VPC_ID' --query 'length(InternetGateways)' --output text) -ge 1 ]"

check "04" "NO NAT Gateway in this VPC (cost safety)" \
  "[ \$(aws ec2 describe-nat-gateways --region $REGION --filter 'Name=vpc-id,Values=$VPC_ID' 'Name=state,Values=available,pending' --query 'length(NatGateways)' --output text) -eq 0 ]"

# ─── Security Groups ───
check "05" "Web security group exists" \
  "aws ec2 describe-security-groups --region $REGION --filters 'Name=vpc-id,Values=$VPC_ID' 'Name=group-name,Values=life-hw-web-sg-$STUDENT_NAME'"

check "06" "DB security group exists" \
  "aws ec2 describe-security-groups --region $REGION --filters 'Name=vpc-id,Values=$VPC_ID' 'Name=group-name,Values=life-hw-db-sg-$STUDENT_NAME'"

check "07" "DB SG only allows 5432 from web SG (not 0.0.0.0/0)" \
  "[ \$(aws ec2 describe-security-groups --region $REGION --filters 'Name=group-name,Values=life-hw-db-sg-$STUDENT_NAME' --query 'SecurityGroups[0].IpPermissions[?FromPort==\`5432\`].IpRanges' --output text | wc -l) -eq 0 ]"

# ─── EC2 ───
check "08" "EC2 instance running with student tag" \
  "[ \$(aws ec2 describe-instances --region $REGION --filters 'Name=tag:Owner,Values=$STUDENT_NAME' 'Name=tag:Lab,Values=07-iac-homework' 'Name=instance-state-name,Values=running' --query 'length(Reservations[].Instances[])' --output text) -ge 1 ]"

INSTANCE_ID=$(aws ec2 describe-instances --region "$REGION" \
  --filters "Name=tag:Owner,Values=$STUDENT_NAME" "Name=tag:Lab,Values=07-iac-homework" "Name=instance-state-name,Values=running" \
  --query 'Reservations[0].Instances[0].InstanceId' --output text 2>/dev/null || echo "")

check "09" "EC2 is t3.micro (free tier)" \
  "[ \"\$(aws ec2 describe-instances --region $REGION --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].InstanceType' --output text)\" = 't3.micro' ]"

check "10" "EC2 has IAM instance profile attached" \
  "[ -n \"\$(aws ec2 describe-instances --region $REGION --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].IamInstanceProfile.Arn' --output text)\" ]"

# ─── RDS ───
check "11" "RDS PostgreSQL instance exists" \
  "aws rds describe-db-instances --region $REGION --db-instance-identifier life-hw-db-$STUDENT_NAME"

check "12" "RDS is db.t3.micro (free tier)" \
  "[ \"\$(aws rds describe-db-instances --region $REGION --db-instance-identifier life-hw-db-$STUDENT_NAME --query 'DBInstances[0].DBInstanceClass' --output text)\" = 'db.t3.micro' ]"

check "13" "RDS engine is postgres" \
  "[ \"\$(aws rds describe-db-instances --region $REGION --db-instance-identifier life-hw-db-$STUDENT_NAME --query 'DBInstances[0].Engine' --output text)\" = 'postgres' ]"

check "14" "RDS Multi-AZ disabled (cost safety)" \
  "[ \"\$(aws rds describe-db-instances --region $REGION --db-instance-identifier life-hw-db-$STUDENT_NAME --query 'DBInstances[0].MultiAZ' --output text)\" = 'False' ]"

# ─── S3 ───
check "15" "App S3 bucket exists with student tag" \
  "[ \$(aws s3api list-buckets --query 'Buckets[?starts_with(Name, \`life-hw-$STUDENT_NAME-\`)] | length(@)' --output text) -ge 1 ]"

# ─── IAM ───
check "16" "EC2 IAM role exists" \
  "aws iam get-role --role-name life-hw-ec2-role-$STUDENT_NAME"

# ─── Application reachability ───
EC2_IP=$(aws ec2 describe-instances --region "$REGION" \
  --instance-ids "$INSTANCE_ID" \
  --query 'Reservations[0].Instances[0].PublicIpAddress' --output text 2>/dev/null || echo "")

check "17" "Backend health endpoint reachable on port 8080" \
  "[ \"\$(curl -sf -o /dev/null -w '%{http_code}' --max-time 10 http://$EC2_IP:8080/health 2>/dev/null || echo 000)\" = '200' ]"

# ─── Cost discipline ───
SPEND=$(aws ce get-cost-and-usage \
  --time-period Start="$(date -u +%Y-%m-01)",End="$(date -u +%Y-%m-%d)" \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --query 'ResultsByTime[0].Total.BlendedCost.Amount' \
  --output text 2>/dev/null || echo "0")

check "18" "Month-to-date spend < \$5 (currently \$$SPEND)" \
  "awk -v s='$SPEND' 'BEGIN { exit !(s < 5) }'"

# ─── Summary ───
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
printf "  Result: %d / %d checks passed\n" "$PASSED" "$TOTAL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ─── Generate receipt ───
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

cat > "$RECEIPT_PATH" <<EOF
# Lab 07 — IaC and Cloud Homework Receipt

| | |
|---|---|
| **Student** | $STUDENT_NAME |
| **Branch** | $BRANCH |
| **Commit** | $COMMIT |
| **AWS Account** | $ACCOUNT_ID |
| **Region** | $REGION |
| **Timestamp** | $TIMESTAMP |
| **MTD Spend** | \$$SPEND |
| **Score** | $PASSED / $TOTAL |

## Results

| # | Check | Status |
|---|-------|--------|
$(printf '%s\n' "${RESULTS[@]}")

---

## REMINDER

After submitting this receipt, you MUST run:

\`\`\`bash
cd starter
terraform destroy
\`\`\`

Then verify nothing remains:

\`\`\`bash
aws ec2 describe-instances --filters "Name=tag:Owner,Values=$STUDENT_NAME" "Name=instance-state-name,Values=running"
aws rds describe-db-instances --query 'DBInstances[?starts_with(DBInstanceIdentifier, \`life-hw-\`)]'
\`\`\`

*Generated by verify.sh at $TIMESTAMP*
EOF

echo "Receipt written to: $RECEIPT_PATH"
echo ""
echo "REMINDER: run terraform destroy after submitting!"
echo ""
