locals {
  account_id                              = data.aws_caller_identity.current.account_id
  issuer_host_path                        = trim(var.issuer_url, "https://")
  provider_arn                            = "arn:aws:iam::${local.account_id}:oidc-provider/${local.issuer_host_path}"
  service_account                         = var.service_account == "" ? "${var.k8s_cluster_name}-alb-ingress-controller" : var.service_account
  service_account_arn                     = "system:serviceaccount:${var.k8s_namespace}:${local.service_account}"
  aws_iam_path_prefix                     = var.aws_iam_path_prefix == "" ? null : var.aws_iam_path_prefix
  aws_vpc_id                              = data.aws_vpc.selected.id
  aws_alb_ingress_controller_version      = var.aws_alb_ingress_controller_version
  aws_region_name                         = data.aws_region.current.name
  aws_alb_ingress_controller_docker_image = "docker.io/amazon/aws-alb-ingress-controller:v${var.aws_alb_ingress_controller_version}"
  aws_alb_ingress_class                   = "alb"
}
