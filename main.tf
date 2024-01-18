provider "aws" {
  region = "us-east-1"
}

module "iam_policy_module" {
  source               = "./modules/iam_policy"
  app_image_bucket_arn = module.s3_module.app_image_bucket_arn
}

module "iam_role_module" {
  source                         = "./modules/iam_role"
  lambda_trust_policy            = module.iam_policy_module.lambda_trust_policy
  nsfw_detect_lambda_policy_arns = module.iam_policy_module.app_nsfw_detect_lambda_policy_arns
}

module "vpc_module" {
  source         = "./modules/vpc"
  vpc_cidr_block = "10.0.0.0/16"
  vpc_name       = "app-vpc"
}

module "s3_module" {
  source                     = "./modules/s3"
  app_nsfw_detect_lambda_arn = module.lambda_module.app_nsfw_detect_lambda_arn
}

module "lambda_module" {
  source                              = "./modules/lambda"
  app_image_bucket_arn                = module.s3_module.app_image_bucket_arn
  app_nsfw_detect_lambda_iam_role_arn = module.iam_role_module.app_nsfw_detect_lambda_iam_role_arn
}


