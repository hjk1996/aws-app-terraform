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

variable "app_vpc_public_subnet_ids" {
  type = list(string)
}

variable "delete_table_item_lambda_security_group_id" {
  type = string

}


variable "app_image_bucket_name" {
  type = string

}


variable "image_resize_queue_arn" {
  type = string

}

variable "image_metadata_queue_arn" {
  type = string
}

variable "image_delete_cleanup_lambda_iam_role_arn" {
  type = string

}

variable "delete_cleanup_queue_arn" {
  type = string

}

# variable "app_opensearch_index" {
#   type = string

# }


# variable "app_opensearch_endpoint" {
#   type = string

# }
