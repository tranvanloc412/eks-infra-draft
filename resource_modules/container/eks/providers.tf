
provider "kubernetes" {
  # alias                  = "eks"
  host                   = data.aws_eks_cluster.target.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.target.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.aws_iam_authenticator.token
  # config_path            = var.config_file_path
  # load_config_file       = false
}

data "aws_eks_cluster" "target" {
  name = aws_eks_cluster.prod_eks_cluster.id
  depends_on  = [aws_eks_cluster.prod_eks_cluster]
}

data "aws_eks_cluster_auth" "aws_iam_authenticator" {
  name = aws_eks_cluster.prod_eks_cluster.id
  depends_on  = [aws_eks_cluster.prod_eks_cluster]
}
