variable "allowed_zones" {
  default     = ["arn:aws:route53:::hostedzone/*"]
  description = "List of zones this service account is permitted to update (in ARN format)"
  type        = list(string)
}

variable "cluster_name" {
  type = string
}

variable "issuer_url" {
  description = "OIDC issuer URL (include prefix)"
  type        = string
}

variable "service_account" {
  default     = "external-dns"
  description = "Name of service account to create (computed based on cluster name if not specified)"
  type        = string
}

variable "tags" {
  default     = {}
  description = "Tags to add to supported resources"
  type        = map(string)
}

variable "k8s_namespace" {
  description = "Kubernetes namespace to deploy the AWS External DNS into."
  type        = string
  default     = "default"
}

variable "k8s_pod_annotations" {
  default     = ""
}