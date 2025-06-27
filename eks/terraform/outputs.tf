output "jump_host_IP" {
  value = aws_instance.jump_host.public_ip
}

output "first_node_private_ip" {
  value = data.aws_instance.first_node.private_ip
}