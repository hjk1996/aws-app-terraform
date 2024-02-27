


##################


resource "aws_lambda_function" "image_delete_cleanup_lambda" {
  function_name    = "app_image_delete_cleanup"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  role             = var.image_delete_cleanup_lambda_iam_role_arn
  filename         = "${path.module}/zips/image_delete_cleanup/lambda_function.zip"
  source_code_hash = filebase64sha256("${path.module}/codes/image_delete_cleanup/lambda_function.py")

  vpc_config {
    subnet_ids         = var.app_vpc_public_subnet_ids
    security_group_ids = [var.delete_table_item_lambda_security_group_id]
  }


  environment {
    variables = {
      DYNAMODB_TABLE_NAME = var.app_image_metadata_table_name
    }
  }

  tags = {
    "Terraform" = "true"
  }


}

resource "aws_lambda_permission" "image_delete_cleanup_lambda_allow_sqs_invoke" {
  statement_id  = "AllowSQSInvocation"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.image_delete_cleanup_lambda.arn
  principal     = "sqs.amazonaws.com"
  source_arn    = var.app_on_object_deleted_topic_arn
}

resource "aws_lambda_event_source_mapping" "image_delete_cleanup_lambda_sqs_mapping" {
  event_source_arn = var.delete_cleanup_queue_arn
  function_name    = aws_lambda_function.image_delete_cleanup_lambda.arn
  batch_size       = 10
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

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = var.app_image_metadata_table_name
    }
  }

  tags = {
    "Terraform" = "true"
  }

  depends_on = [
    data.archive_file.face_index
  ]
}


resource "aws_lambda_permission" "face_index_lambda_allow_sqs_invoke" {
  statement_id  = "AllowSQSInvocation"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.face_index_lambda.arn
  principal     = "sqs.amazonaws.com"
  source_arn    = var.app_on_object_created_topic_arn
}

resource "aws_lambda_event_source_mapping" "face_index_lambda_sqs_mapping" {
  event_source_arn = var.image_metadata_queue_arn
  function_name    = aws_lambda_function.face_index_lambda.arn
  batch_size       = 10

}



##################

resource "aws_lambda_function" "image_resize_lambda" {
  function_name = "app_image_resize"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  s3_bucket     = "app-lambda-code-bucket"
  s3_key        = "app_image_resize/lambda_function.zip"
  role          = var.image_resize_lambda_iam_role_arn
  tags = {
    "Terraform" = "true"
  }


  environment {
    variables = {
      BUCKET_NAME = var.app_image_bucket_name
      IMAGE_SIZE  = "300"
    }
  }

}


resource "aws_lambda_permission" "app_image_resize_allow_sqs_invoke" {
  statement_id  = "AllowSQSInvocation"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.image_resize_lambda.arn
  principal     = "sqs.amazonaws.com"
  source_arn    = var.image_resize_queue_arn
}

resource "aws_lambda_event_source_mapping" "image_resize_lambda_sqs_mapping" {
  event_source_arn = var.image_resize_queue_arn
  function_name    = aws_lambda_function.image_resize_lambda.arn
  batch_size       = 10

}



##################
