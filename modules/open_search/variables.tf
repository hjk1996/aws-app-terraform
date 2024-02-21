
variable "collection_name" {
  description = "The name of the collection to apply the policy to"
  type        = string
}

variable "vpc_id" {
  type = string
  
}

variable "private_subnet_ids" {
  type = list(string)
}




variable "app_vector_db_security_group_id" {
    type = string
}

variable "face_search_irsa_role_arn" {
  type = string
}

variable "image_caption_irsa_role_arn" {
  type = string
}

