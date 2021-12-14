locals {
  vpc_tags = {
    Environment = var.env
    Project     = var.project_name
    Terraform   = true
  }

  security_groups = {
    public = {
      name       = "public-sg"
      desciption = "Security Group for public access"
      ingress = {
        open = {
          from        = 0
          to          = 0
          protocol    = -1
          cidr_blocks = [var.access_ip]
        }
        http = {
          from        = 80
          to          = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
        nginx = {
          from        = 8000
          to          = 8000
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }
  }

  # map_roles = [
  #   {
  #     rolearn  = module.cicd.codebuild_role
  #     username = "build"
  #     groups   = ["system:masters", ]
  #   },
  # ]
}
