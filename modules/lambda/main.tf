

# lambda function이 사용할 docker image repository에 대한 정보를 가져온다
data "aws_ecr_repository" "app_nsfw_detect_lambda_repo" {
  name = "nsfw-detector"
}

# lambda function을 생성한다.
resource "aws_lambda_function" "app_nsfw_detect_lambda" {
  function_name = "app-nsfw-detect-lambda"

  role          = var.app_nsfw_detect_lambda_iam_role_arn
  image_uri     = "${data.aws_ecr_repository.app_nsfw_detect_lambda_repo.repository_url}:latest"
  package_type  = "Image"
  memory_size   = 1024
  timeout       = 120
  depends_on    = [var.app_nsfw_detect_lambda_iam_role_arn]
}


# s3가 lambda를 invoke할 수 있도록 권한을 부여한다.
resource "aws_lambda_permission" "app_nsfw_detect_lambda_allow_s3_invoke" {
  statement_id  = "AllowS3Invocation"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.app_nsfw_detect_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.app_image_bucket_arn
}


##################
