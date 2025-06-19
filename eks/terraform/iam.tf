resource "aws_iam_role" "flask_node_role" {
  name = "eks-flask-auto-node-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["sts:AssumeRole"]
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "flask_node_EKS_worker_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.flask_node_role.name
}

resource "aws_iam_role_policy_attachment" "flask_node_ECR_pull_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
  role       = aws_iam_role.flask_node_role.name
}

resource "aws_iam_role_policy_attachment" "flask_node_EKS_CNI_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.flask_node_role.name
}

resource "aws_iam_role" "flask_cluster_role" {
  name = "eks-flask-cluster"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "flask_cluster_role_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.flask_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "flask_cluster_compute_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSComputePolicy"
  role       = aws_iam_role.flask_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "flask_cluster_storage_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSBlockStoragePolicy"
  role       = aws_iam_role.flask_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "flask_cluster_lb_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy"
  role       = aws_iam_role.flask_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "flask_cluster_networking_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSNetworkingPolicy"
  role       = aws_iam_role.flask_cluster_role.name
}