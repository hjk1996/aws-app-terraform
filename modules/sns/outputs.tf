
output "app_on_object_created_topic_arn" {
  value = aws_sns_topic.app_sns_on_object_created.arn
}

output "app_on_object_deleted_topic_arn" {
  value = aws_sns_topic.app_sns_on_object_deleted.arn
}