output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.lab.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.lab.arn
}

output "bucket_region" {
  description = "Region the bucket lives in"
  value       = aws_s3_bucket.lab.region
}
