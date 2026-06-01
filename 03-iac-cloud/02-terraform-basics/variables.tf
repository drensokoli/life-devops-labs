variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-central-1"
}

variable "student_name" {
  description = "Your name in lowercase-kebab-case (e.g. dren-sokoli)"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,28}[a-z0-9]$", var.student_name))
    error_message = "Use lowercase letters, numbers, and hyphens only (e.g. dren-sokoli)."
  }
}

variable "student_name_2" {
  description = "Your name in lowercase-kebab-case (e.g. dren-sokoli)"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,28}[a-z0-9]$", var.student_name_2))
    error_message = "Use lowercase letters, numbers, and hyphens only (e.g. dren-sokoli)."
  }
}
