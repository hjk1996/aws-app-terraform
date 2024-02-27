

output "app_image_bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.app_image_bucket.arn
}

output "app_image_bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.app_image_bucket.bucket
}