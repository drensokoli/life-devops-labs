variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "student_name" {
  description = "Your kebab-case name (must match the one used in 04-vpc-networking)"
  type        = string
}

variable "db_password" {
  description = "PostgreSQL master password (min 8 chars)"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.db_password) >= 8
    error_message = "Password must be at least 8 characters."
  }
}

variable "instance_type" {
  description = "EC2 instance type (use t3.micro for free tier)"
  type        = string
  default     = "t3.micro"
}
