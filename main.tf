provider "aws" {
  region = "us-east-1"
}

module "vpc_module" {
  source         = "./modules/vpc"
  vpc_cidr_block = "10.0.0.0/16"
  vpc_name       = "app-vpc"
}

module "s3_module" {
  source = "./modules/s3"
}



