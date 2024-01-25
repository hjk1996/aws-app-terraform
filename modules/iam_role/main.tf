

resource "aws_iam_role" "app_nsfw_detect_lambda_iam_role" {
  name               = "app-nsfw-detect-lambda-role"
  assume_role_policy = var.lambda_trust_policy
  tags = {
    "Terraform" = "true"
  }
  depends_on = [var.lambda_trust_policy]

}

resource "aws_iam_role_policy_attachment" "app_nsfw_detect_lambda_role_policy_attachment" {
  count      = length(var.nsfw_detect_lambda_policy_arns)
  role       = aws_iam_role.app_nsfw_detect_lambda_iam_role.name
  policy_arn = var.nsfw_detect_lambda_policy_arns[count.index]
  depends_on = [aws_iam_role.app_nsfw_detect_lambda_iam_role]
}



resource "aws_iam_role" "eks_cluster_iam_role" {
  name = "app-eks-cluster-role"

  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : [
            "sts:AssumeRole"
          ],
          "Effect" : "Allow",
          "Principal" : {
            "Service" : [
              "eks.amazonaws.com"
            ]
          }
        }
      ]
    }
  )
  tags = {
    "Terraform" = "true"
  }
  depends_on = [var.eks_trust_policy]
}

resource "aws_iam_role_policy_attachment" "app_eks_cluster_role_policy_attachment" {
  role       = aws_iam_role.eks_cluster_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  depends_on = [aws_iam_role.eks_cluster_iam_role]

}


resource "aws_iam_role" "karpenter_instance_node_role" {
  name = "karpenter-instance-node-role"
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
  ]
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : [
            "sts:AssumeRole"
          ],
          "Effect" : "Allow",
          "Principal" : {
            "Service" : [
              "eks.amazonaws.com"
            ]
          }
        }
      ]
    }
  )
  tags = {
    "Terraform" = "true"
  }
}
