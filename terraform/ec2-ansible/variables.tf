variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/24"
}

variable "subnet_cidr" {
  type    = string
  default = "10.0.0.0/25"
}

variable "num_instances" {
  type    = number
  default = 3
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "allowed_ports" {
  type    = list(number)
  default = [22, 80, 443]
}