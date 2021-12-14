data "tls_certificate" "dev_tls-cert" {
  url = aws_eks_cluster.prod_eks_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "this" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.dev_tls-cert.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.prod_eks_cluster.identity[0].oidc[0].issuer
}