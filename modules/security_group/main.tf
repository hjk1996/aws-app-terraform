

resource "aws_security_group" "app_db_security_group" {
    name = "app-db-security-group"
    vpc_id = var.app_vpc_id
    ingress {
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = var.public_subnet_cidr_blocks
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "app-db-security-group"
    }

}