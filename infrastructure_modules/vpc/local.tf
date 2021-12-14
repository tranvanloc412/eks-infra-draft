locals {
  ## VPC ##  
  public_subnet_tags = {
    # need to tag subnets with "shared" so K8s can find right subnets to create ELBs
    # ref: https://github.com/kubernetes/kubernetes/issues/29298, https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/examples/complete/main.tf
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = 1 # need this tag for public ELB. Ref: https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html
    "Tier" = "public"
  }

  # need tag for internal-elb to be able to create ELB
  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = 1 # need this tag for internal ELB. Ref: https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html
    "Tier" = "private"
  }

  database_subnet_tags = {
    "Tier" = "database"
  }

  ep_security_groups = {
    endpoints = {
      name       = "endpoints"
      desciption = "Security group for endpoints"
      ingress = {
        ec2 = {
          from        = 443
          to          = 443
          protocol    = "tcp"
          cidr_blocks = var.private_subnets
        }
      }
    }
  }

  eks_cluster_security_group = {
    eks_cluster = {
      name       = "eks_cluster"
      desciption = "Security group for eks cluster"
      ingress = {
        ec2 = {
          from        = 443
          to          = 443
          protocol    = "tcp"
          cidr_blocks = var.private_subnets
        }
      }
    }
  }

  config_file_path = "/home/loctran/.kube/config"
}
