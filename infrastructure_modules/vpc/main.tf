module "vpc" {
  source = "../../resource_modules/network/vpc"

  vpc_cidr = var.vpc_cidr
  azs      = var.azs

  private_subnets  = var.private_subnets
  public_subnets   = var.public_subnets
  database_subnets = var.database_subnets

  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags                 = var.tags
  public_subnet_tags   = local.public_subnet_tags
  private_subnet_tags  = local.private_subnet_tags
  database_subnet_tags = local.database_subnet_tags

  project_name = var.project_name
  env          = var.env
}

module "vpc_endpoints" {
  source = "../../resource_modules/network/vpc_endpoints"

  vpc_id       = module.vpc.vpc_id
  subnets      = module.vpc.private_subnets
  route_tables = module.vpc.private_route_table

  depends_on = [module.endpoint_security_group]
}

module "security_group" {
  source = "../../resource_modules/compute/security_group"

  vpc_id          = module.vpc.vpc_id
  security_groups = var.security_groups
}

module "endpoint_security_group" {
  source = "../../resource_modules/compute/security_group"

  vpc_id          = module.vpc.vpc_id
  security_groups = local.ep_security_groups
}