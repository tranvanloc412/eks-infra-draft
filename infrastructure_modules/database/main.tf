module "database" {
  source              = "../../resource_modules/database/rds"
  db_storage          = 10
  db_engine_version   = "8.0.23"
  db_intance_class    = "db.t2.micro"
  dbname              = var.dbname
  dbuser              = var.dbuser
  dbpassword          = var.dbpassword
  database_subnets    = var.database_subnets
  vpc_id              = var.vpc_id
  db_identifier       = var.db_identifier
  db_skip_db_snapshot = true

  project_name = var.project_name
  env          = var.env

  depends_on = [module.security_group]
}

module "security_group" {
  source = "../../resource_modules/compute/security_group"

  vpc_id          = var.vpc_id
  security_groups = local.rds_sg
}