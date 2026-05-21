# 06 — CI/CD with GitHub Actions + OIDC

## Purpose

Wire GitHub Actions to push images to ECR and redeploy the EC2 — without storing any AWS access keys in GitHub.

## Why OIDC?

OpenID Connect lets GitHub Actions assume an AWS IAM role using a short-lived JSON Web Token. No long-lived credentials. No `AWS_ACCESS_KEY_ID` in GitHub Secrets. Industry standard since 2022.

```
GitHub Actions ─(JWT token)─► AWS STS ─► temporary credentials (1h)
                                          │
                                          ▼
                                   API calls to ECR / EC2 / SSM
```

## Prerequisites

- `04-vpc-networking/` and `05-compute-storage/` already applied (EC2 + ECR running)
- Your fork of `life-devops-labs` pushed to GitHub on your student branch

## Folder layout

```
06-cicd-github-actions/
├── terraform/             # OIDC provider + IAM role
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars.example
└── workflow-template/
    └── deploy.yml         # Copy to .github/workflows/deploy.yml
```

## Step 1 — Apply the IAM Terraform

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars:
#   github_owner  = "drensokoli"  (your GH username)
#   github_branch = "dren-sokoli"  (your student branch)

terraform init
terraform plan
terraform apply
```

Save the outputs:

```bash
terraform output deploy_role_arn
# arn:aws:iam::123456789012:role/life-gh-deploy-dren-sokoli
```

## Step 2 — Wire up the workflow

Create `.github/workflows/deploy.yml` in your fork (root of the repo, not inside `06-cicd-github-actions/`):

```bash
# From the root of your life-devops-labs clone
mkdir -p .github/workflows
cp 03-iac-cloud/06-cicd-github-actions/workflow-template/deploy.yml .github/workflows/deploy.yml
```

Edit `.github/workflows/deploy.yml`:
- Replace `YOUR-BRANCH` (line 8) with your student branch
- Replace `YOUR-NAME-HERE` everywhere with your kebab-case name
- Replace `arn:aws:iam::ACCOUNT-ID:role/life-gh-deploy-YOUR-NAME-HERE` with the real ARN from Step 1
- Replace `$RDS_CONN` placeholder by setting it as a GitHub Secret (next step)

## Step 3 — Set the RDS connection string as a repo secret

```bash
# Get the connection string from Terraform
cd ../../05-compute-storage
terraform output -raw connection_string
# Host=...;Database=lifedb;Username=life;Password=...
```

In GitHub:
1. Repo → **Settings** → **Secrets and variables** → **Actions**
2. **New repository secret**
3. Name: `RDS_CONN`
4. Value: paste the full connection string
5. **Add secret**

Update `deploy.yml` to use it:

```yaml
- name: Trigger redeploy via SSM
  env:
    REGISTRY: ${{ steps.ecr.outputs.registry }}
    BACKEND_IMAGE: ...
    FRONTEND_IMAGE: ...
    RDS_CONN: ${{ secrets.RDS_CONN }}    # ← add this
```

> **Why a secret here?** The OIDC token gives GitHub Actions permission to *call AWS APIs*, but the database connection string itself is a value our application needs. Secrets are the right tool for app-level config that's sensitive.

## Step 4 — Push and watch it run

```bash
cd ../  # back to repo root
git checkout dren-sokoli   # your branch
git add .github/workflows/deploy.yml
git commit -m "feat: add GitHub Actions deploy workflow with OIDC"
git push origin dren-sokoli
```

Open GitHub → **Actions** tab → watch the workflow run live.

You should see:
1. ✅ Configure AWS credentials (OIDC)
2. ✅ Login to ECR
3. ✅ Build & push backend image
4. ✅ Build & push frontend image
5. ✅ Find EC2 instance
6. ✅ Trigger redeploy via SSM

After it succeeds, visit `http://<EC2_PUBLIC_IP>:3000` — your latest code is live.

## Step 5 — Test it: change something and push

```bash
# Make any visible change to the frontend
sed -i '' 's/Register/Register Now/' 01-containers/07-debugging/frontend/app/page.tsx

git add -A
git commit -m "feat: rename register button"
git push
```

Watch GitHub Actions. ~3 minutes later, the new version is on EC2.

## Concepts demonstrated

### Trust policy — who can assume this role?

```hcl
condition {
  variable = "token.actions.githubusercontent.com:sub"
  values   = ["repo:drensokoli/life-devops-labs:ref:refs/heads/dren-sokoli"]
}
```

Only YOUR branch in YOUR repo can assume this role. Even if someone steals the role ARN, they can't use it.

### Least privilege

The role can only:
- Push to YOUR ECR repos (not anyone else's)
- Describe EC2 instances (no create/destroy)
- Send SSM commands (no other AWS API)

### Caching ECR images

GitHub Actions doesn't cache Docker layers automatically. For larger projects, use `docker/build-push-action@v6` with `cache-from` / `cache-to` for ECR remote cache.

## Cleanup

```bash
cd terraform
terraform destroy
```

This removes the OIDC provider and IAM role. The workflow file in `.github/workflows/deploy.yml` is harmless — it just won't be able to authenticate to AWS anymore.

## Cleanup checklist

- [ ] `terraform destroy` ran successfully (no leftover IAM role/policy)
- [ ] You can see the role is gone: `aws iam list-roles --query 'Roles[?starts_with(RoleName, \`life-gh-deploy-\`)]'`
- [ ] Workflow file removed or disabled if you don't intend to keep it (`mv .github/workflows/deploy.yml .github/workflows/deploy.yml.disabled`)
