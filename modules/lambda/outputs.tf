
output "face_index_lambda_arn" {
  description = "The ARN of the lambda function"
  value       = data.aws_lambda_function.app_s3_face_index_lambda.arn
}


output "delete_face_index_lambda_arn" {
  description = "The ARN of the lambda function"
  value       = aws_lambda_function.delete_face_index_lambda.arn
}





