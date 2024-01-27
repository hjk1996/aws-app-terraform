


provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "rapa-app-tfstate-bucket"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }

}

locals {
  eks_cluster_name = "app-eks-cluster"
}


module "s3_module" {
  source                     = "./modules/s3"
  app_nsfw_detect_lambda_arn = module.lambda_module.app_nsfw_detect_lambda_arn
}


module "iam_policy_module" {
  source               = "./modules/iam_policy"
  app_image_bucket_arn = module.s3_module.app_image_bucket_arn
}

module "iam_role_module" {
  source                         = "./modules/iam_role"
  lambda_trust_policy            = module.iam_policy_module.lambda_trust_policy
  eks_trust_policy               = module.iam_policy_module.eks_trust_policy
  nsfw_detect_lambda_policy_arns = module.iam_policy_module.app_nsfw_detect_lambda_policy_arns
}

module "vpc_module" {
  source         = "./modules/vpc"
  eks_cluster_name = local.eks_cluster_name
  vpc_name = "app_vpc"
  vpc_azs = ["us-east-1a", "us-east-1b"]
  vpc_cidr = "10.0.0.0/16"
  vpc_public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  vpc_private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]
}


module "lambda_module" {
  source                              = "./modules/lambda"
  app_image_bucket_arn                = module.s3_module.app_image_bucket_arn
  app_nsfw_detect_lambda_iam_role_arn = module.iam_role_module.app_nsfw_detect_lambda_iam_role_arn
  app_nsfw_dtect_lambda_ecr_url       = module.ecr_module.app_nsfw_dtect_lambda_ecr_url
}

module "ecr_module" {
  source = "./modules/ecr"
}

module "security_group_module" {
  source                    = "./modules/security_group"
  app_vpc_id                = module.vpc_module.app_vpc_id
  public_subnet_cidr_blocks = module.vpc_module.public_subnet_cidr_blocks
}


module "eks_module" {
  source             = "./modules/eks"
  eks_cluster_name   = local.eks_cluster_name
  vpc_id             = module.vpc_module.app_vpc_id
  public_subnet_ids  = module.vpc_module.public_subnet_ids
  private_subnet_ids = module.vpc_module.private_subnet_ids
  instance_types     = ["m6i.large"]
}