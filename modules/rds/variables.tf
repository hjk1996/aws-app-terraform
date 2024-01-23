variable "app_db_security_group_id" {
  type        = string
  description = "The ID of the security group for the app DB"
}

variable "app_private_subnet_ids" {
  type        = list(string)
  description = "The IDs of the private subnets"
}

variable "app_db_instance_type" {
  type        = string
  description = "The instance type of the app DB"
  default     = "db.t4g.micro"
}