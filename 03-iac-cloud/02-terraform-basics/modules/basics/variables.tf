variable "student_name" {
  description = "Your name in lowercase-kebab-case (e.g. dren-sokoli)"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,28}[a-z0-9]$", var.student_name))
    error_message = "Use lowercase letters, numbers, and hyphens only (e.g. dren-sokoli)."
  }
}
