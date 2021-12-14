########################################
# VPC
########################################
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

# output "private_subnets_cidr_block" {
#   description = "The CIDR block of the VPC"
#   value       = module.vpc.private_subnets_cidr_block
# }

# output "endpoints_sg" {
#   value = module.vpc.endpoints_sg
# }
