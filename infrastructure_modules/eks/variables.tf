variable "cluster_name" {}
variable "region" {}
variable "vpc_id" {}
variable "private_subnets" {}
variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap. See examples/basic/variables.tf for example format."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}
