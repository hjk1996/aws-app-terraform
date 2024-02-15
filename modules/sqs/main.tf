

resource "aws_sqs_queue" "image_caption_queue" {
  name                        = "image-caption-queue"
}



resource "aws_sqs_queue_policy" "image_caption_queue_policy" {
  queue_url = aws_sqs_queue.image_caption_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
   {
        Effect    = "Allow"
        Principal = {
          AWS = var.image_caption_irsa_role_arn
        }
        Action    = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource  = aws_sqs_queue.image_caption_queue.arn
      },

      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.image_caption_queue.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn": var.app_image_bucket_arn
          }
        }
      }
    ]
  })
}


