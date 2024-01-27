data "aws_ecrpublic_authorization_token" "token" {

}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"

  version = "~> 19.0"

  cluster_name    = var.eks_cluster_name
  cluster_version = "1.27"

  cluster_endpoint_private_access = false
  cluster_endpoint_public_access  = true
  
  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts        = "OVERWRITE"
      service_account_role_arn = module.vpc_cni_irsa.iam_role_arn
    }
  }





  vpc_id     = var.vpc_id
  subnet_ids = concat(var.public_subnet_ids, var.private_subnet_ids)

  enable_irsa = true



  eks_managed_node_group_defaults = {
    disk_size                  = 30
    instance_types             = var.instance_types
    ami_type                   = "AL2_x86_64"
    iam_role_attach_cni_policy = true
  }


  eks_managed_node_groups = {
    eks_worker = {
      desired_size = 1
      min_size     = 1
      max_size     = 3
      labels = {
        role = "general"
      }
      subnet_ids     = var.private_subnet_ids
      instance_types = var.instance_types
      capacity_type  = "ON_DEMAND"
    }
  }

  #   manage_aws_auth_configmap = true
  #   aws_auth_roles = [
  #     # We need to add in the Karpenter node IAM role for nodes launched by Karpenter
  #     {
  #       rolearn  = module.karpenter.role_arn
  #       username = "system:node:{{EC2PrivateDNSName}}"
  #       groups = [
  #         "system:bootstrappers",
  #         "system:nodes",
  #       ]
  #     },
  #   ]


  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

# AWS VPC CNI (Container Network Interface) 플러그인을 위한 역할
# AWS VPC CNI 플러그인은 기본적으로 IPv4 주소를 파드에 할당하는 역할을 함
module "vpc_cni_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name_prefix = "VPC-CNI-IRSA"
  #AWS VPC CNI 플러그인에 필요한 IAM 정책을 자동으로 첨부하도록 지시
  attach_vpc_cni_policy = true
  #IPv4 지원을 활성화
  vpc_cni_enable_ipv4 = true # NOTE: This was what needed to be added

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }
}



# module "karpenter" {
#   source = "terraform-aws-modules/eks/aws//modules/karpenter"

#   cluster_name = module.eks.cluster_name

#   irsa_oidc_provider_arn          = module.eks.oidc_provider_arn
#   irsa_namespace_service_accounts = ["karpenter:karpenter"]

#   # Attach additional IAM policies to the Karpenter node IAM role
#   iam_role_additional_policies = {
#     AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
#   }

#   tags = {
#     Environment = "dev"
#     Terraform   = "true"
#   }
# }


# resource "helm_release" "karpenter" {
#   namespace        = "karpenter"
#   create_namespace = true

#   name                = "karpenter"
#   repository          = "oci://public.ecr.aws/karpenter"
#   repository_username = data.aws_ecrpublic_authorization_token.token.user_name
#   repository_password = data.aws_ecrpublic_authorization_token.token.password
#   chart               = "karpenter"
#   version             = "v0.32.1"

#   values = [
#     <<-EOT
#     settings:
#       clusterName: ${module.eks.cluster_name}
#       clusterEndpoint: ${module.eks.cluster_endpoint}
#       interruptionQueueName: ${module.karpenter.queue_name}
#     serviceAccount:
#       annotations:
#         eks.amazonaws.com/role-arn: ${module.karpenter.irsa_arn} 
#     EOT
#   ]
# }

# resource "kubectl_manifest" "karpenter_node_class" {
#   yaml_body = <<-YAML
#     apiVersion: karpenter.k8s.aws/v1beta1
#     kind: EC2NodeClass
#     metadata:
#       name: default
#     spec:
#       amiFamily: AL2
#       role: ${module.karpenter.role_name}
#       subnetSelectorTerms:
#         - tags:
#             karpenter.sh/discovery: ${module.eks.cluster_name}
#       securityGroupSelectorTerms:
#         - tags:
#             karpenter.sh/discovery: ${module.eks.cluster_name}
#       tags:
#         karpenter.sh/discovery: ${module.eks.cluster_name}
#   YAML

#   depends_on = [
#     helm_release.karpenter
#   ]
# }

# resource "kubectl_manifest" "karpenter_node_pool" {
#   yaml_body = <<-YAML
#     apiVersion: karpenter.sh/v1beta1
#     kind: NodePool
#     metadata:
#       name: default
#     spec:
#       template:
#         spec:
#           nodeClassRef:
#             name: default
#           requirements:
#             - key: "karpenter.k8s.aws/instance-category"
#               operator: In
#               values: ["c", "m", "r"]
#             - key: "karpenter.k8s.aws/instance-cpu"
#               operator: In
#               values: ["4", "8", "16", "32"]
#             - key: "karpenter.k8s.aws/instance-hypervisor"
#               operator: In
#               values: ["nitro"]
#             - key: "karpenter.k8s.aws/instance-generation"
#               operator: Gt
#               values: ["2"]
#       limits:
#         cpu: 1000
#       disruption:
#         consolidationPolicy: WhenEmpty
#         consolidateAfter: 30s
#   YAML

#   depends_on = [
#     kubectl_manifest.karpenter_node_class
#   ]
# }

# # Example deployment using the [pause image](https://www.ianlewis.org/en/almighty-pause-container)
# # and starts with zero replicas
# resource "kubectl_manifest" "karpenter_example_deployment" {
#   yaml_body = <<-YAML
#     apiVersion: apps/v1
#     kind: Deployment
#     metadata:
#       name: inflate
#     spec:
#       replicas: 0
#       selector:
#         matchLabels:
#           app: inflate
#       template:
#         metadata:
#           labels:
#             app: inflate
#         spec:
#           terminationGracePeriodSeconds: 0
#           containers:
#             - name: inflate
#               image: public.ecr.aws/eks-distro/kubernetes/pause:3.7
#               resources:
#                 requests:
#                   cpu: 1
#   YAML

#   depends_on = [
#     helm_release.karpenter
#   ]
# }