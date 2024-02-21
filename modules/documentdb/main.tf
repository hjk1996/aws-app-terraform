resource "aws_docdb_cluster" "app_vector_database_cluster" {
  cluster_identifier      = "my-docdb-cluster"
  engine                  = "docdb"
  master_username         = "clusteradmin"
  master_password         = "ace12345"
  engine_version = "5.0.0"
  skip_final_snapshot     = true
  db_subnet_group_name = aws_docdb_subnet_group.app_db_subnet_group.name

    vpc_security_group_ids = [var.app_vector_db_security_group_id]
  tags = {
    Name = "app-vector-database"
  }
}

resource "aws_docdb_cluster_instance" "app_vector_database_instance" {
  identifier = "my-docdb-cluster-instance"
  engine = "docdb"
  cluster_identifier = aws_docdb_cluster.app_vector_database_cluster.id
  instance_class = "db.t3.medium"
  apply_immediately = true
}


resource "aws_docdb_subnet_group" "app_db_subnet_group" {
  name       = "app-db-subnet-group"
  subnet_ids = var.app_private_subnet_ids
  tags = {
    Name = "app-db-subnet-group"
  }
}