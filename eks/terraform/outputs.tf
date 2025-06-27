output "jump_host_IP" {
  value = aws_instance.jump_host.public_ip
}