resource "kubernetes_namespace" "fargate" {
  metadata {
    annotations = {
      name = var.k8s_namespace
    }

    labels = {
      mylabel = var.k8s_namespace
    }

    name = var.k8s_namespace
  }
}

resource "aws_eks_fargate_profile" "fargate" {
  cluster_name           = var.cluster_name
  fargate_profile_name   = var.fargate_profile_name
  pod_execution_role_arn = aws_iam_role.fargate.arn
  subnet_ids             = var.private_subnets

  selector {
    namespace = kubernetes_namespace.fargate.id
  }
}

resource "aws_iam_role" "fargate" {
  name = "eks-fargate-profile"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks-fargate-pods.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSFargatePodExecutionRolePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate.name
}