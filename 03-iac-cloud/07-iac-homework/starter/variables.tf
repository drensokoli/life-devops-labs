variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "student_name" {
  description = "Your kebab-case name"
  type        = string
}

variable "db_password" {
  description = "PostgreSQL master password (min 8 chars)"
  type        = string
  sensitive   = true
}

# TODO: add a variable `instance_type` with default = "t3.micro"
# TODO: add a variable `vpc_cidr` with default = "10.10.0.0/16"
