variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/24"
}

variable "public_subnet1_cidr" {
  type    = string
  default = "10.0.0.0/26"
}

variable "public_subnet2_cidr" {
  type    = string
  default = "10.0.0.64/26"
}

variable "private_subnet1_cidr" {
  type    = string
  default = "10.0.0.128/26"
}

variable "private_subnet2_cidr" {
  type    = string
  default = "10.0.0.192/26"
}

variable "eks_cluster_name" {
  type    = string
  default = "demo_cluster"
}