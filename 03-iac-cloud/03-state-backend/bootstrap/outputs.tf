output "state_bucket" {
  description = "S3 bucket name for Terraform state"
  value       = aws_s3_bucket.tf_state.id
}

output "lock_table" {
  description = "DynamoDB table name for state locking"
  value       = aws_dynamodb_table.tf_locks.id
}

output "backend_config" {
  description = "Snippet to paste into your next Terraform module's backend"
  value       = <<-EOT
    backend "s3" {
      bucket         = "${aws_s3_bucket.tf_state.id}"
      key            = "PATH/TO/STATE.tfstate"
      region         = "${var.aws_region}"
      dynamodb_table = "${aws_dynamodb_table.tf_locks.id}"
      encrypt        = true
    }
  EOT
}
