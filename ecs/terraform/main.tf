provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket  = "demo-terraform-state-bucket"
    key     = "terraform/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}