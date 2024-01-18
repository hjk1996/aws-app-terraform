output "app_db_rds_address" {
    description = "The address of the app DB"
    value       = aws_db_instance.app_db.address
}