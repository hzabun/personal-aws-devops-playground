resource "aws_eks_cluster" "flask_cluster" {
  name = var.eks_cluster_name

  access_config {
    authentication_mode = "API"
  }

  role_arn = aws_iam_role.flask_cluster_role.arn
  version  = "1.31"

  bootstrap_self_managed_addons = false

  compute_config {
    enabled       = true
    node_pools    = ["general-purpose"]
    node_role_arn = aws_iam_role.flask_node_role.arn
  }

  kubernetes_network_config {
    elastic_load_balancing {
      enabled = true
    }
  }

  storage_config {
    block_storage {
      enabled = true
    }
  }

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true

    subnet_ids = [
      aws_subnet.public_subnet1.id,
      aws_subnet.public_subnet2.id
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.flask_cluster_role_policy_attachment,
    aws_iam_role_policy_attachment.flask_cluster_compute_policy_attachment,
    aws_iam_role_policy_attachment.flask_cluster_storage_policy_attachment,
    aws_iam_role_policy_attachment.flask_cluster_lb_policy_attachment,
    aws_iam_role_policy_attachment.flask_cluster_networking_policy_attachment,
  ]
}