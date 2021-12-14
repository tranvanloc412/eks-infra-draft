########################################
# Provider to connect to AWS
# https://www.terraform.io/docs/providers/aws/
########################################

terraform {
  required_version = "=v1.0.9"
  backend "s3" {} # use backend.config for remote backend

  required_providers {
    aws    = ">= 3.28, < 4.0"
    random = "~> 2"
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.6.0"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = var.profile_name
}

# provider "kubernetes" {
#  version = “~> 1.0”
# // host = var.eks_cluster_endpoint
# // cluster_ca_certificate = base64decode(var.eks_cluster_cert)
# // token = data.aws_eks_cluster_auth.cluster.token
# // load_config_file = false
 
#  load_config_file = true
#  config_path = “~/.kube/config”
# }
