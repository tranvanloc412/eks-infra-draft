# resource "aws_cloudwatch_log_group" "this" {
#   name = "/aws/eks/${var.cluster_name}/cluster"

#   tags = {
#     Environment = "production"
#     Application = var.cluster_name
#   }
# }

resource "aws_eks_cluster" "prod_eks_cluster" {
  name                      = var.cluster_name
  role_arn                  = aws_iam_role.prod_eks_cluster_role.arn
  enabled_cluster_log_types = ["api", "audit", ]

  vpc_config {
    subnet_ids              = var.private_subnets
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["115.76.182.50/32"]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController,
    # aws_cloudwatch_log_group.this,
  ]
}

resource "aws_iam_role" "prod_eks_cluster_role" {
  name = "prod_eks_cluster_role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.prod_eks_cluster_role.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.prod_eks_cluster_role.name
}

resource "kubernetes_namespace" "this" {
  metadata {
    # annotations = {
    #   name = "example-annotation"
    # }

    labels = {
      name = "controller"
    }

    name = "controller"
  }
}

resource "aws_eks_node_group" "prod_node_group" {
  cluster_name    = aws_eks_cluster.prod_eks_cluster.name
  node_group_name = "prod_node_group"
  node_role_arn   = aws_iam_role.prod_node_group_role.arn
  subnet_ids      = var.private_subnets
  instance_types  = ["t3.small"]
  capacity_type   = "ON_DEMAND"
  disk_size       = 15
  remote_access {
    ec2_ssh_key = "kube-demo"
  }

  scaling_config {
    desired_size = var.desired_nodes
    max_size     = 2
    min_size     = 1
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    # kubernetes_config_map.aws_auth
  ]
}

resource "aws_iam_role" "prod_node_group_role" {
  name = "prod_node_group_role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.prod_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.prod_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.prod_node_group_role.name
}

module "alb_ingress_controller" {
  source = "./modules/alb_ingress_controller"

  k8s_cluster_type = "eks"
  k8s_namespace    = kubernetes_namespace.this.metadata[0].name
  k8s_cluster_name = aws_eks_cluster.prod_eks_cluster.id
  issuer_url       = data.aws_eks_cluster.target.identity[0].oidc[0].issuer

  depends_on = [
    aws_eks_node_group.prod_node_group,
  ]
}

module "external_dns" {
  source = "./modules/external_dns"

  cluster_name  = var.cluster_name
  issuer_url    = data.aws_eks_cluster.target.identity[0].oidc[0].issuer
  k8s_namespace = kubernetes_namespace.this.metadata[0].name

  depends_on = [
    aws_eks_node_group.prod_node_group,
  ]
}

# module "fargate" {
#   source = "./modules/fargate"

#   cluster_name         = aws_eks_cluster.prod_eks_cluster.id
#   fargate_profile_name = "fp-dev"
#   k8s_namespace        = "fp-dev"
#   private_subnets      = var.private_subnets

#   depends_on = [aws_eks_cluster.prod_eks_cluster]
# }
