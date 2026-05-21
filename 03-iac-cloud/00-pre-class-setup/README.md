# 00 — Pre-Class AWS Setup

> **DO THIS BEFORE THE LECTURE.** Allow ~45 minutes. You cannot follow along live without an AWS account, billing alerts, an IAM user, and AWS CLI installed.

## Checklist

By the end of this guide, you will have:

- [ ] An AWS account with verified email and payment method
- [ ] Billing preferences enabled (so alarms can fire)
- [ ] An AWS Budget set to **$20** with alerts at 50% and 80%
- [ ] CloudWatch billing alarms at $1, $5, and $10
- [ ] An IAM user named `terraform-student` with admin access (lab use only)
- [ ] AWS CLI v2 installed and configured locally
- [ ] Terraform >= 1.5 installed locally

---

## Step 1 — Create an AWS Account

> If you already have an AWS account, skip to Step 2.

1. Go to https://aws.amazon.com/free/
2. Click **Create a Free Account**
3. Use your real email (you'll need it for billing)
4. Choose a strong root password — store it in a password manager
5. **Personal account** type
6. Provide payment method (you won't be charged if you stay in free tier)
7. Verify phone number
8. Choose **Basic Support — Free**

Sign in to the console: https://console.aws.amazon.com

---

## Step 2 — Enable Billing Alerts (CRITICAL)

> Without this, NO billing alarms will work, even if you create them.

1. Sign in as **root user** (top-right says your email/account name)
2. Click your account name → **Billing and Cost Management**
3. In the left sidebar: **Billing preferences**
4. Check ALL of:
   - **Receive AWS Free Tier alerts**
   - **Receive Billing alerts**
   - **Receive PDF invoices**
5. Save

---

## Step 3 — Create an AWS Budget

1. Still in **Billing and Cost Management**
2. Left sidebar: **Budgets** → **Create a budget**
3. Choose **Customize (advanced)**
4. **Budget type:** Cost budget
5. **Budget name:** `life-devops-monthly-cap`
6. **Period:** Monthly
7. **Budget effective date:** Recurring
8. **Budgeted amount:** `$20.00 USD` (your hard cap for the course)
9. **Alerts:**
   - Threshold 1: **50% of budgeted** → email yourself
   - Threshold 2: **80% of budgeted** → email yourself
   - Threshold 3: **100% of forecasted** → email yourself
10. Save

> **Why $20?** You won't spend $20 — you'll spend pennies. But the budget gives you a buffer if something goes wrong, and you'll get an early warning long before damage is done.

---

## Step 4 — Create CloudWatch Billing Alarms

> Belt-and-suspenders backup to the budget. CloudWatch alarms fire faster.

1. Switch region to **us-east-1** (billing metrics only live there)
2. Go to **CloudWatch** → **Alarms** → **All alarms** → **Create alarm**
3. **Select metric** → **Billing** → **Total Estimated Charge** → **USD**
4. Statistic: **Maximum**, Period: **6 hours**
5. Threshold type: **Static**, Whenever EstimatedCharges is **Greater than 1**
6. **Next** → **Create new topic** → name `billing-alerts` → email yourself → confirm subscription via email
7. Alarm name: `billing-alarm-1usd`
8. Repeat for **$5** and **$10** alarms

After this, you'll get email if you EVER cross $1, $5, or $10 of total spend in a billing cycle.

---

## Step 5 — Lock Down the Root Account

> The root account can do everything — including delete the account. After this step, never use it again except for billing changes.

1. Top-right account dropdown → **Security credentials**
2. Under **Multi-factor authentication (MFA)** → **Assign MFA device**
3. Use Authy / Google Authenticator / 1Password — NOT SMS
4. Save backup codes in your password manager
5. Do **NOT** create access keys for the root user

---

## Step 6 — Create an IAM User for Terraform

> This is the user you'll use for the rest of the course.

1. **IAM** → **Users** → **Create user**
2. **User name:** `terraform-student`
3. **Provide user access to the AWS Management Console** — leave UNCHECKED (CLI only)
4. **Next**
5. Permissions: **Attach policies directly** → check **AdministratorAccess**
6. **Next** → **Create user**

Now create access keys:

7. Click into the new user → **Security credentials** tab
8. **Create access key** → **Command Line Interface (CLI)**
9. Confirm checkbox → **Next** → **Create access key**
10. **Download .csv** AND save the keys somewhere safe — they're shown only once

> **Why AdministratorAccess?** For learning. In production, you scope down to minimum required permissions. We'll touch on that later.

---

## Step 7 — Install AWS CLI v2

### macOS

```bash
brew install awscli
aws --version
# aws-cli/2.15.x
```

### Windows

Download installer: https://awscli.amazonaws.com/AWSCLIV2.msi
Run it, restart terminal:
```powershell
aws --version
```

### Linux

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version
```

---

## Step 8 — Configure AWS CLI

```bash
aws configure --profile life
```

When prompted:
- **AWS Access Key ID:** paste from Step 6
- **AWS Secret Access Key:** paste from Step 6
- **Default region:** `eu-central-1`
- **Default output format:** `json`

Set the profile as default for this terminal session:

### macOS / Linux

```bash
export AWS_PROFILE=life
# Add to ~/.zshrc or ~/.bashrc to make permanent
echo 'export AWS_PROFILE=life' >> ~/.zshrc
```

### Windows PowerShell

```powershell
$env:AWS_PROFILE = "life"
```

Verify:

```bash
aws sts get-caller-identity
```

You should see something like:

```json
{
    "UserId": "AIDA...",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/terraform-student"
}
```

If `Arn` ends in `:user/terraform-student` — you're ready.

---

## Step 9 — Install Terraform

### macOS

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
terraform version
# Terraform v1.7.x or higher
```

### Windows

```powershell
choco install terraform
# or download from https://developer.hashicorp.com/terraform/install
terraform version
```

### Linux

```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
terraform version
```

Required: **>= 1.5.0**

---

## Step 10 — Final Verification

Run all of these. They must all succeed:

```bash
aws --version          # aws-cli/2.x
terraform version      # >= 1.5
docker --version       # any
git --version          # any

# Most important: who am I in AWS?
aws sts get-caller-identity
# Arn must end in :user/terraform-student

# Can I list buckets? (probably empty)
aws s3 ls

# Can I list regions?
aws ec2 describe-regions --query 'Regions[].RegionName' --output table
```

If everything passes — **you're ready for class**.

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `aws: command not found` | Reinstall AWS CLI v2, restart terminal |
| `Unable to locate credentials` | Run `aws configure --profile life` again, set `AWS_PROFILE=life` |
| `An error occurred (InvalidClientTokenId)` | Wrong access key — recreate in IAM and retry |
| `Could not connect to the endpoint URL` | Check region is `eu-central-1` and you have internet |
| Billing alarm "no metric data" | Wait 24 hours after enabling billing alerts in Step 2 |
| MFA on root not working | Re-pair the authenticator app, ensure phone time is synced |

---

## Money Safety Reminders

- The IAM user you just created has **AdministratorAccess** — keep its keys safe
- If you accidentally publish keys to git: **delete them in IAM immediately**, rotate everything
- Set a calendar reminder for end of class week: log in to AWS, run `aws ec2 describe-instances` and `aws rds describe-db-instances` — verify nothing is running
