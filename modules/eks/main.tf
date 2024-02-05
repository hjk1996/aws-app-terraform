


data "aws_ecrpublic_authorization_token" "token" {

}

data "aws_region" "current" {


}


resource "tls_private_key" "eks-worker-ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "eks-worker-key" {
  key_name   = "eks-worker-key"
  public_key = tls_private_key.eks-worker-ssh.public_key_openssh
}

// EKS 클러스터 생성
module "eks" {
  source = "terraform-aws-modules/eks/aws"

  version = "~> 19.0"

  cluster_name    = var.eks_cluster_name
  cluster_version = "1.29"

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  node_security_group_tags = {
    "karpenter.sh/discovery" = var.eks_cluster_name
  }



  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::109412806537:root"
      username = "root"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::109412806537:user/hik"
      username = "root"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::109412806537:user/ktj"
      username = "root"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::109412806537:user/kcj"
      username = "root"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::109412806537:user/khj"
      username = "root"
      groups   = ["system:masters"]
    }
  ]

  cluster_addons = {
    coredns = {
      most_recent = true

      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {
      most_recent = true

    }
    vpc-cni = {
      most_recent              = true
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

      min_size = 1
      max_size = 3
      labels = {
        role = "general"
      }
      key_name = aws_key_pair.eks-worker-key.key_name
      subnet_ids     = var.private_subnet_ids
      instance_types = var.instance_types
      capacity_type  = "ON_DEMAND"
    }
  }


  tags = {
    Environment = "dev"
    Terraform   = "true"
  }

}





resource "null_resource" "update_kubeconfig" {
  depends_on = [module.eks]

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig  --name ${var.eks_cluster_name} --region ${data.aws_region.current.name}"
  }
}


# AWS VPC CNI (Container Network Interface) 플러그인을 위한 역할
# AWS VPC CNI 플러그인은 기본적으로 IPv4 주소를 파드에 할당하는 역할을 함
module "vpc_cni_irsa" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

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

module "load_balancer_controller_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                              = "${var.eks_cluster_name}-load-balancer-controller"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}

module "fluent_bit_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name = "${var.eks_cluster_name}-fluent-bit"


  role_policy_arns = {
    policy = "arn:aws:iam::aws:policy/AmazonOpenSearchServiceFullAccess"
  }

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["logging:fluent-bit-service-account"]
    }
  }

}
