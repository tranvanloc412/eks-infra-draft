locals {
  kubeconfig = templatefile("${path.module}/templates/kubeconfig.tpl", {
    kubeconfig_name                   = local.kubeconfig_name
    endpoint                          = coalescelist(aws_eks_cluster.prod_eks_cluster[*].endpoint, [""])[0]
    cluster_auth_base64               = coalescelist(aws_eks_cluster.prod_eks_cluster[*].certificate_authority[0].data, [""])[0]
    aws_authenticator_command         = var.kubeconfig_aws_authenticator_command
    aws_authenticator_command_args    = var.kubeconfig_aws_authenticator_command_args
    aws_authenticator_additional_args = var.kubeconfig_aws_authenticator_additional_args
    aws_authenticator_env_variables   = var.kubeconfig_aws_authenticator_env_variables
  })

  kubeconfig_name    = var.cluster_name
  
  config_output_path = "${path.cwd}/config"
}