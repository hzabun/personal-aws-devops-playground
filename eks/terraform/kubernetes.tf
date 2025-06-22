resource "kubernetes_manifest" "karpenter_nodepool" {
  provider = kubernetes
  manifest = {
    apiVersion = "karpenter.sh/v1"
    kind       = "NodePool"
    metadata = {
      name = "restricted-nodepool"
    }
    spec = {
      template = {
        metadata = {
          labels = {
            nodepool = "restricted"
          }
        }
        spec = {
          nodeClassRef = {
            apiVersion = "karpenter.k8s.aws/v1beta1"
            kind       = "EC2NodeClass"
            name       = "restricted-nodeclass"
          }
          requirements = [
            {
              key      = "karpenter.sh/capacity-type"
              operator = "In"
              values   = ["on-demand"]
            },
            {
              key      = "node.kubernetes.io/instance-type"
              operator = "In"
              values   = var.allowed_instance_types
            },
            {
              key      = "kubernetes.io/arch"
              operator = "In"
              values   = ["amd64"]
            }
          ]
        }
      }
      limits = {
        cpu    = "1000"
        memory = "1000Gi"
      }
      disruption = {
        consolidationPolicy = "WhenUnderutilized"
        consolidateAfter    = "30s"
      }
    }
  }

  depends_on = [aws_eks_cluster.flask_cluster]
}

resource "kubernetes_manifest" "karpenter_nodeclass" {
  provider = kubernetes
  manifest = {
    apiVersion = "karpenter.k8s.aws/v1"
    kind       = "EC2NodeClass"
    metadata = {
      name = "restricted-nodeclass"
    }
    spec = {
      amiFamily = "AL2"

      subnetSelectorTerms = [
        {
          tags = {
            "karpenter.sh/discovery" = var.eks_cluster_name
          }
        }
      ]

      securityGroupSelectorTerms = [
        {
          tags = {
            "karpenter.sh/discovery" = var.eks_cluster_name
          }
        }
      ]

      # Role reference for the EC2 instances
      role = aws_iam_role.flask_node_role

    }
  }

  depends_on = [aws_eks_cluster.flask_cluster]
}