data "aws_region" "current" {

}


module "app_vpc" {
  source  = "terraform-aws-modules/vpc/aws"

  name               = "app_vpc"
  cidr               = var.vpc_cidr
  azs                = var.vpc_azs
  private_subnets    = var.vpc_public_subnets
  public_subnets     = var.vpc_private_subnets

  enable_nat_gateway = true
  
  public_subnet_tags = {
    "karpenter.sh/discovery" = var.eks_cluster_name
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "karpenter.sh/discovery"          = var.eks_cluster_name
    "kubernetes.io/role/internal-elb" = 1
  }

}

resource "aws_vpc_endpoint" "app-vpc-s3-gateway-endpoint" {
  vpc_id       = module.app_vpc.vpc_id
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"
  route_table_ids = concat(module.app_vpc.public_route_table_ids, module.app_vpc.private_route_table_ids)
  vpc_endpoint_type = "Gateway"

  policy = <<POLICY
  {
    "Version": "2008-10-17",
    "Statement": [
      {
        "Action": "*",
        "Effect": "Allow",
        "Resource": "*",
        "Principal": "*"
      }
    ]
  }
  POLICY


  tags = {
    Name      = "app-vpc-s3-gateway-endpoint"
    Terraform = "true"
  }
}
