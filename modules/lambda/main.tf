


##################



data "archive_file" "delete_table_item" {
  type        = "zip"
  source_dir  = "${path.module}/codes/delete_table_item"
  output_path = "${path.module}/zips/delete_table_item/lambda_function.zip"
}



resource "aws_lambda_function" "delete_table_item_lambda" {
  function_name    = "app_delete_table_item"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  role             = var.delete_face_index_lambda_iam_role_arn
  filename         = "${path.module}/zips/delete_table_item/lambda_function.zip"
  source_code_hash = filebase64sha256("${path.module}/codes/delete_table_item/lambda_function.py")


  environment {
    variables = {
      DYNAMODB_TABLE_NAME = var.app_image_metadata_table_name
    }
  }

  tags = {
    "Terraform" = "true"
  }

  depends_on = [
    data.archive_file.delete_table_item
  ]
}

resource "aws_lambda_permission" "app_delete_table_item_allow_sns_invoke" {
  statement_id  = "AllowSNSInvocation"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete_table_item_lambda.arn
  principal     = "sns.amazonaws.com"
  source_arn    = var.app_on_object_deleted_topic_arn
}



##################

data "archive_file" "create_table_item" {
  type        = "zip"
  source_dir  = "${path.module}/codes/create_table_item"
  output_path = "${path.module}/zips/create_table_item/lambda_function.zip"
}

resource "aws_lambda_function" "create_table_item_lambda" {
  function_name    = "app_create_table_item"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  role             = var.face_index_lambda_iam_role_arn
  filename         = "${path.module}/zips/create_table_item/lambda_function.zip"
  source_code_hash = filebase64sha256("${path.module}/codes/create_table_item/lambda_function.py")


  environment {
    variables = {
      DYNAMODB_TABLE_NAME = var.app_image_metadata_table_name
    }
  }

  tags = {
    "Terraform" = "true"
  }

  depends_on = [
    data.archive_file.create_table_item
  ]
}


resource "aws_lambda_permission" "app_create_table_item_lambda_allow_sns_invoke" {
  statement_id  = "AllowSNSInvocation"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_table_item_lambda.arn
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


##################
