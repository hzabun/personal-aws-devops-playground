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
  default = "demo-cluster"
}

variable "admin_user_name" {
  type = string
}

variable "allowed_instance_types" {
  description = "List of allowed EC2 instance types for Karpenter"
  type        = list(string)
  default = [
    "t2.micro",
    "t2.small",
    "t2.medium",
    "t3.micro",
    "t3.small",
    "t3.medium"
  ]
}