
output "face_index_lambda_arn" {
  description = "The ARN of the lambda function"
  value       = aws_lambda_function.face_index_lambda.arn
}

output "image_resize_lambda_arn" {
  description = "The ARN of the lambda function"
  value       = aws_lambda_function.image_resize_lambda.arn
}


output "delete_table_item_lambda_arn" {
  description = "The ARN of the lambda function"
  value       = aws_lambda_function.image_delete_cleanup_lambda
}





