variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/24"
}

variable "subnet_cidr" {
  type    = string
  default = "10.0.0.0/25"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ecs_cluster_name" {
  type    = string
  default = "demo_cluster"

}