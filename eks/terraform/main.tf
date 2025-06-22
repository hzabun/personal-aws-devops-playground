
provider "aws" {
  region = "us-east-1"
}

provider "kubernetes" {
  host                   = aws_eks_cluster.flask_cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.flask_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.flask_cluster.token
}

data "aws_eks_cluster_auth" "flask_cluster" {
  name = aws_eks_cluster.flask_cluster.name
}