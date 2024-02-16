

resource "aws_sns_topic" "app_sns_on_object_created" {
  name = "app_on_object_created"

}

resource "aws_sns_topic_policy" "app_sns_on_object_created_topic_policy" {
  arn = aws_sns_topic.app_sns_on_object_created.arn
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = "sns:Publish",
        Resource  = aws_sns_topic.app_sns_on_object_created.arn,
        Condition = {
          ArnLike = {
            "AWS:SourceArn" = var.app_image_bucket_arn
          }
        }
      }
    ]
  })
}


resource "aws_sns_topic_subscription" "index_face_lambda_subscribe_to_sns_on_object_created" {
  topic_arn = aws_sns_topic.app_sns_on_object_created.arn
  protocol  = "lambda"
  endpoint  = var.face_index_lambda_arn
}


resource "aws_sns_topic_subscription" "image_resize_lambda_subscribe_to_sns_on_object_created" {
  topic_arn = aws_sns_topic.app_sns_on_object_created.arn
  protocol  = "lambda"
  endpoint  = var.image_resize_lambda_arn
}

resource "aws_sns_topic_subscription" "image_caption_queue_subscribe_to_sns_on_object_created" {
  topic_arn = aws_sns_topic.app_sns_on_object_created.arn
  protocol  = "sqs"
  endpoint  = var.image_caption_queue_arn
}


##### ############################# #####

resource "aws_sns_topic" "app_sns_on_object_deleted" {
  name = "app_on_object_deleted"
}



resource "aws_sns_topic_policy" "app_sns_on_object_deleted_topic_policy" {
  arn = aws_sns_topic.app_sns_on_object_deleted.arn
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = "sns:Publish",
        Resource  = aws_sns_topic.app_sns_on_object_deleted.arn,
        Condition = {
          ArnLike = {
            "AWS:SourceArn" = var.app_image_bucket_arn
          }
        }
      }
    ]
  })
}

resource "aws_sns_topic_subscription" "delete_face_index_lambda_subscribe_to_sns_on_object_deleted" {
  topic_arn = aws_sns_topic.app_sns_on_object_deleted.arn
  protocol  = "lambda"
  endpoint  = var.delete_face_index_lambda_arn
}