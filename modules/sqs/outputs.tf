

output "image_caption_queue_arn" {
  value = aws_sqs_queue.image_caption_queue.arn
}

output "image_resize_queue_arn" {
  value = aws_sqs_queue.image_resize_queue.arn
}

output "image_metadata_queue_arn" {
  value = aws_sqs_queue.image_metadata_queue.arn

}

output "delete_cleanup_queue_arn" {
  value = aws_sqs_queue.delete_cleanup_queue.arn
}