output "app_vpc_id" {
  description = "The ID of the VPC"
  value       = module.app_vpc.vpc_id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = module.app_vpc.public_subnets
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = module.app_vpc.private_subnets
}

output "public_subnet_cidr_blocks" {
  value = module.app_vpc.public_subnets_cidr_blocks
}
