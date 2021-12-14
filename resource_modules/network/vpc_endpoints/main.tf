###########################
# VPC Endpoints
###########################
data "aws_security_group" "endpoints" {
  vpc_id = var.vpc_id
  name   = "endpoints"
}

data "aws_vpc_endpoint_service" "ec2" {
  service = "ec2"
}

data "aws_vpc_endpoint_service" "ecr_api" {
  service = "ecr.api"
}

data "aws_vpc_endpoint_service" "ecr_dkr" {
  service = "ecr.dkr"
}

data "aws_vpc_endpoint_service" "s3" {
  service      = "s3"
  service_type = "Gateway"
}

resource "aws_vpc_endpoint" "ec2" {
  vpc_id              = var.vpc_id
  service_name        = data.aws_vpc_endpoint_service.ec2.service_name
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = var.subnets
  security_group_ids  = [data.aws_security_group.endpoints.id]
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = var.vpc_id
  service_name        = data.aws_vpc_endpoint_service.ecr_api.service_name
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = var.subnets
  security_group_ids  = [data.aws_security_group.endpoints.id]
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = var.vpc_id
  service_name        = data.aws_vpc_endpoint_service.ecr_dkr.service_name
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = var.subnets
  security_group_ids  = [data.aws_security_group.endpoints.id]
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  service_name      = data.aws_vpc_endpoint_service.s3.service_name
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [var.route_tables]
}