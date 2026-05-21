output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnets
}

output "web_sg_id" {
  description = "Security group ID for web traffic"
  value       = aws_security_group.web.id
}

output "db_sg_id" {
  description = "Security group ID for the database"
  value       = aws_security_group.db.id
}

output "azs_used" {
  description = "Availability zones used"
  value       = local.azs
}
