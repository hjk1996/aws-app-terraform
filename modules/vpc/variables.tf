

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "vpc_name" {
  type    = string
  default = "app-vpc"
}

variable "vpc_azs" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]

}

variable "vpc_public_subnets" {
  type = list(string)
  default = [
    "10.0.1.0/24", "10.0.2.0/24"
  ]
}

variable "vpc_private_subnets" {
  type = list(string)
  default = [
    "10.0.101.0/24", "10.0.102.0/24"
  ]
}


variable "eks_cluster_name" {
  type    = string
  default = "app-eks-cluster"
}


# variable "open_search_vpc_endpoint_id" {
#   type = string
# }
