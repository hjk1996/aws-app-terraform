
resource "aws_db_subnet_group" "app_db_subnet_group" {
  name       = "app-db-subnet-group"
  subnet_ids = var.app_private_subnet_ids
  tags = {
    Name = "app-db-subnet-group"
  }
}

resource "aws_db_instance" "app_vector_database" {

  allocated_storage = 100
  db_name           = "ace"
  engine            = "postgres"
  engine_version    = "15.5"
  instance_class    = "db.t4g.large"

  username                 = "clusteradmin"
  password                 = "ace12345"
  publicly_accessible      = false
  skip_final_snapshot      = true
  db_subnet_group_name     = aws_db_subnet_group.app_db_subnet_group.name
  delete_automated_backups = true
  vpc_security_group_ids   = [var.app_vector_db_security_group_id]



  tags = {
    Name = "app-vector-database"
  }
}

resource "aws_db" "name" {

}