


provider "aws" {
  region = "us-east-1"
}


terraform {
  backend "s3" {
    bucket = "app-tfstate-bucket"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }

}

locals {
  eks_cluster_name                   = "app-eks"
  lb_controller_service_account_name = "aws-load-balancer-controller"
}


module "s3_module" {
  source                          = "./modules/s3"
  image_caption_queue_arn         = module.sqs_module.image_caption_queue_arn
  app_on_object_created_topic_arn = module.sns_module.app_on_object_created_topic_arn
  app_on_object_deleted_topic_arn = module.sns_module.app_on_object_deleted_topic_arn
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
  source              = "./modules/vpc"
  eks_cluster_name    = local.eks_cluster_name
  vpc_name            = "app_vpc"
  vpc_azs             = ["us-east-1a", "us-east-1b"]
  vpc_cidr            = "10.0.0.0/16"
  vpc_public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  vpc_private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]
# open_search_vpc_endpoint_id = module.open_search_module.open_search_vpc_endpoint_id
}


module "lambda_module" {
  source                                     = "./modules/lambda"
  app_image_bucket_arn                       = module.s3_module.app_image_bucket_arn
  app_on_object_created_topic_arn            = module.sns_module.app_on_object_created_topic_arn
  delete_face_index_lambda_iam_role_arn      = module.iam_role_module.delete_face_index_lambda_iam_role_arn
  face_index_lambda_iam_role_arn             = module.iam_role_module.face_index_lambda_iam_role_arn
  app_on_object_deleted_topic_arn            = module.sns_module.app_on_object_deleted_topic_arn
  image_resize_lambda_iam_role_arn           = module.iam_role_module.image_resize_lambda_iam_role_arn
  app_image_metadata_table_name              = module.dynamodb_module.app_image_metadata_table_name
  app_vpc_public_subnet_ids                  = module.vpc_module.private_subnet_ids
  delete_table_item_lambda_security_group_id = module.security_group_module.delete_table_item_lambda_security_group_id
  # app_opensearch_endpoint = module.open_search_module.open_search_endpoint
  # app_opensearch_index = "image_caption_vector_index"
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

module "sqs_module" {
  source                              = "./modules/sqs"
  create_table_item_lambda_arn        = module.lambda_module.create_table_item_lambda_arn
  app_image_bucket_arn                = module.s3_module.app_image_bucket_arn
  image_caption_irsa_role_arn         = module.eks_module.image_caption_irsa_role_arn
  app_sns_on_object_created_topic_arn = module.sns_module.app_on_object_created_topic_arn
}

module "dynamodb_module" {
  source = "./modules/dynamodb"

}

module "sns_module" {
  source                       = "./modules/sns"
  app_image_bucket_arn         = module.s3_module.app_image_bucket_arn
  create_table_item_lambda_arn = module.lambda_module.create_table_item_lambda_arn
  delete_table_item_lambda_arn = module.lambda_module.delete_table_item_lambda_arn
  image_resize_lambda_arn      = module.lambda_module.image_resize_lambda_arn
  image_caption_queue_arn      = module.sqs_module.image_caption_queue_arn
}

# module "open_search_module" {
#   source = "./modules/open_search"
#   app_vector_db_security_group_id = module.security_group_module.app_vector_db_security_group_id
#   collection_name = "app-image-caption-vector"
#   private_subnet_ids = module.vpc_module.private_subnet_ids
#   vpc_id = module.vpc_module.app_vpc_id
#   image_caption_irsa_role_arn = module.eks_module.image_caption_irsa_role_arn
#   face_search_irsa_role_arn = module.eks_module.face_search_irsa_role_arn
# }

module "security_manager_module" {
  source = "./modules/security_manager"
  
}

# module "rds_module" {
#   source = "./modules/rds"
#   app_private_subnet_ids = module.vpc_module.private_subnet_ids
#   app_vector_db_security_group_id = module.security_group_module.app_vector_db_security_group_id
# }

module "documentdb_module" {
  source = "./modules/documentdb"
  app_private_subnet_ids = module.vpc_module.private_subnet_ids
  app_vector_db_security_group_id = module.security_group_module.app_vector_db_security_group_id
}