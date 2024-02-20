variable "app_image_bucket_arn" {
  type = string
}

variable "app_on_object_created_topic_arn" {
  type = string
}

variable "delete_face_index_lambda_iam_role_arn" {
  type = string

}

variable "app_on_object_deleted_topic_arn" {
  type = string
}


variable "face_index_lambda_iam_role_arn" {
  type = string
}

variable "image_resize_lambda_iam_role_arn" {
  type = string
}

variable "app_image_metadata_table_name" {
  type = string
}