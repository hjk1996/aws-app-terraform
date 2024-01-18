
resource "aws_iam_role" "app_nsfw_detect_lambda_iam_role" {
  name               = "app-nsfw-detect-lambda-role"
  assume_role_policy = var.lambda_trust_policy
  tags = {
    "Terraform" = "true"
  }
  depends_on = [var.lambda_trust_policy]

}

resource "aws_iam_role_policy_attachment" "app_nsfw_detect_lambda_role_policy_attachment" {
  count = length(var.nsfw_detect_lambda_policy_arns)
  role       = aws_iam_role.app_nsfw_detect_lambda_iam_role.name
  policy_arn = var.nsfw_detect_lambda_policy_arns[count.index]
  depends_on = [aws_iam_role.app_nsfw_detect_lambda_iam_role]
}
