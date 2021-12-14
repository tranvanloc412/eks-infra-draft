# locals {
#   # Convert to format needed by aws-auth ConfigMap
#   configmap_roles = [
#     {
#       # Work around https://github.com/kubernetes-sigs/aws-iam-authenticator/issues/153
#       # Strip the leading slash off so that Terraform doesn't think it's a regex
#       rolearn  = aws_iam_role.prod_node_group_role.arn
#       username = "system:node:{{EC2PrivateDNSName}}"
#       groups = tolist(concat(
#         [
#           "system:bootstrappers",
#           "system:nodes",
#         ],
#       ))
#     },
#     {
#       rolearn  = module.fargate.role
#       username = "system:node:{{SessionName}}"
#       groups = tolist(concat(
#         [
#           "system:bootstrappers",
#           "system:nodes",
#           "system:node-proxier"
#         ],
#       ))
#     }
#   ]
# }

# resource "kubernetes_config_map" "aws_auth" {
#   metadata {
#     name      = "aws-auth"
#     namespace = "kube-system"
#     labels = merge(
#       {
#         "app.kubernetes.io/managed-by" = "Terraform"
#         # / are replaced by . because label validator fails in this lib 
#         # https://github.com/kubernetes/apimachinery/blob/1bdd76d09076d4dc0362456e59c8f551f5f24a72/pkg/util/validation/validation.go#L166
#         "terraform.io/module" = "terraform-aws-modules.eks.aws"
#       },
#       var.aws_auth_additional_labels
#     )
#   }

#   data = {
#     mapRoles = yamlencode(
#       distinct(concat(
#         local.configmap_roles,
#         var.map_roles,
#       ))
#     )
#     mapUsers    = yamlencode(var.map_users)
#     mapAccounts = yamlencode(var.map_accounts)
#   }
# }
