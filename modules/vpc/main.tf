data "aws_region" "current" {

}

resource "aws_vpc" "app-vpc" {

  cidr_block = var.vpc_cidr_block

  tags = {
    Name      = var.vpc_name
    Terraform = "true"
  }
}

resource "aws_internet_gateway" "app-vpc-igw" {
  vpc_id = aws_vpc.app-vpc.id
  tags = {
    Name      = "app-vpc-igw"
    Terraform = "true"
  }
}

resource "aws_route_table" "app-vpc-public-route-table" {
  vpc_id = aws_vpc.app-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app-vpc-igw.id

  }

  tags = {
    Name      = "app-vpc-public-route-table"
    Terraform = "true"
  }
}

resource "aws_route_table" "app-vpc-private-route-table" {
  vpc_id = aws_vpc.app-vpc.id

  tags = {
    Name      = "app-vpc-priate-route-table"
    Terraform = "true"
  }
}

resource "aws_subnet" "app-vpc-public-subnets" {
  for_each                = var.subnet_list
  vpc_id                  = aws_vpc.app-vpc.id
  cidr_block              = "10.0.${each.key}.0/24"
  availability_zone       = "${data.aws_region.current.name}${each.value}"
  map_public_ip_on_launch = true
  tags = {
    Name      = "app-vpc-public-subnet-${each.value}"
    Terraform = "true"
  }
  depends_on = [aws_internet_gateway.app-vpc-igw, aws_route_table.app-vpc-public-route-table]

}



resource "aws_subnet" "app-vpc-private-subnets" {
  for_each          = var.subnet_list
  vpc_id            = aws_vpc.app-vpc.id
  cidr_block        = "10.0.${each.key + 10}.0/24"
  availability_zone = "${data.aws_region.current.name}${each.value}"
  tags = {
    Name      = "app-vpc-private-subnet-${each.value}"
    Terraform = "true"
  }
  depends_on = [aws_route_table.app-vpc-private-route-table]

}


resource "aws_route_table_association" "app-vpc-public-subnet-association" {
  for_each       = var.subnet_list
  subnet_id      = aws_subnet.app-vpc-public-subnets[each.key].id
  route_table_id = aws_route_table.app-vpc-public-route-table.id
  depends_on     = [aws_internet_gateway.app-vpc-igw, aws_route_table.app-vpc-public-route-table]
}

resource "aws_route_table_association" "app-vpc-private-subnet-association" {
  for_each       = var.subnet_list
  subnet_id      = aws_subnet.app-vpc-private-subnets[each.key].id
  route_table_id = aws_route_table.app-vpc-private-route-table.id
  depends_on     = [aws_route_table.app-vpc-private-route-table]
}