output "lambda_trust_policy" {
  description = "The trust policy for the lambda function"
  value       = data.aws_iam_policy_document.lambda_trust_policy_data.json
}


output "app_nsfw_detect_lambda_policy_arns" {
  description = "The policy for the lambda function"
  value = [
    aws_iam_policy.app_nsfw_detect_lambda_policy.arn,
    aws_iam_policy.allow_logs_policy.arn,
  ]
}
