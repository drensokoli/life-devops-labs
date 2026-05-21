locals {
  common_tags = {
    Owner   = var.student_name
    Course  = "LIFE-DevOps"
    Lecture = "03-iac-cloud"
    Lab     = "02-terraform-basics"
    Managed = "terraform"
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "lab" {
  bucket = "life-lab-${var.student_name}-${random_id.suffix.hex}"

  tags = local.common_tags
}

resource "aws_s3_bucket_public_access_block" "lab" {
  bucket = aws_s3_bucket.lab.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "lab" {
  bucket = aws_s3_bucket.lab.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_object" "hello" {
  bucket  = aws_s3_bucket.lab.id
  key     = "hello.txt"
  content = "Hello from Terraform — owner: ${var.student_name}"

  tags = local.common_tags
}
