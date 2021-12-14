locals {
  rds_sg = {
    rds = {
      name       = "rds-sg"
      desciption = "rds access"
      ingress = {
        mysql = {
          from        = 3306
          to          = 3306
          protocol    = "tcp"
          cidr_blocks = var.private_subnets_cidr
        }
      }
    }
  }
}
