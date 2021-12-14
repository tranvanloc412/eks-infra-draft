########################################
# Variables
########################################

variable "vpc_cidr" {
  type = string
}
variable "enable_dns_hostnames" {
  type = bool
}
variable "enable_dns_support" {
  type = bool
}
variable "project_name" {
  type = string
}
variable "env" {
  type = string
}
variable "azs" {
  type = list(string)
}
variable "tags" {
  type = map(string)
}
variable "public_subnets" {
  type = list(string)
}
variable "public_subnet_tags" {
  type = map(string)
}
variable "private_subnets" {
  type = list(string)
}
variable "private_subnet_tags" {
  type = map(string)
}
variable "database_subnets" {
  type = list(string)
}
variable "database_subnet_tags" {
  type = map(string)
}