################################################################################
# VPC
################################################################################

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = {
    Name                            = "${var.project_name}-${var.env}-vnet-01"
    "kubernetes.io/cluster/cl01"    = "shared"
    "kubernetes.io/cluster/dev_eks" = "shared"
  }

  lifecycle {
    create_before_destroy = true
  }
}

################################################################################
# Subnets
################################################################################

resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnets[count.index]
  map_public_ip_on_launch = true
  availability_zone       = var.azs[count.index]

  tags = merge(
    {
      Name = "${var.project_name}-${var.env}-vnet-01-public-subnet-${count.index + 1}"
    },
    var.tags,
    var.public_subnet_tags,
  )
}

resource "aws_subnet" "private" {
  count                   = length(var.private_subnets)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.private_subnets[count.index]
  map_public_ip_on_launch = false
  availability_zone       = var.azs[count.index]

  tags = merge(
    {
      Name = "${var.project_name}-${var.env}-vnet-01-private-subnet-${count.index + 1}"
    },
    var.tags,
    var.private_subnet_tags,
  )
}

resource "aws_subnet" "database" {
  count                   = length(var.database_subnets)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.database_subnets[count.index]
  map_public_ip_on_launch = false
  availability_zone       = var.azs[count.index]

  tags = merge(
    {
      Name = "${var.project_name}-${var.env}-vnet-01-database-subnet-${count.index + 1}"
    },
    var.tags,
    var.database_subnet_tags,
  )
}

################################################################################
# Internet Gateway
################################################################################

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.project_name}-${var.env}-vnet-01-igw"
  }
}

################################################################################
# NAT gateway
################################################################################

resource "aws_eip" "this" {
  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.this.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "${var.project_name}-${var.env}-vnet-01-nat-gw"
  }

  depends_on = [aws_internet_gateway.this]
}

################################################################################
# Public route table
################################################################################

resource "aws_default_route_table" "this" {
  default_route_table_id = aws_vpc.this.default_route_table_id

  tags = {
    Name = "${var.project_name}-${var.env}-vnet-01-default-route_table"
  }
}

################################################################################
# Public routing
################################################################################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.project_name}-${var.env}-vnet-01-public-route_table"
  }
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

################################################################################
# Private routing
################################################################################

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.project_name}-${var.env}-vnet-01-private-route_table"
  }
}

resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

################################################################################
# Database routing
################################################################################

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.project_name}-${var.env}-vnet-01-database-route_table"
  }
}

resource "aws_route_table_association" "database" {
  count          = length(var.database_subnets)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}