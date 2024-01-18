output "app_nsfw_dtect_lambda_ecr_url" {
  description = "The URI of the ECR repository"
  value       = aws_ecr_repository.app_nsfw_detect_lambda_repo.repository_url
}