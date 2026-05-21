resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "demo" {
  bucket = "life-remote-demo-${var.student_name}-${random_id.suffix.hex}"

  tags = {
    Owner   = var.student_name
    Course  = "LIFE-DevOps"
    Lab     = "03-state-backend-main"
    Managed = "terraform"
  }
}
