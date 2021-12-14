data "aws_caller_identity" "current" {}

locals {
  account_id                = data.aws_caller_identity.current.account_id
  issuer_host_path          = trim(var.issuer_url, "https://")
  provider_arn              = "arn:aws:iam::${local.account_id}:oidc-provider/${local.issuer_host_path}"
  service_account           = var.service_account == "" ? "${var.cluster_name}-external-dns" : var.service_account
  service_account_arn       = "system:serviceaccount:${var.k8s_namespace}:${local.service_account}"
  external_dns_docker_image = "k8s.gcr.io/external-dns/external-dns:v0.7.6"
}
