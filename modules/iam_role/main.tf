



#### ############################# ####



resource "aws_iam_role" "image_delete_cleanup_lambda_iam_role" {
  name = "app-image-delete-cleanup-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    "Terraform" = "true"
  }

}

resource "aws_iam_role_policy_attachment" "image_delete_cleanup_lambda_iam_role_policy_attachment_1" {
  role       = aws_iam_role.image_delete_cleanup_lambda_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}

resource "aws_iam_role_policy_attachment" "image_delete_cleanup_lambda_iam_role_policy_attachment_2" {
  role       = aws_iam_role.image_delete_cleanup_lambda_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_role_policy_attachment" "image_delete_cleanup_lambda_iam_role_policy_attachment_3" {
  role       = aws_iam_role.image_delete_cleanup_lambda_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRekognitionFullAccess"
}


resource "aws_iam_role_policy_attachment" "image_delete_cleanup_lambda_iam_role_policy_attachment_4" {
  role = aws_iam_role.image_delete_cleanup_lambda_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy_attachment" "image_delete_cleanup_lambda_iam_role_policy_attachment_5" {
  role       = aws_iam_role.image_delete_cleanup_lambda_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

resource "aws_iam_policy" "vpc_access_policy" {
  name        = "vpc-access-policy"
  description = "Allows access to VPC resources"
  
  policy =  jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "image_delete_cleanup_lambda_iam_role_policy_attachment_6" {
  role       = aws_iam_role.image_delete_cleanup_lambda_iam_role.name
  policy_arn = aws_iam_policy.vpc_access_policy.arn
}






### ############################# ###


resource "aws_iam_role" "face_index_lambda_iam_role" {
  name = "face-index-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    "Terraform" = "true"
  }

}

resource "aws_iam_role_policy_attachment" "face_index_lambda_role_policy_attachment_1" {
  role       = aws_iam_role.face_index_lambda_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}

resource "aws_iam_role_policy_attachment" "face_index_lambda_role_policy_attachment_2" {
  role       = aws_iam_role.face_index_lambda_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_role_policy_attachment" "face_index_lambda_role_policy_attachment_3" {
  role       = aws_iam_role.face_index_lambda_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRekognitionFullAccess"
}


resource "aws_iam_role_policy_attachment" "face_index_lambda_role_policy_attachment_4" {
  role       = aws_iam_role.face_index_lambda_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy_attachment" "face_index_lambda_role_policy_attachment_5" {
  role       = aws_iam_role.face_index_lambda_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}


### ############################# ###

resource "aws_iam_role" "image_resize_lambda_iam_role" {
  name = "image-resize-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    "Terraform" = "true"
  }

}

resource "aws_iam_role_policy_attachment" "image_resize_lambda_role_policy_attachment_1" {
  role       = aws_iam_role.image_resize_lambda_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}


resource "aws_iam_role_policy_attachment" "image_resize_lambda_role_policy_attachment_2" {
  role       = aws_iam_role.image_resize_lambda_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy_attachment" "image_resize_lambda_role_policy_attachment_3" {
  role       = aws_iam_role.image_resize_lambda_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}



### ############################# ###



### ############################# ###
