

output "image_caption_queue_arn" {
  value = aws_sqs_queue.image_caption_queue.arn
}