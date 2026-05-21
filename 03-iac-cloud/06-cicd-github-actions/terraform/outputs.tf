output "deploy_role_arn" {
  description = "Paste this into the GitHub Actions workflow `role-to-assume:`"
  value       = aws_iam_role.gh_deploy.arn
}

output "oidc_provider_arn" {
  description = "OIDC provider ARN (for reference)"
  value       = aws_iam_openid_connect_provider.github.arn
}

output "trusted_subject" {
  description = "GitHub OIDC subject pattern allowed to assume the role"
  value       = "repo:${var.github_owner}/${var.github_repo}:ref:refs/heads/${var.github_branch}"
}
