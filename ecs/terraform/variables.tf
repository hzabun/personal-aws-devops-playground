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

variable "instance_type" {
  type    = string
  default = "t3.medium"
}

variable "ecs_cluster_name" {
  type    = string
  default = "demo_cluster"
}

variable "account_id" {
  type      = string
  sensitive = true
}

variable "namespace" {
  type    = string
  default = "playground"
}

variable "repo" {
  type    = string
  default = "flask-app"
}