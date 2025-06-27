resource "aws_eks_cluster" "flask_cluster" {
  name = var.eks_cluster_name

  access_config {
    authentication_mode = "API"
  }

  role_arn = aws_iam_role.eks_flask_cluster_role.arn
  version  = "1.31"

  bootstrap_self_managed_addons = true

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true

    subnet_ids = [
      aws_subnet.private_subnet1.id,
      aws_subnet.private_subnet2.id
    ]

    security_group_ids = [aws_security_group.flask_eks_cluster_sg.id]
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

  launch_template {
    name    = aws_launch_template.flask_node_launch_configuration.name
    version = aws_launch_template.flask_node_launch_configuration.latest_version
  }

  depends_on = [
    aws_iam_role_policy_attachment.flask_node_EKS_worker_policy_attachment,
    aws_iam_role_policy_attachment.flask_node_EKS_CNI_policy_attachment,
    aws_iam_role_policy_attachment.flask_node_ECR_pull_policy_attachment,
  ]
}

resource "aws_launch_template" "flask_node_launch_configuration" {
  name          = "flask-node-launch-configuration"
  instance_type = "t3.medium"
  metadata_options {
    http_put_response_hop_limit = 2
  }

  vpc_security_group_ids = [aws_security_group.EKS_node_allow_curl_to_k8s_service.id, aws_eks_cluster.flask_cluster.vpc_config[0].cluster_security_group_id]
}

data "aws_instances" "node_group_instances" {
  filter {
    name   = "tag:kubernetes.io/cluster/${aws_eks_cluster.flask_cluster.name}"
    values = ["owned"]
  }

  filter {
    name   = "instance-state-name"
    values = ["running"]
  }

  depends_on = [aws_eks_node_group.eks_nodes]
}

data "aws_instance" "first_node" {
  instance_id = data.aws_instances.node_group_instances.ids[0]
}