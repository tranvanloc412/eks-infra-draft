########################################
# VPC
########################################

variable "vpc_cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
  default     = "0.0.0.0/0"
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  default     = []
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  default     = []
}

variable "database_subnets" {
  description = "A list of database subnets inside the VPC"
  default     = []
}

variable "azs" {
  description = "Number of availability zones to use in the region"
  type        = list(string)
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  default     = true
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  default     = true
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}

variable "access_ip" {
  type = string
}

## Metatada ##
variable "env" {}
variable "project_name" {}
variable "region" {}
variable "profile_name" {}
variable "cluster_name" {}

variable "dbname" {}
variable "dbuser" {}
variable "dbpassword" {}
variable "db_identifier" {}
variable "repos" {}