
output "image_delete_cleanup_lambda_iam_role_arn" {
  value = aws_iam_role.image_delete_cleanup_lambda_iam_role.arn

}

output "face_index_lambda_iam_role_arn" {
  value = aws_iam_role.face_index_lambda_iam_role.arn

}

output "image_resize_lambda_iam_role_arn" {
  value = aws_iam_role.image_resize_lambda_iam_role.arn
}
