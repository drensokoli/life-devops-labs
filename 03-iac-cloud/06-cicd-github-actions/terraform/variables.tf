variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "student_name" {
  description = "Your kebab-case name (must match prior labs)"
  type        = string
}

variable "github_owner" {
  description = "Your GitHub username or org, e.g. drensokoli"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name, e.g. life-devops-labs"
  type        = string
  default     = "life-devops-labs"
}

variable "github_branch" {
  description = "Branch allowed to assume the role (or '*' for any). Use your student branch name."
  type        = string
}
