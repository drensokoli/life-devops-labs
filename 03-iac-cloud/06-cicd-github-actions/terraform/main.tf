data "aws_caller_identity" "current" {}

locals {
  common_tags = {
    Owner   = var.student_name
    Course  = "LIFE-DevOps"
    Lecture = "03-iac-cloud"
    Lab     = "06-cicd-github-actions"
    Managed = "terraform"
  }
}

# ─────────────────────────────────────────────────────────────────
# OIDC provider for GitHub Actions
# Only ONE per account — share it with: data "aws_iam_openid_connect_provider"
# ─────────────────────────────────────────────────────────────────

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]

  # GitHub's OIDC thumbprint — AWS validates these
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd",
  ]

  tags = local.common_tags
}

# ─────────────────────────────────────────────────────────────────
# IAM role that GitHub Actions assumes via OIDC
# ─────────────────────────────────────────────────────────────────

data "aws_iam_policy_document" "gh_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    # Only this branch in this repo can assume the role
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [
        "repo:${var.github_owner}/${var.github_repo}:ref:refs/heads/${var.github_branch}",
      ]
    }
  }
}

resource "aws_iam_role" "gh_deploy" {
  name               = "life-gh-deploy-${var.student_name}"
  assume_role_policy = data.aws_iam_policy_document.gh_assume.json
  max_session_duration = 3600 # 1 hour
  tags               = local.common_tags
}

# Permissions: push to ECR + describe EC2 (least privilege)
data "aws_iam_policy_document" "gh_perms" {
  statement {
    sid     = "ECRAuth"
    effect  = "Allow"
    actions = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid    = "ECRPush"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]
    resources = [
      "arn:aws:ecr:${var.aws_region}:${data.aws_caller_identity.current.account_id}:repository/life-backend-${var.student_name}",
      "arn:aws:ecr:${var.aws_region}:${data.aws_caller_identity.current.account_id}:repository/life-frontend-${var.student_name}",
    ]
  }

  statement {
    sid    = "EC2Describe"
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeTags",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "SSMDeploy"
    effect = "Allow"
    actions = [
      "ssm:SendCommand",
      "ssm:GetCommandInvocation",
      "ssm:ListCommandInvocations",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "gh_perms" {
  name   = "life-gh-deploy-perms-${var.student_name}"
  policy = data.aws_iam_policy_document.gh_perms.json
}

resource "aws_iam_role_policy_attachment" "gh_perms" {
  role       = aws_iam_role.gh_deploy.name
  policy_arn = aws_iam_policy.gh_perms.arn
}
