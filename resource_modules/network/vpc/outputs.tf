########################################
# Outputs
########################################

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = aws_vpc.this.arn
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.this.cidr_block
}

output "subnets" {
  value = concat(aws_subnet.public.*.id, aws_subnet.private.*.id)
}

output "private_subnets_cidr_block" {
  value = aws_subnet.private.*.cidr_block
}

output "private_subnets" {
  value = aws_subnet.private.*.id
}

output "private_route_table" {
  value = aws_route_table.private.id
}

output "database_subnets" {
  value = aws_subnet.database.*.id
}