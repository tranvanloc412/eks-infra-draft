# variable "vpc_id" {}
variable "db_storage" {}
variable "db_engine_version" {}
variable "db_intance_class" {}
variable "dbname" {}
variable "dbuser" {}
variable "dbpassword" {}
variable "database_subnets" {}
variable "vpc_id" {}
variable "db_identifier" {}
variable "db_skip_db_snapshot" {}
variable "project_name" {
  type = string
}
variable "env" {
  type = string
}
