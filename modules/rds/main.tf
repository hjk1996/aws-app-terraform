
resource "aws_db_subnet_group" "app_db_subnet_group" {
    name = "app-db-subnet-group"
    subnet_ids = var.app_private_subnet_ids
    tags = {
        Name = "app-db-subnet-group"
    }
}

resource "aws_db_instance" "app_db" {
  allocated_storage    = 30
  db_name              = "ace"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = var.app_db_instance_type
  username             = "admin"
  password             = "ace12345"
  parameter_group_name = "default.mysql5.7"
  publicly_accessible = false
  skip_final_snapshot  = true
  vpc_security_group_ids = [var.app_db_security_group_id]
}