

variable "app_image_bucket_name" {
  type    = string
  default = "rapa-app-image-bucket"
}

variable "app_frontend_bucket_name" {
  type    = string
  default = "rapa-app-frontend-bucket"
}


variable "image_caption_queue_arn" {
  type = string
}

variable "app_on_object_created_topic_arn" {
  type = string

}

variable "app_on_object_deleted_topic_arn" {
  type = string
}


# variable "app_frontend_cloudfront_arn" {
#   type        = string
#   description = "The ARN of the CloudFront distribution"
# }