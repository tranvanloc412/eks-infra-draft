## ECR repo ##
variable "repos" {
  description = "(Required) Name of the repositories."
}
variable "image_tag_mutability" {
  description = "(Optional) The tag mutability setting for the repository. Must be one of: MUTABLE or IMMUTABLE. Defaults to MUTABLE."
  default = "MUTABLE"
}
variable "tags" {
  description = "(Optional) A mapping of additional tags to assign to the resource."
  type = map(string)
  default = {}
}

variable "project_name" {
  description = "project name"
  default = "eks-infra"
}

variable "env" {
  description = "environment"
  default = "prod"
}

# ## ECR repo policy ##
# variable "ecr_repo_policy" {
#   description = "(Required) The policy document. This is a JSON formatted string."
# }

# ## ECR lifecycle policy ##
# variable "ecr_lifecycle_policy" {
#   description = "(Required) The policy document. This is a JSON formatted string."
# }