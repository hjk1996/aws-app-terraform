output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = aws_subnet.app-vpc-public-subnets
}



output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = aws_subnet.app-vpc-private-subnets
}