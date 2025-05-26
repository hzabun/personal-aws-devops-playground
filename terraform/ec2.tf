data "aws_ami" "aws_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_instance" "flask_instances" {
  ami                         = data.aws_ami.aws_linux.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.allow_internet_traffic.id, aws_security_group.allow_internal_ssh.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.kp.key_name
  count                       = var.num_instances
  user_data = count.index == 0 ? file("${path.module}/scripts/user_data.sh") : null
  tags = merge(local.tags, {
    Name = "flask_instance"
  })
}

resource "aws_key_pair" "kp" {
  key_name   = "flask_app_key"
  public_key = file("${path.module}/../ssh-keys/ec2-key.pub")
}