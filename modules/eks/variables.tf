variable "eks_cluster_name" {
  type    = string
  default = "app-eks-cluster"
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)

}

variable "instance_types" {
  type = list(string)
}

