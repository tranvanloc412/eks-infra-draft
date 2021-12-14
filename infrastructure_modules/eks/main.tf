module "eks" {
  source           = "../../resource_modules/container/eks"
  cluster_name     = var.cluster_name
  region           = var.region
  vpc_id           = var.vpc_id
  config_file_path = local.config_file_path
  private_subnets  = var.private_subnets
  desired_nodes    = 1
  map_roles        = var.map_roles
}
