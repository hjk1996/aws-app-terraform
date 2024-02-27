

variable "face_index_lambda_iam_role_arn" {
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

variable "app_sns_on_object_deleted_topic_arn" {
  type = string
}

variable "image_resize_lambda_iam_role_arn" {
  type = string
}

variable "image_delete_cleanup_lambda_iam_role_arn" {
  type = string
}