output "app_vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.app-vpc.id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = [for subnet in aws_subnet.app-vpc-public-subnets : subnet.id]
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = [for subnet in aws_subnet.app-vpc-private-subnets : subnet.id]
}

output "public_subnet_cidr_blocks" {
  value = [for subnet in aws_subnet.app-vpc-public-subnets : subnet.cidr_block]
}
