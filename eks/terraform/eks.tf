resource "aws_eks_cluster" "flask_cluster" {
  name = var.eks_cluster_name

  access_config {
    authentication_mode = "API"
  }

  role_arn = aws_iam_role.eks_flask_cluster_role.arn
  version  = "1.31"

  bootstrap_self_managed_addons = false

  compute_config {
    enabled = false
  }

  kubernetes_network_config {
    elastic_load_balancing {
      enabled = false
    }
  }

  storage_config {
    block_storage {
      enabled = false
    }
  }

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true

    subnet_ids = [
      aws_subnet.private_subnet1.id,
      aws_subnet.private_subnet2.id
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.flask_cluster_role_policy_attachment,
  ]
}

resource "aws_eks_access_entry" "flask_cluster_access_entry" {
  cluster_name  = aws_eks_cluster.flask_cluster.name
  principal_arn = data.aws_iam_user.admin_user.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "flask_cluster_admin_policy_association" {
  cluster_name  = aws_eks_access_entry.flask_cluster_access_entry.cluster_name
  principal_arn = data.aws_iam_user.admin_user.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_node_group" "eks_nodes" {
  cluster_name    = aws_eks_cluster.flask_cluster.name
  node_group_name = "flask-eks-nodes"
  node_role_arn   = aws_iam_role.eks_flask_node_role.arn
  subnet_ids      = [aws_subnet.private_subnet1.id, aws_subnet.private_subnet2.id]

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 1
  }

  instance_types = ["t3.medium"]

  depends_on = [
    aws_iam_role_policy_attachment.flask_node_EKS_worker_policy_attachment,
    aws_iam_role_policy_attachment.flask_node_EKS_CNI_policy_attachment,
    aws_iam_role_policy_attachment.flask_node_ECR_pull_policy_attachment,
  ]
}