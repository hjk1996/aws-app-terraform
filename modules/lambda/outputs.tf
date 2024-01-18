output "app_nsfw_detect_lambda_arn" {
  description = "The ARN of the lambda function"
  value       = aws_lambda_function.app_nsfw_detect_lambda.arn
}

