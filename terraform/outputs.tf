output "vpc_cidr" {
  value = var.vpc_cidr
}

output "subnet_cidr" {
  value = var.subnet_cidr
}

output "instance_ips" {
  value = "${aws_instance.flask_instances.*.public_ip}"
}