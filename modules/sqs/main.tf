

resource "aws_sqs_queue" "image_caption_queue" {
  name = "image-caption-queue"
}



resource "aws_sqs_queue_policy" "image_caption_queue_policy" {
  queue_url = aws_sqs_queue.image_caption_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = var.image_caption_irsa_role_arn
        }
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.image_caption_queue.arn
      },

      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.image_caption_queue.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" : var.app_sns_on_object_created_topic_arn
          }
        }
      }
    ]
  })
}


#######


resource "aws_sqs_queue" "image_resize_queue" {
  name = "image-resize-queue"
}



resource "aws_sqs_queue_policy" "image_resize_queue_policy" {
  queue_url = aws_sqs_queue.image_resize_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = var.image_resize_lambda_iam_role_arn
        }
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.image_resize_queue.arn
      },

      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.image_resize_queue.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" : var.app_sns_on_object_created_topic_arn
          }
        }
      }
    ]
  })
}


#######

resource "aws_sqs_queue" "image_metadata_queue" {
  name = "image-metadata-queue"
}



resource "aws_sqs_queue_policy" "image_metadata_queue_policy" {
  queue_url = aws_sqs_queue.image_metadata_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = var.face_index_lambda_iam_role_arn
        }
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.image_metadata_queue.arn
      },

      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.image_metadata_queue.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" : var.app_sns_on_object_created_topic_arn
          }
        }
      }
    ]
  })
}

#######

resource "aws_sqs_queue" "delete_cleanup_queue" {
  name = "delete_cleanup_queue"
}



resource "aws_sqs_queue_policy" "delete_cleanup_queue_policy" {
  queue_url = aws_sqs_queue.delete_cleanup_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = var.image_delete_cleanup_lambda_iam_role_arn
        }
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.image_metadata_queue.arn
      },

      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.image_metadata_queue.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" : var.app_sns_on_object_deleted_topic_arn
          }
        }
      }
    ]
  })
}