resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.subnet_cidr

  tags = merge(local.tags, {
    visibility = "public"
  })
}

resource "aws_security_group" "allow_ingress" {
  vpc_id = aws_vpc.main.id
  tags   = local.tags
  dynamic "ingress" {
    for_each = var.allowed_ports
    iterator = port
    content {
      protocol = "tcp"
      from_port = port.value
      to_port = port.value
    }
  }
}

resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

output "vpc_cidr" {
  value = var.vpc_cidr
}

output "subnet_cidr" {
  value = var.subnet_cidr
}