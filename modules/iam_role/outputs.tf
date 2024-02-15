output "app_nsfw_detect_lambda_iam_role_arn" {
  value = aws_iam_role.app_nsfw_detect_lambda_iam_role.arn
}

output "delete_face_index_lambda_arn" {
  value = aws_iam_role.delete_face_index_iam_role.arn

}

