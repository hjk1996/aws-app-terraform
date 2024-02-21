

resource "aws_security_group" "app_db_security_group" {
  name   = "app-db-security-group"
  vpc_id = var.app_vpc_id
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = var.public_subnet_cidr_blocks
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app-db-security-group"
  }

}

resource "aws_security_group" "delete_table_item_lambda_security_group" {
  name   = "delete-table-item-lambda-security-group"
  vpc_id = var.app_vpc_id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

}


resource "aws_security_group" "app_vector_db_security_group" {
  name        = "app-vector-db-security-group"
  description = "Security group for AWS OpenSearch Serverless VPC Endpoint"
  vpc_id      = var.app_vpc_id

  ingress {
    description = "Allow inbound traffic from OpenSearch Serverless VPC Endpoint"
    from_port   = 27017
    to_port     = 27018
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] 
  }

  # 아웃바운드 규칙 예시: 모든 아웃바운드 트래픽 허용
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "App Vector DB Security Group"
  }
}



###### 


