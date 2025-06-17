variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/24"
}

variable "subnet1_cidr" {
  type    = string
  default = "10.0.0.0/25"
}

variable "subnet2_cidr" {
  type    = string
  default = "10.0.0.128/25"
}

variable "eks_cluster_name" {
  type    = string
  default = "demo_cluster"
}