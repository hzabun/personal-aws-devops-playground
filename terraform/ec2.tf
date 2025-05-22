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
  associate_public_ip_address = true
  key_name = aws_key_pair.kp.key_name
  count = var.num_instances

  tags = merge(local.tags, {
    name = "flask_instance"
  })
}

resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kp" {
  key_name   = "flask_app_key"
  public_key = tls_private_key.pk.public_key_openssh
}
resource "local_file" "ssh_key" {
  filename = "${aws_key_pair.kp.key_name}.pem"
  content = tls_private_key.pk.private_key_pem
  file_permission = "0400"
}