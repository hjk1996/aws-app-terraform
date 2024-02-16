

variable "face_index_lambda_arn" {
  type = string

}

variable "app_image_bucket_arn" {
  type = string
}

variable "image_caption_irsa_role_arn" {
  type = string
}


variable "app_sns_on_object_created_topic_arn" {
  type = string
}