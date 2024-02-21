output "app_vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc_module.app_vpc_id
}

output "public_subnet_cidr_blocks" {
  description = "The CIDR blocks of the public subnets"
  value       = module.vpc_module.public_subnet_cidr_blocks
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = module.vpc_module.public_subnet_ids

}

output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = module.vpc_module.private_subnet_ids
}

output "eks_cluster_endpoint" {
  description = "The endpoint of the EKS cluster"
  value       = module.eks_module.eks_cluster_endpoint
}

# output "open_search_endpoint" {
#   description = "The endpoint of the OpenSearch cluster"
#   value       = module.open_search_module.open_search_endpoint
# }


