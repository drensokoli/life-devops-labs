data "aws_caller_identity" "current" {}

output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "ecr_registry" {
  description = "ECR registry hostname"
  value       = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
}

output "backend_repo_url" {
  description = "Full ECR URL for life-backend"
  value       = aws_ecr_repository.backend.repository_url
}

output "frontend_repo_url" {
  description = "Full ECR URL for life-frontend"
  value       = aws_ecr_repository.frontend.repository_url
}

output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.web.public_ip
}

output "ec2_instance_id" {
  description = "EC2 instance ID (for SSM Session Manager)"
  value       = aws_instance.web.id
}

output "ssh_command" {
  description = "Command to SSH into the EC2 instance"
  value       = "ssh -i ${path.module}/life-key.pem ec2-user@${aws_instance.web.public_ip}"
}

output "rds_endpoint" {
  description = "PostgreSQL endpoint (host:port)"
  value       = aws_db_instance.postgres.endpoint
}

output "rds_address" {
  description = "PostgreSQL hostname only"
  value       = aws_db_instance.postgres.address
}

output "app_bucket" {
  description = "S3 bucket for app data"
  value       = aws_s3_bucket.app.id
}

output "connection_string" {
  description = "PostgreSQL connection string for the backend container"
  value       = "Host=${aws_db_instance.postgres.address};Database=lifedb;Username=life;Password=${var.db_password}"
  sensitive   = true
}
