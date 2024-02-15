
output "face_index_lambda_arn" {
  description = "The ARN of the lambda function"
  value       = data.aws_lambda_function.app_s3_face_index_lambda.arn
}



  


