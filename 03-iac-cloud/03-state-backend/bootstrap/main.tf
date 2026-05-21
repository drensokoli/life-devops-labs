locals {
  bucket_name = "life-tf-state-${var.student_name}"
  table_name  = "life-tf-locks-${var.student_name}"

  common_tags = {
    Owner   = var.student_name
    Course  = "LIFE-DevOps"
    Lecture = "03-iac-cloud"
    Lab     = "03-state-backend-bootstrap"
    Managed = "terraform"
  }
}

resource "aws_s3_bucket" "tf_state" {
  bucket = local.bucket_name
  tags   = local.common_tags

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "tf_locks" {
  name         = local.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = local.common_tags
}
