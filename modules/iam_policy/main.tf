# s3에 대한 권한을 부여하는 iam_policy 모듈을 생성합니다.
data "aws_iam_policy_document" "allow_app_image_s3_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = [
      "${var.app_image_bucket_arn}/*"
    ]
  }

}

# cloudwatch logs에 대한 권한을 부여하는 iam_policy 모듈을 생성합니다.
data "aws_iam_policy_document" "allow_logs_policy_data" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }

}

# lambda 함수가 iam_role을 사용할 수 있도록 권한을 부여하는 iam_policy 모듈을 생성합니다.
data "aws_iam_policy_document" "lambda_trust_policy_data" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

  }
}

data "aws_iam_policy_document" "eks_trust_policy_data" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

  }
}


data "aws_iam_policy_document" "eks_cluster_role_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = [
      "${var.app_image_bucket_arn}/*"
    ]
  }

}



resource "aws_iam_policy" "app_nsfw_detect_lambda_policy" {
  name   = "nsfw_detect_lambda_policy"
  policy = data.aws_iam_policy_document.allow_app_image_s3_policy.json
  tags = {
    "Terraform" = "true"
  }
  depends_on = [data.aws_iam_policy_document.allow_app_image_s3_policy]

}

resource "aws_iam_policy" "allow_logs_policy" {
  name   = "allow_logs_policy_data"
  policy = data.aws_iam_policy_document.allow_logs_policy_data.json
  tags = {
    "Terraform" = "true"
  }
  depends_on = [data.aws_iam_policy_document.allow_logs_policy_data]
}