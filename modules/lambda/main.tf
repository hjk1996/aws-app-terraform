
data "aws_lambda_function" "app_s3_face_index_lambda" {
  function_name = "app_s3_face_index"
}

##################

resource "aws_lambda_permission" "app_s3_index_face_lambda_allow_sns_invoke" {
  statement_id  = "AllowSQSInvocation"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.app_s3_face_index_lambda.arn
  principal     = "sns.amazonaws.com"
  source_arn    = var.app_on_object_created_topic_arn
}

