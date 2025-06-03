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

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.main.id
}

resource "aws_security_group" "allow_internet_traffic" {
  vpc_id = aws_vpc.main.id
  tags = merge(local.tags, {
    Name = "Basic internet traffic"
  })

}


resource "aws_vpc_security_group_ingress_rule" "allow_ssh_http_https" {
  for_each          = toset([for port in var.allowed_ports : tostring(port)])
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = tonumber(each.value)
  to_port           = tonumber(each.value)
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.allow_internet_traffic.id
}


resource "aws_vpc_security_group_egress_rule" "allow_https" {
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.allow_internet_traffic.id
}

resource "aws_security_group" "allow_internal_ssh" {
  vpc_id = aws_vpc.main.id
  tags = merge(local.tags, {
    Name = "Internal SSH"
  })

}

resource "aws_vpc_security_group_ingress_rule" "allow_internal_ssh_ingress" {
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
  security_group_id            = aws_security_group.allow_internal_ssh.id
  referenced_security_group_id = aws_security_group.allow_internal_ssh.id
  description                  = "Allow SSH from other instances in same SG"
}

resource "aws_vpc_security_group_egress_rule" "allow_internal_ssh_egress" {
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
  security_group_id            = aws_security_group.allow_internal_ssh.id
  referenced_security_group_id = aws_security_group.allow_internal_ssh.id
  description                  = "Allow SSH to other instances in same SG"
}

resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}