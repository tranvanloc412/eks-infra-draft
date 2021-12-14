module "ecr" {
  source = "../../resource_modules/container/ecr"

  repos        = var.repos
  project_name = var.project_name
  env          = var.env
}

module "codebuild" {
  source = "../../resource_modules/devops/codebuild"

  cluster_name = var.cluster_name
  vpc_id       = var.vpc_id
  subnets_id   = var.subnets_id
}

module "codepipeline" {
  source = "../../resource_modules/devops/codepipeline"

}