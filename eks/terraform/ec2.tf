data "aws_ami" "aws_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_instance" "jump_host" {
  ami                         = data.aws_ami.aws_linux.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet1.id
  vpc_security_group_ids      = [aws_security_group.jump_host_sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.kp.key_name
  tags = merge(local.tags, {
    Name = "jump-host"
  })
}

resource "aws_key_pair" "kp" {
  key_name   = "flask-app-key"
  public_key = file("${path.module}/../ssh-keys/ec2-key.pub")
}