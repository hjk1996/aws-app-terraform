

variable "app_image_bucket_arn" {
  type = string

}

variable "face_index_lambda_arn" {
  type = string
}

variable "delete_face_index_lambda_arn" {
  type = string
}

variable "image_resize_lambda_arn" {
  type = string
  
}

variable "image_caption_queue_arn" {
  type = string
}