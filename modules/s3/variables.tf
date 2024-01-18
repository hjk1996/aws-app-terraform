

variable "app_image_bucket_name" {
  type    = string
  default = "rapa-app-image-bucket"

}

variable "app_nsfw_detect_lambda_arn" {
  type        = string
  description = "The ARN of the lambda function"
}