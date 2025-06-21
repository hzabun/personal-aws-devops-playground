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

resource "aws_eks_access_entry" "flask_cluster_access_entry" {
  cluster_name      = aws_eks_cluster.flask_cluster.name
  principal_arn     = data.aws_iam_user.admin_user.arn
  kubernetes_groups = ["platform-admins"]
  type              = "STANDARD"
}

resource "aws_eks_access_policy_association" "flask_cluster_admin_policy_association" {
  cluster_name  = aws_eks_access_entry.flask_cluster_access_entry.cluster_name
  principal_arn = data.aws_iam_user.admin_user.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  access_scope {
    type = "cluster"
  }
}