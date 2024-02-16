


##################



data "archive_file" "delete_face_index" {
  type        = "zip"
  source_dir  = "${path.module}/codes/delete_face_index"
  output_path = "${path.module}/zips/delete_face_index/lambda_function.zip"
}



resource "aws_lambda_function" "delete_face_index_lambda" {
  function_name    = "app_delete_face_index"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  role             = var.delete_face_index_lambda_iam_role_arn  
  filename         = "${path.module}/zips/delete_face_index/lambda_function.zip"
  source_code_hash = filebase64sha256("${path.module}/codes/delete_face_index/lambda_function.py")
  tags = {
    "Terraform" = "true"
  }

  depends_on = [
    data.archive_file.delete_face_index
  ]
}

resource "aws_lambda_permission" "app_delete_face_lambda_allow_sns_invoke" {
  statement_id  = "AllowSNSInvocation"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete_face_index_lambda.arn
  principal     = "sns.amazonaws.com"
  source_arn    = var.app_on_object_deleted_topic_arn
}



##################

data "archive_file" "face_index" {
  type        = "zip"
  source_dir  = "${path.module}/codes/face_index"
  output_path = "${path.module}/zips/face_index/lambda_function.zip"
}

resource "aws_lambda_function" "face_index_lambda" {
  function_name    = "app_face_index"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  role             = var.face_index_lambda_iam_role_arn
  filename         = "${path.module}/zips/face_index/lambda_function.zip"
  source_code_hash = filebase64sha256("${path.module}/codes/face_index/lambda_function.py")
  tags = {
    "Terraform" = "true"
  }

  depends_on = [
    data.archive_file.face_index
  ]
}


resource "aws_lambda_permission" "app_face_index_lambda_allow_sns_invoke" {
  statement_id  = "AllowSNSInvocation"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.face_index_lambda.arn
  principal     = "sns.amazonaws.com"
  source_arn    = var.app_on_object_created_topic_arn
}


##################

resource "aws_lambda_function" "image_resize_lambda" {
  function_name    = "app_image_resize"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  role             = var.image_resize_lambda_iam_role_arn
  filename         = "${path.module}/zips/resize_image/lambda_function.zip"
  source_code_hash = filebase64sha256("${path.module}/zips/resize_image/lambda_function.zip")
  tags = {
    "Terraform" = "true"
  }

}


resource "aws_lambda_permission" "app_image_resize_allow_sns_invoke" {
  statement_id  = "AllowSNSInvocation"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.image_resize_lambda.arn
  principal     = "sns.amazonaws.com"
  source_arn    = var.app_on_object_created_topic_arn
}
