########################################
# VPC
########################################
module "vpc" {
  source = "../../../../infrastructure_modules/vpc"

  cluster_name = var.cluster_name

  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  private_subnets      = var.private_subnets
  public_subnets       = var.public_subnets
  database_subnets     = var.database_subnets
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  security_groups = local.security_groups

  region = var.region

  ## Common tag metadata ##
  project_name = var.project_name
  env          = var.env
  tags         = local.vpc_tags
}

# module "rds" {
#   source = "../../../../infrastructure_modules/database"

#   vpc_id               = module.vpc.vpc_id
#   database_subnets     = module.vpc.database_subnets
#   dbname               = var.dbname
#   dbuser               = var.dbuser
#   dbpassword           = var.dbpassword
#   db_identifier        = var.db_identifier
#   private_subnets_cidr = module.vpc.private_subnets_cidr_block

#   project_name = var.project_name
#   env          = var.env
# }

module "eks" {
  source = "../../../../infrastructure_modules/eks"

  cluster_name    = var.cluster_name
  region          = var.region
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  # map_roles       = local.map_roles
}

module "cicd" {
  source = "../../../../infrastructure_modules/cicd"

  repos        = var.repos
  project_name = var.project_name
  env          = var.env

  cluster_name = var.cluster_name
  vpc_id       = module.vpc.vpc_id
  subnets_id   = module.vpc.private_subnets
}

