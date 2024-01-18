output "app_vpc_id" {
    description = "The ID of the VPC"
    value       = module.vpc_module.app_vpc_id
}

output "public_subnet_cidr_blocks" {
    description = "The CIDR blocks of the public subnets"
    value       = module.vpc_module.public_subnet_cidr_blocks
}