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

resource "aws_security_group" "allow_http_and_https" {
  vpc_id = aws_vpc.main.id
  tags   = local.tags
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.allow_http_and_https.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  security_group_id = aws_security_group.allow_http_and_https.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

output "vpc_cidr" {
  value = var.vpc_cidr
}

output "subnet_cidr" {
  value = var.subnet_cidr
}