

variable "app_image_bucket_name" {
  type    = string
  default = "rapa-app-image-bucket"
}

variable "app_frontend_bucket_name" {
  type    = string
  default = "rapa-app-frontend-bucket"
}

variable "app_nsfw_detect_lambda_arn" {
  type        = string
  description = "The ARN of the lambda function"
}

# variable "app_frontend_cloudfront_arn" {
#   type        = string
#   description = "The ARN of the CloudFront distribution"
# }