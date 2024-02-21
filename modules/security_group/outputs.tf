output "delete_table_item_lambda_security_group_id" {
  value = aws_security_group.delete_table_item_lambda_security_group.id
}

output "app_vector_db_security_group_id" {
  value = aws_security_group.app_vector_db_security_group.id
}