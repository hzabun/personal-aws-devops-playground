resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "public_subnet1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet1_cidr
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = merge(local.tags, {
    visibility = "public"
  })
}

resource "aws_subnet" "public_subnet2" { 
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet2_cidr
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true

  tags = merge(local.tags, {
    visibility = "public"
  })
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = merge(local.tags, {
    Name = "public-rt"
  })
}

resource "aws_route_table_association" "public_assoc1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.main.id
}

resource "aws_route_table_association" "public_assoc2" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.main.id
}

resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}