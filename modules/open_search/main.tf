resource "aws_opensearchserverless_security_policy" "encryption_policy" {
  name        = "example-encryption-policy"
  type        = "encryption"
  description = "encryption policy for ${var.collection_name}"
  policy = jsonencode({
    Rules = [
      {
        Resource = [
          "collection/${var.collection_name}"
        ],
        ResourceType = "collection"
      }
    ],
    AWSOwnedKey = true
  })
}

resource "aws_opensearchserverless_collection" "app_image_caption_vector_collection" {
  name = var.collection_name
  description = "Collection for storing image caption vectors"
  type = "VECTORSEARCH"

  depends_on = [aws_opensearchserverless_security_policy.encryption_policy]

}

resource "aws_opensearchserverless_security_policy" "network_policy" {
  name        = "example-network-policy"
  type        = "network"
  description = "public access for dashboard, VPC access for collection endpoint"
  policy = jsonencode([
    {
      Description = "VPC access for collection endpoint",
      Rules = [
        {
          ResourceType = "collection",
          Resource = [
            "collection/${var.collection_name}"
          ]
        }
      ],
      AllowFromPublic = false,
      SourceVPCEs = [
        aws_opensearchserverless_vpc_endpoint.vpc_endpoint.id
      ]
    },
    {
      Description = "Public access for dashboards",
      Rules = [
        {
          ResourceType = "dashboard"
          Resource = [
            "collection/${var.collection_name}"
          ]
        }
      ],
      AllowFromPublic = true
    }
  ])
}

resource "aws_opensearchserverless_vpc_endpoint" "vpc_endpoint" {
  name               = "example-vpc-endpoint"
  vpc_id             = var.vpc_id
  subnet_ids         = var.private_subnet_ids
  security_group_ids = [var.app_vector_db_security_group_id]
}

data "aws_caller_identity" "current" {}



# Creates a data access policy
resource "aws_opensearchserverless_access_policy" "data_access_policy" {
  name        = "example-data-access-policy"
  type        = "data"
  description = "allow index and collection access"
  policy = jsonencode([
    {
      Rules = [
        {
          ResourceType = "index",
          Resource = [
            "index/${var.collection_name}/*"
          ],
          Permission = [
            "aoss:*"
          ]
        },
        {
          ResourceType = "collection",
          Resource = [
            "collection/${var.collection_name}"
          ],
          Permission = [
            "aoss:*"
          ]
        }
      ],
      Principal = [
        data.aws_caller_identity.current.arn,
        var.image_caption_irsa_role_arn,
        var.face_search_irsa_role_arn,
        "arn:aws:iam::109412806537:role/KarpenterNodeRole-app-eks",
        "arn:aws:iam::109412806537:role/eks_worker-eks-node-group-2024012812590583420000000b"
      ]
    }
  ])
}