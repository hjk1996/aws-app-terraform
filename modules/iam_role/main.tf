

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


#### ############################# ####



resource "aws_iam_role" "delete_face_index_iam_role" {
  name = "app-delete-face-index-lambda-role"
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

resource "aws_iam_role_policy_attachment" "delete_face_index_lambda_role_policy_attachment_1" {
  role       = aws_iam_role.delete_face_index_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
}

resource "aws_iam_role_policy_attachment" "delete_face_index_lambda_role_policy_attachment_2" {
  role       = aws_iam_role.delete_face_index_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_role_policy_attachment" "delete_face_index_lambda_role_policy_attachment_3" {
  role       = aws_iam_role.delete_face_index_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRekognitionFullAccess"
}


resource "aws_iam_role_policy_attachment" "delete_face_index_lambda_role_policy_attachment_4" {
  role       = aws_iam_role.delete_face_index_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

### ############################# ###