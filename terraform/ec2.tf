data "aws_ami" "aws_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_instance" "flask_instances" {
  ami                    = data.aws_ami.aws_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.allow_ingress.id]
  # security_groups = [aws_security_group.allow_http_and_https.name]
  count = var.num_instances

  tags = merge(local.tags, {
    name = "flask_instance"
  })
}